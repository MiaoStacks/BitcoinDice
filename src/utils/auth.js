import { StacksTestnet } from '@stacks/network'
import { UserSession, showConnect } from '@stacks/connect'

export const network = new StacksTestnet();
export const session = new UserSession();

export function getAddress() {
  return session.loadUserData().profile.stxAddress.testnet;
}

export function signIn() {
  showConnect({
    appDetails: {
      name: 'Bitcoin Dice',
      icon: 'https://ipfs.io/ipfs/Qmeww5X6a99Zj29v3NjT3T6VrjRamGJs1m1JrCmqC7ijSa',
    },
    redirectTo: '/',
    onFinish: () => {
      window.location.reload();
    },
    session: session,
  });
}

export function signOut() {
  session.signUserOut()
  window.location.reload()
}

export function getContracts() {
  return {
    contractAddress: 'ST1SSKENSBB7EKQZ1Q6GFYQV49E2Q7WMDAXASKVBB',
    lotteryContractName: 'lottery-1',
    lotteryPrizeContractName: 'lottery-1-prize',
  }
}
