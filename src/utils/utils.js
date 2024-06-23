import { cvToValue, listCV, uintCV } from '@stacks/transactions'

export function getLocalTime(nS) {
  return new Date(parseInt(nS) * 1000).toLocaleString().replace(/:\d{1,2}$/,' ');
}

export function getIpfsUrl(cid) {
  return 'https://ipfs.io/ipfs/' + cid
}

export function buffer2Str(v) {
  return Buffer.from(v.value.substring(2), 'hex').toString()
}

export function tipError(obj, msg) {
  obj.$message({message: msg, type: 'error'});
}
export function tipInfo(obj, msg) {
  obj.$message(msg);
}

export function parseRspArray(svrData) {
  if (svrData.type == 10 && svrData.value.list.length == 0) {
    return []
  } else {
    const svrApplys = cvToValue(svrData)
    let result = []
    if (svrApplys) {
      for (const v of svrApplys.value) {
        result.push(v.value)
      }
    }
    return result
  }
}

export function uintArr2CvArr(valList) {
  let cvList = listCV()
  cvList.list = []
  for (let v of valList) {
    cvList.list.push(uintCV(v))
  }
  return cvList
}

export function formatBlocksTime(blocks) {
  let remainTimeDesc = ''
  if (blocks <= 0) {
    return 'expired'
  } else if (blocks < 6) {
    remainTimeDesc = (blocks * 10) + ' minutes'
  } else if (blocks < 144) {
    let hours = Math.floor(blocks/6)
    remainTimeDesc = hours + ' hour' + (hours > 1 ? 's' : '')
  } else {
    const days = Math.floor(blocks/144)
    remainTimeDesc = days + ' day' + (days > 1 ? 's' : '')
  }
  return remainTimeDesc
}

export function getDurationAgo(lastStamp) {
  const curStamp = Math.floor(Date.now() / 1000)
  if (!lastStamp || lastStamp <= 0 || lastStamp > curStamp) {
    return '-'
  }
  const deltaSeconds = curStamp - lastStamp
  if (deltaSeconds >= 86400) {
    const days = Math.floor(deltaSeconds/86400)
    return days + ' day' + (days > 1 ? 's' : '') + ' ago'
  } else if (deltaSeconds >= 3600) {
    const hours = Math.floor(deltaSeconds/3600)
    return hours + ' hour' + (hours > 1 ? 's' : '') + ' ago'
  } else if (deltaSeconds >= 60) {
    const mins = Math.floor(deltaSeconds/60)
    return mins + ' minute' + (mins > 1 ? 's' : '') + ' ago'
  } else {
    return 'just now'
  }
}

export function sleep(ms) {
  return new Promise(resolve => setTimeout(resolve, ms));
}
