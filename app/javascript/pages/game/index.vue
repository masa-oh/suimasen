<template>
  <v-container fill-height fluid>
    <v-row align-content="center" justify="center">
      <v-spacer />
      <v-col cols="8">
        <v-img class="img--stage" height="350" :src="srcImage">
          <template v-slot:placeholder>
            <v-row
              class="fill-height ma-0"
              align="center"
              justify="center"
            >
              <v-progress-circular
                indeterminate
                color="grey lighten-5"
              ></v-progress-circular>
            </v-row>
          </template>
        </v-img>
        <div class="text-center">
          <v-divider class="my-4" />

          <strong>{{ stage.name }}ですいません</strong>
          <v-fade-transition leave-absolute>
            <p>{{ statusText }}</p>
          </v-fade-transition>

          <v-divider class="my-4" />

          <div v-if="!isJudged">
            <v-btn
              :loading="isRunning"
              :disabled="isRunning||isJudged"
              id="custom-disabled"
              class="mx-2"
              fab
              dark
              x-large
              color="primary lighten-1"
              @click="startListening"
            >
              <v-icon dark>fas fa-microphone</v-icon>
            </v-btn>
            <p class="mt-4">
              <span>{{ finalTranscript }}</span>
              <span class="interim-transcript">{{ interimTranscript }}</span><br/>
            </p>
          </div>

          <!-- 結果を描画 -->
          <GameResult
            v-if="isJudged"
            :result="result"
            :pattern="pattern"
            :stage="stage"
            :voiceMixed="voiceMixed"
            :voiceOrigin="voiceOrigin"
          />
        </div>
      </v-col>
      <v-spacer />
    </v-row>
  </v-container>
</template>

<script>
import GameResult from '../../components/GameResult.vue'

import axios from '../../plugins/axios'
import '../../plugins/vue_youtube'

import noise_restaurant from 'restaurant.mp3';
import noise_izakaya from 'izakaya.mp3';
import noise_wind from 'windblowing.mp3';
import noise_pachinko from 'pachinko.mp3';

import 'restaurant.jpg';
import 'izakaya.jpg';
import 'strong_wind.jpg';
import 'pachinko.jpg';

export default {
  name: "GameIndex",
  components: {
    GameResult,
  },
  data() {
    return {
      srcNoise: null,
      srcImage: null,
      stage: null,
      loader: null,
      isRunning: false,
      isJudged: false,
      voiceOrigin: { url: '' },
      voiceMixed: { url: '' },
      srcOrigin: null,
      srcNoise: null,
      result: { transcript: '', confidence: null },
      stream: null,
      audioChunks: [],
      audioBlob: null,
      recorder: null,
      recognition: null,
      ctx: null,
      destination: null,
      gain: null,
      statusText: 'ボタンを押したら、店員さんを呼んでみよう！',
      pattern: /すいません|すみません/,
      finalTranscript: '', // 確定した認識結果
      interimTranscript: '', // 暫定の認識結果
    }
  },
  created() {
    // stage = { name: ステージ名, difficulty: 難易度（5段階評価）, gain_value: 声の減衰率 }
    switch (this.$route.params.stage_name) {
      case 'restaurant':
        this.stage = { name: "レストラン", difficulty: 2, gain_value: 0.5 };
        this.srcNoise = noise_restaurant
        this.srcImage = require("restaurant.jpg")
        break;
      case 'pub':
        this.stage = { name: "居酒屋", difficulty: 3, gain_value: 0.4 };
        this.srcNoise = noise_izakaya
        this.srcImage = require("izakaya.jpg")
        break;
      case 'wind':
        this.stage = { name: "強風の中", difficulty: 4, gain_value: 0.3 };
        this.srcNoise = noise_wind
        this.srcImage = require("strong_wind.jpg")
        break;
      case 'pachinko':
        this.stage = { name: "パチンコ屋", difficulty: 5, gain_value: 0.3 };
        this.srcNoise = noise_pachinko
        this.srcImage = require("pachinko.jpg")
        break;
    }
  },
  methods: {
    startListening() {
      console.log('getUserMedia')
      navigator.mediaDevices
        .getUserMedia({ audio: {
          echoCancellation: true,
          echoCancellationType: 'system',
          noiseSuppression: false
        }})
        .then(stream => {
          this.isRunning = true;
          this.finalTranscript = '';
          this.interimTranscript = '';
          this.stream = stream
          // 録音APIの準備
          this.recorder = new MediaRecorder(stream);
          // 音声認識を開始
          this.startSpeechRecognition(stream);
        }).catch(error => {
          console.error('mediaDevices.getUserMedia() error:', error)
        })
    },

    // Web Speech APIでリアルタイムに文字起こしを行う
    startSpeechRecognition(stream) {
      this.recognition = new webkitSpeechRecognition(stream);
      this.recognition.lang = 'ja'
      this.recognition.interimResults = true
      this.recognition.continuous = false
      this.statusText = '「すいません」を聞き取り中...'
      if (this.voiceOrigin.url) {
        window.URL.revokeObjectURL(this.voiceOrigin.url);
        this.voiceOrigin.url = null;
      }

      // （声でなくても）音声入力を検知した時に発火する
      this.recognition.onaudiostart = () => {
        // MediaRecorderで録音を開始する
        this.startRecording();
      }

      // 音声入力の終了を検知後、音声の認識に成功すると発火する
      this.recognition.onresult = (e) => {
        for (let i = e.resultIndex; i < e.results.length; i++) {
          let transcript = e.results[i][0].transcript;
          if (e.results[i].isFinal) {
            this.interimTranscript = '';
            this.finalTranscript += transcript;
            this.stopSpeechRecognition();
            this.statusText = '解析中...';
            this.stopRecording();
          } else {
            this.interimTranscript = transcript;
          }
        }
      }

      // 文字起こし開始
      this.recognition.start();
    },

    // Web Speech APIの処理を終了する
    stopSpeechRecognition() {
      this.recognition.stop();
    },

    // MediaRecorderで録音を開始する
    startRecording() {
      this.recorder.ondataavailable = async (e) => {
        // クライアントのメモリ上に作成された録音データのURLを発行する
        this.voiceOrigin.url = await window.URL.createObjectURL(e.data);
        // 録音した声と環境音を重ねる
        await this.startMixing(this.srcNoise, this.voiceMixed)
          .then(() => {
            // 節約のため、エラー解消するまでコメントアウト
            this.judgeSuimasen();
          });
      }
 
      this.recorder.start();
    },

    // MediaRecorderで録音を終了する
    stopRecording() {
      this.recorder.stop();
      this.stream.getTracks()[0].stop();
    },

    async judgeSuimasen() {
      // 元の音声が「すいません」の場合処理を続行
      if (this.pattern.test(this.finalTranscript)) {
        // 録音した音声を環境音と重ねてサーバーに送る処理
        this.statusText = '通信中...';
        let formData = new FormData();

        await this.waitAudioChunks();

        this.audioBlob = new Blob(this.audioChunks, {
            'type' : `${this.recorder.mimeType}`
        });
        //console.log('2ばんめ');

        formData.append('voice', this.audioBlob);

        let config = {
          headers: {
            'content-type': 'multipart/form-data'
          }
        };

        await axios.post('/api/games', formData, config)
          .then(res => {
            //console.log(res.data)
            this.result.transcript = res.data.transcript
            this.result.confidence = res.data.confidence
            this.isJudged = true
            this.isRunning = false
            this.statusText = '測定完了！気づいてもらえたかな…？'
          }).catch(err => {
            console.log(err)
          })
      } else {
        this.statusText = '「すいません」と言って店員さんを呼ぼう！'
        this.isRunning = false
      }
    },

    async startMixing(noiseFile, audioElement) {
      console.log("startMixing");
      // Audioの出力先を作る
      this.ctx = new AudioContext();
      this.destination = this.ctx.createMediaStreamDestination();

      // 入力チャネルが複数あるので、ステレオからモノラルへのダウンミックスを行う
      this.destination.channelCount = 1;

      // 仮想のaudio要素を作り、src属性に録音した音声データを持たせる
      let audioOrigin = document.createElement('audio');
      audioOrigin.src = this.voiceOrigin.url;

      // 仮想のaudio要素を作り、src属性に環境音データを持たせる
      let audioNoise = document.createElement('audio');
      audioNoise.src = noiseFile;

      // それぞれのMediaSourceを作成する
      this.srcOrigin = this.ctx.createMediaElementSource(audioOrigin);
      this.srcNoise = this.ctx.createMediaElementSource(audioNoise);

      // 音声はボリュームを小さくするフィルターを通す（gain.valueは最小が0、最大(デフォルト)が1）
      this.gain = this.ctx.createGain();
      this.gain.gain.value = this.stage.gain_value;

      // 作成したMediaSourceに、両方とも同じ出力先を設定する
      this.srcOrigin.connect(this.gain).connect(this.destination);
      this.srcNoise.connect(this.destination);

      // メモ：ここでended発火時の処理を定義した場合、後続処理で再度startMixingが呼ばれた時に、
      // 　　　前のcompleteMixingが完了しておらずエラーとなる
      // audioOrigin.onended = async (e) => {
      //   await this.completeMixing(audioElement);
      // }

      // 仮想audio要素の音を再生する
      audioOrigin.play();
      audioNoise.play();

      // MediaRecorderで録音を開始する
      this.recorder = new MediaRecorder(this.destination.stream);
      this.startMixRecording();

      // 録音処理が終了するのを待つ
      await (() => {
        return new Promise(resolve => {
          audioOrigin.addEventListener("ended", async () => {
            await this.completeMixing(audioElement);
            await resolve();
          }, { once: true });
        });
      })();

      // 録音データを文字起こしAPIに送る（利用回数を節約するため、コメントアウト）
      // this.judgeSuimasen();
    },

    completeMixing(audioElement) {
      this.recorder.ondataavailable = (e) => {
        this.audioChunks = [];
        this.audioChunks.push(e.data);
        //console.log('1ばんめ');
        audioElement.url = window.URL.createObjectURL(e.data);
      }
      this.recorder.stop();
      this.srcOrigin.disconnect(this.gain);
      this.gain.disconnect(this.destination);
      this.srcNoise.disconnect(this.destination);
    },

    // MediaRecorderで録音を開始し、Blobを用意する
    startMixRecording() {
      // this.recorder.onstop = async (e) => {
      //   this.audioBlob = await new Blob(this.audioChunks, {
      //     'type' : `${this.recorder.mimeType}`
      //   });
      // }

      this.recorder.start();
    },

    async waitAudioChunks() {
      return new Promise(resolve => {
        const intervalId = setInterval(() => {
          if (!this.audioChunks.length) {
            console.log(1);
            return;
          } else {
            clearInterval(intervalId);
            resolve();
          }
        }, 100)
      });
    },
  },
}
</script>

<style scoped>
.interim-transcript {
  font-style: italic;
}

.custom-loader {
  animation: loader 1s infinite;
  display: flex;
}

@keyframes loader {
  from {
    transform: rotate(0);
  }
  to {
    transform: rotate(360deg);
  }
}

#custom-disabled.v-btn--disabled {
    background-color: #37879c !important;
}

.img--stage {
   border-radius: 5px;
   box-shadow: 0 8px 10px 1px rgba(0,0,0,0.14), 0 3px 14px 2px rgba(0,0,0,0.12), 0 5px 5px -3px rgba(0,0,0,0.2);
}
</style>
