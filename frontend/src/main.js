import Vue from 'vue';
import App from './App.vue';
import router from './router';
import store from './store';

/**
 * Import Component of Element-ui
 */
import {
  Table,
  TableColumn,
  Pagination,
  Loading,
  Button,
  Message,
  MessageBox,
  Dialog,
  Upload,
  Form,
  FormItem,
  Input,
  Select,
  Option,
  DatePicker,
  Card,
  Notification,
} from 'element-ui';
import 'element-ui/lib/theme-chalk/index.css';
[
  Table,
  TableColumn,
  Pagination,
  Button,
  Message,
  Dialog,
  Upload,
  Form,
  FormItem,
  Input,
  Select,
  Option,
  DatePicker,
  Card,
].forEach((Comp) => {
  Vue.component(Comp.name, Comp);
});
Vue.use(Loading);
Vue.prototype.$message = Message;
Vue.prototype.$prompt = MessageBox.prompt;
Vue.prototype.$confirm = MessageBox.confirm;
Vue.prototype.$notification = Notification;

import dayjs from 'dayjs';
Vue.filter('day', (input) => {
  return dayjs(input).format('YYYY年MM月DD日');
});

import VueClipboard from 'vue-clipboard2';
Vue.use(VueClipboard);

/**
 * Initial App
 */
Vue.config.productionTip = false;

/**
 * Import Global Style
 */
import './assets/global.less';

new Vue({
  router,
  store,
  render: (h) => h(App),
}).$mount('#app');
