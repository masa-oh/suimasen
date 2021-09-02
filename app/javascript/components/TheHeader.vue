<template>
  <header id="header">
    <v-app-bar
      color="primary lighten-1"
      dark
      app
    >
      <v-app-bar-nav-icon
        @click.stop="changeDrawer"
      >
      </v-app-bar-nav-icon>
      <v-toolbar-title>
        すいませんチェッカー
      </v-toolbar-title>
    </v-app-bar>
  </header>
</template>

<script>
export default {
  name: "TheHeader",
  methods: {
    changeDrawer() {
      this.$emit('change-drawer');
    }
  }
}
</script>

<style scoped>

</style>
