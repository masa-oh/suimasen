<template>
  <v-app-bar
    color="primary lighten-1"
    dark
    app
  >
    <v-toolbar-title>
      <v-img :src="src_dark" max-width="250" max-height="50"/>
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
