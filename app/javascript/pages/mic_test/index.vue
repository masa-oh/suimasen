<template>
  <div class="container-fluid text-center">
    <div class="row">
      <div class="d-flex flex-column col-lg-8">
        <audio ref="audio1">
          <source type="audio/mp3" src="~cicadasinging.mp3"/>
        </audio>
        <audio ref="audio2">
          <source type="audio/mp3" src="~izakaya.mp3"/>
        </audio>
        <div id="volume-meter">
          <meter
            :value="audio.volume"
            min="-96"
            max="0"
            high="-40"
          /> <span>{{ audio.volume }}</span>
        </div>
        <div id="canvas-container">
          <canvas
            id="canvas"
            ref="canvas"
            :width="canvas.width"
            :height="canvas.height"
          />
        </div>
      </div>
      <div class="d-flex flex-column justify-content-center align-items-center col-lg-4">
        <div id="mic_buttons">
          <button
            v-if="!audio.running"
            class="btn btn--circle"
            @click="getUserMedia"
          >
            <i class="fas fa-microphone" /><br>START
          </button>
          <button
            v-if="audio.running"
            class="btn btn--circle"
            @click="disconnectMedia"
          >
            <i class="fas fa-microphone" /><br>STOP
          </button>
        </div>
        <div class>
          <input
            id="checkbox"
            v-model="checked"
            type="checkbox"
          >
          <label for="checkbox">テスト完了！</label>
        </div>
        <div>
          <v-btn
            :disabled="!checked"
            @click="startGame"
          >
            ゲーム開始
          </v-btn>
        </div>
      </div>
    </div>
  </div>
</template>

<script>
import axios from '../../plugins/axios'
import 'cicadasinging.mp3'
import 'izakaya.mp3'

export default {
  name: "MicTestIndex",
  data() {
    return {
      audio: {
        ctx: null,
        processor: null,
        analyser: null,
        mic: null,
        running: false,
        volume: -96,
        spectrums: null,
        max_volume: null,
        max_frequency: null,
      },
      audioElement1: null,
      audioSource1: null,
      audioElement2: null,
      audioSource2: null,
      audioData: [],
      canvas: {
        ctx: null,
        width: 1200,
        height: 600,
        paddingTop: 20,
        paddingBottom: 20,
        paddingLeft: 30,
        paddingRight: 30,
        innerWidth: 1140, // width  - paddingLeft - paddingRight
        innerHeight: 560, // height - paddingTop  - paddingBottom
        innerBottom: 580, // height - paddingBottom
      },
      checked: false,
    }
  },
  mounted() {},
  methods: {
    playMp3() {
      let audioContext = window.AudioContext || window.webkitAudioContext
      // audioContextのオブジェクトを作成
      this.audio.ctx = new audioContext({ sampleRate: 44100 })
      // 音声データを扱うためのオブジェクトを生成
      // BufferSizeはブラウザが自動で選ぶ(256,512,..,8192,16384)
      this.audio.processor = this.audio.ctx.createScriptProcessor()
      // 周波数を解析するためAnalyzerNodeオブジェクトを生成
      this.audio.analyser = this.audio.ctx.createAnalyser()

      this.audioElement1 = this.$refs.audio1;
      this.audioSource1 = this.audio.ctx.createMediaElementSource(this.audioElement1);

      this.audioElement2 = this.$refs.audio2;
      this.audioSource2 = this.audio.ctx.createMediaElementSource(this.audioElement2);
      this.audioSource1
        .connect(this.audio.ctx.destination)
      this.audioSource1
        .connect(this.audio.analyser)

      this.audioSource2
        .connect(this.audio.ctx.destination)
      this.audioSource2
        .connect(this.audio.analyser)

      //this.audioSource.loop = true;
      this.audioElement1.play();
      this.audioElement2.play();
      this.audio.processor.onaudioprocess = this.handleOnAudioProcess
    },
    getUserMedia() {
      console.log('getUserMedia')
      navigator.mediaDevices
        .getUserMedia({ audio: true, video: false })
        .then(stream => {
          this.getLocalMediaStream(stream)
          this.audio.running = true
          // イベントハンドラー
          this.audio.processor.onaudioprocess = this.handleOnAudioProcess
        }).catch(error => {
          console.error('mediaDevices.getUserMedia() error:', error)
        })
    },

    getLocalMediaStream(mediaStream) {
      // AudioContextの利用宣言（クロスブラウザー対応）
      let audioContext = window.AudioContext || window.webkitAudioContext
      // audioContextのオブジェクトを作成
      this.audio.ctx = new audioContext({ sampleRate: 44100 })
      // 音声データを扱うためのオブジェクトを生成
      // BufferSizeはブラウザが自動で選ぶ(256,512,..,8192,16384)
      this.audio.processor = this.audio.ctx.createScriptProcessor()
      // 周波数を解析するためAnalyzerNodeオブジェクトを生成
      this.audio.analyser = this.audio.ctx.createAnalyser()
      // audioContextで音声ストリームを扱えるようにする
      this.audio.mic = this.audio.ctx.createMediaStreamSource(mediaStream)

      // それぞれをconnectで接続し、ストリームの音声データを扱えるようにする
      // mic (Input) -> ScriptProcessorNode (Processing) -> AudioDestinationNode (Output)
      //             └-> AnalyserNode (Visualization)
      this.audio.mic
        .connect(this.audio.processor)
        .connect(this.audio.ctx.destination)
      this.audio.mic
        .connect(this.audio.analyser)
    },

    handleOnAudioProcess(event) {
      // via. https://tech.drecom.co.jp/web_audio_api_audiobuffer/
      // サンプリング周波数と量子化ビット数を-1〜1の間で正規化した値を Float32Array で保存
      const input = event.inputBuffer.getChannelData(0) // 入力ソースの音声データを取得
      let sum = 0.0

      for(let i = 0; i < input.length; ++i) {
        // inputBufferの値は-1〜1の間で正規化された数値であるため2乗することで正の数値に変更する
        sum += input[i] * input[i]
      }
      // sum / input.length: inputBufferから取得した音量の平均値を取得
      // 平方根を取ることで input[i] * input[i] の値をもとに戻す
      this.audio.volume = Math.sqrt(sum / input.length)
      // dB換算し、少数第3位を四捨五入し表示
      // this.volume = this.volume.toFixed(2)
      this.audio.volume = (20 * Math.log10(this.audio.volume)).toFixed(2);

      // 波形描画
      this.canvas.ctx = this.$refs.canvas.getContext('2d');
      this.audio.analyser.fftSize = 4096;  // The default value
      this.audio.analyser.maxDecibels = 0;
      this.audio.analyser.minDecibels = -100;
      this.drawCanvas();
    },

    drawCanvas() {
      let range = this.audio.analyser.maxDecibels - this.audio.analyser.minDecibels;

      // Frequency resolution
      let fsDivN = this.audio.ctx.sampleRate / this.audio.analyser.fftSize;

      // This value is the number of samples during 440 Hz
      let n440Hz = Math.floor(440 / fsDivN);

      // Get data for drawing spectrum (dB)
      this.audio.spectrums = new Float32Array(this.audio.analyser.frequencyBinCount);  // Array size is 1024

      this.audio.max_volume = this.audio.analyser.minDecibels;
      this.audio.max_frequency = 0;

      this.audio.analyser.getFloatFrequencyData(this.audio.spectrums);

      // Clear previous data
      this.canvas.ctx.clearRect(0, 0, this.canvas.width, this.canvas.height);

      // Draw spectrum (dB)
      this.canvas.ctx.beginPath();

      for (let i = 0, len = this.audio.spectrums.length / 4; i < len; i++) {

        if (this.audio.max_volume < this.audio.spectrums[i]) {
          this.audio.max_volume = this.audio.spectrums[i];
          this.audio.max_frequency = i * fsDivN;
        }

        let x = Math.floor((i / len) * this.canvas.innerWidth) + this.canvas.paddingLeft;
        let y = (-1 * ((this.audio.spectrums[i] - this.audio.analyser.maxDecibels) / range) * this.canvas.innerHeight) + this.canvas.paddingTop;

        if (i === 0) {
          this.canvas.ctx.moveTo(x, y);
        } else {
          this.canvas.ctx.lineTo(x, y);
        }

        // 440 Hz ?
        if ((i % n440Hz) === 0) {
          let text = (440 * (i / n440Hz)) + ' Hz';  // index -> frequency
          // Draw grid (X)
          this.canvas.ctx.fillStyle = 'rgba(255, 0, 0, 1.0)';
          this.canvas.ctx.fillRect(x, this.canvas.paddingTop, 1, this.canvas.innerHeight);
          // Draw text (X)
          this.canvas.ctx.fillStyle = 'rgba(0, 0, 0, 1.0)';
          this.canvas.ctx.font = '12px "Times New Roman"';
          this.canvas.ctx.fillText(text, (x - (this.canvas.ctx.measureText(text).width / 2)), (this.canvas.height - 3));
        }
      }

      this.canvas.ctx.strokeStyle = 'rgba(0, 0, 255, 1.0)';
      this.canvas.ctx.lineWidth = 2;
      this.canvas.ctx.lineCap = 'round';
      this.canvas.ctx.lineJoin = 'miter';
      this.canvas.ctx.stroke();

      // Draw text and grid (Y)
      for (let i = this.audio.analyser.minDecibels; i <= this.audio.analyser.maxDecibels; i += 10) {
        let gy = (-1 * ((i - this.audio.analyser.maxDecibels) / range) * this.canvas.innerHeight) + this.canvas.paddingTop;
        // Draw grid (Y)
        this.canvas.ctx.fillStyle = 'rgba(255, 0, 0, 1.0)';
        this.canvas.ctx.fillRect(this.canvas.paddingLeft, gy, this.canvas.innerWidth, 1);
        // Draw text (Y)
        this.canvas.ctx.fillStyle = 'rgba(0, 0, 0, 1.0)';
        this.canvas.ctx.font = '12px "Times New Roman"';
        this.canvas.ctx.fillText((i + ' dB'), 3, gy);
      }
      
      // for debug
      console.log(`audioContext.sampleRate: ${this.audio.ctx.sampleRate}, analyserNode.fftSize: ${this.audio.analyser.fftSize}, fsDivN: ${fsDivN},  n440Hz: ${n440Hz}, spectrums.length: ${this.audio.spectrums.length}, analyserNode.frequencybinCount: ${this.audio.analyser.frequencyBinCount}`);
    },

    disconnectMedia() {
      if (this.audio.running == true) {
        // this.audioCtx.close()
        // Object.assign(this.$data, this.$options.data()) 
        this.audio.mic.disconnect(this.audio.processor)
        this.audio.processor.disconnect(this.audio.ctx.destination)
        this.audio.mic.disconnect(this.audio.analyser)

        this.audio.processor.onaudioprocess = null
        this.audio.running = false
      }
    },

    async startGame() {
      try {
        await this.disconnectMedia(); 
        axios.post('/api/games')
          .then(res => {
            this.$router.push({ name: 'GameIndex', params: { game_id: res.data.id }})
          })
      } catch (error) {
        console.log(error);
      }
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
