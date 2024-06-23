<template>
  <div id="app">
    <MenuBar menu="none" redirectFlag=0></MenuBar>
    <router-view/>
  </div>
</template>

<script>
export default {
  name: 'App',
  components: {
  },
}
</script>

<style>
#app {
  font-family: 'Barlow', 'Arial', sans-serif;
  font-size: 16px;
  margin: 0;
}
</style>
