<template>
  <v-container fill-height fluid>
    <v-row align-content="center">
      <v-spacer />
      <v-col class="text-right align-self-center" cols="6">
        <p class="text-h2 mb-8 d-sm-block text-no-wrap service-name">すいませんチェッカー</p>
        <p class="text-h5 mb-12 font-weight-bold d-sm-block text-no-wrap service-description">
          周りの音にかき消されない<br/>"通る声"を手に入れよう
        </p>
        <v-spacer />
        <!-- 開始ボタン -->
        <div>
          <v-dialog
            v-model="dialog"
            width="700"
          >
            <template v-slot:activator="{ on, attrs }">
              <v-btn
                  class="mb-8"
                  color="primary"
                  x-large
                  dark
                  v-bind="attrs"
                  v-on="on"
              >
                さっそくはじめる
              </v-btn>
            </template>

            <v-card>
              <v-card-title class="text-h5 white--text primary lighten-2" dark>
                注意事項
              </v-card-title>

              <v-card-text>
                <p/>
                <ul>
                  <li>
                    このゲームは、PCでのみプレイ可能です。<br/>
                    現時点で、スマートフォンからはご利用いただけません。（※近日中の対応を予定しております）
                  </li>
                  <li>
                      推奨ブラウザは以下の通りです。
                    <ul>
                      <li>Windowsの場合：Google Chrome，Microsoft Edge（※Internet Explolerでは利用不可）</li>
                      <li>macOSの場合：Google Chrome，Safari</li>
                    </ul>
                  </li>
                  <li>このゲームでは、マイクを使用します。周囲の環境には十分ご配慮ください。</li>
                  <li>
                    ゲームを開始した時点で、
                    <router-link :to="{ name: 'Terms' }">利用規約</router-link>、
                    <router-link :to="{ name: 'PrivacyPolicy' }">プライバシーポリシー</router-link>
                    に同意頂いたものとみなします。</li>
                </ul>
              </v-card-text>

              <v-divider></v-divider>

              <v-card-actions>
                <v-spacer></v-spacer>
                <v-btn
                  color="primary"
                  text
                  @click="dialog = false"
                  :to="{ name: 'StageSelectIndex' }"
                >
                  わかった！
                </v-btn>
              </v-card-actions>
            </v-card>
          </v-dialog>
        </div>
      </v-col>
      <v-col cols="3">
        <v-img class="img--woman" max-width="300" :src="srcWoman" />
      </v-col>
      <v-spacer />
    </v-row>
  </v-container>
</template>

<script>
import 'suimasen_logo.svg'
import 'suimasen_dark.svg'
import 'suimasen_boxlogo.svg'
import 'suimasen_woman.svg'
import 'cafe.jpg'

export default {
  name: "TopIndex",
  data() {
    return {
      dialog: false,
      srcWoman: require("suimasen_woman.svg"),
    }
  },
}
</script>

<style scoped>
.top {
  color: #3b394d;
}

.logo {
  background-color: #132C33;
}

.service-name {
  font-family: 'Baloo Tamma', cursive;
  color: #fff;
  letter-spacing: 5px;
  text-shadow: -1px -1px 0px #55a2b7,
    3px 3px 0px #55a2b7,
    6px 6px 0px #37879c;
}

.service-description {
  color: #55a2b7;
  letter-spacing: -4px;
  text-shadow: 1px 1px 0px #fff;
}
</style>
