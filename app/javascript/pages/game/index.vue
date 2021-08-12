<template>
  <div class="container-fluid text-center">
    <div class="row">
      <div class="d-flex flex-column col-lg-8">
        <div v-if="result">
          <span>録音時間：{{ result.total_length }}秒</span><br/>
          <span>発声認識時間：{{ result.valid_length }}秒</span><br/>
          <span>周波数領域：{{ result.min_freq }}Hz〜{{ result.max_freq }}Hz</span>
        </div>
        <div v-if="recordfailed">
          <span>声が認識できませんでした</span>
        </div>
      </div>
      <div class="d-flex flex-column justify-content-center align-items-center col-lg-4">
        <div id="mic_buttons">
          <button v-if="!audio.running" @click="getUserMedia" class="btn btn--circle"><i class="fas fa-microphone"></i></br>START</button>
          <button v-if="audio.running" @click="disconnectMedia" class="btn btn--circle"><i class="fas fa-microphone"></i></br>STOP</button>
        </div>
        <div>
          <button class="btn btn-primary" @click="sendToServer">送信</button>
        </div>
      </div>
    </div>
  </div>
</template>

<script>
import axios from '../../plugins/axios'

export default {
  name: "GameIndex",
  data() {
    return {
      audio: {
        ctx: null,
        analyser: null,
        mic: null,
        running: false,
        range: null,
        fsDivN: null,
        n440Hz: null,
        spectrums: null,
      },
      audioData: [],
      interval: 100,
      timeoutID: null,
      intervalID: null,
      result: null,
      recordfailed: false,
    }
  },
  computed: {
    validAudioData() {
      return this.audioData.filter((item) => {
        return item.length > 1;
      });
    },
  },
  methods: {
    getUserMedia() {
      console.log('getUserMedia')
      this.audioData=[];
      navigator.mediaDevices
        .getUserMedia({ audio: true, video: false })
        .then(stream => {
          this.getLocalMediaStream(stream)
          this.audio.running = true
          // イベントハンドラー
          this.timeoutID = window.setTimeout(this.disconnectMedia, 5000)
          this.analyseData();
        }).catch(error => {
          console.error('mediaDevices.getUserMedia() error:', error)
        })
    },

    getLocalMediaStream(mediaStream) {
      // AudioContextの利用宣言（クロスブラウザー対応）
      let audioContext = window.AudioContext || window.webkitAudioContext
      // audioContextのオブジェクトを作成
      this.audio.ctx = new audioContext({ sampleRate: 44100 })
      // 周波数を解析するためAnalyzerNodeオブジェクトを生成
      this.audio.analyser = this.audio.ctx.createAnalyser()
      // audioContextで音声ストリームを扱えるようにする
      this.audio.mic = this.audio.ctx.createMediaStreamSource(mediaStream)
      // それぞれをconnectで接続し、ストリームの音声データを扱えるようにする
      // mic (Input) -> AnalyserNode (Output)
      this.audio.mic.connect(this.audio.analyser)
    },

    analyseData() {
      this.audio.analyser.fftSize = 4096;
      this.audio.analyser.maxDecibels = 0;
      this.audio.analyser.minDecibels = -100;

      this.audio.range = this.audio.analyser.maxDecibels - this.audio.analyser.minDecibels;
      // Frequency resolution
      this.audio.fsDivN = this.audio.ctx.sampleRate / this.audio.analyser.fftSize;
      // This value is the number of samples during 440 Hz
      this.audio.n440Hz = Math.floor(440 / this.audio.fsDivN);
      this.audio.fundamentalTones = [];
      this.audio.overtones = [];
      this.result = null;
      this.recordfailed = false;

      this.intervalID = setInterval(this.executeFFT, this.interval);
    },

    async executeFFT() {
      // Get data for drawing spectrum (dB)
      this.audio.spectrums = new Float32Array(this.audio.analyser.frequencyBinCount);  // Array size is a half of fftSize
      this.audio.analyser.getFloatFrequencyData(this.audio.spectrums);

      // 一番音量が大きい周波数を基音とする
      let fundamentalTone = await this.getFundamentalTone();
      // 基音の整数次倍音のデータを取る
      let overtones = await this.getOvertones(fundamentalTone);
      // 基音と倍音をまとめて配列に入れる
      this.audioData.push([fundamentalTone].concat(overtones));
      this.logger();
    },

    logger() {
      // for debug
      console.log(`audioContext.sampleRate: ${this.audio.ctx.sampleRate}, analyserNode.fftSize: ${this.audio.analyser.fftSize}, fsDivN: ${this.audio.fsDivN},  n440Hz: ${this.audio.n440Hz}, spectrums.length: ${this.audio.spectrums.length}, analyserNode.frequencybinCount: ${this.audio.analyser.frequencyBinCount}`);
    },

    getFundamentalTone() {
      let fundamentalTone = {
        times: 1,
        volume: -100,
        index: 0,
        frequency: 0,
      };
      // spectrumには(fsDivN * fftSize/2)Hzまでの音量データが入っているが、高周波帯は不要なため、適当な長さで処理を中断
      for (let i = 0, len = this.audio.spectrums.length / 4; i < len; i++) {
        if (fundamentalTone.volume < this.audio.spectrums[i]) {
          fundamentalTone.volume = this.audio.spectrums[i].toFixed(2);
          fundamentalTone.index = i;
          fundamentalTone.frequency = (i * this.audio.fsDivN).toFixed(2);
        }
      };
      return fundamentalTone;
    },

    getOvertones(fundamentalTone) {
      let overtones=[]
      if (fundamentalTone.frequency > 0.2*1000 && fundamentalTone.frequency < 4*1000 && fundamentalTone.volume > -70) {
        for (let i = fundamentalTone.index * 2, len = this.audio.spectrums.length / 4; i < len; i += fundamentalTone.index) {
          let overtone = {
            times: i / fundamentalTone.index,
            volume: this.audio.spectrums[i].toFixed(2),
            index: i,
            frequency: (i * this.audio.fsDivN).toFixed(2),
          };
          overtones.push(overtone);
        }
      }
      return overtones;
    },

    disconnectMedia() {
      if (this.audio.running == true) {
        this.audio.mic.disconnect(this.audio.analyser);
        this.audio.running = false;
        clearTimeout(this.timeoutID);
        clearInterval(this.intervalID);
        this.displayResult();
      }
      // axios.get('games', )
      //  .then(res =>)
    },

    async displayResult() {
      if (this.validAudioData.length > 0) {
        this.result = await this.calcResult();
      } else {
        this.result = null;
        this.recordfailed = true;
      };
    },

    calcResult() {
      let result = {
        total_length: (this.audioData.length * this.interval / 1000).toFixed(2),
        valid_length: (this.validAudioData.length * this.interval / 1000).toFixed(2),
        min_freq:
          this.validAudioData.reduce((acc,item) => {
            return Math.min(acc, item[0].frequency)
          }, this.validAudioData[0][0].frequency),
        max_freq:
          this.validAudioData.reduce((acc,item) => {
            return Math.max(acc, item[0].frequency)
          }, this.validAudioData[0][0].frequency),
      }
      return result
    },

    sendToServer() {
      let formData = new FormData();
      let spectrums = JSON.stringify(this.audioData[0]);
      formData.append('spectrums', spectrums);
      let config = {headers: {'content-type': 'multipart/form-data'}};
      axios.post('games', formData, config)
        .then(res => {
          console.log(res.data)
        });
    }
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

#canvas-container{
    position: relative;
    height: 0;
    overflow: hidden;
    padding-top: 56.25%;
}
  #canvas{
      position: absolute;
      top: 0;
      left: 0;
      width: 100%;
      height: 100%;
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
