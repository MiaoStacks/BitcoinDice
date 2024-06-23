<template>
  <div>
    <div id='main'>
      <div class="title">
        <span style="color: #555">Prize 1: </span>Win Grand NFT #1, Bitcoin decides!
      </div>

      <el-tabs id="tab" v-model="subMenu" :before-leave="handleTabChange">
        <el-tab-pane name="/prize1/bet">
          <div class="tabDiv" slot="label">Bet</div>
        </el-tab-pane>
        <el-tab-pane name="/prize1/history">
          <div class="tabDiv" slot="label">History</div>
        </el-tab-pane>
        <el-tab-pane name="/prize1/winner">
          <div class="tabDiv" slot="label">Winner</div>
        </el-tab-pane>
        <el-tab-pane name="/prize1/about">
          <div class="tabDiv" slot="label">About</div>
        </el-tab-pane>
        <router-view></router-view>
      </el-tabs>
    </div>
  </div>
</template>

<script>
export default {
  name: 'IndexPage',
  components: {
  },
  data () {
    return {
      subMenu: '',
    }
  },
  async mounted() {
    this.subMenu = this.$route.path
  },
  watch: {
    '$route': 'onChangeRoute'
  },
  methods: {
    handleTabChange: function(newVal) {
      if (newVal && newVal != 0) {
        this.$router.push({path:newVal})
      }
    },
    onChangeRoute() {
      this.subMenu = this.$route.path
    },
  }
}

</script>

<!-- Add "scoped" attribute to limit CSS to this component only -->
<style scoped>
#main {
  margin: 25px 128px 32px 128px;
  text-align: left;
  min-height: 400px;
}
.title {
  font-size: 26px;
  text-align: center;
  color: #333;
  margin-bottom: 32px;
  /* text-shadow: #FC0 1px 0 10px; */
}
#tab {
  min-height: 830px;
}
</style>
