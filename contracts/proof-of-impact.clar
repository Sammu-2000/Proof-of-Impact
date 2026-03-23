;; ============================================================
;; ProofOfImpact.clar
;; Contribution Streak Tracking Protocol
;; Version 2.0 (Refactored)
;; ============================================================

;; =========================
;; ERRORS
;; =========================
(define-constant ERR-ALREADY-LOGGED (err u400))
(define-constant ERR-NOT-FOUND (err u404))
(define-constant ERR-NOT-AUTHORIZED (err u403))

;; =========================
;; CONFIG
;; =========================
(define-data-var admin principal tx-sender)

;; =========================
;; STORAGE
;; =========================

(define-map streaks
  { user: principal }
  {
    last-block: uint,
    current: uint,
    longest: uint,
    total: uint
  }
)

;; =========================
;; READ FUNCTIONS
;; =========================

(define-read-only (get-streak (user principal))
  (map-get? streaks { user: user })
)

(define-read-only (current-streak (user principal))
  (match (map-get? streaks { user: user })
    data (ok (get current data))
    ERR-NOT-FOUND
  )
)

(define-read-only (longest-streak (user principal))
  (match (map-get? streaks { user: user })
    data (ok (get longest data))
    ERR-NOT-FOUND
  )
)

(define-read-only (total-contributions (user principal))
  (match (map-get? streaks { user: user })
    data (ok (get total data))
    ERR-NOT-FOUND
  )
)

;; =========================
;; INTERNAL HELPERS
;; =========================

(define-private (calc-streak (last uint) (now uint) (current uint))
  (if (is-eq now (+ last u1))
      (+ current u1)
      u1
  )
)

(define-private (max (a uint) (b uint))
  (if (> a b) a b)
)

;; =========================
;; CORE LOGIC
;; =========================

(define-public (log)
  (let (
        (user tx-sender)
        (now burn-block-height)
        (entry (map-get? streaks { user: tx-sender }))
       )
    (match entry
      data
      ;; EXISTING USER
      (let (
            (last (get last-block data))
            (current (get current data))
            (longest (get longest data))
            (total (get total data))
           )
        (begin
          ;; prevent same block logging
          (asserts! (> now last) ERR-ALREADY-LOGGED)

          (let (
                (new-current (calc-streak last now current))
                (new-longest (max longest (calc-streak last now current)))
                (new-total (+ total u1))
               )
            (map-set streaks { user: user }
              {
                last-block: now,
                current: new-current,
                longest: new-longest,
                total: new-total
              })

            (print { event: "streak-updated", user: user, streak: new-current })
            (ok new-current)
          )
        )
      )

      ;; NEW USER
      (begin
        (map-set streaks { user: user }
          {
            last-block: now,
            current: u1,
            longest: u1,
            total: u1
          })

        (print { event: "new-user", user: user })
        (ok u1)
      )
    )
  )
)

;; =========================
;; ADMIN
;; =========================

(define-private (only-admin)
  (if (is-eq tx-sender (var-get admin))
    (ok true)
    ERR-NOT-AUTHORIZED
  )
)

(define-public (reset (user principal))
  (begin
    (try! (only-admin))
    (asserts! (not (is-eq user tx-sender)) (err u999))
    (map-delete streaks { user: user })
    (print { event: "streak-reset", user: user })
    (ok true)
  )
)

(define-public (set-admin (new-admin principal))
  (begin
    (try! (only-admin))
    (asserts! (not (is-eq new-admin tx-sender)) (err u999))
    (var-set admin new-admin)
    (ok new-admin)
  )
)
