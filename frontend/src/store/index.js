import Vue from 'vue';
import Vuex from 'vuex';

Vue.use(Vuex);

export default new Vuex.Store({
  state: {
    accountHash: '',
    precision: 1,
  },
  getters: {
    $accountHash: (state) => state.accountHash,
    $precision: (state) => state.precision,
  },
  mutations: {
    UPDATE_ACCOUNT_HASH(state, payload) {
      state.accountHash = payload;
    },
    UPDATE_ACCOUNT_PRECISION(state, payload) {
      state.precision = payload;
    },
  },
  actions: {
    $updateAccountHash({ commit }, payload) {
      commit('UPDATE_ACCOUNT_HASH', payload);
    },
    $updatePrecision({ commit }, payload) {
      commit('UPDATE_ACCOUNT_PRECISION', payload);
    },
  },
});
