<template>
  <div class="text-center">
    <h3>すいませんチェッカー</h3>
    <div class="mt-4">
      店員さん、ちゃんと呼べてますか？
    </div>
    <router-link
      :to="{ name: 'MicTestIndex' }"
      class="btn btn-dark mt-5"
    >
      ログイン
    </router-link>
    <router-link
      :to="{ name: 'MicTestIndex' }"
      class="btn btn-dark mt-5"
    >
      ログインせずに開始
    </router-link>
  </div>
</template>

<script>
export default {
  name: "TopIndex",
}
</script>

<style scoped>
</style>
