#!/bin/bash

# internsctl - Custom Linux Command
# Version: v0.1.0
# Author: Pramod Singh

# DESCRIPTION
# internsctl is a custom Linux command that provides various functionalities for server management.

# FUNCTIONS

# Display the manual page
function display_manual() {
    echo "internsctl(1) - Custom Linux Command"
    echo " "
    echo "NAME"
    echo "    internsctl - custom Linux command for operations"
    echo " "
    echo "SYNOPSIS"
    echo "    internsctl [OPTIONS] COMMAND [arg...]"
    echo " "
    echo "DESCRIPTION"
    echo "    internsctl is a custom Linux command that provides various functionalities for server management."
    echo "    "
    echo "OPTIONS"
    echo "    man             Display manual page"
    echo "    --help          Display help information"
    echo "    --version       Display version information"
    echo " "
    echo "COMMANDS"
    echo "    cpu getinfo     Get CPU information"
    echo "    memory getinfo  Get memory information"
    echo "    user create     Create a new user"
    echo "    user list       List all users"
    echo "    user list --sudo-only  List users with sudo permissions"
    echo "    file getinfo    Get file information"
    echo " "
    echo "EXAMPLES"
    echo "    internsctl cpu getinfo"
    echo "    internsctl memory getinfo"
    echo "    internsctl user create <username>"
    echo "    internsctl user list"
    echo "    internsctl user list --sudo-only"
    echo "    internsctl file getinfo <file-name>"
}

# Display help information
function display_help() {
    display_manual
}

# Display version information
function display_version() {
    echo "internsctl v0.1.0"
}

# Get CPU information
function get_cpu_info() {
    lscpu
}

# Get memory information
function get_memory_info() {
    free
}

# Create a new user
function create_user() {
    local username=$1
    sudo useradd -m $username
    sudo passwd $username
}

# List all users
function list_users() {
    cut -d: -f1 /etc/passwd
}

# List users with sudo permissions
function list_sudo_users() {
    grep -Po '^sudo.+:\K.*$' /etc/group | tr ',' '\n'
}

# Get file information
function get_file_info() {
    local file=$1

    # Check if options are provided
    while [[ "$#" -gt 1 ]]; do
        case $2 in
            "--size" | "-s")
                stat -c%s $file
                return
                ;;
            "--permissions" | "-p")
                stat -c%a $file
                return
                ;;
            "--owner" | "-o")
                stat -c%U $file
                return
                ;;
            "--last-modified" | "-m")
                stat -c%y $file
                return
                ;;
            *)
                echo "Invalid option: $2"
                display_manual
                exit 1
                ;;
        esac
        shift
    done

    # Default output if no options are specified
    local size=$(stat -c%s $file)
    local permissions=$(stat -c%a $file)
    local owner=$(stat -c%U $file)
    local last_modified=$(stat -c%y $file)

    echo "File: $file"
    echo "Access: $permissions"
    echo "Size(B): $size"
    echo "Owner: $owner"
    echo "Modify: $last_modified"
}

# Parse command line arguments
case $1 in
    "man")
        display_manual
        ;;
    "--help")
        display_help
        ;;
    "--version")
        display_version
        ;;
    "cpu")
        case $2 in
            "getinfo")
                get_cpu_info
                ;;
            *)
                echo "Invalid command"
                ;;
        esac
        ;;
    "memory")
        case $2 in
            "getinfo")
                get_memory_info
                ;;
            *)
                echo "Invalid command"
                ;;
        esac
        ;;
    "user")
        case $2 in
            "create")
                create_user $3
                ;;
            "list")
                if [ "$3" == "--sudo-only" ]; then
                    list_sudo_users
                else
                    list_users
                fi
                ;;
            *)
                echo "Invalid command"
                ;;
        esac
        ;;
    "file")
        case $2 in
            "getinfo")
                shift # Remove "getinfo"
                get_file_info "$@"
                ;;
            *)
                echo "Invalid command"
                ;;
        esac
        ;;
    *)
        echo "Invalid command"
        ;;
esac
