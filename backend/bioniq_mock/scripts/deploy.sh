#!/bin/sh

#######################################################################
# For Linux & Mac
#######################################################################
export PYTHONPATH="${PYTHONPATH}:$(realpath ../../../icpp_llm/llama2_c)"


#######################################################################
# --network [local|ic]
#######################################################################

# Default network type is local
NETWORK_TYPE="local"

SUBNET="jtdsg-3h6gi-hs7o5-z2soi-43w3z-soyl3-ajnp3-ekni5-sw553-5kw67-nqe"

# Parse command line arguments for network type
while [ $# -gt 0 ]; do
    case "$1" in
        --network)
            shift
            if [ "$1" = "local" ] || [ "$1" = "ic" ]; then
                NETWORK_TYPE=$1
            else
                echo "Invalid network type: $1. Use 'local' or 'ic'."
                exit 1
            fi
            shift
            ;;
        *)
            echo "Unknown argument: $1"
            echo "Usage: $0 --network [local|ic]"
            exit 1
            ;;
    esac
done

echo "Using network type: $NETWORK_TYPE"

#######################################################################

echo " "
echo "--------------------------------------------------"
echo "Deploying the bioniq_mock canister"

if [ "$NETWORK_TYPE" = "ic" ]; then
    echo dfx deploy bioniq_mock -m reinstall --yes --network $NETWORK_TYPE --subnet $SUBNET
    dfx deploy bioniq_mock -m reinstall --yes --network $NETWORK_TYPE --subnet $SUBNET
else
    echo dfx deploy bioniq_mock -m reinstall --yes --network $NETWORK_TYPE
    dfx deploy bioniq_mock -m reinstall --yes --network $NETWORK_TYPE
fi

echo " "
echo "--------------------------------------------------"
echo "Checking health endpoint"
output=$(dfx canister call bioniq_mock health --network $NETWORK_TYPE)

if [ "$output" != "(variant { Ok = record { status_code = 200 : nat16 } })" ]; then
    echo "bioniq_mock is not healthy. Exiting."
    exit 1
else
    echo "bioniq_mock is healthy."
fi

echo " "
echo "--------------------------------------------------"
echo "Generating bindings for a frontend"
dfx generate

echo " "
echo "--------------------------------------------------"
echo "Checking whitelist logic"
output=$(dfx canister call bioniq_mock isWhitelistLogicOk --network $NETWORK_TYPE)

if [ "$output" != "(variant { Ok = record { status_code = 200 : nat16 } })" ]; then
    echo "ERROR: bioniq_mock is not whitelisted. Make sure to update the ctrlb_canister."
    exit 1
else
    echo "bioniq_mock is whitelisted."
fi