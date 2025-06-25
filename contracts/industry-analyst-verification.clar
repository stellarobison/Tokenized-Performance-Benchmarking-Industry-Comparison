;; Industry Analyst Verification Contract
;; Validates and manages certified industry analysts

(define-constant CONTRACT_OWNER tx-sender)
(define-constant ERR_UNAUTHORIZED (err u100))
(define-constant ERR_ALREADY_VERIFIED (err u101))
(define-constant ERR_NOT_FOUND (err u102))
(define-constant ERR_INSUFFICIENT_STAKE (err u103))

(define-data-var min-stake-amount uint u1000)

(define-map verified-analysts
  principal
  {
    verified: bool,
    stake-amount: uint,
    verification-date: uint,
    specialization: (string-ascii 50),
    reputation-score: uint
  }
)

(define-map analyst-submissions
  principal
  {
    total-submissions: uint,
    approved-submissions: uint,
    last-submission: uint
  }
)

(define-public (verify-analyst (analyst principal) (specialization (string-ascii 50)) (stake-amount uint))
  (begin
    (asserts! (is-eq tx-sender CONTRACT_OWNER) ERR_UNAUTHORIZED)
    (asserts! (>= stake-amount (var-get min-stake-amount)) ERR_INSUFFICIENT_STAKE)
    (asserts! (is-none (map-get? verified-analysts analyst)) ERR_ALREADY_VERIFIED)

    (map-set verified-analysts analyst {
      verified: true,
      stake-amount: stake-amount,
      verification-date: block-height,
      specialization: specialization,
      reputation-score: u100
    })

    (map-set analyst-submissions analyst {
      total-submissions: u0,
      approved-submissions: u0,
      last-submission: u0
    })

    (ok true)
  )
)

(define-public (update-reputation (analyst principal) (new-score uint))
  (begin
    (asserts! (is-eq tx-sender CONTRACT_OWNER) ERR_UNAUTHORIZED)
    (match (map-get? verified-analysts analyst)
      analyst-data (begin
        (map-set verified-analysts analyst
          (merge analyst-data { reputation-score: new-score }))
        (ok true)
      )
      ERR_NOT_FOUND
    )
  )
)

(define-read-only (is-verified-analyst (analyst principal))
  (match (map-get? verified-analysts analyst)
    analyst-data (get verified analyst-data)
    false
  )
)

(define-read-only (get-analyst-info (analyst principal))
  (map-get? verified-analysts analyst)
)

(define-read-only (get-analyst-stats (analyst principal))
  (map-get? analyst-submissions analyst)
)
