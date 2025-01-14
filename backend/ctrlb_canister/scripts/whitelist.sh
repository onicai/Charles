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
BIONIQ_PRINCIPAL="---"

# Parse command line arguments for network type
while [ $# -gt 0 ]; do
    case "$1" in
        --network)
            shift
            if [ "$1" = "local" ] || [ "$1" = "ic" ]; then
                NETWORK_TYPE=$1
                if [ "$NETWORK_TYPE" = "ic" ]; then
                    # Bioniq's prod subnet - prod
                    BIONIQ_PRINCIPAL="syhes-kiaaa-aaaaj-azxda-cai"
                    # My bioniq_mock canister
                    # BIONIQ_PRINCIPAL="62yam-niaaa-aaaaj-qnfza-cai"
                fi
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
echo "Checking health endpoint"
output=$(dfx canister call ctrlb_canister health --network $NETWORK_TYPE )

if [ "$output" != "(variant { Ok = record { status_code = 200 : nat16 } })" ]; then
    echo "ERROR: ctrlb_canister health check failed. Exiting."
    exit 1
else
    echo "ctrlb_canister health check succeeded."
fi

echo "==================================================="
echo "Whitelisting bioniq principal $BIONIQ_PRINCIPAL with ctrlb_canister"

output=$(dfx canister call ctrlb_canister whitelistPrincipal "(principal \"$BIONIQ_PRINCIPAL\")" --network $NETWORK_TYPE )

if [ "$output" != "(variant { Ok = record { status_code = 200 : nat16 } })" ]; then
    echo "ERROR: Whitelisting bioniq principal $BIONIQ_PRINCIPAL with ctrlb_canister failed. Exiting."
    exit 1
else
    echo "Whitelisting bioniq principal $BIONIQ_PRINCIPAL with ctrlb_canister succeeded."
fi