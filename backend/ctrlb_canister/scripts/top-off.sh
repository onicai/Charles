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

# Define the threshold balance in TCycles (When to top off)
TOPPED_OFF_BALANCE_TRESHOLD_TC=5 
TOPPED_OFF_BALANCE_TRESHOLD=$(echo "$TOPPED_OFF_BALANCE_TRESHOLD_TC * 1000000000000" | bc)
TOPPED_OFF_BALANCE_TRESHOLD=$(printf "%.0f" $TOPPED_OFF_BALANCE_TRESHOLD)

# Define the target balance in TCycles (To top off too)
TOPPED_OFF_BALANCE_TARGET_TC=8
TOPPED_OFF_BALANCE_TARGET=$(echo "$TOPPED_OFF_BALANCE_TARGET_TC * 1000000000000" | bc)
TOPPED_OFF_BALANCE_TARGET=$(printf "%.0f" $TOPPED_OFF_BALANCE_TARGET)


echo " "
echo "--------------------------------------------------"
echo -n "- dfx identity             : "; dfx identity whoami
echo -n "- Wallet balance           : "; dfx wallet --network $NETWORK_TYPE balance

echo " "
echo "--------------------------------------------------"
CURRENT_BALANCE=$(dfx canister --network $NETWORK_TYPE status ctrlb_canister 2>&1 | grep "Balance:" | awk '{gsub("_", ""); print $2}')
NEED_CYCLES_THRESHOLD=$(echo "$TOPPED_OFF_BALANCE_TRESHOLD - $CURRENT_BALANCE" | bc)
NEED_CYCLES_TARGET=$(echo "$TOPPED_OFF_BALANCE_TARGET - $CURRENT_BALANCE" | bc)
if [ $(echo "$NEED_CYCLES_THRESHOLD > 0" | bc) -eq 1 ]; then
    CANISTER_ID=$(dfx canister --network $NETWORK_TYPE id ctrlb_canister)
    echo "Sending $NEED_CYCLES_TARGET cycles to ctrlb_canister"
    dfx wallet send $CANISTER_ID $NEED_CYCLES_TARGET --network $NETWORK_TYPE
else
    # echo "No need to send cycles to ctrlb_canister. Balance = $CURRENT_BALANCE"
    echo "No need to send cycles to ctrlb_canister. Balance = $(echo "scale=2; $CURRENT_BALANCE / 1000000000000" | bc) TCycles"

fi

echo " "
echo "--------------------------------------------------"
echo -n "- dfx identity             : "; dfx identity whoami
echo -n "- Wallet balance after     : "; dfx wallet --network $NETWORK_TYPE balance
