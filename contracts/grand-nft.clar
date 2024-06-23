;; Grand NFT

(define-non-fungible-token GrandNFT uint)

(define-constant OWNER tx-sender)

(define-data-var last-id uint u0)

(define-public (mint (receiver principal))
  (begin
    (asserts! (is-eq tx-sender OWNER) (err u101))
    (var-set last-id (+ (var-get last-id) u1))
    (try! (nft-mint? GrandNFT (var-get last-id) receiver))
    (ok true)
  )
)

(define-public (transfer (id uint) (sender principal) (receiver principal))
  (begin
    (asserts! (is-eq sender tx-sender) (err u102))
    (nft-transfer? GrandNFT id sender receiver)
  )
)

(define-read-only (get-owner (id uint))
  (ok (nft-get-owner? GrandNFT id))
)

(define-read-only (get-last-token-id)
  (ok (var-get last-id))
)

(define-read-only (get-token-uri (id uint))
  (ok (some "ipfs://QmeNMYmJGAUaptVDd58frJYNqC22n8zJJEak3VLnpebEGR"))
)
