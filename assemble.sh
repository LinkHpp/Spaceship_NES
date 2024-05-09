#! /bin/sh

ca65 src/spaceship.asm
ca65 src/reset.asm
ca65 src/controllers.asm
ld65 src/reset.o src/controllers.o src/spaceship.o -C nes.cfg -o spaceship.nes
