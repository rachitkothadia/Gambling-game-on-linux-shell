#!/bin/bash

# Initial balance
balance=10000

# Function to generate random number between 1 and 9
generate_number() {
    echo $((RANDOM % 9 + 1))
}

# Function to print text in color
print_color() {
    local color=$1
    local text=$2
    case $color in
        "red")
            echo -e "\033[31m${text}\033[0m"
            ;;
        "green")
            echo -e "\033[32m${text}\033[0m"
            ;;
        "yellow")
            echo -e "\033[33m${text}\033[0m"
            ;;
        "blue")
            echo -e "\033[34m${text}\033[0m"
            ;;
        *)
            echo "${text}"
            ;;
    esac
}

# Function to display a separator
separator() {
    print_color "yellow" "--------------------------------------------------"
}

# Initialize game counters
game_played=0
win_streak=0

# Function to determine if the player should win based on conditions
should_win() {
    local current_bid=$1

    # Allow winning if bid is small (< 1000) with high probability
    if [ "$current_bid" -lt 1000 ]; then
        if ((RANDOM % 10 < 7)); then
            return 0  # Win
        else
            return 1  # Lose occasionally for small bids
        fi
    fi

    # For large bids (>= 1000), win occasionally to make it seem realistic
    if [ "$current_bid" -ge 1000 ]; then
        if ((RANDOM % 10 < 3)); then
            return 0  # Win sometimes for large bids
        else
            return 1  # Lose more often for larger bids
        fi
    fi

    # Allow winning if balance is very low
    if [ "$balance" -le 500 ] && [ "$win_streak" -lt 4 ]; then
        return 0
    fi

    # Default lose condition
    return 1
}

# Function to simulate the spinning process and set numbers based on win condition
spin_and_set_numbers() {
    local win_condition=$1
    if [ "$win_condition" -eq 0 ]; then
        # Player is to win: set all numbers equal
        local win_number=$(generate_number)
        num1=$win_number
        num2=$win_number
        num3=$win_number
    else
        # Player is to lose: ensure at least one number is different
        num1=$(generate_number)
        num2=$(generate_number)
        num3=$(generate_number)
        # Ensure not all three are equal
        while [ "$num1" -eq "$num2" ] && [ "$num2" -eq "$num3" ]; do
            num3=$(generate_number)
        done
    fi
}

# Main game loop
while true; do
    separator
    print_color "blue" "Your current balance: $balance Rupees"
    separator

    # Ask for bid amount
    print_color "green" "Enter your bid amount (in Rupees): "
    read bid

    # Validate bid input
    if ! [[ "$bid" =~ ^[0-9]+$ ]] || [ "$bid" -le 0 ]; then
        print_color "red" "Invalid bid amount. Please enter a positive number."
        continue
    fi

    if [ "$bid" -gt "$balance" ]; then
        print_color "red" "You don't have enough balance to place this bid."
        continue
    fi

    # Ask for multiplier
    print_color "green" "Choose your multiplier:"
    echo "1) 2x"
    echo "2) 5x"
    echo "3) 7x"
    echo "4) 10x"
    echo "5) 50x"
    echo "6) 100x"
    read multiplier_choice

    # Validate multiplier choice
    case $multiplier_choice in
        1) multiplier=2;;
        2) multiplier=5;;
        3) multiplier=7;;
        4) multiplier=10;;
        5) multiplier=50;;
        6) multiplier=100;;
        *) 
            print_color "red" "Invalid choice. Please select a valid multiplier option."
            continue 
            ;;
    esac

    # Determine if the player should win based on current conditions
    should_win "$bid"
    win_condition=$?

    # Spin the wheel and set numbers based on win condition
    spin_and_set_numbers "$win_condition"

    # Simulate the spinning process
    print_color "yellow" "Spinning the wheel..."
    sleep 1

    # Display the result
    print_color "blue" "Result: $num1 $num2 $num3"
    sleep 1

    # Check if the player has won
    if [ "$num1" -eq "$num2" ] && [ "$num2" -eq "$num3" ]; then
        # Player wins
        winnings=$((bid * multiplier))
        balance=$((balance + winnings))
        print_color "green" "You won! Your prize is $winnings Rupees."
        win_streak=$((win_streak + 1))
    else
        # Player loses
        balance=$((balance - bid))
        print_color "red" "You lost $bid Rupees."
        win_streak=0
    fi

    # Increment the game counter
    game_played=$((game_played + 1))

    # Check for game over
    if [ "$balance" -le 0 ]; then
        print_color "red" "Game Over! You ran out of money."
        break
    fi

    separator

    # Ask if the player wants to continue
    print_color "yellow" "Do you want to play again? (y/n)"
    read answer
    if [ "$answer" != "y" ]; then
        print_color "blue" "Thank you for playing! Your final balance is $balance Rupees."
        break
    fi
done
