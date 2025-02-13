#!/bin/bash

take_input_and_confirm() {
    description="$1"
    while true; do
        read -p "Enter the desired $description: " input
        read -p "Confirm the $description: " input2
        if [ "$input" == "$input2" ]; then
            break
        else
            echo "Second input does not match the first, please try again."
        fi
    done
    echo "$input"
}