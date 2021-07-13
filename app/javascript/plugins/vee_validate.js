import Vue from 'vue'
import { ValidationProvider, ValidationObserver, extend } from 'vee-validate';
import { email, required, image } from 'vee-validate/dist/rules';

Vue.component('ValidationProvider', ValidationProvider);
Vue.component('ValidationObserver', ValidationObserver);

extend('email', {
  ...email,
  message: '{_field_}の形式で入力してください'
});

extend('required', {
  ...required,
  message: '{_field_}は必須項目です'
});

extend('image', {
  ...image,
  message: '{_field_}は画像形式で入力してください'
});

extend('min', {
  validate(value, { length }) {
    return value.length >= length;
  },
  params: ['length'],
  message: '{_field_}は{length}文字以上で入力してください'
});

extend('max', {
  validate(value, { length }) {
    return value.length <= length;
  },
  params: ['length'],
  message: '{_field_}は{length}文字以下で入力してください'
});

extend('confirmed', {
  params: ['target'],
  validate(value, { target }) {
    return value === target;
  },
  message: 'パスワードと一致しません'
});
