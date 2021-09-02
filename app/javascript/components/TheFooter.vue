<template>
  <footer id="footer">
    <v-footer
      color="primary lighten-1"
      padless
    >
      <v-row
        justify="center"
        no-gutters
      >
        <v-btn
          v-for="link in links"
          :key="link"
          color="white"
          text
          rounded
          class="my-2"
        >
          {{ link }}
        </v-btn>
        <v-col
          class="primary lighten-2 py-4 text-center white--text"
          cols="12"
        >
        <small>Copyright &copy; {{ new Date().getFullYear() }}. <strong>すいませんチェッカー</strong></small>
        </v-col>
      </v-row>
    </v-footer>
  </footer>
</template>

<script>
export default {
  name: "TheFooter",
  data: () => ({
    links: [
      '利用規約',
      'プライバシーポリシー',
      'お問い合わせ',
    ],
  }),
}
</script>

<style scoped>

</style>
