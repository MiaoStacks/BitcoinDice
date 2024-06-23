<template>
  <div>
    <div id='main'>
      <div>
        <span id="roundTip">Round:&nbsp;</span>
        <el-input-number id="round" v-model="curRound" @change="onChangeRound" :min="1" :max="maxRound" :disabled="bLatestInReq || bInReqHistory" size="large"></el-input-number>
        <span id="titleGap"></span>
      </div>

      <el-descriptions id="summaryArea" :column="3" border v-loading="bLatestInReq || bInReqHistory">
        <el-descriptions-item>
          <template slot="label">
            <!-- <i class="el-icon-user"></i> -->
            <span style="white-space: nowrap;">Start block</span>
          </template>
          <span style="white-space: nowrap; padding-left:8px;padding-right: 8px;">{{ curRoundInfo.startAtStx > 0 ? ' ' + curRoundInfo.startAtStx + ' ' : 'Wait bet to start' }}</span>

        </el-descriptions-item>
        <el-descriptions-item>
          <template slot="label">
            <!-- <i class="el-icon-mobile-phone"></i> -->
            <span style="white-space: nowrap;">End block</span>
          </template>
          <span style="white-space: nowrap;">{{ curRoundInfo.endAtStx > 0 ? curRoundInfo.endAtStx : '-' }}</span>
        </el-descriptions-item>
        <el-descriptions-item>
          <template slot="label">
            <span style="white-space: nowrap;">End Bitcoin block</span>
          </template>
          <span style="white-space: nowrap;">{{ curRoundInfo.endAtBtc > 0 ? curRoundInfo.endAtBtc : '-' }}</span>
        </el-descriptions-item>

        <el-descriptions-item :span="3">
          <template slot="label">
            <span style="white-space: nowrap;">Jackpot</span>
          </template>
          <div id="jackpotArea" v-if="curRoundInfo.hashList.length>0">
            <div class="equalWidth" v-for="index of curRoundInfo.hashList.length" :key="index">
              {{curRoundInfo.hashList[index-1].substr(0, 50)}}<span class="bold">{{curRoundInfo.hashList[index-1].substr(50, 1)}}</span>{{curRoundInfo.hashList[index-1].substr(51, 13)}}(<a class="mylink" :href="'https://mempool.space/block/'+curRoundInfo.hashList[index-1]" target="_blank">{{curRoundInfo.endAtBtc+5+index}}</a>)
            </div>
            <div>Result: <span class="equalWidth bold result">{{ curRoundInfo.jackpot }}</span></div>
          </div>
          <div v-else>
            -
          </div>
        </el-descriptions-item>

        <el-descriptions-item>
          <template slot="label">
            <span style="white-space: nowrap;">Total bets</span>
          </template>
          <span style="white-space: nowrap; padding-left:8px;padding-right: 8px;">{{ curRoundInfo.totalBetCount }}</span>
        </el-descriptions-item>

        <el-descriptions-item>
          <template slot="label">
            <span style="white-space: nowrap;">Winner{{ curRoundInfo.winners.length > 1 ? 's' : '' }}</span>
          </template>
          {{ curRoundInfo.winners.length > 0 ? curRoundInfo.winners.join('\n') : (this.curRound < this.latestRoundInfo.round ? 'None' : '-') }}
        </el-descriptions-item>
      </el-descriptions>

      <div id='horArea'>
        <!-- All -->
        <el-card id="allArea" v-loading = "bInReqHistory">  <!-- :body-style="{padding:'2px'}" -->
          <div slot="header">
            <div>All bets: {{ curRoundInfo.totalBetCount }}</div>
            <el-pagination
              id='pagetool'
              @current-change="onChangePage"
              :page-size="200"
              layout="prev, pager, next"
              hide-on-single-page
              :current-page.sync='curPage'
              :total="curRoundInfo.totalBetCount">
            </el-pagination>
          </div>
          <!-- <div v-if="curRound==maxRound" id='emptyOrder'>Not finish draw yet.</div> -->
          <!-- v-if="curRound<maxRound" -->
          <el-table
            :data="allBetList"
            empty-text='Empty'
            v-loading = "bInReqAllBetPage"
            :max-height="curRoundInfo.totalBetCount > 200 ? 548 : 595">
            <!-- <el-table-column
              type="index"
              width="45">
            </el-table-column> -->

            <el-table-column label="" width="60">
              <template slot-scope="scope">
                {{ (curPage-1)*200 + scope.$index + 1 }}
              </template>
            </el-table-column>

            <el-table-column label="Address" width="150">
              <template slot-scope="scope">
                <el-link :href="'https://explorer.hiro.so/address/'+scope.row.addr+'?chain=testnet'" target="_blank" :style="{color:'black',fontWeight:(scope.row.bSelf?'bold':'normal')}">{{ scope.row.brAddr + (scope.row.bSelf?'(me)' : '') }}</el-link>
              </template>
            </el-table-column>
            <el-table-column
              label="Sequence">
              <template slot-scope="scope">
                <span class="seq equalWidth">
                  <span v-for="index of scope.row.hits.length" :key="index" :class='scope.row.hits[index-1]?"bold":""'>{{ scope.row.chs[index-1] }}</span>
                </span>
              </template>
            </el-table-column>
          </el-table>
        </el-card>

        <!-- Mine -->
        <el-card id="mineArea" v-if="bSignedIn" v-loading="bInReqHistory">
          <div slot="header">
            <span>My bets: {{ myBetList.length }}</span>
            <el-button class='betbtn' plain type="primary" size="small" :style='{visibility:"hidden"}'>
              &nbsp;
            </el-button>
          </div>
          <el-table
            :data="myBetList"
            empty-text='Empty'
            :max-height="580"
            :show-header	= 'false'
            size="small">
            <el-table-column
              type="index"
              width="45">
            </el-table-column>
            <el-table-column>
              <template slot-scope="scope">
                <span class="seq equalWidth">
                  <span v-for="index of scope.row.hits.length" :key="index" :class='scope.row.hits[index-1]?"bold":""'>{{ scope.row.chs[index-1] }}</span>
                </span>
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
  </div>
</template>

<script>
  import { session, getAddress, network, getContracts, signIn } from '../../../utils/auth'
  import { callReadOnlyFunction, cvToValue, uintCV, standardPrincipalCV } from '@stacks/transactions'

  const { contractAddress, lotteryContractName }  = getContracts();
  const senderAddress = contractAddress;

  export default {
    name: 'HistoryPage',
    components: {
    },
    data () {
      return {
        bSignedIn: session.isUserSignedIn(),
        ///
        bLatestInReq: false,
        latestRoundInfo: {
          round: 0,
          state: 0,
          totalBetCount: 0,
          startAtStx: 0,
          endAtStx: 0,
          endAtBtc: 0,
        },
        /// History ////////////////////////
        bHasReqHistory: false,
        bInReqHistory: false,
        curRound: 1,
        maxRound: 1000000,
        curPage: 1,
        bHistoryHasInfo: false,
        // maxAllBetTableHeight: 540,
        bInReqAllBetPage: false,
        betCountPerPage: 25,
        curRoundInfo: {
          startAtStx: 0,
          endAtStx: 0,
          endAtBtc: 0,
          jackpot: '',
          totalBetCount: 0,
          hashList: [
            // '00000000000000000002f45a2aba5d821ce8aad5513960d86e31f786f13bb8c9',
            // '00000000000000000004240704c7da0c3aaf066d088a2e2d6d628436fe185873',
            // '00000000000000000003d28ccc65e90a6ae4b26082dbdf3abfa9c540796d135d',
            // '00000000000000000003090ca1a457620a856404361427fa2fab2022d156217b',
            // '000000000000000000036223e16716b18e6957c0a1fbc1836fbe6f8c8c2aa85a',
          ],
          winners: [],
        },
        allBetList: [
          // {
          //   bSelf: false,
          //   brAddr: 'ST1S..YPD5',
          //   addr: 'ST1SJ3DTE5DN7X54YDH5D64R3BCB6A2AG2ZQ8YPD5',
          //   chs: 'aaaaa',
          //   hits: [],
          // }
        ],
        /// My bets ////////////////////////
        myBetList: [
          // {
          //   chs: 'bbbbb',
          //   hits: [],
          // }
        ],
        ///
        HITS_NO_LIST: [false, false, false, false, false],
      }
    },
    async mounted() {
      this.requestBaseSummary()
      this.requestHistorySummary(0)
    },
    methods: {
      async requestBaseSummary() {
        this.bLatestInReq = true
        const options = {
          contractAddress,
          contractName: lotteryContractName,
          functionName: 'get-summary',
          functionArgs: [],
          network,
          senderAddress,
        };

        const summaryRsp = await callReadOnlyFunction(options);
        let serverData = cvToValue(summaryRsp)
        // console.log('___requestBaseSummary: ', serverData)
        this.latestRoundInfo = {
          round: serverData.round.value,
          state: serverData.state.value,
          totalBetCount: serverData['bet-count'].value,
          startAtStx: serverData['start-at'].value,
          endAtStx: serverData['end-at'].value,
          endAtBtc: serverData['end-at-btc'].value,
        }
        this.bLatestInReq = false
        this.maxRound = this.latestRoundInfo.round
        this.combineLatestQueries()
      },
      async requestHistorySummary(round) {
        this.bInReqHistory = true
        const functionName = this.bSignedIn ? 'get-history-with-user' : 'get-history'
        const functionArgs = this.bSignedIn ? [ uintCV(round), standardPrincipalCV(getAddress()) ] : [uintCV(round)]
        const options = {
          contractAddress,
          contractName: lotteryContractName,
          functionName,
          functionArgs,
          network,
          senderAddress,
        };
        const rawServerData = await callReadOnlyFunction(options);
        // console.log('___rawServerData: ', rawServerData)

        let values = {
          round: 0,
          bHasInfo: false,
          startAtStx: 0,
          endAtStx: 0,
          endAtBtc: 0,
          jackpot: '',
          totalBetCount: 0,
          hashes: [],
          winners: [],
        }

        let rawBase = this.bSignedIn ? rawServerData.data.base : rawServerData
        values.round = cvToValue(rawBase.data.t)
        if (rawBase.data.v.type == 9) {
          values.bHasInfo = false
        } else {
          values.bHasInfo = true
          const vv = rawBase.data.v.value.data
          values.startAtStx = cvToValue(vv['start-at-stx'])
          values.endAtStx = cvToValue(vv['end-at-stx'])
          values.endAtBtc = cvToValue(vv['end-at-btc'])
          values.jackpot = cvToValue(vv.jackpot)
          values.totalBetCount = cvToValue(vv['bet-count'])
          let tmpHashValue = cvToValue(vv.hashes)
          for (let v of tmpHashValue) {
            values.hashes.push(v.value)
          }
          const tmpWinners = cvToValue(vv.winners)
          for (let v of tmpWinners) {
            values.winners.push(v.value)
          }
        }
        this.curRound = values.round
        this.curRoundInfo.startAtStx = values.startAtStx
        this.curRoundInfo.endAtStx = values.endAtStx
        this.curRoundInfo.endAtBtc = values.endAtBtc
        this.curRoundInfo.jackpot = values.jackpot
        this.curRoundInfo.totalBetCount = values.totalBetCount
        this.curRoundInfo.hashList.splice(0, this.curRoundInfo.hashList.length)
        this.curRoundInfo.hashList = values.hashes.map((el) => { return el.substr(2, 64)})
        this.curRoundInfo.winners.splice(0, this.curRoundInfo.winners.length)
        this.curRoundInfo.winners.push(...values.winners)

        this.bInReqHistory = false
        this.bHasReqHistory = true
        this.bHistoryHasInfo = values.bHasInfo

        if (!this.bHistoryHasInfo) { // Current round
          this.combineLatestQueries()
          if (this.bSignedIn) {
            this.genMyBet(cvToValue(rawServerData.data['user-bet']))
          }
          return
        }
        this.queryCurAllBetPage(1)
        if (this.bSignedIn) {
          this.genMyBet(cvToValue(rawServerData.data['user-bet']))
        }
      },
      combineLatestQueries() {
        if (this.bLatestInReq || !this.bHasReqHistory) {
          return
        }
        if (!this.bHistoryHasInfo && this.curRound == this.latestRoundInfo.round) {
          this.curRoundInfo.startAtStx = this.latestRoundInfo.startAtStx
          this.curRoundInfo.endAtStx = this.latestRoundInfo.endAtStx
          this.curRoundInfo.endAtBtc = this.latestRoundInfo.endAtBtc
          this.curRoundInfo.jackpot = ''
          this.curRoundInfo.totalBetCount = this.latestRoundInfo.totalBetCount
          this.curRoundInfo.hashList.splice(0, this.curRoundInfo.hashList.length)
          this.curRoundInfo.winners.splice(0, this.curRoundInfo.winners.length)
          this.queryCurAllBetPage(1)
        }
      },
      genMyBet(userBet) {
        this.myBetList.splice(0, this.myBetList.length)
        if (!userBet) {
          return
        }
        for (let v of userBet.value) {
          this.myBetList.push({
            chs: v.value,
            hits: this.genHits(this.curRoundInfo.jackpot, v.value),
          })
        }
      },
      async queryCurAllBetPage(page) {
        this.allBetList.splice(this.allBetList, this.allBetList.length)
        if (Math.ceil(this.curRoundInfo.totalBetCount / this.betCountPerPage) < page) {
          return
        }
        this.bInReqAllBetPage = true
        const options = {
          contractAddress,
          contractName: lotteryContractName,
          functionName: 'get-bet-bunch',
          functionArgs: [uintCV(this.curRound), uintCV(page-1)],  // page from 0
          network,
          senderAddress,
        };

        const summaryRsp = await callReadOnlyFunction(options);
        let serverData = cvToValue(summaryRsp)
        // console.log('___serverData', serverData)
        for (let v of serverData.value) {
          const [addr, betValue] = [v.value.p.value, v.value.dv.value]
          this.allBetList.push({
            bSelf: this.bSignedIn && addr == getAddress(),
            brAddr: addr.substr(0, 4) + '..' + addr.substr(addr.length-4, 4),
            addr: addr,
            chs: betValue,
            hits: this.genHits(this.curRoundInfo.jackpot, betValue),
          })
        }
        this.bInReqAllBetPage = false
      },
      onChangePage(val) {
        let outThis = this
        this.bInRequestMyBets = true
        this.queryCurAllBetPage(val)
      },
      onChangeRound(round) {
        const intRound = parseInt(round)
        if (!intRound) {
          return
        }
        this.curRound = Math.min(Math.max(1, intRound), this.maxRound)
        this.requestHistorySummary(this.curRound)
      },
      genHits(jackpot, value) {
        if (this.curRoundInfo.jackpot.length <= 0) {
          return this.HITS_NO_LIST
        }
        let arr = []
        for (let i = 0; i < 5; i++) {
          arr[i] = jackpot.substr(i, 1) == value.substr(i, 1)
        }
        return arr
      }
    }
  }

  </script>

  <!-- Add "scoped" attribute to limit CSS to this component only -->
<style scoped>
#main {
  margin: 28px;
  text-align: center;
  min-height: 400px;
}
#roundTip {
  font-weight: bold;
  font-size: 21px;
}
#titleGap {
  margin-left: 50px;
}
#summaryArea {
  width: 820px;
  margin: 40px auto auto auto;
}
.equalWidth {
  font-family: monospace, Courier, "Courier New", Consolas;
}
.result {
  font-size: 20px;
}
.seq {
  font-size: 20px;
}

.mylink {
  text-decoration: underline;
  color: black;
}
.bold {
  font-weight: bold;
  color:#00f;
}
#jackpotArea {
  text-align: left;
  margin-left: 8px;
}
#horArea {
  margin: 40px auto 20px auto;
  text-align: center;
}
#pagetool {
  text-align: center;
  margin-top: 16px;
  margin-left: -30px;
  display: block;
}
#allArea {
  display: inline-block;
  width: 360px;
  height: 666px;
  text-align: left;
  vertical-align: top;
}
#mineArea {
  display: inline-block;
  width: 350px;
  height: 666px;
  text-align: left;
  vertical-align: top;
  margin-left: 96px;
}

</style>
