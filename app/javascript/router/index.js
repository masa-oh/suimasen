import Vue from 'vue'
import Router from 'vue-router'

import TopIndex from "../pages/top/index.vue"
import MicTestIndex from "../pages/mic_test/index.vue"

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
      path: '/mic_test',
      component: MicTestIndex,
      name: "MicTestIndex",
    },
  ],
});

export default router
