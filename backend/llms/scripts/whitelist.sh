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
NUM_LLMS_DEPLOYED=12
# local...
CTRLB_PRINCIPAL="be2us-64aaa-aaaaa-qaabq-cai"

# Parse command line arguments for network type
while [ $# -gt 0 ]; do
    case "$1" in
        --network)
            shift
            if [ "$1" = "local" ] || [ "$1" = "ic" ]; then
                NETWORK_TYPE=$1
                if [ "$NETWORK_TYPE" = "ic" ]; then
                    # new one, on bioniq's prod subnet
                    CTRLB_PRINCIPAL="tom4z-7yaaa-aaaaj-azxga-cai"
                    # old one, on bioniq's dev subnet
                    # CTRLB_PRINCIPAL="6t3lq-3aaaa-aaaaj-qnfyq-cai"
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
echo "==================================================="
echo "Whitelisting $CTRLB_PRINCIPAL with all $NUM_LLMS_DEPLOYED llms..."
llm_id_start=0
llm_id_end=$((NUM_LLMS_DEPLOYED - 1))

# Whitelisting with the llms can be done in parallel, using subshells
for i in $(seq $llm_id_start $llm_id_end)
do
    (  # Start a subshell to run the commands in parallel for each llm
        

        # Temporary file to store timing for each NFT
        temp_file=$(mktemp)

        echo "Whitelisting for llm_$i, writing output to $temp_file"

        echo " " >> $temp_file
        echo "--------------------------------------------------" >> $temp_file
        echo "Checking health endpoint for llm_$i"
        echo "Checking health endpoint for llm_$i" >> $temp_file
        output=$(dfx canister call llm_$i health --network $NETWORK_TYPE )

        if [ "$output" != "(variant { Ok = record { status_code = 200 : nat16 } })" ]; then
            echo "llm_$i health check failed. Exiting." >> $temp_file
            echo $output >> $temp_file
            echo "****************************************************************"
            echo "llm_$i health check failed. Exiting."
            cat $temp_file
            rm $temp_file
            echo "****************************************************************"
            exit 1
        else
            echo "llm_$i health check succeeded." >> $temp_file
        fi

        echo " " >> $temp_file
        echo "--------------------------------------------------" >> $temp_file
        echo "Whitelisting ctrlb_canister for llm_$i"
        echo "Whitelisting ctrlb_canister for llm_$i" >> $temp_file
        output=$(dfx canister call llm_$i nft_whitelist "(record { id = principal \"$CTRLB_PRINCIPAL\"; description = \"Local ctrlb_canister\"; })" --network $NETWORK_TYPE )

        if [ "$output" != "(variant { Ok = record { status_code = 200 : nat16 } })" ]; then
            echo "Whitelisting ctrlb_canister for llm_$i failed. Exiting." >> $temp_file
            echo $output >> $temp_file
            echo "****************************************************************"
            echo "Whitelisting ctrlb_canister for llm_$i failed. Exiting."
            cat $temp_file
            rm $temp_file
            echo "****************************************************************"
            exit 1
        else
            echo "Whitelisting ctrlb_canister for llm_$i worked."  >> $temp_file
        fi

        # All good if we come here
        echo "llm_$i successfully deployed."
        rm $temp_file # Clean up the temporary file

    ) & # Run the subshell in the background  (parallel processing)
    # ) # Run the subshell in the foreground  (sequential processing)
done
wait # Wait for all background processes to finish

# verify readiness of all llms in sequential mode
echo " "
echo "--------------------------------------------------"
echo "Checking readiness endpoint for all llms"
for i in $(seq $llm_id_start $llm_id_end)
do
    output=$(dfx canister call llm_$i ready --network $NETWORK_TYPE )

    if [ "$output" != "(variant { Ok = record { status_code = 200 : nat16 } })" ]; then
        echo "llm_$i is not ready. Exiting."
        echo $output
        exit 1
    else
        echo "llm_$i is ready."
    fi
done