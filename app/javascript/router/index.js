import Vue from 'vue'
import Router from 'vue-router'

import TopIndex from "../pages/top/index.vue"
import StageSelectIndex from "../pages/stage_select/index.vue"
import GameIndex from "../pages/game/index.vue"
import Terms from "../pages/shared/terms.vue"
import PrivacyPolicy from "../pages/shared/privacy_policy.vue"
import Inquiry from "../pages/shared/inquiry.vue"

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
    {
      path: '/terms',
      component: Terms,
      name: "Terms",
    },
    {
      path: '/privacy_policy',
      component: PrivacyPolicy,
      name: "PrivacyPolicy",
    },    {
      path: '/inquiry',
      component: Inquiry,
      name: "Inquiry",
    },
  ],
});

export default router
