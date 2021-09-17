<template>
  <v-container class="inquiry" fill-height fluid>
    <v-row align-content="center">
      <v-spacer />
      <v-col class="text-center" cols="10">
        <p>サービスの利用に関するお問い合わせ、不具合の報告などがございましたら、</p>
        <p>お手数ですが、以下のTwitterアカウント宛のダイレクトメールにてお知らせください。</p>
        <p>
          <span class="mr-1"><i class="fab fa-twitter" />Twitter ID:</span>
          <v-btn
            href="https://twitter.com/m_asa_o"
            target="_blank"
            text
            color="primary"
            min-height="20"
            class="x-small post-link align-center py-1 px-2"
          >
            <span class="text-left">@m_asa_o</span>
          </v-btn>
        </p>
      </v-col>
      <v-spacer />
    </v-row>
  </v-container>
</template>

<script>
export default {
}
</script>

<style scoped>
.post-link {
  display: inline-block;
  word-break: break-all;
  padding: 2px 8px;
  border-radius: 5px;
  text-transform: none !important;
  white-space: normal;
  max-width: calc(100% - 30px);
  height: inherit !important;
}
</style>
