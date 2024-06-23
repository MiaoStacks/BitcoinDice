<template>
    <div>
      <div id='main' v-loading="reqState==1">
        <el-empty v-if="reqState==2 && winners.length==0" id="emptyArea" image-size="128" description="No winner yet"></el-empty>

        <div v-if="winners.length==1">
          <span class="title">Winner: </span>
          <el-link :href="'https://explorer.hiro.so/address/'+winners[0]+'?chain=mainnet'" target="_blank" :style="{color:'black'}">{{ winners[0] }}</el-link>
        </div>

        <div v-if="winners.length>1">
          <span class="title">Winners: </span>
          <div class="mAddr" v-for="index in winners.length" :key="index" >
            <el-link :href="'https://explorer.hiro.so/address/'+winners[index-1]+'?chain=mainnet'" target="_blank" :style="{color:'black'}">{{ winners[index-1] }}</el-link>
          </div>
        </div>

        <el-card v-if="reqState==2" class="claimCardSingle">
          <div slot="header" class="clearfix">
            <span>Single winner</span>
          </div>
          <el-input :disabled="winners.length!=1" class="sReceiver" placeholder="Receiver address" v-model="sReceiverAddr" maxlength="60" size="large" clearable></el-input>
          <el-button type="primary" :disabled="sReceiverAddr.trim().length<=0" round @click="onClickClaimSingle">Claim</el-button>
        </el-card>

        <el-card v-if="reqState==2" class="claimCardMulti">
          <div slot="header" class="clearfix">
            <span>Multi winners</span>
          </div>
          <div>
            <el-input :disabled="winners.length<=1" class="sReceiver" placeholder="Receiver address" v-model="mReceiverAddr" maxlength="60" size="large" clearable></el-input>
            <el-button type="primary" :disabled="mReceiverAddr.trim().length<=0" round @click="onClickCreateVote">Create vote</el-button>
            <div class="claimTip">* The transaction will print vote id, other winners need input the vote id and click the "Vote yes" button below.</div>
          </div>
          <div class="mFiledDiv">
            <el-input :disabled="winners.length<=1" class="sReceiver" placeholder="Input vote id" v-model="mQueryVoteId" maxlength="60" size="large"></el-input>
            <el-button type="primary" :disabled="mQueryVoteId.trim().length<=0" round @click="onClickQueryVote">Query vote</el-button>
            <div class="claimTip" v-if="queryVoteIdState==1">{{queryFailVoteStr}}</div>
            <div id="queryResultFS" v-if="queryVoteIdState==2">
              <div class="claimTip">Receiver: {{ mQueryResultReceiver }}</div>
              <div class="claimTip" v-for="index in winners.length" :key="index" >
                {{ winners[index-1] + (voteYesSet[winners[index-1]] ? ' vote yes' : ' not vote yet') }}
              </div>
            </div>
          </div>
          <div class="mFiledDiv">
            <el-input :disabled="winners.length<=1" class="sReceiver" placeholder="Input vote id" v-model="mVoteYesVoteId" maxlength="60" size="large" clearable></el-input>
            <el-button type="primary" :disabled="mVoteYesVoteId.trim().length<=0" round @click="onClickVoteYes">Vote yes</el-button>
          </div>
        </el-card>
      </div>
    </div>
  </template>

  <script>
  import { session, network, getContracts, signIn } from '../../../utils/auth'
  import { tipError } from '../../../utils/utils'
  import { callReadOnlyFunction, makeContractNonFungiblePostCondition, createAssetInfo, NonFungibleConditionCode, cvToValue, bufferCVFromString, tupleCV,  uintCV, standardPrincipalCV } from '@stacks/transactions'
  import { openContractCall } from '@stacks/connect';

  const { contractAddress, lotteryPrizeContractName }  = getContracts();
  const senderAddress = contractAddress;

  export default {
    name: 'WinnerPage',
    components: {
    },
    data () {
      return {
        bSignedIn: session.isUserSignedIn(),
        ///
        reqState: 1,
        winners: [],
        sReceiverAddr: '',
        mReceiverAddr: '',
        queryVoteIdState: 0,
        queryFailVoteStr: '',
        mQueryVoteId: '',
        mQueryResultReceiver: '',
        voteYesSet: {},
        mVoteYesVoteId: '',
      }
    },
    async mounted() {
      this.reqState = 1
      const options = {
        contractAddress,
        contractName: lotteryPrizeContractName,
        functionName: 'get-summary',
        functionArgs: [],
        network,
        senderAddress,
      };

      const summaryRsp = await callReadOnlyFunction(options);
      // await sleep(2000) //TOOD
      const winners = cvToValue(summaryRsp.data.winners)
      // console.log('___winners: ', winners)
      for (let v of winners) {
        this.winners.push(v.value)
      }
      this.reqState = 2
    },
    methods: {
      preCheckClaim(addr) {
        if (this.winners.length <= 0) {
          tipError('No winner yet')
          return false
        }

        if (addr) {
          try {
            addr = addr.trim()
            standardPrincipalCV(addr)
          } catch (err) {
            tipError(this, 'Invalid address')
            return false
          }
        }

        if (!this.bSignedIn) {
          signIn()
          return false
        }

        if (this.winners.indexOf(getAddress()) == -1) {
          tipError(this, 'Current account is not winner')
          return false
        }

        return true
      },
      /// Single
      async onClickClaimSingle() {
        const receiverAddr = this.sReceiverAddr.trim()
        if (!this.preCheckClaim(receiverAddr)) {
          return
        }

        const tokenAssetName = tupleCV({
          namespace: bufferCVFromString(prizeNamespace),
          name: bufferCVFromString(prizeName),
        });
        const nonFungibleAssetInfo = createAssetInfo(contractAddress, lotteryPrizeContractName, 'GrandNFT');
        const contractNonFungiblePostCondition = makeContractNonFungiblePostCondition(
          contractAddress,
          lotteryPrizeContractName,
          NonFungibleConditionCode.DoesNotOwn,
          nonFungibleAssetInfo,
          uintCV(1)
        );

        let outThis = this
        const options = {
          contractAddress,
          contractName: lotteryPrizeContractName,
          functionName: 'claim-award',
          functionArgs: [standardPrincipalCV(receiverAddr)],
          network,
          postConditions: [contractNonFungiblePostCondition],
          onFinish: data => {
            outThis.doNotify('Claim')
          },
        };
        openContractCall(options)
      },
      ///
      async onClickCreateVote() {
        const receiverAddr = this.mReceiverAddr.trim()
        if (!this.preCheckClaim(receiverAddr)) {
          return
        }

        const loading = this.createLoading('checking');
        let [prizeNamespace, prizeName] = await this.resolvePrizeName()
        loading.close()
        if (!prizeNamespace || !prizeName) {
          return
        }

        let outThis = this
        const options = {
          contractAddress,
          contractName: lotteryPrizeContractName,
          functionName: 'new-vote',
          functionArgs: [ standardPrincipalCV(this.mReceiverAddr) ],
          network,
          // postConditions: [contractNonFungiblePostCondition],
          postConditionMode: 1,
          onFinish: data => {
            outThis.doNotify('Create vote')
          },
        };
        openContractCall(options)
      },
      async queryVoteDetail(queryVoteId) {
        const options = {
          contractAddress,
          contractName: lotteryPrizeContractName,
          functionName: 'get-summary-with-vote',
          functionArgs: [uintCV(queryVoteId)],
          network,
          senderAddress,
        };

        const loading = this.createLoading('checking');
        const summaryRsp = await callReadOnlyFunction(options);
        loading.close()

        if (summaryRsp.data.action.type == 9) {
          return [false, '']
        }

        const receiver = cvToValue(summaryRsp.data.action).value
        for (let v of this.winners) {
          this.voteYesSet[v] = false
        }
        const voteVal = cvToValue(summaryRsp.data.value).value
        for (let i = 0; i < this.winners.length; i++) {
          if ((voteVal & (1 << i)) != 0) {
            this.voteYesSet[this.winners[i]] = true
          }
        }
        return [true, receiver]
      },
      async onClickQueryVote() {
        let queryVoteId = parseInt(this.mQueryVoteId)
        if (!queryVoteId) {
          tipError(this, 'invalid vote id')
          return
        }
        const [bOk, receiver] = await this.queryVoteDetail(queryVoteId)
        if (!bOk) {
          this.queryVoteIdState = 1
          this.queryFailVoteStr = `Vote ID ${queryVoteId} not exist.`
          return
        }
        this.queryVoteIdState = 2
        this.mQueryResultReceiver = receiver
      },
      async onClickVoteYes() {
        if (!this.preCheckClaim()) {
          return
        }

        const loading = this.createLoading('checking');
        const [prizeNamespace, prizeName] = await this.resolvePrizeName()
        loading.close()
        if (!prizeNamespace || !prizeName) {
          return
        }

        const voteYesId = parseInt(this.mVoteYesVoteId)
        if (!voteYesId) {
          tipError(this, 'Invalid vote ID')
          return
        }

        const [bOk, receiver] = await this.queryVoteDetail(voteYesId)
        if (!bOk) {
          tipError(this, 'Invalid vote ID')
          return
        }

        if (this.voteYesSet[getAddress()]) {
          tipError(this, 'You created the vote or has voted yes.')
          return
        }

        let unVoteYesCount = 0
        for (let v of this.winners) {
          if (!this.voteYesSet[v]) {
            unVoteYesCount++
          }
        }

        let pconds = []
        // Use post-condition if only remain 1 member not vote
        if (unVoteYesCount == 1) {
          const nonFungibleAssetInfo = createAssetInfo(contractAddress, lotteryPrizeContractName, 'GrandNFT');
          const contractNonFungiblePostCondition = makeContractNonFungiblePostCondition(
            contractAddress,
            lotteryPrizeContractName,
            NonFungibleConditionCode.DoesNotOwn,
            nonFungibleAssetInfo,
            uintCV(1)
          );
          pconds.push(contractNonFungiblePostCondition)
        }

        let outThis = this
        const options = {
          contractAddress,
          contractName: lotteryPrizeContractName,
          functionName: 'vote-yes',
          functionArgs: [ uintCV(voteYesId) ],
          network,
          postConditions: pconds,
          onFinish: data => {
            outThis.doNotify('Vote yes')
          },
        };
        openContractCall(options)
      },
      ///
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
  margin-top: 32px;
  text-align: center;
  min-height: 400px;
}
#emptyArea {
  margin-top: -55px;
  margin-bottom: -16px;
}
.title {
  color: #333;
}
.mAddr {
  margin: 8px auto;
}
.claimCardSingle {
  width: 800px;
  margin: 50px auto auto auto;
  text-align: left;
}
.claimCardMulti {
  width: 800px;
  margin: 80px auto 20px auto;
  text-align: left;
}
.sReceiver {
  display: inline-block;
  max-width: 500px;
}
.claimTip {
  margin-top: 10px;
  font-size: 14px;
  color: grey;
}
.mFiledDiv {
  margin: 32px auto auto auto;
}
#queryResultFS {
  border-radius: 8px;
  box-shadow: 0 2px 6px 0 rgba(0, 0, 0, 0.3);
  padding: 8px;
  margin-top: 4px;
  max-width: 490px;
}
</style>
