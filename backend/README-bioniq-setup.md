# ctrlb_canister (Control & Load Balancer)

## Setup

Install mops (https://mops.one/docs/install)
Install motoko dependencies:

```bash
# from folder backend/ctrlb_canister:

mops install
```

## All canisters

- Subnet: [qdvhd-os4o2-zzrdw-xrcv4-gljou-eztdp-bj326-e6jgr-tkhuc-ql6v2-yqe](https://dashboard.internetcomputer.org/subnet/qdvhd-os4o2-zzrdw-xrcv4-gljou-eztdp-bj326-e6jgr-tkhuc-ql6v2-yqe)
  - Bioniq Prod Canister: [syhes-kiaaa-aaaaj-azxda-cai](https://dashboard.internetcomputer.org/canister/syhes-kiaaa-aaaaj-azxda-cai)
  - ctrlb_canister: [tom4z-7yaaa-aaaaj-azxga-cai](https://dashboard.internetcomputer.org/canister/tom4z-7yaaa-aaaaj-azxga-cai)
  - llm_8: [tsigi-iyaaa-aaaaj-azxea-cai](https://dashboard.internetcomputer.org/canister/tsigi-iyaaa-aaaaj-azxea-cai)
  - llm_9: [tvja4-faaaa-aaaaj-azxeq-cai](https://dashboard.internetcomputer.org/canister/tvja4-faaaa-aaaaj-azxeq-cai)
  - llm_10: [t4kla-tiaaa-aaaaj-azxfa-cai](https://dashboard.internetcomputer.org/canister/t4kla-tiaaa-aaaaj-azxfa-cai)
  - llm_11: [t3lnu-6qaaa-aaaaj-azxfq-cai](https://dashboard.internetcomputer.org/canister/t3lnu-6qaaa-aaaaj-azxfq-cai)

- Subnet: [jtdsg-3h6gi-hs7o5-z2soi-43w3z-soyl3-ajnp3-ekni5-sw553-5kw67-nqe](https://dashboard.internetcomputer.org/subnet/jtdsg-3h6gi-hs7o5-z2soi-43w3z-soyl3-ajnp3-ekni5-sw553-5kw67-nqe)
  - llm_0: [4hfoe-6aaaa-aaaaj-qnfwq-cai](https://dashboard.internetcomputer.org/canister/4hfoe-6aaaa-aaaaj-qnfwq-cai)
  - llm_1: [4ogfy-iiaaa-aaaaj-qnfxa-cai](https://dashboard.internetcomputer.org/canister/4ogfy-iiaaa-aaaaj-qnfxa-cai)
  - llm_2: [4jhdm-fqaaa-aaaaj-qnfxq-cai](https://dashboard.internetcomputer.org/canister/4jhdm-fqaaa-aaaaj-qnfxq-cai)
  - llm_3: [6u2ne-wyaaa-aaaaj-qnfya-cai](https://dashboard.internetcomputer.org/canister/6u2ne-wyaaa-aaaaj-qnfya-cai)

- Subnet: [lspz2-jx4pu-k3e7p-znm7j-q4yum-ork6e-6w4q6-pijwq-znehu-4jabe-kqe](https://dashboard.internetcomputer.org/subnet/lspz2-jx4pu-k3e7p-znm7j-q4yum-ork6e-6w4q6-pijwq-znehu-4jabe-kqe)
  - llm_4: [lkh5o-3yaaa-aaaag-acguq-cai](https://dashboard.internetcomputer.org/canister/lkh5o-3yaaa-aaaag-acguq-cai)
  - llm_5: [laxfu-oqaaa-aaaag-ak5kq-cai](https://dashboard.internetcomputer.org/canister/laxfu-oqaaa-aaaag-ak5kq-cai)
  - llm_6: [ljuoi-yyaaa-aaaag-ak5la-cai](https://dashboard.internetcomputer.org/canister/ljuoi-yyaaa-aaaag-ak5la-cai)
  - llm_7: [lovi4-vaaaa-aaaag-ak5lq-cai](https://dashboard.internetcomputer.org/canister/lovi4-vaaaa-aaaag-ak5lq-cai)


## Deployment

### 0 - conda & identity

- `conda activate icpp_llm`
- `dfx identity use icpp-llm`

### 1 - Deploy Backend Canisters

from folder backend/llms:

- First time for a new subnet, make sure there is no `canister_ids.json`

- Second time:
  - If redeploying all, just copy `canister_ids_all.json` to `canister_ids.json`
    - Update `backend/llms/scripts/deploy.sh` to NOT use a SUBNET

  - If redeploying only for a single subnet:
    - copy `canister_ids_...subnet.json` to `canister_ids.json`
    - Update `backend/llms/scripts/deploy.sh` for subnet


- run:
```bash
# from folder backend/ctrlb_canister:

# Activate the same python environment as you defined for deploying the LLMs
# (This might not be needed, but I did it this way...)
conda activate icpp_llm

# Use correct dfx identity
dfx identity use icpp-llm

# Deploy
scripts/deploy.sh --network ic

# Unless deploying a new ctrlb_canister, just run whitelist now on ALL the LLMs
scripts/whitelist.sh --network ic

# REPEAT FOR NEXT SUBNET
```

Notes: 
- When deploying ctrlb_canister for the first time: 
  - we can not yet whitelist the ctrlb_canister, because it is not yet deployed.
  - First do step 2.

### 2 - Deploy ctrlb_canister

From folder backend/ctrlb_canister:

- First time only, make sure there is no `canister_ids.json`

- Update `backend/ctrlb_canister/scripts/deploy.sh` for:
  - SUBNET
  - CANISTER_ID_LLM_x  (copy from backend/llms/canister_ids.json)

- run:

```bash
# from folder backend/ctrlb_canister:

# Activate the same python environment as you defined for deploying the LLMs
# (This might not be needed, but I did it this way...)
conda activate icpp_llm

# Use correct dfx identity
dfx identity use icpp-llm

# Deploy
scripts/deploy.sh --network ic
```

Notes:
- When deploying ctrlb_canister for the first time:
  - The whitelist logic, since ctrlb_canister is not yet whitelsted with the LLMs
  - But now we have the id of the ctrlb_canister, so we can go update the LLMs.

### 3 - Whitelist ctrlb_canister with the Backend Canisters

from folder backend/llms:

- Update `backend/llms/scripts/whitelist.sh` for CTRLB_PRINCIPAL
  - copy value from backend/ctrlb_canister/canister_ids.json , and update it in this block:
    ```bash
    while [ $# -gt 0 ]; do
    case "$1" in
        --network)
            shift
            if [ "$1" = "local" ] || [ "$1" = "ic" ]; then
                NETWORK_TYPE=$1
                if [ "$NETWORK_TYPE" = "ic" ]; then
                    CTRLB_PRINCIPAL="6t3lq-3aaaa-aaaaj-qnfyq-cai"       # <-- !!!
                fi
    ```

### 4 - Verify that ctrlb_canister is properly whitelisted

```bash
# from folder backend/ctrlb_canister:

# Activate the same python environment as you defined for deploying the LLMs
# (This might not be needed, but I did it this way...)
conda activate icpp_llm

# Use correct dfx identity
dfx identity use icpp-llm

# Check whitelisting
scripts/whitelist-check.sh --network ic
```

### 5 - Whitelist bioniq's nft_canister with the ctrlb_canister

- Update value of `BIONIQ_PRINCIPAL` in `backend/ctrlb_canister/scripts/whitelist.sh`

- run:
```bash
# from folder backend/ctrlb_canister:

# Activate the same python environment as you defined for deploying the LLMs
# (This might not be needed, but I did it this way...)
conda activate icpp_llm

# Use correct dfx identity
dfx identity use icpp-llm

# Deploy
scripts/whitelist.sh --network ic

# See all the whitelisted principals
dfx canister --ic call ctrlb_canister WhitelistedPrincipals
```


### 6 - Optional: Deploy the bioniq_mock canister

```bash
# from folder backend/bioniq_mock:

# Activate the same python environment as you defined for deploying the LLMs
# (This might not be needed, but I did it this way...)
conda activate icpp_llm

# Use correct dfx identity
dfx identity use icpp-llm

# Deploy
scripts/deploy.sh --network ic
```

Note:
- Whitelist logic will fail. 
- We need to update the ctrlb_canister, to whitelist bioniq_mock canister. 


### 7 - Optional: Whitelist the bioniq_mock canister

- Update value of `BIONIQ_PRINCIPAL` in `backend/ctrlb_canister/scripts/whitelist.sh`
  - give it the value of `bioniq_mock/canister_ids.json` 

run: whitelist the bioniq_mock canister. This will add, not replace...

```bash
# from folder backend/ctrlb_canister:

# Activate the same python environment as you defined for deploying the LLMs
# (This might not be needed, but I did it this way...)
conda activate icpp_llm

# Use correct dfx identity
dfx identity use icpp-llm

# Deploy
scripts/whitelist.sh --network ic

# See all the whitelisted principals
dfx canister --ic call ctrlb_canister WhitelistedPrincipals
```

### 8 - OPTIONAL: Verify that bioniq_mock is properly whitelisted

```bash
# from folder backend/bioniq_mock:

# Activate the same python environment as you defined for deploying the LLMs
# (This might not be needed, but I did it this way...)
conda activate icpp_llm

# Use correct dfx identity
dfx identity use icpp-llm

# Check
scripts/whitelist-check.sh --network ic
```


# Testing

## Run test script

```bash
# from folder backend/ctrlb_canister: 
scripts/test.sh --network ic
```

## Test ctrlb_canister with dfx

```bash
# from folder backend/ctrlb_canister: 
dfx canister --ic call ctrlb_canister whoami

# Run with same identity used to deploy (as a controller)
$ dfx canister --ic call ctrlb_canister amiController
(variant { Ok = record { status_code = 200 : nat16 } })

# See all the whitelisted principals
$ dfx canister --ic call ctrlb_canister WhitelistedPrincipals
(
  vec {
    principal "62yam-niaaa-aaaaj-qnfza-cai";
    principal "yewhw-wqaaa-aaaaj-qnfnq-cai";
  },
)

# This call checks if the ctrlb_canister is whitelisted in the llm_0
$ dfx canister --ic call ctrlb_canister isWhitelistLogicOk
(variant { Ok = record { status_code = 200 : nat16 } })

# StoryGet will return an #Err if it is called before StoryUpdate is called
dfx canister --ic call ctrlb_canister StoryGet '(record {storyID="0-1"; storyPrompt="Charles loves ice cream."})'
(variant { Err = variant { Other = "storyID 0-1 does not yet exist." } })

# Call the ctrlb_canister StoryUpdate endpoint
dfx canister --ic call ctrlb_canister StoryUpdate '(record {storyID="0-1"; storyPrompt="Charles loves ice cream."})'

# While it is generating,, you can keep track of the story generation progress
# Just call it multiple times as the generation is going on...
dfx canister --ic call ctrlb_canister StoryGet '(record {storyID="0-1"; storyPrompt="Charles loves ice cream."})'

# Optional: Test the ctrlb_canister StoryUpdate endpoint
dfx canister --ic call ctrlb_canister StoryUpdate '(record {storyID="0-1"; storyPrompt="Charles loves ice cream."})'
```

## Test bioniq_mock with dfx

```bash
# from folder backend/bioniq_mock: 
dfx canister --ic call bioniq_mock whoami

# Run with same identity used to deploy (as a controller)
$ dfx canister --ic call bioniq_mock amiController
(variant { Ok = record { status_code = 200 : nat16 } })

# This call checks if the ctrlb_canister is whitelisted in the llm_0
$ dfx canister --ic call bioniq_mock isWhitelistLogicOk
(variant { Ok = record { status_code = 200 : nat16 } })

# Test the bioniq_mock StoryUpdate endpoint
dfx canister --ic call bioniq_mock StoryUpdate '(record {storyID="0-1"; storyPrompt="Charles loves ice cream."})'
```
