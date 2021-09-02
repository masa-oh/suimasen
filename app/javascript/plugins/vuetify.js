import Vue from 'vue';
import Vuetify from 'vuetify';
import colors from 'vuetify/lib/util/colors';
import 'vuetify/dist/vuetify.min.css';

Vue.use(Vuetify)

export default new Vuetify({
  theme: {
    themes: {
      light: {
        primary: "#126E82",
        secondary: "#D8E3E7",
        //accent: colors.shades.black,
        //error: colors.red.accent3,
        background: "#D8E3E7"
      },
      dark: {
        primary: colors.blue.lighten3,
      },
    }
  }
})
