<template>
  <section class="section">
    <div class="columns">
      <div class="column">
        <meter :value="audio.volume" min="-96" max="0" high="-40"></meter> <span>{{ audio.volume }}</span>
      </div>
    </div>
    <div>
      <canvas ref="canvas" :width="canvas.width" :height="canvas.height"></canvas>
    </div>
    <div class="buttons">
      <button v-if="!audio.running" @click="getUserMedia">音声の取得を開始する</button>
      <button v-if="audio.running" @click="disconnectMedia">音声の取得を停止する</button>
    </div>
  </section>
</template>

<script>
export default {
  data() {
    return {
      streamConst: {
        audio: true, // 録音する場合はaudio: trueとする
        video: false,
      },
      audio: {
        ctx: null,
        processor: null,
        analyser: null,
        mic: null,
        running: false,
        volume: -96,
      },
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
    }
  },
  mounted() {},
  methods: {
    getUserMedia() {
      console.log('getUserMedia')
      navigator.mediaDevices
        .getUserMedia(this.streamConst)
        .then(stream => {
          this.getLocalMediaStream(stream)
          this.audio.running = true
        }).catch(error => {
          console.error('mediaDevices.getUserMedia() error:', error)
        })
    },

    getLocalMediaStream(mediaStream) {
      // AudioContextの利用宣言（クロスブラウザー対応）
      let audioContext = window.AudioContext || window.webkitAudioContext
      // audioContextのオブジェクトを作成
      this.audio.ctx = new audioContext()
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
      this.audio.mic.connect(this.audio.processor)
      this.audio.processor.connect(this.audio.ctx.destination)
      this.audio.mic.connect(this.audio.analyser)

      // イベントハンドラー
      this.audio.processor.onaudioprocess = this.handleOnAudioProcess
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
      // 少数第3位を四捨五入し表示
      // this.volume = this.volume.toFixed(2)
      this.audio.volume = 20 * Math.log10(this.audio.volume);

      // 波形描画
      this.canvas.ctx = this.$refs.canvas.getContext('2d');
      this.audio.analyser.fftSize = 2048;  // The default value
      this.audio.analyser.maxDecibels = 0;
      this.audio.analyser.minDecibels = -70;

      window.setInterval(this.drawCanvas(), 500);
    },

    drawCanvas() {
      let range = this.audio.analyser.maxDecibels - this.audio.analyser.minDecibels;  // 70 dB

      // Frequency resolution
      let fsDivN = this.audio.ctx.sampleRate / this.audio.analyser.fftSize;

      // This value is the number of samples during 500 Hz
      let n500Hz = Math.floor(500 / fsDivN);

      // Get data for drawing spectrum (dB)
      let spectrums = new Float32Array(this.audio.analyser.frequencyBinCount / 4);  // Array size is 256 (FFT sizeの半分 / 4)
      this.audio.analyser.getFloatFrequencyData(spectrums);

      // Clear previous data
      this.canvas.ctx.clearRect(0, 0, this.canvas.width, this.canvas.height);

      // Draw spectrum (dB)
      this.canvas.ctx.beginPath();

      for (let i = 0, len = spectrums.length; i < len; i++) {
        let x = (i / len) * this.canvas.width;
        let y = (-1 * ((spectrums[i] - this.audio.analyser.maxDecibels) / range)) * this.canvas.height;

        if (i === 0) {
          this.canvas.ctx.moveTo(x, y);
        } else {
          this.canvas.ctx.lineTo(x, y);
        }

        // 500 Hz ?
        if ((i % n500Hz) === 0) {
          let text = (500 * (i / n500Hz)) + ' Hz';  // index -> frequency
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
      console.log(`audioContext.sampleRate: ${this.audio.ctx.sampleRate}, analyserNode.fftSize: ${this.audio.analyser.fftSize}, fsDivN: ${fsDivN},  n500Hz: ${n500Hz}, spectrums[0]: ${spectrums[0]}, analyserNode.frequencybinCount: ${this.audio.analyser.frequencyBinCount}`);
    },

    disconnectMedia() {
      // this.audioCtx.close()
      // Object.assign(this.$data, this.$options.data()) 
      this.audio.mic.disconnect(this.audio.processor)
      this.audio.processor.disconnect(this.audio.ctx.destination)
      this.audio.mic.disconnect(this.audio.analyser)

      this.audio.processor.onaudioprocess = null
      this.audio.running = false
    }
  },
}
</script>

<style scoped>
</style>
