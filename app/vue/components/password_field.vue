<script>
  // https://github.com/apertureless/vue-password-strength-meter

  import Password from 'vue-password-strength-meter'
  export default {
    components: { Password },
    data: function() {
      return {
        password: null,
        secureLength: 12,
        badge: false
      }
    },
    props: ['name', 'placeholder', 'css_class']
  }
</script>

<template>
  <password v-model="password" :name="name" :placeholder="placeholder" :defaultClass="css_class" :secureLength="secureLength" :badge="badge"></password>
</template>

<style lang="sass">
  .Password
    max-width: initial !important

</style>