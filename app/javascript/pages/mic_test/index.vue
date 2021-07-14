<template>
  <div class="video-container">
    <div class="video-area">
      <video
        id="my-video"
        autoplay
        playsinline />
    </div>
    <div class="btns">
      <button :class="isMuteAudio ? 'can' : 'disabled'" @click="muteAudio()">audio</button>
      <button :class="isMuteVideo ? 'can' : 'disabled'" @click="muteVideo()">video</button>
    </div>
  </div>
</template>

<script>
export default {
  name: "MicTestIndex",
  data () {
    return {
      videos: [],
      audios: [],
      selectedAudio: '',
      selectedVideo: '',
      localStream: null,
      isMuteAudio: false,
      isMuteVideo: false
    }
  },

  async mounted () {
    await this.prepareAudioVideoDevice()
    await this.connectLocalCamera()
  },

  destroyed() {
    this.disconnectLocalCamera()
  },

  methods: {
    prepareAudioVideoDevice () {
      navigator.mediaDevices.enumerateDevices()
        .then(deviceInfos => {
          // MediaDeviceInfo
          // - deviceId （デバイスID)
          // - kind 3type（audioinput, videoinput, audiooutput）
          // - label （名称）※ 取得できる場合と、できない場合がある
          // - groupId
          const audios = [{ text: '指定なし', value: '' }]
          const videos = [{ text: '指定なし', value: '' }]
          for (let i = 0; i < deviceInfos.length; i++) {
            const deviceInfo = deviceInfos[i]
            if (deviceInfo.kind === 'audioinput') {
              audios.push({
                text: deviceInfo.label || `Microphone ${audios.length + 1}`,
                value: deviceInfo.deviceId
              })
            } else if (deviceInfo.kind === 'videoinput') {
              videos.push({
                text: deviceInfo.label || `Camera  ${videos.length + 1}`,
                value: deviceInfo.deviceId
              })
            }
          }
          this.audios = audios
          this.videos = videos
        })
    },

    connectLocalCamera () {
      const constraints = {
        audio: this.selectedAudio ? { deviceId: { exact: this.selectedAudio } } : true,
        video: this.selectedVideo ? { deviceId: { exact: this.selectedVideo } } : true,
      }

      if (this.localStream) {
        this.localStream = null
      }

      navigator.mediaDevices.getUserMedia(constraints)
        .then(stream => {
          document.getElementById('my-video').srcObject = stream
          this.localStream = stream
        }).catch(error => {
          console.error('mediaDevice.getUserMedia() error:', error)
        })
    },

    muteAudio () {
      if (!this.localStream) return
      this.localStream.getAudioTracks()[0].enabled = !this.isMuteAudio
      this.isMuteAudio = !this.isMuteAudio
    },

    muteVideo () {
      if (!this.localStream) return
      if (!this.isMuteVideo) {
        // Mute
        this.localStream.getVideoTracks()[0].stop()
        this.localStream.removeTrack(this.localStream.getVideoTracks()[0])
        document.getElementById('my-video').srcObject = null
      } else {
        // Re-connect
        this.connectLocalCamera()
      }
      this.isMuteVideo = !this.isMuteVideo
    },

    disconnectLocalCamera () {
      if (!!this.localStream) {
        this.localStream.getTracks().forEach(track => track.stop())
        document.getElementById('my-video').srcObject = null
        this.localStream = null
      }
    },

  }
}
</script>

<style scoped>
</style>
