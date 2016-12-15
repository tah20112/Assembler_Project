# use syscalls to take from assembler and feed to cpu
from os import sys
from subprocess import call

# subprocess.call(args, *, stdin=None, stdout=None, stderr=None, shell=False)

def main(file_in):
    with open(file_in) as f:
        for i, line in enumerate(f):
            if any(ord(char) > 128 for char in line):
                print "Please use English characters in your assembly code."
    num_lines = i + 1
    call(["./assembler", file_in, "assembled_code.dat", str(num_lines)])

if __name__ == "__main__":
    main(sys.argv[1])
