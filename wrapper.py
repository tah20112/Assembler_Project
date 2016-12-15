# use syscalls to take from assembler and feed to cpu
from os import sys
from subprocess import call

# subprocess.call(args, *, stdin=None, stdout=None, stderr=None, shell=False)

def main(file_in, file_out):
    with open(file_in) as f:
        for i, line in enumerate(f):
            if any(ord(char) > 128 for char in line):
                print "Use normal ASCII characters"
    num_lines = i + 1
    call(["./assembler", file_in, file_out, str(num_lines)])

if __name__ == "__main__":
    main(sys.argv[1], sys.argv[2])