(define-constant ERROR-INVALID-STATE u1001)
(define-constant ERROR-END-BET u1002)
(define-constant ERROR-HAS-BET u1003)
(define-constant ERR-NOT-MEMBER u1004)
(define-constant ERR-TRANSFER-STX u1005)
(define-constant ERROR-SLICE u1006)
(define-constant ERROR-AS-MAX-LEN u1007)
(define-constant ERROR-BET-COUNT-TOO-LESS u1008)
(define-constant ERROR-EXCEED-MAX-BET-COUNT u1009)
(define-constant ERROR-DRAW-CD u1010)
(define-constant ERROR-GET-BLOCK-INFO u1011)
(define-constant ERROR-RETURN-AWARD u1012)
(define-constant ERROR-BTC-HEIGHT-TOO-SMALL u1013)
(define-constant ERROR-BTC-HEIGHT-TOO-BIG u1014)

(define-constant STX-COST-PER-BET u1000)                ;; 0.001 STX/bet
(define-constant MIN-BET-TO-START-ROUND u5)             ;; Min 5 bets to start a round
(define-constant MAX-TOTAL-BET-PER-ROUND u30000)        ;; Max 30,000 bets per round
(define-constant BET-BLOCKS u124)                       ;; 1) 124 blocks(about 21 hours) for users to bet
(define-constant WAIT-TO-END-BET-BLOCKS u6)             ;; 2) Wait for 6 blocks(do nothing), then user can call end-bet to enter wait-for-draw state
(define-constant WAIT-TO-DRAW-BLOCKS u14)               ;; 3) Wait 14 blocks, then user can call draw
(define-constant BYTE-INDEX-FOR-GEN-JACKPOT u25)        ;; Use header-hash's 51th character(25th byte) to generate jockpot
(define-constant RETURN-AWARD-MIN-BLOCK u111111)         ;; Can get back award after this block
(define-constant RETURN-AWARD-MAX-ROUND-BLOCKS u1000)    ;; If round still not over after 1000 blocks since start, founder can get back award
(define-constant RETURN-AWARD-ADDRESS tx-sender)
(define-constant FOUNDER tx-sender)

(define-constant STATE-IDLE u1)
(define-constant STATE-BET u2)
(define-constant STATE-WAIT-TO-DRAW u3)
(define-constant STATE-HAS-WINNER u4)
(define-constant STATE-FREEZED u5)
(define-constant BUNCH-CAPACITY u200)
(define-constant LIST-13 (list u1 u2 u3 u4 u5 u6 u7 u8 u9 u10 u11 u12 u13))
(define-constant HEX-CHARS "0123456789abcdef")
(define-constant BUFF-TO-BYTE (list
  0x00 0x01 0x02 0x03 0x04 0x05 0x06 0x07 0x08 0x09 0x0a 0x0b 0x0c 0x0d 0x0e 0x0f
  0x10 0x11 0x12 0x13 0x14 0x15 0x16 0x17 0x18 0x19 0x1a 0x1b 0x1c 0x1d 0x1e 0x1f
  0x20 0x21 0x22 0x23 0x24 0x25 0x26 0x27 0x28 0x29 0x2a 0x2b 0x2c 0x2d 0x2e 0x2f
  0x30 0x31 0x32 0x33 0x34 0x35 0x36 0x37 0x38 0x39 0x3a 0x3b 0x3c 0x3d 0x3e 0x3f
  0x40 0x41 0x42 0x43 0x44 0x45 0x46 0x47 0x48 0x49 0x4a 0x4b 0x4c 0x4d 0x4e 0x4f
  0x50 0x51 0x52 0x53 0x54 0x55 0x56 0x57 0x58 0x59 0x5a 0x5b 0x5c 0x5d 0x5e 0x5f
  0x60 0x61 0x62 0x63 0x64 0x65 0x66 0x67 0x68 0x69 0x6a 0x6b 0x6c 0x6d 0x6e 0x6f
  0x70 0x71 0x72 0x73 0x74 0x75 0x76 0x77 0x78 0x79 0x7a 0x7b 0x7c 0x7d 0x7e 0x7f
  0x80 0x81 0x82 0x83 0x84 0x85 0x86 0x87 0x88 0x89 0x8a 0x8b 0x8c 0x8d 0x8e 0x8f
  0x90 0x91 0x92 0x93 0x94 0x95 0x96 0x97 0x98 0x99 0x9a 0x9b 0x9c 0x9d 0x9e 0x9f
  0xa0 0xa1 0xa2 0xa3 0xa4 0xa5 0xa6 0xa7 0xa8 0xa9 0xaa 0xab 0xac 0xad 0xae 0xaf
  0xb0 0xb1 0xb2 0xb3 0xb4 0xb5 0xb6 0xb7 0xb8 0xb9 0xba 0xbb 0xbc 0xbd 0xbe 0xbf
  0xc0 0xc1 0xc2 0xc3 0xc4 0xc5 0xc6 0xc7 0xc8 0xc9 0xca 0xcb 0xcc 0xcd 0xce 0xcf
  0xd0 0xd1 0xd2 0xd3 0xd4 0xd5 0xd6 0xd7 0xd8 0xd9 0xda 0xdb 0xdc 0xdd 0xde 0xdf
  0xe0 0xe1 0xe2 0xe3 0xe4 0xe5 0xe6 0xe7 0xe8 0xe9 0xea 0xeb 0xec 0xed 0xee 0xef
  0xf0 0xf1 0xf2 0xf3 0xf4 0xf5 0xf6 0xf7 0xf8 0xf9 0xfa 0xfb 0xfc 0xfd 0xfe 0xff
))

(define-data-var m-round uint u1)
(define-data-var m-state uint STATE-IDLE)
(define-data-var m-stx-start-at uint u0)
(define-data-var m-stx-end-at uint u0)
(define-data-var m-btc-end-at uint u0)

;; round => total-bet-count
(define-map map-bet-count
  uint
  uint
)

(define-map map-bet-bunch
  { round: uint, index: uint }  ;; starts from 0
  (list 200 {
      p: principal,
      dv: (string-ascii 5)
    }
  )
)

(define-map map-user-bet
  { round: uint, p: principal }
  (list 200 (string-ascii 5))
)

(define-map map-bet-2-users
  { round: uint, dv: (string-ascii 5) }
  (list 3 principal)
)

(define-map map-history
  uint
  {
    start-at-stx: uint,
    end-at-stx: uint,
    end-at-btc: uint,
    jackpot: (string-ascii 5),
    bet-count: uint,
    hashes: (list 5 (buff 32)),
    winners: (list 3 principal),
  }
)

(define-public (bet (bet-list (list 200 (string-ascii 5))))
  (let
    (
      (caller contract-caller)
      (bh block-height)
      (state (var-get m-state))
      (round (var-get m-round))
      (round-bet-count (default-to u0 (map-get? map-bet-count round)))
      (bet-item-list (map build-bet-item bet-list))
      (item-count (len bet-item-list))
      (stx-cost (* item-count STX-COST-PER-BET))
      (bunch-index (/ round-bet-count BUNCH-CAPACITY))
      (cur-bunch (default-to (list) (map-get? map-bet-bunch { round: round, index: bunch-index })))
      (cur-bunch-len (len cur-bunch))
      (new-round-bet-count (+ (default-to u0 (map-get? map-bet-count round)) item-count))
    )
    (if (is-eq state STATE-IDLE)
      (and
        (var-set m-state STATE-BET)
        (var-set m-stx-start-at bh)
        (asserts! (>= item-count MIN-BET-TO-START-ROUND) (err ERROR-BET-COUNT-TOO-LESS))
      )
      (if (is-eq state STATE-BET)
        (and
          (asserts! (<= bh (+ (var-get m-stx-start-at) BET-BLOCKS)) (err ERROR-END-BET))
          (asserts! (>= item-count u1) (err ERROR-BET-COUNT-TOO-LESS))
        )
        (asserts! false (err ERROR-INVALID-STATE))
      )
    )
    (asserts! (<= new-round-bet-count MAX-TOTAL-BET-PER-ROUND) (err ERROR-EXCEED-MAX-BET-COUNT))
    (asserts! (is-none (map-get? map-user-bet { round: round, p: caller })) (err ERROR-HAS-BET))
    (unwrap! (stx-transfer? stx-cost caller FOUNDER) (err ERR-TRANSFER-STX))
    (map-set map-bet-count round new-round-bet-count)
    (if (<= (+ cur-bunch-len item-count) BUNCH-CAPACITY)
      (map-set map-bet-bunch
        { round: round, index: bunch-index }
        (unwrap! (as-max-len? (concat cur-bunch bet-item-list) u200) (err ERROR-AS-MAX-LEN))
      )
      (let
        (
          (combine-list (unwrap! (as-max-len? (concat cur-bunch bet-item-list) u400) (err ERROR-AS-MAX-LEN)))
        )
        (map-set map-bet-bunch
          { round: round, index: bunch-index }
          (unwrap! (as-max-len? (unwrap! (slice? combine-list u0 BUNCH-CAPACITY) (err ERROR-SLICE)) u200) (err ERROR-AS-MAX-LEN))
        )
        (map-set map-bet-bunch
          { round: round, index: (+ bunch-index u1) }
          (unwrap! (as-max-len? (unwrap! (slice? combine-list BUNCH-CAPACITY (len combine-list)) (err ERROR-SLICE)) u200) (err ERROR-AS-MAX-LEN))
        )
      )
    )
    (map-set map-user-bet { round: round, p: caller } bet-list)
    (fold walk-user-bet bet-item-list round)
    (ok item-count)
  )
)

(define-public (end-bet (btc-height uint))
  (let
    (
      (caller contract-caller)
      (bh block-height)
    )
    (asserts! (is-eq (var-get m-state) STATE-BET) (err ERROR-INVALID-STATE))
    (asserts! (> bh (+ (var-get m-stx-start-at) BET-BLOCKS WAIT-TO-END-BET-BLOCKS)) (err ERROR-END-BET))
    (asserts! (is-none (get-burn-block-info? header-hash (+ btc-height u7))) (err ERROR-BTC-HEIGHT-TOO-SMALL))
    (asserts! (is-some (get-burn-block-info? header-hash (- btc-height u7))) (err ERROR-BTC-HEIGHT-TOO-BIG))
    (var-set m-btc-end-at (fold f LIST-13 (+ btc-height u6))) ;; search the latest dealt bitcoin height in [btc-height - 6, btc-height + 6]
    (var-set m-stx-end-at bh)
    (var-set m-state STATE-WAIT-TO-DRAW)
    (ok true)
  )
)

(define-public (draw)
  (let
    (
      (caller contract-caller)
      (end-at-btc (var-get m-btc-end-at))
      (hash1 (unwrap! (get-burn-block-info? header-hash (+ end-at-btc u6)) (err ERROR-GET-BLOCK-INFO)))
      (hash2 (unwrap! (get-burn-block-info? header-hash (+ end-at-btc u7)) (err ERROR-GET-BLOCK-INFO)))
      (hash3 (unwrap! (get-burn-block-info? header-hash (+ end-at-btc u8)) (err ERROR-GET-BLOCK-INFO)))
      (hash4 (unwrap! (get-burn-block-info? header-hash (+ end-at-btc u9)) (err ERROR-GET-BLOCK-INFO)))
      (hash5 (unwrap! (get-burn-block-info? header-hash (+ end-at-btc u10)) (err ERROR-GET-BLOCK-INFO)))
      (jackpot (fold gen-ascii (list hash1 hash2 hash3 hash4 hash5) ""))
      (winners (default-to (list) (map-get? map-bet-2-users { round: (var-get m-round), dv: jackpot })))
    )
    (asserts! (is-eq (var-get m-state) STATE-WAIT-TO-DRAW) (err ERROR-INVALID-STATE))
    (asserts! (>= block-height (+ (var-get m-stx-end-at) WAIT-TO-DRAW-BLOCKS)) (err ERROR-DRAW-CD))
    (print {
      title: "draw",
      jackpot: jackpot,
      winners: winners,
    })
    (map-set map-history (var-get m-round) {
      start-at-stx: (var-get m-stx-start-at),
      end-at-stx: (var-get m-stx-end-at),
      end-at-btc: end-at-btc,
      jackpot: jackpot,
      bet-count: (default-to u0 (map-get? map-bet-count (var-get m-round))),
      hashes: (list hash1 hash2 hash3 hash4 hash5),
      winners: winners,
    })
    (if (> (len winners) u0)
      (begin
        (try! (contract-call? .lottery-1-prize set-winners winners))
        (var-set m-state STATE-HAS-WINNER)
      )
      (begin
        (var-set m-round (+ (var-get m-round) u1))
        (var-set m-state STATE-IDLE)
        (var-set m-stx-start-at u0)
        (var-set m-stx-end-at u0)
        (var-set m-btc-end-at u0)
      )
    )
    (ok true)
  )
)

;; Can return award in two situations:
;; 1. Block height exceeds RETURN-AWARD-MIN-BLOCK, and in idle state. Only RETURN-AWARD-ADDRESS can call(in case that rounder wants to continue, but someone break).
;; 2. 1000 blocks passed since round-start. Probably stuck due to bug, allow return award to rescue. Anyone can call.
(define-public (return-award)
  (if (or (is-eq (var-get m-state) STATE-HAS-WINNER) (is-eq (var-get m-state) STATE-FREEZED))
    (err ERROR-RETURN-AWARD)
    (if (is-eq (var-get m-state) STATE-IDLE)
      (if (>= block-height RETURN-AWARD-MIN-BLOCK)
        (begin
          (asserts! (is-eq contract-caller RETURN-AWARD-ADDRESS) (err ERROR-RETURN-AWARD))
          (var-set m-state STATE-FREEZED)
          (contract-call? .lottery-1-prize return-award RETURN-AWARD-ADDRESS)
        )
        (err ERROR-RETURN-AWARD)
      )
      (if (>= block-height (+ (var-get m-stx-start-at) RETURN-AWARD-MAX-ROUND-BLOCKS)) ;; stuck
        (begin
          (var-set m-state STATE-FREEZED)
          (contract-call? .lottery-1-prize return-award RETURN-AWARD-ADDRESS)
        )
        (err ERROR-RETURN-AWARD)
      )
    )
  )
)

(define-read-only (get-summary)
  {
    bh: block-height,
    round: (var-get m-round),
    state: (var-get m-state),
    start-at: (var-get m-stx-start-at),
    end-at: (var-get m-stx-end-at),
    end-at-btc: (var-get m-btc-end-at),
    bet-count: (default-to u0 (map-get? map-bet-count (var-get m-round))),
  }
)

(define-read-only (get-summary-with-user (user principal))
  {
    base: (get-summary),
    stx: (stx-get-balance user),
    user-bet: (map-get? map-user-bet { round: (var-get m-round), p: user }),
  }
)

(define-read-only (get-bet-bunch (round uint) (index uint))
  (map-get? map-bet-bunch { round: round, index: index })
)

(define-read-only (get-user-bet (round uint) (user principal))
  (map-get? map-user-bet { round: round, p: user })
)

(define-read-only (get-same-bet-players (round uint) (dv (string-ascii 5)))
  (map-get? map-bet-2-users { round: round, dv: dv })
)

;; round = 0 means current round
(define-read-only (get-history (round uint))
  (let
    (
      (target-round (if (> round u0) round (var-get m-round)))
    )
    {
      t: target-round,
      v: (map-get? map-history target-round),
    }
  )
)

(define-read-only (get-history-with-user (round uint) (user principal))
  {
    base: (get-history round),
    user-bet: (map-get? map-user-bet { round: (if (> round u0) round (var-get m-round)), p: user }),
  }
)

(define-private (build-bet-item (dv (string-ascii 5)))
  { p: contract-caller, dv: dv }
)

(define-private (walk-user-bet (item { p: principal, dv: (string-ascii 5) }) (round uint))
  (begin
    (match (map-get? map-bet-2-users { round: round, dv: (get dv item) }) pList
      (if (< (len pList) u3)
        (map-set map-bet-2-users
          { round: round, dv: (get dv item) }
          (unwrap-panic (as-max-len? (concat pList (list (get p item))) u3)))
        false
      )
      (map-set map-bet-2-users { round: round, dv: (get dv item) } (list (get p item)))
    )
    round
  )
)

(define-private (gen-ascii (seed (buff 32)) (result (string-ascii 5)))
  (match (element-at? seed BYTE-INDEX-FOR-GEN-JACKPOT) byte
    (match (index-of BUFF-TO-BYTE byte) index
      (unwrap-panic (as-max-len? (concat result (unwrap-panic (element-at? HEX-CHARS (/ index u16)))) u5))
      result
    )
    result
  )
)

(define-private (f (index uint) (cur-btc-height uint))
  (match (get-burn-block-info? header-hash cur-btc-height) hash
    cur-btc-height
    (- cur-btc-height u1)
  )
)

(contract-call? .lottery-1-prize set-lottery-contract (as-contract tx-sender))
