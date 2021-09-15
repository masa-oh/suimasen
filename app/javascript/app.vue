<template>
  <v-app style="background: linear-gradient(128deg, #EE7C5895, #D8E3E7, #55a2b7);">
    <!-- ヘッダー -->
    <TheHeader />

    <!-- メインコンテンツ -->
    <v-main>
      <transition mode="out-in">
        <router-view />
      </transition>
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
.v-enter-active, .v-leave-active {
  transition: opacity .5s;
}
.v-enter, .v-leave-to {
  opacity: 0;
}
</style>
