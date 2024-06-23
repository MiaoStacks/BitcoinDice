<template>
  <div>
    <div id='main'>
      <div id="summaryArea">
        <div id="summaryDiv">
          <span class="summaryTitle">Round: </span>
          <span>{{ round == 0 ? '' : round }}</span>
          <span :style='{margin: marginGap}'>&nbsp;</span>
          <span class="summaryTitle">State: </span>
          <el-button class="summaryBtn" :disabled="bSendEndBet" v-if="bCanEndBet" size="small" plain type="primary" @click="onClickEndBet">End bet</el-button>
          <el-button class="summaryBtn" :disabled="bSendDraw" v-if="bCanDraw" size="small" plain type="primary" @click="onClickDraw">Draw</el-button>
          <span v-if="!bCanDraw && !bCanEndBet" id="summaryRound">{{ stateStr }}</span>
          <span :style='{margin: marginGap}'>&nbsp;</span>
          <span class="summaryTitle">Total bets: </span>
          <span>{{ round == 0 ? '' : totalBetCount }}</span>
        </div>
      </div>

      <div id="reqLoading" v-if="round==0" v-loading='bInitialReq'></div>

      <div id='horArea' v-if="round>0">
        <el-card class="pickArea">
          <div slot="header" class="clearfix">
            <span>Select 5 characters</span>
            <el-button id="instantBtn" size="small" plain type="primary" :disabled="state <= 0 || state > 2 || bCanEndBet || alreadyBet() || orderList.length>=maxOrderCount" @click="onClickInstantPick">Bulk bet</el-button>
          </div>
          <div>
            <el-button class="hexBtn" v-for="index in hexList.length" :key="index" type="primary" :disabled="alreadyBet() || orderList.length>=maxOrderCount" @click="onClickCharacter($event, index)">{{ hexList[index-1] }}</el-button>
          </div>
          <div id="pickPendingArea">
            <span class="equalWidth">{{ pendingChs }}</span>
            <el-button v-if="pendingChs.length > 0" id="pendingBackBtn" size="mini" icon="el-icon-back" circle @click="onClickPickPendingBackBtn"></el-button>
            <span class="cannotPickTip" v-if="!alreadyBet() && orderList.length>=maxOrderCount">Max {{ maxOrderCount }} bets per round.</span>
            <span class="cannotPickTip" v-if="alreadyBet()">Already bet in current round.</span>
          </div>
        </el-card>

        <div class='betArrowArea'>
          <i class="el-icon-d-arrow-right"></i>
        </div>

        <el-card id="orderArea">
          <div slot="header">
            <span>Count: {{orderList.length}}</span>
            <el-button class='betbtn' plain type="primary" size="small" :disabled="(state!=1&&state!=2)||historyBetList.length>0" :style='{visibility:orderList.length>0 ? "visible": "hidden"}' @click="onClickBet()">
              Bet ({{ config.stxPrice*orderList.length/1000000 + ' STX' }})
            </el-button>
          </div>
          <el-table
            :data="orderList"
            empty-text='Empty'
            :max-height="maxOrderListHeight"
            size="small">
            <el-table-column
              type="index"
              width="45">
            </el-table-column>
            <el-table-column
              label="Sequence"
              sortable
              :sort-method=chsCmp
              width="190">
              <template slot-scope="scope">
                <span class="orderChs equalWidth" :style="{color:scope.row.bDup?'#f00':'#000'}">{{ scope.row.chs + (scope.row.bDup ? '(dupl)' : '') }}</span>
              </template>
            </el-table-column>
            <el-table-column label="Delete">
              <template slot-scope="scope">
                <el-button size="mini" type="info" icon="el-icon-delete" circle @click="handleDelete(scope.$index, scope.row)"></el-button>
              </template>
            </el-table-column>
          </el-table>
        </el-card>

        <el-card id="historyArea" v-if="historyBetList.length>0">
          <div slot="header">
            <span>My bets: {{ historyBetList.length }}</span>
            <el-button class='betbtn' plain type="primary" size="small" :style='{visibility:"hidden"}'>
              &nbsp;
            </el-button>
          </div>
          <el-table
            :data="historyBetList"
            empty-text='Empty'
            :max-height="maxOrderListHeight"
            :show-header	= 'false'
            size="small">
            <el-table-column
              type="index"
              width="45">
            </el-table-column>
            <el-table-column
              label="">
              <template slot-scope="scope">
                <span class="orderChs equalWidth">{{ scope.row.chs }}</span>
              </template>
            </el-table-column>
            <!-- <el-table-column label="Status">
              <template slot-scope="scope">
                <i :class='scope.row.bConfirmed ? "el-icon-check" : "el-icon-loading"' style="margin-left:12px"></i>
              </template>
            </el-table-column> -->
          </el-table>
        </el-card>
      </div>
    </div>
    <div id="belowTip" v-if="round>0">
      0.001 STX/Bet
    </div>

    <!-- Bulk add dialog -->
    <el-dialog title="How many bets to add?" :visible.sync="bInstantPickVisible" width='400px'>
      <div>
        <el-input-number v-model="instantPickCount" :step="instantPickStep" :min='0' :max='instantPickMaxCount'></el-input-number>
        <span id="bulkAddPrice">({{ config.stxPrice*instantPickCount/1000000 + ' STX' }})</span>
        <div id="bulkAddTip">* Won't generate duplicate bets.</div>
      </div>
      <div slot="footer" class="dialog-footer">
        <el-button @click="bInstantPickVisible = false">Cancel</el-button>
        <el-button type="primary" @click="handleInstantPick">Pick</el-button>
      </div>
    </el-dialog>
    <!-- Input bitcoin block height dialog -->
    <el-dialog title="End bet" :visible.sync="bInputBtcHeightVisible" width='400px'>
      <div>
        <div style="margin-bottom:8px">Input latest bitcoin block height:</div>
        <el-input placeholder="Latest block height" v-model="latestBtcHeight" maxlength="8" size="large" clearable></el-input>
        <div id="btcHeightTip">
          View latest block height
          <a class="mylink" href="https://mempool.space/blocks" target="_blank">here</a>
          or
          <a class="mylink" href="https://blockstream.info/blocks/recent" target="_blank">here</a>
          , wrong number will lead to transaction fail.
        </div>
      </div>
      <div slot="footer" class="dialog-footer">
        <el-button @click="bInputBtcHeightVisible = false">Cancel</el-button>
        <el-button type="primary" @click="onSelectBtcHeightOk()">Ok</el-button>
      </div>
    </el-dialog>
  </div>
</template>

<script>
import { session, getAddress, network, getContracts, signIn } from '../../../utils/auth'
import { tipError } from '../../../utils/utils'
import { callReadOnlyFunction, listCV, makeContractNonFungiblePostCondition, createAssetInfo, contractPrincipalCV, FungibleConditionCode, NonFungibleConditionCode, makeStandardSTXPostCondition, makeStandardNonFungiblePostCondition, makeContractSTXPostCondition, noneCV, cvToValue, stringAsciiCV, bufferCVFromString, tupleCV,  uintCV, trueCV, falseCV, someCV, standardPrincipalCV, makeStandardFungiblePostCondition } from '@stacks/transactions'
import { openContractCall } from '@stacks/connect';
import router from '../../../router';
import { type } from 'os';
import BigNumCC from 'bn.js';

const { contractAddress, lotteryContractName }  = getContracts();
const senderAddress = contractAddress;

export default {
  name: 'BetPage',
  components: {
  },
  data () {
    return {
      bSignedIn: session.isUserSignedIn(),
      subMenu: '',
      /// Same as contract
      config: {
        stxPrice: 1000,
        minBetCountToStartRound: 5,
        maxBetPerRound: 30000,
        betBlocks: 124,
        waitToEndBetBlocks: 6,
        waitToDrawBlocks: 14,
      },
      ///
      bInitialReq: false,
      round: 0,
      state: 1, // 1 = idle, 2 = bet, 3 = wait-draw, 4 = has-winner, 5 = freezed
      stateStr: '',
      bCanEndBet: false,
      bCanDraw: false,
      totalBetCount: 0,
      curStxHeight: 0,
      startAtStxHeight: 0,
      endAtStxHeight: 0,
      endAtBtcHeight: 0,
      stxBalance: 0,
      timeHandle: null,
      maxOrderListHeight: 520,
      hexList: ['0','1','2','3','4','5','6','7','8','9','a','b','c','d','e','f'],
      marginGap: "auto 40px",
      /// pick card
      pendingChs: '',
      bInstantPickVisible: false,
      instantPickCount: 200,
      instantPickStep: 0,
      instantPickMaxCount: 0,
      /// order card
      bExpandOrderList: false,
      maxOrderCount: 200,
      orderList: [
        // {
        //   chs: 'aaaaa',
        //   bDup: false,
        // },
      ],
      bInputBtcHeightVisible: false,
      latestBtcHeight: '',
      /// History card
      bJustBet: false,
      historyBetList: [
        // {
        //   chs: 'aaaaa',
        // }
      ],
      /// draw
      bSendEndBet: false,
      bSendDraw: false,
    }
  },
  async mounted() {
    this.bInitialReq = true
    await this.requestSummary()
    this.bInitialReq = false
  },
  methods: {
    alreadyBet() {
      return this.bJustBet || this.historyBetList.length > 0
    },
    ///
    async requestSummary() {
      const functionName = this.bSignedIn ? 'get-summary-with-user' : 'get-summary'
      const functionArgs = this.bSignedIn ? [ standardPrincipalCV(getAddress()) ] : []
      const options = {
        contractAddress,
        contractName: lotteryContractName,
        functionName,
        functionArgs,
        network,
        senderAddress,
      };

      const summaryRsp = await callReadOnlyFunction(options);
      let serverData = cvToValue(summaryRsp)
      // console.log('___serverData: ', serverData)
      const baseData = this.bSignedIn ? serverData.base.value : serverData
      this.round = baseData.round.value
      this.state = baseData.state.value
      this.totalBetCount = baseData['bet-count'].value
      this.curStxHeight = baseData.bh.value
      this.startAtStxHeight = baseData['start-at'].value
      this.endAtStxHeight = baseData['end-at'].value
      this.endAtBtcHeight = baseData['end-at-btc'].value
      if (this.bSignedIn) {
        this.stxBalance = serverData.stx.value
        if (!serverData['user-bet'].type.includes('none')) {
          this.historyBetList.splice(0, this.historyBetList.length)
          for (let v of serverData['user-bet'].value.value) {
            this.historyBetList.push({
              chs: v.value,
            })
          }
        }
      }
      /// parse state str
      this.dealDrawState()
      ///
      if (this.timeHandle) {
        clearInterval(this.timeHandle)
      }
      this.timeHandle = setTimeout(this.requestSummary, 20000) // 20 seconds
    },
    dealDrawState() {
      this.bCanEndBet = false
      this.bCanDraw = false
      if (this.state == 1) {  // Idle
        this.stateStr = `Make at least ${ this.config.minBetCountToStartRound } bets to start the round`
        this.marginGap = "auto 27px"
      } else if (this.state == 2) { // Bet
        let remainBetBlocks = this.startAtStxHeight + this.config.betBlocks - this.curStxHeight
        if (remainBetBlocks > 0) {
          this.stateStr = `Bet available (remain ${remainBetBlocks} blocks)`
          this.marginGap = "auto 20px"
        } else {
          const waitToEndBetBlocks = this.startAtStxHeight + this.config.betBlocks + this.config.waitToEndBetBlocks - this.curStxHeight
          if (waitToEndBetBlocks > 0) {
            this.stateStr = `Wait to end bet (remain ${waitToEndBetBlocks} blocks)`
            this.marginGap = "auto 20px"
          } else {
            this.bCanEndBet = true
            this.marginGap = "auto 30px"
          }
        }
      } else if (this.state == 3) { // Wait to draw
        let remainBlocks = this.endAtStxHeight + this.config.waitToDrawBlocks - this.curStxHeight
        if (remainBlocks > 0) {
          this.stateStr = `Wait to draw (remain ${remainBlocks} blocks)`
          this.marginGap = "auto 20px"
        } else {
          this.stateStr = `Draw available`
          this.marginGap = "auto 38px"
          this.bCanDraw = true
        }
      } else {
        this.stateStr = 'Freezed'
        this.marginGap = "auto 66px"
      }
    },
    /// Pick area //////////////////////////////////////////////////////////////////
    onClickInstantPick() {
      if (!this.bSignedIn) {
        signIn()
        return
      }
      if (this.orderList.length >= this.maxOrderCount) {
        tipError(this, `Max ${this.maxOrderCount} bets per round`);
        return
      }
      this.instantPickMaxCount = Math.max(0, this.maxOrderCount - this.orderList.length)
      if (this.instantPickMaxCount > 0 && this.instantPickMaxCount < 10) {
        this.instantPickStep = 1
        this.instantPickCount = 1
      } else {
        this.instantPickStep = 10
        this.instantPickCount = 10
      }
      this.bInstantPickVisible = true
    },
    chsCmp(a, b) {
      if (a.chs != b.chs) {
        return a.chs < b.chs ? -1 : 1
      }
      return 0
    },
    onClickCharacter(event, index) {
      if (!this.bSignedIn) {
        signIn()
        return
      }
      if (this.pendingChs.length >= 5) {
        return
      }
      let ch = this.hexList[index - 1]
      this.pendingChs = this.pendingChs + ch
      if (this.pendingChs.length == 5) {
        if (this.orderList.length < this.maxOrderCount) {
          this.orderList.unshift({ chs: this.pendingChs })
          this.pendingChs = ''
          this.checkDuplicateBets()
        } else {
          tipError(this, `Max ${this.maxOrderCount} bets per round`);
        }
      }
    },
    onClickPickPendingBackBtn() {
      if (this.pendingChs.length > 0) {
        this.pendingChs = this.pendingChs.substring(0, this.pendingChs.length - 1)
      }
    },
    handleInstantPick() {
      this.bInstantPickVisible = false
      let addCount = Math.min(this.instantPickCount, this.maxOrderCount - this.orderList.length)
      if (addCount <= 0) {
        return
      }
      this.pendingChs = ''
      let pickedSet = {}
      for (let v of this.orderList) {
        pickedSet[v.chs] = true
      }
      let resultList = []
      for (let i = 0; i < addCount; i++) {
        let chs = this.genRandom(pickedSet)
        if (chs && chs.length == 5) {
          resultList.push({ chs: chs, bDup: false })
          pickedSet[chs] = true
        }
      }
      this.orderList.unshift(...resultList)
      this.checkDuplicateBets()
    },
    genRandom(pickedSet) {
      for (let i = 0; i < 1000000; i++) {
        const ch1 = Math.floor(Math.random() * 16)
        const ch2 = Math.floor(Math.random() * 16)
        const ch3 = Math.floor(Math.random() * 16)
        const ch4 = Math.floor(Math.random() * 16)
        const ch5 = Math.floor(Math.random() * 16)
        let chs = this.hexList[ch1] + this.hexList[ch2] + this.hexList[ch3] + this.hexList[ch4] + this.hexList[ch5]
        if (!(chs in pickedSet)) {
          return chs
        }
      }
    },
    checkDuplicateBets() {
      let ch2itemDict = {}
      for (let v of this.orderList) {
        if (v.chs in ch2itemDict) {
          v.bDup = true
          ch2itemDict[v.chs].bDup = true
        } else {
          ch2itemDict[v.chs] = v
          v.bDup = false
        }
      }
    },
    /// order area //////////////////////////////////////////////////////////////////
    handleDelete(index, row) {
      this.orderList.splice(index, 1)
      this.checkDuplicateBets()
    },
    async onClickBet() {
      if (!this.bSignedIn) {
        signIn()
        return
      }
      if (this.orderList.length <= 0) {
        return
      }
      if (this.state == 1 && this.orderList.length < this.config.minBetCountToStartRound) {
        tipError(this, 'Need at least 5 bets to start the round')
        return
      }
      if (this.totalBetCount >= this.maxBetPerRound) {
        tipError(this, 'Each round allows at most 30,000 bets')
        return
      }
      if (this.totalBetCount + this.orderList.length > this.maxBetPerRound) {
        tipError(this, "Each round allows at most 30,000 bets, you can only make " + (this.maxBetPerRound - this.totalBetCount) + ' bets')
        return
      }
      if (this.state == 2) {
        let remainBetBlocks = this.startAtStxHeight + this.config.betBlocks - this.curStxHeight
        if (remainBetBlocks < 0) {
          tipError(this, 'Cannot bet any more')
          return
        }
      }
      for (let v of this.orderList) {
        if (v.bDup) {
          tipError(this, 'Have duplicate bets')
          return
        }
      }
      ///
      const loading = this.createLoading('checking');
      await this.requestSummary()
      loading.close()
      if (this.historyBetList.length > 0) {
        return
      }
      let stxPrice = this.orderList.length * this.config.stxPrice
      // console.log('___prices', {
      //   stxPrice: stxPrice,
      //   mineStx: this.stxBalance,
      // })
      if (this.stxBalance <= stxPrice) {
        tipError(this, 'STX balance unenough')
        return
      }
      let ll = listCV()
      ll.list = []
      for (let v of this.orderList) {
        ll.list.push(stringAsciiCV(v.chs))
      }
      const functionArgs = [
        ll,
      ]

      const standardSTXPostCondition = makeStandardSTXPostCondition(
        getAddress(),
        FungibleConditionCode.LessEqual,
        new BigNumCC(stxPrice),
      )

      let outThis = this
      const options = {
        contractAddress,
        contractName: lotteryContractName,
        functionName: 'bet',
        functionArgs,
        network,
        postConditions: [standardSTXPostCondition],
        onFinish: data => {
          // outThis.doNotify('Bet')
          outThis.bJustBet = true
          outThis.$alert("Transaction has been sent! Each address can only bet once per round, don't bet again in this round. Good luck!", {
            confirmButtonText: 'Ok',
            type: 'info',
          });
        },
      };
      openContractCall(options)
    },
    /// End bet
    onClickEndBet() {
      if (!this.bSignedIn) {
        signIn()
        return
      }

      this.bInputBtcHeightVisible = true
    },
    onSelectBtcHeightOk() {
      let btcHeight = parseInt(this.latestBtcHeight)
      if (!btcHeight || btcHeight <= 791000) {
        tipError(this, 'Invalid bitcoin block height')
        return
      }
      this.bInputBtcHeightVisible = false

      let outThis = this
      const options = {
        contractAddress,
        contractName: lotteryContractName,
        functionName: 'end-bet',
        functionArgs: [uintCV(btcHeight)],
        network,
        postConditions: [],
        onFinish: data => {
          outThis.bSendEndBet = true
          outThis.doNotify('End bet')
        },
      };
      openContractCall(options)
    },
    /// draw
    onClickDraw() {
      if (!this.bSignedIn) {
        signIn()
        return
      }

      let outThis = this
      const options = {
        contractAddress,
        contractName: lotteryContractName,
        functionName: 'draw',
        functionArgs: [],
        network,
        postConditions: [],
        onFinish: data => {
          outThis.bSendDraw = true
          outThis.doNotify('Draw')
        },
      };
      openContractCall(options)
    },
    /// common
    createLoading(tips) {
      return this.$loading({
        lock: true,
        text: tips,
        spinner: 'el-icon-loading',
        background: 'rgba(0, 0, 0, 0.05)'
      });
    },
    doNotify(title) {
      this.$notify({
        title: title,
        message: 'Transaction has been sent, wait a while to be finished.',
        duration: 8000,
      });
    },
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
.title {
  font-size: 26px;
  text-align: center;
  color: #333;
  /* text-shadow: #FC0 1px 0 10px; */
}
#summaryArea {
  width: 800px;
  height: 52px;
  margin: 20px auto auto auto;
  border-radius: 30px;
  box-shadow: 0 2px 12px 0 rgba(0, 0, 0, 0.3);
}
#summaryDiv {
  padding-top: 12px;
  text-align: center;
  font-size: 25px;
}
.summaryTitle {
  color: #666;
}
.summaryBtn {
  vertical-align: middle;
}
#summaryRound {
  font-size: 16px;
  vertical-align: middle;
}
#reqLoading {
  margin-top: 32px;
  min-height: 360px;
}
#horArea {
  margin: 40px auto 20px auto;
  text-align: center;
}
.pickArea {
  display: inline-block;
  width: 310px;
  height: 610px;
  text-align: left;
  vertical-align: top;
}
#instantBtn {
  margin-left: 36px;
  font-size: 14px;
}
#bulkAddPrice {
  margin-left: 8px;
  font-size: 14px;
}
#bulkAddTip {
  margin-top: 8px;
  font-size: 13px;
}
.hexBtn {
  margin: 3px;
  width: 60px;
  height: 60px;
  font-size: 35px;
}
#pickPendingArea {
  text-align: center;
  margin-top: 32px;
  font-size: 20px;
}
.equalWidth {
  font-family: monospace, Courier, "Courier New", Consolas;
}
#pendingBackBtn {
  margin-left: 8px;
}
.cannotPickTip {
  font-size: 16px;
  color: #666;
}
.betArrowArea {
  display: inline-block;
  vertical-align: top;
  margin-top: 200px;
  margin: 216px 32px auto 32px;
}
#orderArea {
  display: inline-block;
  width: 375px;
  height: 610px;
  text-align: left;
  vertical-align: top;
}
.betbtn {
  margin-left: 16px;
  font-size: 14px;
}
.orderChs {
  font-size: 20px;
}
#btcHeightTip {
  margin-top: 8px;
  font-size: 15px;
}
.mylink {
  text-decoration: underline;
  color: black;
}

#historyArea {
  display: inline-block;
  width: 350px;
  height: 610px;
  text-align: left;
  vertical-align: top;
  margin-left: 96px;
}
#introArea {
  margin-top: 100px;
}
#belowTip {
  margin: 8px auto;
  text-align: center;
  font-size: 12px;
}

</style>
