<template>
  <v-app :style="{ background: $vuetify.theme.themes.light.background }">
    <!-- ナビゲーションメニュー -->
    <v-navigation-drawer app v-model="drawer">
    </v-navigation-drawer>

    <!-- ヘッダー -->
    <TheHeader @change-drawer="changeDrawer" />
  
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
  },
  data() {
    return {
      drawer: false,
    }
  },
  methods: {
    changeDrawer() {
      this.drawer = !this.drawer;
    }
  }
}
</script>

<style scoped>
</style>
