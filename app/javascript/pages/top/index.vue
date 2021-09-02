<template>
  <div class="text-center">
    <div>
      <img src="~suimasen_boxlogo.svg" />
    </div>

    <router-link
      :to="{ name: 'MicTestIndex' }"
    >
      <v-btn
          color="primary"
          dark
      >
        はじめる
      </v-btn>
    </router-link>
  </div>
</template>

<script>
import 'suimasen_logo.svg'
import 'suimasen_boxlogo.svg'

export default {
  name: "TopIndex",
}
</script>

<style scoped>
</style>
