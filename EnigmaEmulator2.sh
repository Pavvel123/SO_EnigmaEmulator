#!/bin/bash

# Define the alphabet and rotors
 alphabet="ABCDEFGHIJKLMNOPQRSTUVWXYZ"
   rotor1="EKMFLGDQVZNTOWYHXUSPAIBRCJ"
   rotor2="AJDKSIRUXBLHWTMCQGZNPYFVOE"
   rotor3="BDFHJLCPRTXVZNYEIWGAKMUSQO"
reflector="YRUHQSLDPXNGOKMIEBFZCWVJAT"

# Define the rotor positions (A=0, B=1, ..., Z=25)
position1=0
position2=0
position3=0

# Read the message from the user
read -p "Enter the message to encrypt: " message

# Prepare the message
message=$(echo $message | tr 'a-z' 'A-Z' | tr -d ' ')
encrypted_message=""

# Encrypt the message character by character
for (( i=0; i<${#message}; i++ )); do
    char=${message:$i:1}
    
    # Rotate the rotors
    if [ $position2 -eq 4 ]; then
        position2=5
        position1=$(( (position1 + 1) % 26 ))
    fi
    position3=$(( (position3 + 1) % 26 ))
    if [ $position3 -eq 22 ]; then
        position2=$(( (position2 + 1) % 26 ))
    fi

    # Pass through rotor 3
    index=$(( ( $(echo $alphabet | grep -aob "$char" | cut -d: -f1) + position3 ) % 26 ))
    char=${rotor3:$index:1}
    index=$(( ( $(echo $alphabet | grep -aob "$char" | cut -d: -f1) - position3 + 26 ) % 26 ))
    char=${alphabet:$index:1}

    # Pass through rotor 2
    index=$(( ( $(echo $alphabet | grep -aob "$char" | cut -d: -f1) + position2 ) % 26 ))
    char=${rotor2:$index:1}
    index=$(( ( $(echo $alphabet | grep -aob "$char" | cut -d: -f1) - position2 + 26 ) % 26 ))
    char=${alphabet:$index:1}

    # Pass through rotor 1
    index=$(( ( $(echo $alphabet | grep -aob "$char" | cut -d: -f1) + position1 ) % 26 ))
    char=${rotor1:$index:1}
    index=$(( ( $(echo $alphabet | grep -aob "$char" | cut -d: -f1) - position1 + 26 ) % 26 ))
    char=${alphabet:$index:1}

    # Pass through the reflector
    index=$(echo $alphabet | grep -aob "$char" | cut -d: -f1)
    char=${reflector:$index:1}

    # Pass back through rotor 1 in reverse
    index=$(( $(echo $alphabet | grep -aob "$char" | cut -d: -f1)))
    char=${alphabet:$((($index + $position1) % 26)):1}
    index=$(( $(echo $rotor1 | grep -aob "$char" | cut -d: -f1)))
    char=${alphabet:$((($index - $position1 + 26) % 26)):1}

    # Pass back through rotor 2 in reverse
    index=$(( $(echo $alphabet | grep -aob "$char" | cut -d: -f1)))
    char=${alphabet:$((($index + $position2) % 26)):1}
    index=$(( $(echo $rotor2 | grep -aob "$char" | cut -d: -f1)))
    char=${alphabet:$((($index - $position2 + 26) % 26)):1}

    # Pass back through rotor 3 in reverse
    index=$(( $(echo $alphabet | grep -aob "$char" | cut -d: -f1)))
    char=${alphabet:$((($index + $position3) % 26)):1}
    index=$(( $(echo $rotor3 | grep -aob "$char" | cut -d: -f1)))
    char=${alphabet:$((($index - $position3 + 26) % 26)):1}

    # Append the encrypted character to the result
    encrypted_message+=$char
done

# Display the encrypted message
echo "Encrypted message: $encrypted_message"