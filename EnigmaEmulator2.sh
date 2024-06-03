#!/bin/bash

# Author           : Paweł Kurpiewski ( s198203@student.pg.edu.pl )
# Created On       : 30.05.2024
# Last Modified By : Paweł Kurpiewski ( s198203@student.pg.edu.pl )
# Last Modified On : 3.06.2024 
# Version          : v1.4
#
# Description      :Enigma Emulator - program encrypts message using mechanism used in Enigma machines
# Opis
#
# Licensed under GPL (see /usr/share/common-licenses/GPL for more details
# or contact # the Free Software Foundation for a copy)


PassThroughRotor()
{
    index=$(( ( $(echo $alphabet | grep -aob "$char" | cut -d : -f 1) + position[$1] ) % 26 ))
    char=${rotors[$1]:$index:1}
    index=$(( ( $(echo $alphabet | grep -aob "$char" | cut -d : -f 1) - position[$1] ) % 26 ))
    char=${alphabet:$index:1}
}

PassThroughRotorReverse()
{
    index=$(( $(echo $alphabet | grep -aob "$char" | cut -d : -f 1)))
    char=${alphabet:$((($index + ${position[$1]}) % 26)):1}
    index=$(( $(echo ${rotors[$1]} | grep -aob "$char" | cut -d : -f 1)))
    char=${alphabet:$((($index - ${position[$1]}) % 26)):1}
}

Help()
{
    echo " _____  _   _  _____  _____ ___  ___  ___  
|  ___|| \ | ||_   _||  __ \|  \/  | / _ \ 
| |__  |  \| |  | |  | |  \/| .  . |/ /_\ \ 
|  __| | . ' |  | |  | | __ | |\/| ||  _  |
| |___ | |\  | _| |_ | |_\ \| |  | || | | |
\____/ \_| \_/ \___/  \____/\_|  |_/\_| |_/
"
    echo "-r - you can choose three rotors out of eight available (numbered from 1 to 8) i.e. -r 123"
    echo "-u - you can choose one reflector out of two available (B or C) i.e. -u B"
    echo "-f - you can select an input file, so its content will be encrypted i.e. -f input.txt"
    echo "-s - you can select an output file, so encrypted message will be saved to it (Attention! If the file exists, this option will clear the content of it!) i.e. -s output.txt"
}

Version()
{
    echo v1.4
}

ChooseRotors()
{
    r1="rotor$1"
    r2="rotor$2"
    r3="rotor$3"
    rotors=(${!r1} ${!r2} ${!r3})
}

ChooseReflector()
{
    ref="reflector$1"
    reflector=${!ref}
}

# Define the alphabet and rotors
  alphabet="ABCDEFGHIJKLMNOPQRSTUVWXYZ"
    rotor1="EKMFLGDQVZNTOWYHXUSPAIBRCJ"
    rotor2="AJDKSIRUXBLHWTMCQGZNPYFVOE"
    rotor3="BDFHJLCPRTXVZNYEIWGAKMUSQO"
    rotor4="ESOVPZJAYQUIRHXLNFTGKDCMWB"
    rotor5="VZBRGITYUPSDNHLXAWMJQOFECK"
    rotor6="JPGVOUMFYQBENHZRDKASXLICTW"
    rotor7="NZJHGRCXMYSWBOUFAIVLPEKQDT"
    rotor8="FKQHTLXOCBJSPDZRAMEWNIUYGV"
reflectorB="YRUHQSLDPXNGOKMIEBFZCWVJAT"
reflectorC="FVPJIAOYEDRZXWGCTKUQSBNMHL"

rotors=($rotor1 $rotor2 $rotor3)
reflector=$reflectorB

input=""
output=""

while getopts hvr:u:f:s: OPT; do
    case $OPT in
        h) Help
            exit;;
        v) Version
            exit;;
        r) ChooseRotors ${OPTARG:0:1} ${OPTARG:1:1} ${OPTARG:2:1};;
        u) ChooseReflector $OPTARG;;
        f) input=$OPTARG;;
        s) output=$OPTARG;;
        *) echo "$OPT - unknown option";;
    esac
done

# Define the rotor positions (A=0 B=1  Z=25)
position=(0 0 0)

# Read the message from the user
if [ -z $input ]; then
    read -p "Enter the message to encrypt: " message
else
    message=$(cat $input)
fi

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
    index=$(echo $alphabet | grep -aob "$char" | cut -d : -f 1)
    char=${reflector:$index:1}

    PassThroughRotorReverse 0
    PassThroughRotorReverse 1
    PassThroughRotorReverse 2

    # Append the encrypted character to the result
    encrypted_message+=$char
done

# Display the encrypted message
if [ -z $output ]; then
    echo "Encrypted message: $encrypted_message"
else
    echo $encrypted_message > $output
fi