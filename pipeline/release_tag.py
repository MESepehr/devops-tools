#!/usr/bin/env python3

# Import modules we'll use
import subprocess      # Used to execute git commands
import sys             # Used to exit the program
from datetime import datetime   # Used to get current date and time


# ------------------------------------------------------------
# List of allowed tag prefixes
# ------------------------------------------------------------
PREFIXES = [
    "pro-baz-tv",
    "pro-baz-front",
    "pro-baz-panel",
]


# ------------------------------------------------------------
# Runs any git command
#
# Example:
# run(["git", "fetch", "origin"])
# ------------------------------------------------------------
def run(command):
    subprocess.run(command, check=True)


# ------------------------------------------------------------
# Returns the current branch
#
# git rev-parse --abbrev-ref HEAD
#
# Example output:
# main
# betakarmaye
# feature/login
# ------------------------------------------------------------
def get_current_branch():
    result = subprocess.run(
        ["git", "rev-parse", "--abbrev-ref", "HEAD"],
        capture_output=True,
        text=True,
        check=True,
    )

    return result.stdout.strip()


# ------------------------------------------------------------
# Checks if the tag already exists
#
# git tag -l pro-kar-202607081545
# ------------------------------------------------------------
def tag_exists(tag):

    result = subprocess.run(
        ["git", "tag", "-l", tag],
        capture_output=True,
        text=True,
    )

    return result.stdout.strip() == tag


# ------------------------------------------------------------
# Makes sure we're inside a git repository
#
# If not, the program stops.
# ------------------------------------------------------------
def ensure_git_repository():

    try:
        subprocess.run(
            ["git", "rev-parse", "--git-dir"],
            stdout=subprocess.DEVNULL,
            stderr=subprocess.DEVNULL,
            check=True,
        )

    except subprocess.CalledProcessError:
        print("❌ This folder is not a git repository.")
        sys.exit(1)


# ------------------------------------------------------------
# Main program starts here
# ------------------------------------------------------------
def main():

    # First make sure this is a git project
    ensure_git_repository()

    print("=" * 60)
    print("Git Release Tag Tool")
    print("=" * 60)

    # Get current branch
    current_branch = get_current_branch()

    print(f"\nCurrent branch: {current_branch}")

    # --------------------------------------------------------
    # Update local repository
    # --------------------------------------------------------
    print("\nFetching latest changes...")
    run(["git", "fetch", "origin"])

    print("\nPulling latest changes...")
    run(["git", "pull", "origin"])

    # --------------------------------------------------------
    # Show menu
    # --------------------------------------------------------
    print("\nChoose tag prefix:\n")

    for index, prefix in enumerate(PREFIXES, start=1):
        print(f"{index}. {prefix}")

    # Keep asking until user enters a valid number
    while True:

        try:
            choice = int(input("\nEnter number: "))

            if 1 <= choice <= len(PREFIXES):
                break

            print("Invalid choice.")

        except ValueError:
            print("Please enter a number.")

    # User selection
    prefix = PREFIXES[choice - 1]

    # --------------------------------------------------------
    # Business Rule
    #
    # Pro tags must be created only from main
    # --------------------------------------------------------
    # if prefix.startswith("pro-") and current_branch != "main":

    #     print("\n==============================================")
    #     print("ERROR")
    #     print("==============================================")
    #     print(f"Current Branch : {current_branch}")
    #     print(f"Selected Prefix: {prefix}")
    #     print()
    #     print("Pro tags can only be created from the MAIN branch.")
    #     print("Please checkout main first.")
    #     print("==============================================")

    #     sys.exit(1)

    # --------------------------------------------------------
    # Generate timestamp
    #
    # Example:
    #
    # 202607081530
    # --------------------------------------------------------
    timestamp = datetime.now().strftime("%Y%m%d%H%M")

    # Final tag
    tag = f"{prefix}-{timestamp}"

    print("\nGenerated Tag:")
    print(tag)

    # --------------------------------------------------------
    # Prevent duplicate tag
    # --------------------------------------------------------
    if tag_exists(tag):
        print("\nTag already exists.")
        sys.exit(1)

    # --------------------------------------------------------
    # Ask confirmation
    # --------------------------------------------------------
    confirm = input("\nCreate and Push? (y/N): ")

    if confirm.lower() != "y":
        print("Cancelled.")
        return

    # --------------------------------------------------------
    # Create Tag
    # --------------------------------------------------------
    print("\nCreating tag...")

    run(["git", "tag", tag])

    # --------------------------------------------------------
    # Push Tag
    # --------------------------------------------------------
    print("Pushing tag...")

    run(["git", "push", "origin", tag])

    print("\nDone!")
    print(f"Created tag: {tag}")


# ------------------------------------------------------------
# Program starts here
# ------------------------------------------------------------
if __name__ == "__main__":

    try:
        main()

    except subprocess.CalledProcessError:
        print("\nA git command failed.")
        sys.exit(1)

    except KeyboardInterrupt:
        print("\nCancelled.")
        sys.exit(0)