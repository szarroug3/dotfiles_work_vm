from __future__ import print_function

import argparse
import ast
from builtins import range
import re
import subprocess
import sys
import time

try:
    import configparser
except ImportError:
    import ConfigParser as configparser


def read_args():
    """
    Read in arguments

    Returns:
        argparse.Namespace: args returned from argparse
    """
    parser = argparse.ArgumentParser(description='Set monitor configuration using xrandr based on given config file.')
    parser.add_argument('config', help='path to config file')
    parser.add_argument('-d', '--dry-run', help='Run script as a dry-run', action='store_true')
    parser.add_argument('-f', '--force', help='Run command regardless of whether things changed or not', action='store_true')
    return parser.parse_args()


def read_config(filename, xrandr):
    """
    Read and validate config with name filename

    Args:
        :str filename: name of config file
        :str xrandr: output from xrandr call

    Returns:
        str: primary monitor
        list: list of monitors to turn on
    """
    config = configparser.SafeConfigParser({'on': []})
    config.readfp(open(filename))

    fail = False
    found = False
    final_primary, final_on = None, None

    for section in config.sections():
        # check to make sure primary is set
        if not config.has_option(section, 'primary'):
            fail = True
            print('primary cannot be empty in {}'.format(section))
            continue

        # check that primary is in on if on is set
        primary = config.get(section, 'primary')
        on = [x.strip() for x in config.get(section, 'on').split(',') if x.strip()]
        if on and primary not in on:
            fail = True
            print('{} must be in on if on is set in {}'.format(primary, section))
            continue

        # check if all monitors to be turned on are connected
        if validate_monitors(xrandr, primary, on) and not found:
            final_primary, final_on = primary, on
            found = True

    if fail:
        raise Exception('Something went wrong')

    return final_primary, final_on


def read_xrandr():
    """
    Read in xrandr command

    Returns:
        str: xrandr output
    """
    try:
        out = subprocess.check_output('xrandr')
        return out.decode('utf-8')
    except OSError:
        sys.exit('xrandr must be installed')


def validate_monitors(xrandr, primary, on):
    """
    Make sure monitors are in xrandr as expected

    Args:
        :str xrandr: output from xrandr call
        :str primary: primary monitor
        :list on: list of monitors to turn on
    """
    for m in set([primary]) | set(on):
        if '\n{} connected'.format(m) not in xrandr:
            return False
    return True


def find_enabled_monitors(xrandr):
    """
    Looks for monitors that are turns on in xrandr output

    Returns:
        list: list of monitors that are enabled
    """
    enabled = []
    for m in re.finditer(r'\n(\S+) connected( primary)? \d+x\d+\+\d+\+\d+ \(', xrandr):
        enabled.append(m.group(1))
    return enabled


def run_xrandr(primary, on, off, dry_run):
    """
    Compile and execute the xrandr command

    Args:
        :str primary: primary monitor
        :list on: list of monitors to turn on
        :list off: list of monitors to turn off
        :bool dry_run: false if running actual commands; true for a dry run
    """
    command = ['xrandr', '--output', primary, '--primary', '--auto']

    if primary in off:
        off.remove(primary)

    if on:
        primary_index = on.index(primary)
        # get monitors left of primary
        anchor = primary
        for m in on[:primary_index][::-1]:
            command.extend(['--output', m, '--left-of', anchor, '--auto'])
            anchor = m
            if m in off:
                off.remove(m)

        # get monitors right of primary
        anchor = primary
        for m in on[primary_index+1:]:
            command.extend(['--output', m, '--right-of', anchor, '--auto'])
            anchor = m
            if m in off:
                off.remove(m)

    for m in off:
        command.extend(['--output', m, '--off'])

    print('Executing: {}'.format(' '.join(command)))
    if not dry_run:
        subprocess.call(command)


def main():
    args = read_args()
    xrandr = read_xrandr()
    try:
        primary, on = read_config(args.config, xrandr)
        if not primary:
            sys.exit('None of the configurations specified in config file worked.')
    except Exception as e:
        sys.exit()

    off = find_enabled_monitors(xrandr)

    # we only want to run the command if something's changed
    if set(on) != set(off) or args.force:
        run_xrandr(primary, on, off, args.dry_run)


if __name__ == '__main__':
    main()
