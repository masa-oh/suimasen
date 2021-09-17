<template>
  <footer id="footer">
    <v-footer
      color="transparent"
      padless
    >
      <v-row
        align="center"
        justify="center"
        no-gutters
      >
        <v-col class="text-center" cols="12">
          <v-btn
            v-for="link in links"
            :key="link.text"
            :to="link.to"
            color="black"
            text
            rounded
            class="my-0"
          >
            {{ link.text }}
          </v-btn>
        </v-col>
        <v-col
          class="py-2 text-center black--text"
          cols="12"
        >
        <small>Copyright &copy; {{ new Date().getFullYear() }}. すいませんチェッカー</small>
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
      { text: '利用規約', to: { name: 'Terms' } },
      { text: 'プライバシーポリシー', to: { name: 'PrivacyPolicy' } },
      { text: 'お問い合わせ', to: { name: 'Inquiry' } }
    ],
  }),
}
</script>

<style scoped>
.linktext {
  text-shadow: 1px  1px 4px #222;
}
</style>
