<template>
  <div class="container-fluid text-center">
    <div class="row">
      <div class="d-flex flex-column col-lg-8">
        <audio ref="audio1">
          <source type="audio/mp3" src="~cicadasinging.mp3"/>
        </audio>
        <audio ref="audio2">
          <source type="audio/mp3" src="~izakayagaya.mp3"/>
        </audio>
        {{ url }}
        <button class='btn btn-primary' @click="startMixing">（サンプル）3秒後に男性の声と居酒屋の音を合成してくれるボタン</button>
      </div>
      <div class="d-flex flex-column justify-content-center align-items-center col-lg-4">
        <div>
          {{ statusText }}
        </div>
        <div>
          <span>{{ finalTranscript }}</span>
          <span class='interim-transcript'>{{ interimTranscript }}</span>
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
import 'yoroshiku.mp3'
import 'izakayagaya.mp3'
import 'cicadasinging.mp3'

export default {
  name: "GameIndex",
  data() {
    return {
      isRunning: false,
      url: null,
      stream: null,
      audioChunks: [],
      audioBlob: null,
      recorder: null,
      recognition: null,
      ctx: null,
      destination: null,
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
      window.SpeechRecognition = window.SpeechRecognition || webkitSpeechRecognition
      this.recognition = new window.webkitSpeechRecognition(stream)
      this.recognition.lang = 'ja'
      this.recognition.interimResults = true
      this.recognition.continuous = false
      this.statusText = '録音中'
      if (this.url) {
        let myURL = window.URL || window.webkitURL;
        myURL.revokeObjectURL(this.url);
        this.url = null;
      }

      // （声でなくても）音声入力を検知した時に発火する
      this.recognition.onaudiostart = () => {
        // MediaRecorderで録音を開始する
        this.startRecording();
      }

      // 音声入力の終了を検知後、音声の認識に成功すると発火する
      this.recognition.onresult = (e) => {
        for (let i = e.resultIndex; i < e.results.length; i++) {
          let transcript = event.results[i][0].transcript;
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
      this.audioChunks = [];

      this.recorder.onstop = async (e) => {
        this.audioBlob = await new Blob(this.audioChunks, {
          'type' : `${this.recorder.mimeType}`
        });

        // クライアントのメモリ上に作成された録音データのURLを発行する
        let myURL = window.URL || window.webkitURL;
        this.url = myURL.createObjectURL(this.audioBlob);

        this.judgeSuimasen();
      }

      this.recorder.ondataavailable = (e) => {
        this.audioChunks.push(e.data);
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
        // let myURL = window.URL || window.webkitURL;
        // this.url = myURL.createObjectURL(this.audioBlob);

        let formData = new FormData();

        await formData.append('voice', this.audioBlob);
        let config = {
          headers: {
            'content-type': 'multipart/form-data'
          }
        };
        await axios.post(`/api/games/${this.$route.params.game_id}/transcribe`, formData, config)
          .then(res => {
            console.log(res.data)
          }).catch(err => {
            console.log(err)
          })
      } else {
        this.statusText = 'もう一度やり直してください';
      }
    },

    startMixing() {
      this.ctx = new AudioContext();
      this.destination = this.ctx.createMediaStreamDestination();
      let source1 = this.ctx.createMediaElementSource(this.$refs.audio1);
      let source2 = this.ctx.createMediaElementSource(this.$refs.audio2);
      source1.connect(this.destination);
      source2.connect(this.destination);
      this.$refs.audio1.play();
      this.$refs.audio2.play();

      // 録音用トラックを作成する
      this.localStream = this.destination.stream; 

      // 録音SDKで録音を開始する
      this.recorder = new MediaRecorder(this.localStream);
      this.recorder.start();
      setTimeout(this.completeMixing, 3000);
    },

    completeMixing() {
      this.recorder.stop();
      this.recorder.ondataavailable = (e) => {
        let myURL = window.URL || window.webkitURL;
        this.url = myURL.createObjectURL(e.data);
      }
      this.localstream.getTracks()[0].stop();
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
