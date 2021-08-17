<template>
  <div class="container-fluid text-center">
    <div class="row">
      <div class="d-flex flex-column col-lg-8">
        <audio ref="audio1">
          <source type="audio/mp3" src="~yoroshiku.mp3"/>
        </audio>
        <audio ref="audio2">
          <source type="audio/mp3" src="~izakayagaya.mp3"/>
        </audio>
        {{ url }}
        <button class='btn btn-primary' @click="startMixing">（サンプル）3秒後に男性の声と居酒屋の音を合成してくれるボタン</button>
      </div>
      <div class="d-flex flex-column justify-content-center align-items-center col-lg-4">
        <div id="mic_buttons">
          <button
            v-if="!isRecording"
            class="btn btn--circle"
            @click="startRecording"
          >
            <i class="fas fa-microphone" /><br>START
          </button>
          <button
            v-if="isRecording"
            class="btn btn--circle"
            @click="stopRecording"
          >
            <i class="fas fa-microphone" /><br>STOP
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

export default {
  name: "GameIndex",
  data() {
    return {
      isRecording: false,
      url: null,
      localstream: null,
      audioData: [],
      recorder: null,
      ctx: null,
      destination: null,
    }
  },
  mounted() {},
  methods: {
    startRecording() {
      console.log('getUserMedia')
      navigator.mediaDevices
        .getUserMedia({ audio: true, video: false })
        .then(stream => {
          this.record(stream)
          this.timeoutID = window.setTimeout(this.stopRecording, 5000)
          this.isRecording = true
        }).catch(error => {
          console.error('mediaDevices.getUserMedia() error:', error)
        })
    },

    record(stream) {
      this.localstream = stream
      this.recorder = new MediaRecorder(stream);
      this.recorder.start();
    },

    stopRecording() {
      if (!this.isRecording) return;
      this.recorder.stop();
      this.isRecording = false;
      this.recorder.ondataavailable = (e) => {
        let myURL = window.URL || window.webkitURL;
        this.url = myURL.createObjectURL(e.data);
      }
      this.localstream.getTracks().forEach(track => track.stop());
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
      this.localstream.getTracks().forEach(track => track.stop());
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
</style>
