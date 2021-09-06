<template>
  <div class="top">
    <div class="logo-wrapper">
      <v-container fluid>
        <v-row align-content="center">
          <v-spacer />
          <v-col class="text-right align-self-center" cols="6">
            <p class="text-h2 mb-8 d-sm-block service-name">すいませんチェッカー</p>
            <p class="mb-12 d-sm-block service-description">
              店員さんを呼ぶ声が通らない全ての人のための、
              <br>音声測定・発声改善支援サービスです。
            </p>
            <v-spacer />
            <!-- 開始ボタン -->
            <v-btn
                class="mb-8"
                color="primary"
                :to="{ name: 'MicTestIndex' }"
                x-large
                dark
            >
              さっそくはじめる
            </v-btn>
          </v-col>
          <v-col cols="3">
            <v-img max-width="600" :src="src_woman" />
          </v-col>
          <v-spacer />
        </v-row>
      </v-container>
    </div>
  </div>
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
      src_boxlogo: require("suimasen_boxlogo.svg"),
      src_woman: require("suimasen_woman.svg"),
      src_dark: require("suimasen_dark.svg"),
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
  filter: drop-shadow(5px 5px 0 #F0F0F0);
}

.service-description {
}

.suimasen__content {
  background-image: "cafe.jpg";
  filter: grayscale(100%);
}

</style>
