import Vue from 'vue'

import ElementUI from 'element-ui'
import 'element-ui/lib/theme-chalk/index.css'
Vue.use(ElementUI)

import Router from 'vue-router'
Vue.use(Router)

import MenuBar from '@/components/MenuBar'
Vue.component('MenuBar', MenuBar)

export default new Router({
  mode: 'hash',
  routes: [
    {
      path: '/',
      name: 'MainPage',
      component: () => import('@/components/MainPage'),
      children: [
        {
          path: '/prize1',
          component: () => import('@/components/prizes/prize1/IndexPage'),
          children: [
            {
              path: 'bet',
              component: () => import('@/components/prizes/prize1/BetPage'),
            },
            {
              path: 'history',
              component: () => import('@/components/prizes/prize1/HistoryPage'),
            },
            {
              path: 'winner',
              component: () => import('@/components/prizes/prize1/WinnerPage'),
            },
            {
              path: 'about',
              component: () => import('@/components/prizes/prize1/AboutPage'),
            },
          ],
        },
      ],
    },
    {
      path: '/about',
      name: 'AboutPage',
      component: () => import('@/components/AboutPage')
    },
  ]
})
