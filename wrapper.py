# use syscalls to take from assembler and feed to cpu
from os import sys
from subprocess import call

# subprocess.call(args, *, stdin=None, stdout=None, stderr=None, shell=False)

def main(file_in, file_out):
    with open(file_in) as f:
        for i, line in enumerate(f):
            if any(ord(char) > 128 for char in line):
                print "Please use English characters in your assembly code. You may get crazy errors in the assembler, but I won't stop you. Go ahead and make your own mistakes."
>>>>>>> 556a176a8de2914248c4c454231528f6dcb9eda4
    num_lines = i + 1
    call(["./assembler", file_in, file_out, str(num_lines)])

if __name__ == "__main__":
    main(sys.argv[1], sys.argv[2])
