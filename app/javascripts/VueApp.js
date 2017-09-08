// Make sure to run `bin/pack` after changing this file.
// Or keep `bin/webpack-dev-server` running.
// Otherwise, the changes are not picked up by the asset pipeline.

import Vue from 'vue'
import TurbolinksAdapter from 'vue-turbolinks'
import VuePasswordFieldWithStrengthMeter from './VuePasswordFieldWithStrengthMeter.vue'
import Chartkick from 'chartkick' // https://github.com/ankane/vue-chartkick
import VueChartkick from 'vue-chartkick'

Vue.use(TurbolinksAdapter)
Vue.use(VueChartkick, { Chartkick })

document.addEventListener('turbolinks:load', function() {
  Vue.component('vue-password-field-with-strength-meter', VuePasswordFieldWithStrengthMeter)

  var vueApp = new Vue({
    el: '#vue-app'
  })
})
