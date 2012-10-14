from __future__ import print_function
import os
from subprocess import Popen
import sys


def main():
    exit_code = 0

    project_path = os.path.abspath(os.path.join(os.path.dirname(os.path.abspath(__file__)), '..', '..'))
    if not os.path.isdir(os.path.join(project_path, '.git')):
        raise AssertionError

    if os.name == 'nt':
        brunchCmd = ['cmd', '/c', 'brunch.cmd']
    else:
        brunchCmd = ['brunch']

    proc = Popen(brunchCmd + ['test', '-c', 'config-web.autogen.coffee'],
                 cwd=os.path.join(project_path, 'src'))
    proc.communicate()
    if proc.returncode != 0:
        print('Unit tests failed', file=sys.stderr)
        exit_code = 1

    return exit_code


if __name__ == '__main__':
    sys.exit(main())
