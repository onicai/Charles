"""
Script to run each top-off.sh at a certain interval.
This script goes into an endless loop, and is run as follows:

python top_off_runner.py

"""
import subprocess
import time
import os

# Directories and script names
script1_dir = "/Users/arjaan/icppWorld/repos/charles/backend/ctrlb_canister"
script1_name = "scripts/top-off.sh"

script2_dir = "/Users/arjaan/icppWorld/repos/charles/backend/llms"
script2_name = "scripts/top-off.sh"

# Time interval in seconds (e.g., 1800 seconds = 30 minutes)
interval = 1800

print("Starting the script execution loop. Press Ctrl+C to stop.")

def run_script(script_dir, script_name, script_label):
    try:
        # Change to the script's directory
        os.chdir(script_dir)
        # Run the script and print output directly to the screen
        subprocess.run(
            ["bash", script_name, "--network", "ic"],
            check=True
        )

        # # Run the script
        # result = subprocess.run(
        #     ["bash", script_name, "--network", "ic"],
        #     capture_output=True,
        #     text=True
        # )
        # print(f"[{time.strftime('%Y-%m-%d %H:%M:%S')}] {script_label} executed.")
        # if result.stdout:
        #     print("Output:", result.stdout.strip())
        # if result.stderr:
        #     print("Errors:", result.stderr.strip())
    except Exception as e:
        print(f"An error occurred while running {script_label}: {e}")

try:
    while True:
        print("\nRunning Script 1...")
        run_script(script1_dir, script1_name, "Script 1")

        print("\nRunning Script 2...")
        run_script(script2_dir, script2_name, "Script 2")

        # Wait for the specified interval before running again
        print(f"\nSleeping for {interval} seconds...\n")
        time.sleep(interval)

except KeyboardInterrupt:
    print("Loop stopped by user.")
