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
CTRLB_PRINCIPAL="---"

# Parse command line arguments for network type
while [ $# -gt 0 ]; do
    case "$1" in
        --network)
            shift
            if [ "$1" = "local" ] || [ "$1" = "ic" ]; then
                NETWORK_TYPE=$1
                CTRLB_PRINCIPAL="b77ix-eeaaa-aaaaa-qaada-cai"
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
llm_id_start=0
llm_id_end=11

echo -n "- dfx identity             : "; dfx identity whoami
echo -n "- Wallet balance           : "; dfx wallet --network $NETWORK_TYPE balance

for i in $(seq $llm_id_start $llm_id_end)
do
	echo -n "- llm_$i "; dfx canister status llm_$i --network $NETWORK_TYPE 2>&1 | grep "Memory Size: "
done

echo -n "- $CTRLB_PRINCIPAL "; dfx canister status $CTRLB_PRINCIPAL --network $NETWORK_TYPE 2>&1 | grep "Memory Size: "