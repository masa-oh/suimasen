<template>
  <v-container fill-height fluid>
    <v-row class="mx-0 px-0" align-content="center" justify="center">
      <v-col cols="8">
        <div class="text-center">
          <p class="text-h4 mb-2">ステージセレクト</p>
        </div>
      </v-col>

      <v-col cols="12"></v-col>

      <v-col cols="4">
        <div
          v-for="stage of stages"
          :key="stage.id"
          block
          class="d-flex flex-row justify-space-between align-center"
        >
          <div>
            難易度：
          </div>
          <div>
            {{ "★".repeat(stage.difficulty) }}
          </div>
          <v-btn
            class="mx-2 my-4"
            dark
            x-large
            width='230'
            color="primary lighten-1"
            :to="{ name: 'GameIndex', params: { stage_name: stage.name.en } }"
          >
            <strong>{{ stage.name.ja }}</strong>ですいません
          </v-btn>
        </div>
      </v-col>
    </v-row>
  </v-container>
</template>

<script>
export default {
  name: "StageSelectIndex",
  data() {
    return {
      stages: [
        // { name: ステージ名, difficulty: 難易度（5段階評価）, gain_value: 声の減衰率 }
        { id: 1, name: { en: "restaurant", ja: "レストラン" }, difficulty: 2, gain_value: 0.6 },
        { id: 2, name: { en: "pub", ja: "居酒屋" }, difficulty: 3, gain_value: 0.6 },
        { id: 3, name: { en: "wind", ja: "強風の中" }, difficulty: 4, gain_value: 0.4 },
        { id: 4, name: { en: "pachinko", ja: "パチンコ屋" }, difficulty: 5, gain_value: 0.4 }
      ]
    }
  }
}
</script>

<style scoped>

</style>
