#!/bin/bash

PassThroughRotor()
{
    index=$(( ( $(echo $alphabet | grep -aob "$char" | cut -d: -f1) + position[$1] ) % 26 ))
    char=${rotors[$1]:$index:1}
    index=$(( ( $(echo $alphabet | grep -aob "$char" | cut -d: -f1) - position[$1] + 26 ) % 26 ))
    char=${alphabet:$index:1}
}

PassThroughRotorReverse()
{
    index=$(( $(echo $alphabet | grep -aob "$char" | cut -d: -f1)))
    char=${alphabet:$((($index + ${position[$1]}) % 26)):1}
    index=$(( $(echo ${rotors[$1]} | grep -aob "$char" | cut -d: -f1)))
    char=${alphabet:$((($index - ${position[$1]} + 26) % 26)):1}
}

Help()
{
    echo "Help"
}

Version()
{
    echo v1.0
}

ChooseRotors()
{
    r1="rotor$1"
    r2="rotor$2"
    r3="rotor$3"
    rotors=(${!r1} ${!r2} ${!r3})
    echo ${rotors[0]}
    echo ${rotors[1]}
    echo ${rotors[2]}
}

ChooseReflector()
{
    ref="reflector$1"
    reflector=${!ref}
    echo $reflector
}

# Define the alphabet and rotors
  alphabet="ABCDEFGHIJKLMNOPQRSTUVWXYZ"
    rotor1="EKMFLGDQVZNTOWYHXUSPAIBRCJ"
    rotor2="AJDKSIRUXBLHWTMCQGZNPYFVOE"
    rotor3="BDFHJLCPRTXVZNYEIWGAKMUSQO"
    rotor4="ESOVPZJAYQUIRHXLNFTGKDCMWB"
    rotor5="VZBRGITYUPSDNHLXAWMJQOFECK"
reflectorB="YRUHQSLDPXNGOKMIEBFZCWVJAT"
reflectorC="FVPJIAOYEDRZXWGCTKUQSBNMHL"

rotors=($rotor1 $rotor2 $rotor3)
reflector=$reflectorB

while getopts hvr:u: OPT; do
    case $OPT in
        h) Help;;
        v) Version;;
        r) ChooseRotors ${OPTARG:0:1} ${OPTARG:1:1} ${OPTARG:2:1};;
        u) ChooseReflector $OPTARG;;
        *) echo "unknown option";;
    esac
done

# Define the rotor positions (A=0 B=1  Z=25)
position=(0 0 0)

# Read the message from the user
read -p "Enter the message to encrypt: " message

# Prepare the message
message=$(echo $message | tr 'a-z' 'A-Z')
encrypted_message=""

# Encrypt the message character by character
for (( i=0; i<${#message}; i++ )); do
    char=${message:$i:1}
    if [[ $char != [A-Z] ]]; then
        encrypted_message+=$char
        continue
    fi
    
    # Rotate the rotors
    if [ ${position[1]} -eq 4 ]; then
        position[1]=5
        position[0]=$(( (position[0] + 1) % 26 ))
    fi
    position[2]=$(( (position[2] + 1) % 26 ))
    if [ ${position[2]} -eq 22 ]; then
        position[1]=$(( (position[1] + 1) % 26 ))
    fi

    PassThroughRotor 2
    PassThroughRotor 1
    PassThroughRotor 0

    # Pass through the reflector
    index=$(echo $alphabet | grep -aob "$char" | cut -d: -f1)
    char=${reflector:$index:1}

    PassThroughRotorReverse 0
    PassThroughRotorReverse 1
    PassThroughRotorReverse 2

    # Append the encrypted character to the result
    encrypted_message+=$char
done

# Display the encrypted message
echo "Encrypted message: $encrypted_message"