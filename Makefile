# Dylan Zingler
# Project 02 CMSC 417 NETWORKING
# TCP SERVER
# Credit given to Yanick Rochon
# Some of the format/variables were taken for linking and compiling the code

# Variables
rm       = rm -f

# File Groups
RUBY  := $(wildcard *.rb)
CPROGRAMS := $(wildcard *.c)
EDITED_FILES  := $(wildcard *~)


# Clean-Up
clean:
	$(rm) $(EDITED_FILES)
