<template>
  <v-app>
    <v-navigation-drawer app>
      <!-- -->
    </v-navigation-drawer>
  
    <v-app-bar app>
      <!-- -->
      <TheHeader />
    </v-app-bar>
  
    <!-- アプリケーションのコンポーネントに基づいてコンテンツのサイズを決定 -->
    <v-main>
  
      <!-- アプリケーションに適切なgutterを提供します -->
      <v-container fluid>
  
        <router-view />
      </v-container>
    </v-main>
  
    <v-footer app>
      <!-- -->
      <TheFooter />
    </v-footer>
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
