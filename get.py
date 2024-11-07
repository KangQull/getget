import os
import sys
import time
import subprocess
import re                                                                  import getpass  # Import the getpass module to hide input
os.system("clear")                                                         PURPLE = '\033[1;33m'
RESET = '\033[0m'

# Function to display the progress bar based on progress data
def progress_bar(process):
    bar_length = 50
    progress = 0
    while process.poll() is None:  # Check if the process is still running
        # Read stderr line by line to capture progress
        output = process.stderr.readline()

        if output == b"":
            break  # End of output

        # Decode the output to string
        output = output.decode("utf-8")

        # Look for the progress line, which looks like "Receiving objects: 100% (100/100), 10 KiB | 10.00 MiB/s"
        match = re.search(r'(\d+)%.*?(\d+)/(\d+)', output)
        if match:
            # Extract the progress percentage
            percent = int(match.group(1))
            # Update the progress bar
            filled_length = int((percent / 100) * bar_length)
            bar = f"{PURPLE}[{'#' * filled_length}{'.' * (bar_length - filled_length)}]{RESET} {percent}%"
            sys.stdout.write(f"\r{bar}")
            sys.stdout.flush()

        time.sleep(0.1)

    sys.stdout.write(f"\r{PURPLE}[{'#' * bar_length}]{RESET} 100%\n")
    sys.stdout.flush()

# Function to clone repository with token
def clone_repo():
    repo_name = "docker"

    if os.path.isdir(repo_name):
        print(f"{PURPLE}Folder '{repo_name}' already exists. Cloning aborted.{RESET}")
        sys.exit(1)

    # Use getpass to securely take the token as input without showing it
    token = getpass.getpass("Enter your Acces Key Personal: ")
    print(f"\n{PURPLE}Please wait...{RESET}")

    repo_url = "github.com/KangQull/docker.git"  # Correct URL format, no `https://`

    # Construct the complete URL for cloning
    git_url = f"https://x-access-token:{token}@{repo_url}"

    # Run git clone with token
    cmd = f"git clone --quiet {git_url}"
    process = subprocess.Popen(cmd, shell=True, stdout=subprocess.PIPE, stderr=subprocess.PIPE)

    # Show progress bar while cloning
    progress_bar(process)

    # Wait for the process to finish
    process.wait()

    # Check if the process was successful
    if process.returncode != 0:
        # Capture the error details
        stderr = process.stderr.read().decode("utf-8")
        print(f"\n{PURPLE}Cloning failed. Ensure your Personal Access Token is correct.{RESET}")
        print(f"\nError Details:\n{stderr}")
        sys.exit(1)

    print(f"\n{PURPLE}Download complete!{RESET}")
    time.sleep(3)

    # Copy the script to home directory
    os.system(f"cp {repo_name}/windocker.sh ~/")

    # Clean up repository folder
    os.system(f"rm -rf {repo_name}")

    # Countdown before running the script
    print(f"{PURPLE}Running script in 5 seconds...{RESET}")
    for i in range(5, 0, -1):
        sys.stdout.write(f"\r{PURPLE}{i} seconds remaining...{RESET}")
        sys.stdout.flush()
        time.sleep(1)

    # Run the script
    os.system("bash ~/windocker.sh")

if __name__ == "__main__":
    clone_repo()
