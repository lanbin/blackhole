import Vue from 'vue';
import VueRouter from 'vue-router';
import store from '../store';
import { GetPrecision } from 'utils/Provider';

Vue.use(VueRouter);

const routes = [
  {
    path: '/',
    name: 'Home',
    component: () => import(/* webpackChunkName: "home" */ '../views/Home.vue'),
  },
];

const router = new VueRouter({
  routes,
});

router.beforeEach(async (to, from, next) => {
  if (store.getters.$precision === 1) {
    const res = await GetPrecision();
    store.dispatch('$updatePrecision', res);
  }
  next();
});

export default router;
