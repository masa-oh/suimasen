<template>
  <section class="section">
    <div class="columns">
      <div class="column">
        <meter :value="volume" min="-96" max="0" high="-40"></meter> <span>{{ volume }}</span>
      </div>
    </div>
    <div class="buttons">
      <button v-if="!isConnectedToMic" @click="getUserMedia">音声の取得を開始する</button>
      <button v-if="isConnectedToMic" @click="disconnectMedia">音声の取得を停止する</button>
    </div>
  </section>
</template>

<script>
export default {
  data() {
    return {
      localstream: null,
      streamConst: {
        audio: true, // 録音する場合はaudio: trueとする
        video: false,
      },
      audioContext: null,
      audioScript: null,
      mic: null,
      volume: -96,
      isConnectedToMic: false
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
          this.isConnectedToMic = true
        }).catch(error => {
          console.error('mediaDevices.getUserMedia() error:', error)
        })
    },

    getLocalMediaStream(mediaStream) {
       this.localstream = mediaStream

      // 音声取得
      // 音声コンテキストを作成
      let audioContext = window.AudioContext
      this.audioContext = new audioContext()
      // 音声データを扱うためのオブジェクトを生成
      // bufferSizeはOSごとに最適なサイズをあてる: https://weblike-curtaincall.ssl-lolipop.jp/portfolio-web-sounder/webaudioapi-basic/custom
      this.audioScript = this.audioContext.createScriptProcessor(2048, 1, 1)
      // audioContextで音声ストリームを扱えるようにする
      this.mic = this.audioContext.createMediaStreamSource(mediaStream)

      // それぞれをconnectで接続し、ストリームの音声データを扱えるようにする
      this.mic.connect(this.audioScript)
      this.audioScript.connect(this.audioContext.destination)

      // イベントハンドラー
      this.audioScript.onaudioprocess = this.handleLocalOnAudioProcess
    },
    handleLocalOnAudioProcess(event) {
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
      this.volume = Math.sqrt(sum / input.length)
      // 少数第3位を四捨五入し表示
      // this.volume = this.volume.toFixed(2)
      this.volume = 20 * Math.log10(this.volume);
    },

    disconnectMedia() {
      this.audioContext.close()
      Object.assign(this.$data, this.$options.data()) 
    }
  },
}
</script>

<style scoped>
</style>
