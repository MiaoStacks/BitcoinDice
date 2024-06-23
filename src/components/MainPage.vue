<template>
  <div>
    <div id='main'>
      <el-tabs v-model="subMenu" :before-leave="handleTabChange">
        <el-tab-pane label="Prize 1" name="/prize1/bet">
        </el-tab-pane>
        <!-- <el-tab-pane name="/prize2/bet">
        </el-tab-pane> -->
      </el-tabs>
      <router-view></router-view>
    </div>
  </div>
</template>

<script>
export default {
  name: 'MainPage',
  components: {
  },
  data () {
    return {
      subMenu: '',
    }
  },
  async mounted() {
    this.safeSetSubMenu()
  },
  watch: {
    '$route': 'safeSetSubMenu'
  },
  methods: {
    handleTabChange: function(newVal) {
      if (newVal && newVal != 0) {
        this.$router.push({path:newVal})
      }
    },
    safeSetSubMenu() {
      const p = this.$route.path
      if (p == '/') {
        this.subMenu = '/prize1/bet'
      } else if (p.indexOf('prize1/') != -1) {
        this.subMenu = p
      } else {
        this.subMenu = '/prize1/bet'
      }
    },
  }
}

</script>

<!-- Add "scoped" attribute to limit CSS to this component only -->
<style scoped>
#main {
  margin: 92px 128px 32px 128px;
  /* text-align: center; */
  min-height: 400px;
}
.tabDiv {
  font-size: 18px;
}
</style>
