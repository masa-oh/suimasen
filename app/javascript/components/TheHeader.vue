<template>
  <v-app-bar
    color="#22222250"
    dark
    flat
    app
  >
    <v-toolbar-title>
      <router-link :to="{ name: 'TopIndex' }">
        <v-img
          :src="src_dark"
          max-width="250"
          max-height="50"
        />
      </router-link>
    </v-toolbar-title>
    <v-spacer />
    <v-toolbar-items>
    </v-toolbar-items>
  </v-app-bar>
</template>

<script>
import "suimasen_dark.svg"

export default {
  name: "TheHeader",
  data() {
    return {
      src_dark: require("suimasen_dark.svg"),
    }
  },
  methods: {
  }
}
</script>

<style scoped>

</style>
