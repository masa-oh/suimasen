<template>
  <v-app>
    <!-- ナビゲーションメニュー -->
    <v-navigation-drawer app>
    </v-navigation-drawer>

    <!-- ヘッダー -->
    <TheHeader />
  
    <!-- メインコンテンツ -->
    <v-main>
      <v-container fluid>
        <router-view />
      </v-container>
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
  }
}
</script>

<style scoped>
</style>
