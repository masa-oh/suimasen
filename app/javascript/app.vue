<template>
  <v-app :style="{ background: $vuetify.theme.themes.light.background }">
    <!-- ヘッダー -->
    <TheHeader />
  
    <!-- メインコンテンツ -->
    <v-main>
      <router-view />
    </v-main>
  
    <!-- フッター -->
    <TheFooter />
  </v-app>
</template>

<script>
import TheHeader from './components/TheHeader.vue'
import TheFooter from './components/TheFooter.vue'

export default {
  components: {
    TheHeader,
    TheFooter,
  },
  computed: {
    isTopPage() {
      return this.$route.path === "/"
    }
  },
}
</script>

<style scoped>
.v-application--wrap {
  background-color: #e9f1f5;
}
.container.main-content {
  max-width: 900px;
  margin: 0 auto;
}
.main-content {
  max-width: 900px;
  margin: 0 auto;
}
</style>
