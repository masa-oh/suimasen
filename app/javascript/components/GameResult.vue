<template>
  <div id="result">
    <v-dialog
      v-model="dialog"
      scrollable
      persistent
    >
      <template v-slot:activator="{ on, attrs }">
        <v-btn
          color="primary"
          x-large
          dark
          v-bind="attrs"
          v-on="on"
        >
        結果を見る
        </v-btn>
      </template>
  
      <v-card color="secondary">
        <v-card-title class="justify-center">
          <p class="text-h3">{{ resultMessage.summary }}</p>
        </v-card-title>
        <v-card-subtitle class="text-center">
          <p class="text-h5" v-html="`ステージ：${stage.name}（${'★'.repeat(stage.difficulty)}）`" />
          <p class="text-h5" v-html="resultMessage.score.replace(/\n/g, '<br/>')" />
        </v-card-subtitle>
        <v-card-text>
          <v-container>
            <v-row align-content="center" justify="center">
              <v-col class="text-center" cols="10">
                <p class="text-h5 mb-2" v-html="resultMessage.description.replace(/\n/g, '<br/>')" />
                <p v-html="resultMessage.transcript.replace(/\n/g, '<br/>')" />
              </v-col>
            </v-row>
            <v-divider class="my-4" />
            <v-row align-content="center" justify="center">
              <v-col class="text-center" cols="5">
                <p>元のすいません</p>
                <audio controls :src="voiceOrigin.url"></audio>
              </v-col>
              <v-divider vertical />
              <v-col class="text-center" cols="5">
                <p>{{ stage.name }}でのすいません</p>
                <audio controls :src="voiceMixed.url"></audio>
              </v-col>
            </v-row>
            <v-divider class="my-4" />

            <v-row align-content="center" justify="center">
              <v-col class="text-center" cols="10">
                <div class="sns-share-area">
                  <v-btn
                    :href="snsTwitter"
                    target="_blank"
                  ><i class="fab fa-twitter" />結果をシェア
                  </v-btn>
                </div>
              </v-col>
            </v-row>

            <v-row align-content="center" justify="center">
              <v-col class="text-center" cols="10">
                <p class="text-h5 mb-2">
                  もっと得点を上げたいですか？
                </p>
                <p>
                  声はトレーニングによって改善できます。<br />
                  動画で学んで再チャレンジしよう！
                </p>
              </v-col>
              <v-col class="text-center" cols="10">
                <!-- サーバーのバッチジョブで取得したYoutube動画を埋め込み -->
                <youtube
                  :key="recommendedVideoId"
                  :video-id="recommendedVideoId"
                />
              </v-col>
            </v-row>
          </v-container>
        </v-card-text>
        <v-divider />
        <v-card-actions class="justify-center">
          <v-btn
            text
            @click="dialog = false"
            :to="{ name: 'StageSelectIndex' }"
          >
            別のステージで再挑戦する
          </v-btn>
          <v-btn
            text
            @click="dialog = false"
            :to="{ name: 'TopIndex' }"
          >
            タイトルに戻る
          </v-btn>
        </v-card-actions>
      </v-card>
    </v-dialog>
  </div>
</template>

<script>
import '../plugins/vue_youtube';

export default {
  name: "GameResult",
  props: {
    stage: {},
    pattern: {},
    voiceOrigin: {},
    voiceMixed: {},
    result: {
      transcript: {
        required: true,
        default: ''
      },
      confidence: {
        required: true,
        default: 0
      }
    }
  },
  data() {
    return {
      dialog: false,
      videoIds: [
        '6JrNNSHXz5g',
        'Dakoxfx_Do4',
        'Pm7qN6YCgY0',
      ]
    }
  },
  computed: {
    score() {
      return (this.pattern.test(this.result.transcript) ? Math.round(this.result.confidence * 100) : 0);
    },
    resultMessage() {
      let ret = {}
      if (this.score > 90) {
        ret.summary = "Excellent!"
        ret.description = "理想的なすいませんです。\n率先して店員さんを呼びましょう。"
      } else if (this.score > 60) {
        ret.summary = "Good!"
        ret.description = "なかなかいい線ですね。\n練習してさらなる高みを目指しましょう。"
      } else {
        ret.summary = "Not Good..."
        ret.description = "店員さんを呼ぶのは諦めて、\n呼び鈴のあるお店を選びましょう。"
      }
      ret.score = `得点：${this.score}点`
      ret.transcript =  "あなたの「すいません」は、\n" +
                        (this.pattern.test(this.result.transcript) ? `${this.stage.name}でもしっかり聞こえました！！` :
                         this.result.transcript ? `${this.stage.name}では『${this.result.transcript}』と聞こえました。` :
                         `${this.stage.name}では聞こえませんでした。`)
      return ret
    },
    recommendedVideoId() {
      let rand = Math.floor(Math.random() * this.videoIds.length)
      return this.videoIds[rand]
    },
    fullPath() {
      return window.location.origin + this.$router.resolve({ name: "TopIndex" }).href
    },
    snsTwitter() {
      // Twitterシェアの文言を設定
      let ret = "https://twitter.com/intent/tweet?url=" + this.fullPath +
                "&text=" +
                (`ステージ【${this.stage.name}】（${'★'.repeat(this.stage.difficulty)}）${this.score>0 ? 'クリア！' : '失敗…'}`) + "%0a%0a" + 
                "私のすいませんは、" +
                (this.pattern.test(this.result.transcript) ? `${this.stage.name}でもしっかり通る声でした！` :
                 this.result.transcript ? `${this.stage.name}では『${this.result.transcript}』と聞き取られました。` :
                 `${this.stage.name}では聞き取ってもらえませんでした。`) + "%0a%0a" +
                "↓「すいません」の上手さをチェック！" + "%0a%0a" +
                "&hashtags=すいませんチェッカー";
      return ret;
    }
  },
  methods: {
  },
}
</script>

<style scoped>

</style>
