(define-constant NFT-ID u1)

(define-constant ERR-NOT-LOTTERY-CONTRACT u10001)
(define-constant ERR-NO-WINNER-YET u10002)
(define-constant ERR-NOT-WINNER u10003)
(define-constant ERR-SINGLE-WINNER u10004)
(define-constant ERR-MULTI-WINNERS u10005)
(define-constant ERR-NO-SUCH-WINNER u10006)
(define-constant ERR-VOTE-NOT-EXIST u10007)
(define-constant ERR-LOTTERY-CONTRACT-SET u10008)
(define-constant ERR-LOTTERY-CONTRACT-NOT-SET u10009)

(define-data-var var-lottery-contract (optional principal) none)
(define-data-var var-winners (list 3 principal) (list))
(define-data-var var-vote-id uint u0)

(define-map var-vote-action
  uint  ;; vote id
  principal ;; claim to whom
)

(define-map var-vote-note
  uint
  uint  ;; bit-or
)

(define-public (set-winners (winners (list 3 principal)))
  (let
    (
      (winner0 (element-at? winners u0))
      (winner1 (element-at? winners u1))
      (winner2 (element-at? winners u2))
    )
    (asserts! (is-eq contract-caller (unwrap! (var-get var-lottery-contract) (err ERR-LOTTERY-CONTRACT-NOT-SET))) (err ERR-NOT-LOTTERY-CONTRACT))
    ;; make sure no duplicate
    (if (is-eq (len winners) u1)
      (var-set var-winners winners)
      (if (is-eq (len winners) u2)
        (if (is-eq winner0 winner1)
          (var-set var-winners (list (unwrap-panic winner0)))
          (var-set var-winners winners)
        )
        (if (is-eq winner0 winner1 winner2)
          (var-set var-winners (list (unwrap-panic winner0)))
          (if (or (is-eq winner0 winner1) (is-eq winner1 winner2))  ;; not need check winner0==winner2, one account can only bet once per round
            (var-set var-winners (list (unwrap-panic winner0) (unwrap-panic winner2)))
            (var-set var-winners winners)
          )
        )
      )
    )
    (print {
      title: "set winners",
      winners: winners,
      var-winners: (var-get var-winners),
    })
    (ok true)
  )
)

;; When only 1 winner, he can call this function to receive the award
(define-public (claim-award (receiver principal))
  (let
    (
      (winners (var-get var-winners))
      (winner0 (element-at? winners u0))
    )
    (asserts! (is-some winner0) (err ERR-NO-WINNER-YET))
    (asserts! (or (is-none (element-at? winners u1)) (is-eq winner0 (element-at? winners u1))) (err ERR-MULTI-WINNERS))
    (asserts! (or (is-none (element-at? winners u2)) (is-eq winner0 (element-at? winners u2))) (err ERR-MULTI-WINNERS))
    (asserts! (is-eq (unwrap-panic winner0) contract-caller) (err ERR-NOT-WINNER))
    (print {
      title: "Winner withdraw",
      receiver: receiver,
    })
    (var-set var-winners (list))
    (as-contract (contract-call? .grand-nft transfer NFT-ID tx-sender receiver))
  )
)

;; When multi winners, they can vote to transfer away the award
(define-public (new-vote (whom principal))
  (let
    (
      (winners (var-get var-winners))
      (win-index-opt (index-of? winners contract-caller))
      (vote-id (+ (var-get var-vote-id) u1))
    )
    (asserts! (is-some win-index-opt) (err ERR-NO-SUCH-WINNER))
    (asserts! (is-some (element-at? winners u1)) (err ERR-SINGLE-WINNER))
    (print {
      title: "New vote",
      vote-id: vote-id,
      to-whom: whom
    })
    (var-set var-vote-id vote-id)
    (map-set var-vote-action vote-id whom)
    (map-set var-vote-note vote-id (bit-shift-left u1 (unwrap-panic win-index-opt)))
    (ok true)
  )
)

(define-public (vote-yes (vote-id uint))
  (let
    (
      (winners (var-get var-winners))
      (win-index (unwrap! (index-of? winners contract-caller) (err ERR-NO-SUCH-WINNER)))
      (vote-value (unwrap! (map-get? var-vote-note vote-id) (err ERR-VOTE-NOT-EXIST)))
      (new-value (bit-or vote-value (bit-shift-left u1 win-index)))
    )
    (asserts! (is-some (element-at? winners u1)) (err ERR-SINGLE-WINNER))
    (print {
      title: "Vote yes",
      vote-id: vote-id,
      new-value: new-value,
    })
    (map-set var-vote-note vote-id new-value)
    (and
      (> (bit-and new-value (bit-shift-left u1 u0)) u0)
      (> (bit-and new-value (bit-shift-left u1 u1)) u0)
      (or
        (is-eq (len winners) u2)
        (> (bit-and new-value (bit-shift-left u1 u2)) u0)
      )
      (try! (handle-action vote-id))
    )
    (ok true)
  )
)

(define-public (set-lottery-contract (lottery-contract principal))
  (begin
    (asserts! (is-none (var-get var-lottery-contract)) (err ERR-LOTTERY-CONTRACT-SET))
    (ok (var-set var-lottery-contract (some lottery-contract)))
  )
)

(define-private (handle-action (vote-id uint))
  (let
    (
      (vote-receiver (unwrap! (map-get? var-vote-action vote-id) (err ERR-VOTE-NOT-EXIST)))
    )
    (as-contract (contract-call? .grand-nft transfer NFT-ID tx-sender vote-receiver))
  )
)

(define-public (return-award (receiver principal))
  (begin
    (asserts! (is-eq contract-caller (unwrap! (var-get var-lottery-contract) (err ERR-LOTTERY-CONTRACT-NOT-SET))) (err ERR-NOT-LOTTERY-CONTRACT))
    (as-contract (contract-call? .grand-nft transfer NFT-ID tx-sender receiver))
  )
)

(define-read-only (get-summary)
  {
    winners: (var-get var-winners),
    var-lottery-contract: (var-get var-lottery-contract),
    vote-id: (var-get var-vote-id),
  }
)

(define-read-only (get-summary-with-vote (vote-id uint))
  {
    summary: (get-summary),
    action: (map-get? var-vote-action vote-id),
    value: (map-get? var-vote-note vote-id),
  }
)
