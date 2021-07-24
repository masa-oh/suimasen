<template>
  <div class="container-fluid">
    {{ game  }}
  </div>
</template>

<script>
import axios from '../../plugins/axios'

export default {
  name: "GameIndex",
  data() {
    return {
      game: null
    }
  },
  created() {
    this.fetchGames();
  },
  methods: {
    fetchGames () {
      axios.get('games')
        .then(res => {
          this.game = res.data;
        })
        .catch(err => console.log(err.status));
    },
  }
}
</script>

<style scoped>
</style>
