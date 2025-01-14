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

# When deploying to IC, we deploy to a specific subnet

# none will not use subnet parameter in deploy to ic
SUBNET="none"
# SUBNET="qdvhd-os4o2-zzrdw-xrcv4-gljou-eztdp-bj326-e6jgr-tkhuc-ql6v2-yqe"
# SUBNET="jtdsg-3h6gi-hs7o5-z2soi-43w3z-soyl3-ajnp3-ekni5-sw553-5kw67-nqe"
# SUBNET="lspz2-jx4pu-k3e7p-znm7j-q4yum-ork6e-6w4q6-pijwq-znehu-4jabe-kqe"

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
echo "Building the wasm for the llms"
cd ../../../icpp_llm/llama2_c && icpp build-wasm
cd ../../charles/backend/llms/

echo " "
echo "==================================================="
echo "Deploying $NUM_LLMS_DEPLOYED llms to subnet $SUBNET"
llm_id_start=0
llm_id_end=$((NUM_LLMS_DEPLOYED - 1))

# deploying the canisters must be done sequentially
for i in $(seq $llm_id_start $llm_id_end)
do
    echo " "
    echo "--------------------------------------------------"
    echo "Deploying the wasm to llm_$i"
    if [ "$NETWORK_TYPE" = "ic" ]; then
        if [ "$SUBNET" = "none" ]; then
            dfx deploy llm_$i -m reinstall --yes --network $NETWORK_TYPE
        else
            dfx deploy llm_$i -m reinstall --yes --network $NETWORK_TYPE --subnet $SUBNET
        fi
    else
        dfx deploy llm_$i -m reinstall --yes --network $NETWORK_TYPE
    fi 
done

# Initilizing the llms does not always work in parallel, so now also done sequential
for i in $(seq $llm_id_start $llm_id_end)
do
    (  # Start a subshell to run the commands in parallel for each llm
        

        # Temporary file to store timing for each NFT
        temp_file=$(mktemp)

        echo "Initializing llm_$i, writing output to $temp_file"

        echo " " >> $temp_file
        echo "--------------------------------------------------" >> $temp_file
        echo "Deploying the wasm to llm_$i" 
        echo "Deploying the wasm to llm_$i" >> $temp_file >> $temp_file
        yes | dfx deploy llm_$i -m reinstall --network $NETWORK_TYPE >> $temp_file

        echo " " >> $temp_file
        echo "--------------------------------------------------" >> $temp_file
        echo "Setting canister mode for llm_$i"
        echo "Setting canister mode for llm_$i" >> $temp_file
        output=$(dfx canister call llm_$i set_canister_mode nft-ordinal --network $NETWORK_TYPE)

        if [ "$output" != "(variant { Ok = record { status_code = 200 : nat16 } })" ]; then
            echo "llm_$i set_canister_mode failed. Exiting." >> $temp_file
            echo $output >> $temp_file
            echo "****************************************************************"
            echo "llm_$i set_canister_mode failed. Exiting."
            cat $temp_file
            rm $temp_file
            echo "****************************************************************"
            exit 1
        else
            echo "llm_$i set_canister_mode succeeded." >> $temp_file
        fi

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
        echo "Calling nft_init endpoint for llm_$i"
        echo "Calling nft_init endpoint for llm_$i" >> $temp_file
        python -m scripts.nft_init --network $NETWORK_TYPE --canister llm_$i --nft-supply-cap 0 --nft-symbol CHARLES --nft-name "CHARLES" --nft-description "Charles is an AI NFT, running on the Internet Computer."  >> $temp_file
        # Check the exit status of the Python script
        if [ $? -ne 0 ]; then
            echo "scripts.nft_init for llm_$i exited with an error. Exiting the bash script." >> $temp_file
            echo $output >> $temp_file
            echo "****************************************************************"
            echo "scripts.nft_init for llm_$i exited with an error. Exiting the bash script."
            cat $temp_file
            rm $temp_file
            echo "****************************************************************"
            exit 1
        fi

        echo " " >> $temp_file
        echo "--------------------------------------------------" >> $temp_file
        echo "Upload the model & tokenizer to llm_$i"
        echo "Upload the model & tokenizer to llm_$i" >> $temp_file
        # python -m scripts.upload --network $NETWORK_TYPE --canister llm_$i --model models/stories15Mtok4096.bin --tokenizer tokenizers/tok4096.bin
        # python -m scripts.upload --network $NETWORK_TYPE --canister llm_$i --model models/stories15Mtok4096.bin --tokenizer tokenizers/tok4096.bin >> $temp_file
        # python -m scripts.upload --network $NETWORK_TYPE --canister llm_$i --model stories260K/stories260K.bin --tokenizer stories260K/tok512.bin
        # python -m scripts.upload --network $NETWORK_TYPE --canister llm_$i --model stories260K/stories260K.bin --tokenizer stories260K/tok512.bin >> $temp_file
        # The charles model, trained with IC specific stories
        python -m scripts.upload --network $NETWORK_TYPE --canister llm_$i --model ../../charles/models/out-09/model.bin --tokenizer ../../charles/models/out-09/tok4096.bin

        if [ $? -ne 0 ]; then
            echo "scripts.upload for llm_$i exited with an error. Exiting the bash script." >> $temp_file
            echo $? >> $temp_file
            echo "****************************************************************"
            echo "scripts.upload for llm_$i exited with an error. Exiting the bash script."
            cat $temp_file
            rm $temp_file
            echo "****************************************************************"
            exit 1
        fi

        # All good if we come here
        echo "llm_$i successfully deployed, now deploy ctrlb_canister, and then run whitelist of llms"
        rm $temp_file # Clean up the temporary file

    # ) & # Run the subshell in the background  (parallel processing)
    ) # Run the subshell in the foreground  (sequential processing)
done
wait # Wait for all background processes to finish