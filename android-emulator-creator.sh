#!/bin/bash

sz="$(stat -c %s s.img)"
sz=$((sz/512))
sz=$((sz + 2048 ))
sz=$((sz / 2048 ))
sz=$((sz * 2048 ))

sum=2048
newsum=$((sum+sz+2048))
rm -f system-gpt
truncate -s $((newsum*512)) system-gpt
/sbin/sgdisk -C system-gpt
/sbin/sgdisk --new=1:2048:+$sz system-gpt
/sbin/sgdisk --change-name=1:system system-gpt
dd if=s.img of=system-gpt conv=notrunc seek=$sum

