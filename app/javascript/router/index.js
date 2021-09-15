import Vue from 'vue'
import Router from 'vue-router'

import TopIndex from "../pages/top/index.vue"
import GameIndex from "../pages/game/index.vue"

Vue.use(Router)

const router = new Router({
  mode: 'history',
  routes : [
    { 
      path: '/',
      component: TopIndex,
      name: "TopIndex",
    },
    { 
      path: '/game',
      component: GameIndex,
      name: "GameIndex",
    },
  ],
});

export default router
