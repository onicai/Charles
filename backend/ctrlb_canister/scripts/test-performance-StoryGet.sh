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
echo "Checking readiness endpoint"
output=$(dfx canister call ctrlb_canister ready --network $NETWORK_TYPE)

if [ "$output" != "(variant { Ok = record { status_code = 200 : nat16 } })" ]; then
    echo "ctrlb_canister is not ready. Exiting."
    exit 1
else
    echo "ctrlb_canister is ready for inference."
fi

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

            STORY_ID="$i-$i"
            STORY_PROMPT=" "
            command="dfx canister call ctrlb_canister StoryGet \"(record {storyID=\\\"$STORY_ID\\\"; storyPrompt=\\\"$STORY_PROMPT\\\"})\" --network $NETWORK_TYPE"
            echo "Calling StoryGet endpoint with: $command"
            output=$(eval "$command")

            output_grep=$(echo $output | grep -o "( variant { Ok")
            if [ "$output_grep" != "( variant { Ok" ]; then
                echo "Error calling StoryGet for storyID $STORY_ID - Exiting."
                echo "$output"
                rm -f $temp_results_file # Clean up the temporary files
                rm -f $temp_timing_file
                exit 1
            else
                echo "$output" >> $temp_results_file
                echo "Successfully called StoryGet for storyID $STORY_ID"
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