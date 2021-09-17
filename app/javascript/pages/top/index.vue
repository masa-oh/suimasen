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
        <v-btn
            class="mb-8"
            color="primary"
            :to="{ name: 'StageSelectIndex' }"
            x-large
            dark
        >
          さっそくはじめる
        </v-btn>
      </v-col>
      <v-col cols="3">
        <v-img class="img--woman" max-width="300" :src="src_woman" />
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
      src_woman: require("suimasen_woman.svg"),
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
