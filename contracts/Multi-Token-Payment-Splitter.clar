;; Multi-Token Payment Splitter
;; Split incoming fungible token payments among predefined recipients

(define-constant err-unauthorized (err u100))
(define-constant err-invalid-amount (err u101))
(define-constant err-token-transfer (err u102))
(define-constant err-no-recipients (err u103))
(define-constant err-invalid-total-shares (err u104))

;; Define list of recipients and their share percentages (in basis points, e.g., 2500 = 25%)
(define-data-var recipients (list 10 {recipient: principal, share: uint}) (list))

;; Only contract owner can set recipients
(define-constant contract-owner tx-sender)

;; Helper function to calculate total shares
(define-private (add-share (item {recipient: principal, share: uint}) (acc uint))
  (+ (get share item) acc)
)


;; Set recipients and their shares (must total 10000)
(define-public (set-recipients (new-recipients (list 10 {recipient: principal, share: uint})))
  (begin
    (asserts! (is-eq tx-sender contract-owner) err-unauthorized)
    (let ((total-share (fold add-share new-recipients u0)))
      (asserts! (is-eq total-share u10000) err-invalid-total-shares)
      (var-set recipients new-recipients)
      (ok true)
    )
  )
)

;; Get current recipients
(define-read-only (get-recipients)
  (var-get recipients)
)

;; Calculate amount for a specific share
(define-read-only (calculate-amount (total-amount uint) (share uint))
  (/ (* total-amount share) u10000)
)