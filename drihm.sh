#!/bin/sh

# Regression testing script for DRiHM
# Step through a list of files
#  Compile, run, and check the output of each expected-to-work test
#  Compile and check the error of each expected-to-fail test

# Path to the LLVM interpreter
#LLI="lli"
LLI="/usr/bin/lli"

# Path to the LLVM compiler
LLC="/usr/bin/llc"

# Path to the C compiler
CC="cc"

# Path to the drihm compiler.  Usually "./drihm.native"
# Try "_build/drihm.native" if ocamlbuild was unable to create a symbolic link.
DRIHM="./drihm.native"
#DRIHM="_build/drihm.native"

# Set time limit for all operations
ulimit -t 30

globallog=drihm.log
rm -f $globallog
error=0
globalerror=0

keep=0

Usage() {
    echo "Usage: drihm [options] [.dm files]"
    echo "-k    Keep intermediate files"
    echo "-h    Print this help"
    exit 1
}

SignalError() {
    if [ $error -eq 0 ] ; then
	echo "FAILED"
	error=1
    fi
    echo "  $1"
}

Run() {
    echo $* 1>&2
    eval $* || {
	SignalError "$1 failed on $*"
	return 1
    }
}

while getopts kdpsh c; do
    case $c in
	k) # Keep intermediate files
	    keep=1
	    ;;
	h) # Help
	    Usage
	    ;;
    esac
done

shift `expr $OPTIND - 1`

LLIFail() {
  echo "Could not find the LLVM interpreter \"$LLI\"."
  echo "Check your LLVM installation and/or modify the LLI variable in testall.sh"
  exit 1
}

Clear() {
    if [ $keep -eq 0 ] ; then
        rm -f "${file}.ll" "${file}.s"
    fi
}

which "$LLI" >> $globallog || LLIFail


if [ $# -ge 1 ]
then
    file=`echo $@ | sed 's/.dm$//'`
else
      file="tests/demo.dm"
fi

Run "$DRIHM" "$1" ">" "${file}.ll" &&
Run "$LLC" "-relocation-model=pic" "${file}.ll" ">" "${file}.s" &&
Run "$CC" "-o" "${file}.exe" "${file}.s" "matrix.o" "-lm" &&
Clear

exit $globalerror
