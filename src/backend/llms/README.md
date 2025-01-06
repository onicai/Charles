## Setup

- clone this repo and `icpp_llm` repo as siblings

- prepare a conda environment with python dependencies of `icpp_llm` repo

  ```bash
  conda create --name icpp_llm python=3.11
  conda activate icpp_llm

  # from icpp_llm/llama2_c (the icpp_llm repo!)
  pip install uv
  uv pip install -r requirements.txt

  # We used dfx 0.24.2 (installed with dfxvm)
  sh -ci "$(curl -fsSL https://internetcomputer.org/install.sh)"

  dfx --version
  ```

## Deploy

### Deploy the LLM canisters

```bash
# from folder backend/llms:

conda activate icpp_llm

# when running local, start dfx
dfx start --clean

# WARNING: This will re-deploy all the llm canisters with loss of all existing data!
scripts/deploy.sh --network [local/ic]
```


When deploying local, before continuing, go to the ctrlb_canister folder, and deploy it.
The whitelist check will fail, but we need to do this, to get the canister id.

If you already deployed before, or you are redoing it from scratch in the same order
you can skip this step, because the ctrlb_canister ID will be the same.

```bash
# from ctrlb_canister folder
% scripts/deploy.sh --network [local/ic]
ctrlb_canister canister created with canister id: b77ix-eeaaa-aaaaa-qaada-cai 
```

## Whitelist the ctrlb_canister

```bash
# Update in all the scripts:
NETWORK_TYPE="local"
CTRLB_PRINCIPAL="b77ix-eeaaa-aaaaa-qaada-cai"

# Then run it
scripts/whitelist.sh --network [local/ic]
```

## Verify

```bash
scripts/ready.sh --network [local/ic]
```

## Check cycle balance

```bash
scripts/balance.sh --network [local/ic]
```

## Top up cycles

```bash
# Edit the value of TOPPED_OFF_BALANCE_T in the script.
scripts/top-off.sh --network [local/ic]
```

## OLD...

```bash
# Test the individual NFTs
curl https://lkh5o-3yaaa-aaaag-acguq-cai.raw.icp0.io/api/nft/0
# Optionally format it with jp
curl https://lkh5o-3yaaa-aaaag-acguq-cai.raw.icp0.io/api/nft/0 | jp "@"
```

## Appendix A: Prompt Testing

Prompt testing can be done from llama2.c repo directly, without deploying to a canister:

```bash
git clone https://github.com/icppWorld/llama2.c
cd llama2.c

conda create --name llama2-c python=3.11
conda activate llama2-c
pip install -r requirements.txt

make run

# Use the model that we will deploy to the Charles canister...

# 15M
./run ../../../icpp_llm/llama2_c/models/stories15Mtok4096.bin -z ../../../icpp_llm/llama2_c/tokenizers/tok4096.bin -t 0.1 -p 0.9 -i "Charles is a teddy bear, but not like any"
```
