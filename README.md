# ProofOfImpact.clar

Contribution Streak Tracking Protocol  
**Version 2.0 (Refactored)**

## Overview

ProofOfImpact is a Clarity smart contract for tracking user contribution streaks on the Stacks blockchain. It records, updates, and manages streak data for each user, allowing for gamified engagement and transparent contribution history.

## Features

- **Track Streaks:** Log daily contributions and maintain current, longest, and total streaks per user.
- **Admin Controls:** Only the contract admin can reset user streaks or transfer admin rights.
- **Error Handling:** Custom error codes for common failure scenarios.

## Contract Structure

- **Admin:**  
  The contract deployer is the initial admin. Admin can be changed via `set-admin`.

- **Streaks Map:**  
  Stores each user’s streak data:
  - `last-block`: Last contribution block height
  - `current`: Current streak count
  - `longest`: Longest streak achieved
  - `total`: Total contributions

## Public Functions

- `log`:  
  Log a contribution for the sender. Updates streaks and emits events.

- `reset (user principal)`:  
  Admin-only. Resets the specified user’s streak data.

- `set-admin (new-admin principal)`:  
  Admin-only. Transfers admin rights to a new principal.

## Read-Only Functions

- `get-streak (user principal)`:  
  Returns all streak data for a user.

- `current-streak (user principal)`:  
  Returns the current streak count.

- `longest-streak (user principal)`:  
  Returns the longest streak achieved.

- `total-contributions (user principal)`:  
  Returns the total number of contributions.

## Error Codes

- `ERR-ALREADY-LOGGED (err u400)`: Already logged for this block.
- `ERR-NOT-FOUND (err u404)`: Streak data not found.
- `ERR-NOT-AUTHORIZED (err u403)`: Unauthorized action.

## Events

- `streak-updated`: Emitted when a user’s streak is updated.
- `new-user`: Emitted when a new user logs their first contribution.
- `streak-reset`: Emitted when a user’s streak is reset by the admin.

## Usage

1. **Deploy the contract** to the Stacks blockchain.
2. **Call `log`** to record daily contributions.
3. **Admin can call `reset`** to clear a user’s streak or `set-admin` to transfer admin rights.
4. **Query streaks** using the read-only functions.

## Development

- Contract: proof-of-impact.clar
- Tests: proof-of-impact.test.ts
- Configuration: Clarinet.toml, settings
