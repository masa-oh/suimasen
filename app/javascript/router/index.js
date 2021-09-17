import Vue from 'vue'
import Router from 'vue-router'

import TopIndex from "../pages/top/index.vue"
import StageSelectIndex from "../pages/stage_select/index.vue"
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
      path: '/stage_select',
      component: StageSelectIndex,
      name: "StageSelectIndex",
    },
    {
      path: '/game/:stage_name',
      component: GameIndex,
      name: "GameIndex",
    },
  ],
});

export default router
