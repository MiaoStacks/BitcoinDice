<template>
  <div id='header'>
    <el-row type="flex" align="middle">
      <el-col :span="7">&nbsp;</el-col>
      <el-col :span="4">
        <img id='logo' src="../assets/logo.png" />
        <span id='title'>Bitcoin dice</span>
      </el-col>
      <el-col :span="6">
        <router-link class='menu' to="/prize1/bet" replace>Lottery</router-link>
        <router-link class='menu' to="/about" replace>About</router-link>
        <el-button type="primary" round @click="onClickLoginIn" v-if='!bSignedIn'>Sign in</el-button>
        <el-button type="info" round @click="onClickLoginOut" v-if='bSignedIn'>Sign out</el-button>
      </el-col>
      <el-col :span="7">&nbsp;</el-col>
    </el-row>
  </div>
</template>

<script>
import router from '../router'
import { session, signIn, signOut } from '../utils/auth'

export default {
  name: 'MenuBar',
  data () {
    return {
      bSignedIn: session.isUserSignedIn(),
    }
  },
  props: ['menu', 'redirectFlag'],
  async mounted() {
    // pass
  },
  watch: {
    '$route': 'onChangeRoute'
  },
  methods: {
    onChangeRoute() {
      this.menu = this.$route.path
    },
    onClickLoginIn() {
      signIn()
    },
    onClickLoginOut() {
      signOut()
    }
  },
}

</script>

<!-- Add "scoped" attribute to limit CSS to this component only -->
<style scoped>
#header {
  width: 100%;
  height: 70px;
  position: fixed;
  top: 0;
  background: white;
  border-bottom: 1px solid #eee;
  z-index: 100;
}
#logo {
  width: 60px;
  height: 60px;
}
#title {
  display: inline-block;
  font-size: 26px;
  margin-left: 4px;
  color: black;
  margin-top: 16px;
  vertical-align: top;
}
.menu {
  font-weight: bold;
  font-size: 20px;
  color: #666;
  margin-right: 32px;
  text-decoration: none;
  display: inline-block;
  margin-top: 10px;
}
</style>
