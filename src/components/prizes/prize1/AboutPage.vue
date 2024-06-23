<template>
    <div>
      <div id='main'>
        <div id="introArea">
          <el-collapse v-model="activeName">
            <el-collapse-item title="Brief" name="1">
              <div>1. One bet is a sequence of 5 characters, all belong to "0123456789abcdef".</div>
              <div>2. Each player can make up to 200 bets per round, can only bet once per round. Each round allows up to 30,000 bets.</div>
              <div>3. When a round ends and draws, will produce a jackpot sequence(5 characters). If someone has bet it, he wins 100 STX.</div>
              <div>4. Each bet costs 0.001 STX</div>
              <div>
                5. View lottery contract <a class="mylink" href="https://explorer.hiro.so/txid/ST1SSKENSBB7EKQZ1Q6GFYQV49E2Q7WMDAXASKVBB.lottery-1?chain=testnet" target="_blank">here</a>;
                View prize contract(owns Grand NFT #1) <a class="mylink" href="https://explorer.hiro.so/txid/ST1SSKENSBB7EKQZ1Q6GFYQV49E2Q7WMDAXASKVBB.lottery-1-prize?chain=testnet" target="_blank">here</a>.
              </div>
            </el-collapse-item>
            <!--  -->
            <el-collapse-item title="How long does a round lasts?" name="2">
              <div>1. A round contains 144 blocks(about 24 hours). For each round, state changes as below: </div>
              <div><span class="stepSpan bold">1. Idle: </span>Wait someone to make at least 5 bets to start the round.</div>
              <div><span class="stepSpan bold">2. Bet duration: </span>124 blocks, anyone can make 1-200 bets.</div>
              <div><span class="stepSpan bold">3. Wait to end bet: </span>6 blocks, can't bet, just wait. Then, anybody can click 'End bet' button to goto next step.</div>
              <div><span class="stepSpan bold">4. Wait to draw: </span>14 blocks, just wait. Then, anybody can click 'Draw' button to draw.</div>
              <div class="stepSpan">If someone wins, nobody can bet anymore; If nobody wins, enter next round and goto step 1.</div>
              </el-collapse-item>
            <!--  -->
            <el-collapse-item title="How to produce jackpot sequence?" name="3">
              <div>Each Stacks block is anchored within a Bitcoin block. When deal the 'End bet' transaction, contract will searches the correspond bitcoin block for the last Stacks block.</div>
              <div>For example: Suppose Stacks block contains 'End bet' transcation is 155,016, contract will searches correspond Bitcoin block for 155,015, which is <a class="mylink" href="https://explorer.hiro.so/block/0xcca8b16ff446dad73f3f5c05f27590603e2c92a666b9886f8077322eaa2c4d94?chain=mainnet" target="_blank">849164</a>(calls End-Bitcoin-block).</div>
              <div>When begin to draw, contract uses the Bitcoin block header hash from (End-Bitcoin-block + 6) to (End-Bitcoin-block + 10), i.e. 849170 - 849174: </div>
              <div class="equalWidth">&nbsp;&nbsp; 000000000000000000030fac7dcf1518e2ce2081ddd3158bb5<span class="targetSpan bold">3</span>6b7dc532760a9 (<a class="mylink" href="https://mempool.space/block/000000000000000000030fac7dcf1518e2ce2081ddd3158bb536b7dc532760a9" target="_blank">849170</a>)</div>
              <div class="equalWidth">&nbsp;&nbsp; 000000000000000000009af7f92899631545c331ddaa76de86<span class="targetSpan bold">4</span>8a55d29b96939 (<a class="mylink" href="https://mempool.space/block/000000000000000000009af7f92899631545c331ddaa76de8648a55d29b96939" target="_blank">849171</a>)</div>
              <div class="equalWidth">&nbsp;&nbsp; 0000000000000000000174a20d6e1b58ffd04d1c2534a7362f<span class="targetSpan bold">0</span>6d08ed5aa9cf8 (<a class="mylink" href="https://mempool.space/block/0000000000000000000174a20d6e1b58ffd04d1c2534a7362f06d08ed5aa9cf8" target="_blank">849172</a>)</div>
              <div class="equalWidth">&nbsp;&nbsp; 00000000000000000000be1fa87653eaa6aa0e2521847bc62c<span class="targetSpan bold">4</span>167aefff3881c (<a class="mylink" href="https://mempool.space/block/00000000000000000000be1fa87653eaa6aa0e2521847bc62c4167aefff3881c" target="_blank">849173</a>)</div>
              <div class="equalWidth">&nbsp;&nbsp; 00000000000000000001e2de41673e6c2df405abe09d079c0b<span class="targetSpan bold">f</span>f045621730c6e (<a class="mylink" href="https://mempool.space/block/00000000000000000001e2de41673e6c2df405abe09d079c0bff045621730c6e" target="_blank">849174</a>)</div>
              Combine each of the 51th character, so jackpot sequence is <span class="targetSpan bold">3404f</span>.
            </el-collapse-item>
            <!--  -->
            <el-collapse-item title="How can winner claim rewards?" name="4">
              <div>1. If there's only 1 winner, he can transfer it directly in the "Winner" tab.</div>
              <div>2. If more thant 1 players bet the jackpot sequence, the first 3(or 2) players are all winners, they can vote in the "Winner" tab to transfer it.</div>
            </el-collapse-item>
          </el-collapse>
        </div>
      </div>
    </div>
  </template>

  <script>
  export default {
    name: 'WinnerPage',
    components: {
    },
    data () {
      return {
        activeName: '1',
      }
    },
    // async mounted() {

    // },
    methods: {
    }
  }

  </script>

  <!-- Add "scoped" attribute to limit CSS to this component only -->
<style scoped>
#main {
  margin: 8px;
  text-align: left;
  min-height: 400px;
}
.equalWidth {
  font-family: monospace, Courier, "Courier New", Consolas;
}
.mylink {
  text-decoration: underline;
  color: black;
}
.bold {
  font-weight: bold;
}
.targetSpan {
  color:#00f;
}
.stepSpan {
  margin-left: 16px;
}

</style>
