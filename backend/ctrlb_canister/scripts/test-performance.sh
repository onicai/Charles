#!/bin/bash

#######################################################################
# For Linux & Mac
#######################################################################
export PYTHONPATH="${PYTHONPATH}:$(realpath ../../../icpp_llm/llama2_c)"


#######################################################################
# --network [local|ic]
#######################################################################

# Default network type is local
NETWORK_TYPE="local"
NUM_STORIES=12
NUM_LOOPS=1
TEST_NAME=""
# NUM_LLMS_ROUND_ROBIN=1 # how many LLMs we use for our test

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

# Predefined list of STORY_PROMPTS
STORY_PROMPTS=(
    "In a cozy room, Charles the Teddy Bear loved counting shiny gold coins."
    "Charles looked at the wooden desk filled with piles of paper and exciting ideas."
    "In a cozy garden, Charles the teddy bear smiled brightly."
    "In the heart of a buzzing computer room, Charles the teddy bear waved."
    "Filled with wonder, Charles stepped forward into the blinking lights."
    "In a colorful art gallery, Charles the teddy bear stood with a smile."
    "Charles the bear spotted the sparkling infinity symbol in the darkening sky."
    "Charles felt a soft, purple mist as he gazed skyward, ready for an adventure."
    "In a hidden cave, Charles the teddy bear discovered a glowing computer."
    "Charles was curious as a tiny bear peeked out from behind the shelves near him."
    "In the cozy corner of a magical room, Charles the Teddy Bear stood proudly."
    "Children loved to gather around Charles, listening to his adventurous tales."
    "Charles smiled, dreaming of all the fun he could have with new friends."
     "Beside Charles, a little pot held his favorite colorful pens and pencils."
    "Charles heard the floating coins whispering tales of brave explorers and hidden treasures."
    "Charles the bear danced down the colorful hallway, grinning from ear to ear."
    "Charles laughed as the colors sparkled like stars in the night sky."
)

# Function to get a random STORY_PROMPT
get_random_prompt() {
    local index=$((RANDOM % ${#STORY_PROMPTS[@]}))
    echo "${STORY_PROMPTS[$index]}"
}


#######################################################################



echo " "
echo "--------------------------------------------------"
echo "Checking readiness endpoint"
output=$(dfx canister call ctrlb_canister ready --network $NETWORK_TYPE)

if [ "$output" != "(variant { Ok = record { status_code = 200 : nat16 } })" ]; then
    echo "ctrlb_canister is not ready. Exiting."
    exit 1
else
    echo "ctrlb_canister is ready for inference."
fi

# echo " "
# echo "--------------------------------------------------"
# echo "Setting NUM_LLMS_ROUND_ROBIN to $NUM_LLMS_ROUND_ROBIN"
# output=$(dfx canister call ctrlb_canister setRoundRobinLLMs "($NUM_LLMS_ROUND_ROBIN)" --network $NETWORK_TYPE)

# if [ "$output" != "(variant { Ok = record { status_code = 200 : nat16 } })" ]; then
#     echo "setRoundRobinLLMs call failed. Exiting."
#     exit 1
# else
#     echo "setRoundRobinLLMs was successful."
# fi

echo " "
echo "--------------------------------------------------"
echo "Calling the AI for $NUM_STORIES concurrent users."

# Start timer for the entire operation
overall_start=$(date +%s)

# Temporary files to store timing for each User
temp_results_file=$(mktemp)
temp_timing_file=$(mktemp)

story_id_start=0
story_id_end=$((NUM_STORIES - 1))
for outer_loop in $(seq 1 $NUM_LOOPS)
do
    echo "Starting outer loop iteration $outer_loop"

    for i in $(seq $story_id_start $story_id_end)
    do
        (  # Start a subshell to run the commands in parallel for each llm

            # Start timer for each story's process
            story_start=$(date +%s)

            # IDENTITY="demo$i"
            # command="dfx canister call --identity $IDENTITY ctrlb_canister Inference \"(record {prompt=\\\"\\\"; steps=60; temperature=0.0; topp=0.9; rng_seed=0})\" --network $NETWORK_TYPE"
            # STORY_ID="$TEST_NAME-$outer_loop-$i-$i"
            STORY_ID="$i-$i"
            STORY_PROMPT=$(get_random_prompt)
            # command="dfx canister call ctrlb_canister NFTUpdate \"(record {token_id=\\\"$TOKEN_ID\\\"})\" --network $NETWORK_TYPE"
            command="dfx canister call ctrlb_canister StoryUpdate \"(record {storyID=\\\"$STORY_ID\\\"; storyPrompt=\\\"$STORY_PROMPT\\\"})\" --network $NETWORK_TYPE"
            echo "Calling StoryUpdate endpoint with: $command"
            output=$(eval "$command")

            output_grep=$(echo $output | grep -o "( variant { Ok")
            if [ "$output_grep" != "( variant { Ok" ]; then
                echo "Error calling StoryUpdate for storyID $STORY_ID - Exiting."
                echo "$output"
                rm -f $temp_results_file # Clean up the temporary files
                rm -f $temp_timing_file
                exit 1
            else
                echo "$output" >> $temp_results_file
                echo "Successfully called StoryUpdate for storyID $STORY_ID"
                echo "$output"
            fi

            # End timer for this User's process and calculate duration
            story_end=$(date +%s)
            story_duration=$((story_end - story_start))
            
            # Write the duration to the temporary file, for final summary
            echo "Story $i inference duration: $story_duration seconds" >> $temp_results_file
            echo $story_duration >> $temp_timing_file # Append duration to file for averaging later


        ) & # Run the subshell in the background  (parallel processing)
        # ) # Run the subshell in the foreground  (sequential processing)
    done
wait # Wait for all background processes to finish 
done


# End timer for the entire operation and calculate duration
overall_end=$(date +%s)
overall_duration=$((overall_end - overall_start))

# Sum all the durations stored in the temp_file
echo "--------------------------------------------------"
echo "Calculating average inference time from $temp_timing_file"
total_duration=0
story_count=0
max_duration=0
while read duration; do
    total_duration=$((total_duration + duration))
    story_count=$((story_count + 1))
    if [ "$duration" -gt "$max_duration" ]; then
        max_duration=$duration
    fi
done < $temp_timing_file
# Ensure there are stories counted
if [ "$story_count" -eq 0 ]; then
    echo "Error: No stories found."
    exit 1
fi
# Calculate average
average_duration=$(echo "$total_duration / $story_count" | bc)
echo "Story Count     : $story_count"
echo "Average duration: $average_duration"
echo "Max duration    : $max_duration"

wait # Wait for all background processes to finish 

# Print out the durations for each User
cat $temp_results_file
rm -f $temp_results_file # Clean up the temporary file
rm -f $temp_timing_file

echo "--------------------------------------------------"
echo "All updates completed in $overall_duration seconds."
echo "Slowest LLM took         $max_duration seconds."
echo "All updates completed in $average_duration seconds on average per story."

echo "--------------------------------------------------"
echo "DONE!"