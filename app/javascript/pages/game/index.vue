<template>
  <div class="container-fluid text-center">
    <div class="row">
      <div class="d-flex flex-column justify-content-center align-items-center col-lg-4">
        <div class="d-flex flex-column justify-content-center">
          <div>
            <div>
              加工前：
              <span>{{ finalTranscript }}</span>
              <span class='interim-transcript'>{{ interimTranscript }}</span>
            </div>
            <audio controls :src="voiceOriginUrl"></audio>
          </div>
          <div>
            <div>
              Case 1. レストラン<br>
              認識結果：<span>{{ result1.text }}</span><br>
              得点：<span>{{ Math.round(result1.confidence * 100) }}</span>
            </div>
            <audio controls :src="voiceMixed1.url"></audio>
          </div>
          <div>
            <div>
              Case 2. 居酒屋<br>
              認識結果：<span>{{ result2.text }}</span><br>
              得点：<span>{{ Math.round(result2.confidence * 100) }}</span>
            </div>
            <audio controls :src="voiceMixed2.url"></audio>
          </div>
          <div>
            <div>
              Case 3. 強風の中<br>
              認識結果：<span>{{ result3.text }}</span><br>
              得点：<span>{{ Math.round(result3.confidence * 100) }}</span>
            </div>
            <audio controls :src="voiceMixed3.url"></audio>
          </div>
        </div>
        <div id="mic_buttons">
          <button
            v-if="!isRunning"
            class="btn btn--circle"
            @click="startListening"
          >
            <i class="fas fa-microphone" /><br>測定開始
          </button>
          <button
            v-if="isRunning"
            class="btn btn--circle"
            @click="abortListening"
          >
            <i class="fas fa-microphone" /><br>測定中止
          </button>
        </div>
      </div>
    </div>
  </div>
</template>

<script>
import axios from '../../plugins/axios'
import noise1 from 'restaurant.mp3'
import noise2 from 'izakaya.mp3'
import noise3 from 'windblowing.mp3'
import noise4 from 'cicadasinging.mp3'

export default {
  name: "GameIndex",
  data() {
    return {
      isRunning: false,
      voiceOriginUrl: '',
      voiceMixed1: { url: '' },
      voiceMixed2: { url: '' },
      voiceMixed3: { url: '' },
      srcOrigin: null,
      srcNoise: null,
      result1: { text: '-', confidence: null },
      result2: { text: '-', confidence: null },
      result3: { text: '-', confidence: null },
      stream: null,
      localStream: null,
      audioChunks: [],
      audioBlob: null,
      recorder: null,
      recognition: null,
      ctx: null,
      destination: null,
      gain: null,
      statusText: 'ボタンを押して測定開始',
      finalTranscript: '', // 確定した認識結果
      interimTranscript: '', // 暫定の認識結果
    }
  },
  mounted() {},
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
      this.statusText = '録音中'
      if (this.voiceOriginUrl) {
        window.URL.revokeObjectURL(this.voiceOriginUrl);
        this.voiceOriginUrl = null;
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
      if (!this.isRunning) return;
      this.recognition.stop();
      this.isRunning = false;
    },

    // Web Speech APIの処理を中断する
    abortListening() {
      this.recognition.abort();
      this.recorder.stop();
      this.isRunning = false;
    },

    // MediaRecorderで録音を開始する
    startRecording() {
      this.recorder.ondataavailable = async (e) => {
        // クライアントのメモリ上に作成された録音データのURLを発行する
        this.voiceOriginUrl = await window.URL.createObjectURL(e.data);
        await this.startMixing(noise1, this.voiceMixed1)

        // 節約のため、エラー解消するまでコメントアウト
        //await this.judgeSuimasen();
        await this.startMixing(noise2, this.voiceMixed2)
          .then(() => {
            //this.judgeSuimasen();
          });
        await this.startMixing(noise3, this.voiceMixed3);
      }
 
      this.recorder.start();
    },

    // MediaRecorderで録音を終了する
    stopRecording() {
      this.recorder.stop();
      this.stream.getTracks()[0].stop();
    },

    async judgeSuimasen() {
      if (/すいません|すみません/.test(this.finalTranscript)) {
        // 録音した音声を環境音と重ねてサーバーに送る処理
        this.statusText = '解析中';

        // クライアントのメモリ上に作成された録音データのURLを発行する
        // this.url = window.URL.createObjectURL(this.audioBlob);

        let formData = new FormData();

        await this.waitAudioChunks();

        this.audioBlob = new Blob(this.audioChunks, {
            'type' : `${this.recorder.mimeType}`
        });
        console.log('2ばんめ');

        formData.append('voice', this.audioBlob);

        let config = {
          headers: {
            'content-type': 'multipart/form-data'
          }
        };

        await axios.post(`/api/games/${this.$route.params.game_id}/transcribe`, formData, config)
          .then(res => {
            console.log(res.data)
            this.result1.text = res.data.transcript
            this.result1.confidence = res.data.confidence
          }).catch(err => {
            console.log(err)
          })
      } else {
        this.statusText = 'もう一度やり直してください';
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
      audioOrigin.src = this.voiceOriginUrl;

      // 仮想のaudio要素を作り、src属性に環境音データを持たせる
      let audioNoise = document.createElement('audio');
      audioNoise.src = noiseFile;

      // それぞれのMediaSourceを作成する
      this.srcOrigin = this.ctx.createMediaElementSource(audioOrigin);
      this.srcNoise = this.ctx.createMediaElementSource(audioNoise);

      // 音声はボリュームを小さくするフィルターを通す（gain.valueは最小が0、最大(デフォルト)が1）
      this.gain = this.ctx.createGain();
      this.gain.gain.value = 0.5;

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

      // 録音用MediaStreamを作成する
      this.localStream = this.destination.stream;

      // MediaRecorderで録音を開始する
      this.recorder = new MediaRecorder(this.localStream);
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
        console.log('1ばんめ');
        audioElement.url = window.URL.createObjectURL(e.data);
      }
      this.recorder.stop();
      this.srcOrigin.disconnect(this.gain);
      this.gain.disconnect(this.destination);
      this.srcNoise.disconnect(this.destination);
      // this.localstream.getTracks()[0].stop();
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
*,
*:before,
*:after {
  -webkit-box-sizing: inherit;
  box-sizing: inherit;
}

html {
  -webkit-box-sizing: border-box;
  box-sizing: border-box;
  font-size: 62.5%;
}

body {
  background-color: #D8E3E7;
}

button.btn--circle {
  font-size: 1.6rem;
  width: 140px;
  height: 140px;
  padding: 20px 0 0;
  border-radius: 50%;
  color: #fff;
  background: #51c4d3;
  -webkit-box-shadow: 0 7px 0 rgba(0, 0, 0, 0.25);
  box-shadow: 0 7px 0 rgba(0, 0, 0, 0.25);
}

button.btn--circle i {
  font-size: 150%;
}

.fa-position-bottom {
  position: absolute;
  bottom: 1rem;
  left: calc(50% - 0.5rem);
}

button.btn--circle:active {
  -webkit-transform: translate(0, 4px);
  transform: translate(0, 4px);
  color: #fff;
  -webkit-box-shadow: 0 3px 0 rgba(0, 0, 0, 0.25);
  box-shadow: 0 3px 0 rgba(0, 0, 0, 0.25);
}

.interim-transcript {
  font-style: italic;
}
</style>
