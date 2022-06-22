import sys
import subprocess as sp

def main(argv):
    if len(argv) != 4:
        print('Need 3 arguments: pid, bid, outputPath')
    pid = argv[1]
    bid = argv[2]
    outputPath = argv[3]

    process = sp.Popen('defects4j info -p {} -b {}'.format(pid, bid), shell=True, stderr=sp.PIPE, stdout=sp.PIPE, universal_newlines=True)
    stdout, stderr = process.communicate()
    exitCode = process.poll()

    lines = stdout.strip().split('\n')
    start = False
    output = ''
    for line in lines:
        if 'Root cause in triggering tests:' in line:
            start = True
        elif '------------------------------------------------------' in line and start == True:
            start = False
            break
        elif line.startswith(' - ') and start == True:
            tmp = line[3:]
            output += tmp.replace('::', '#') + '\n'

    with open(outputPath, 'w') as file:
        file.write(output)

if __name__ == '__main__':
    main(sys.argv)