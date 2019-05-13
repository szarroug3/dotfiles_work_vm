import argparse
import logging
import os
import re
import subprocess

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
    parser.add_argument('-o', '--offset', help='Default horizontal resolution of monitor to be used for panning offset; will be used only if monitor\'s value is not set in config', default=2560)
    parser.add_argument('--debug', help='Output debugging statements to ~/auto_xrandr.log', action='store_true')
    return parser.parse_args()


def read_config(filename, offset, xrandr, debug):
    """
    Read and validate config with name filename

    Args:
        :str filename: name of config file
        :str xrandr: output from xrandr call

    Returns:
        str: primary monitor
        list: list of monitors to turn on
    """
    config = configparser.ConfigParser({'on': []})
    config.read_file(open(filename))

    fail = False
    found = False
    final_primary, final_on = None, None
    resolutions = {}

    for section in config.sections():
        # check to make sure primary is set
        if not config.has_option(section, 'primary'):
            fail = True
            if debug:
                logging.debug('primary cannot be empty in {}'.format(section))
            continue

        # check that primary is in on if on is set
        primary = config.get(section, 'primary')
        on = [x.strip() for x in config.get(section, 'on').split(',') if x.strip()]

        if not on:
            fail = True
            if debug:
                logging.debug('on cannot be empty in {}'.format(section))
            continue

        if primary not in on:
            print('here')
            fail = True
            if debug:
                logging.debug('{} must be in on if on is set in {}'.format(primary, section))
            continue

        # check if all monitors to be turned on are connected
        if validate_monitors(xrandr, primary, on) and not found:
            found = True
            final_primary, final_on = primary, on
            for m in on:
                resolutions[m] = config.get(section, m, fallback=offset)

    if fail:
        raise Exception('Something went wrong')

    if not found:
        raise Exception('None of the configurations specified in config file worked.')

    return final_primary, final_on, resolutions


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
        logging.debug('xrandr must be installed')


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


def run_xrandr(primary, on, off, resolutions, dry_run, debug):
    """
    Compile and execute the xrandr command

    Args: :str primary: primary monitor
        :list on: list of monitors to turn on
        :list off: list of monitors to turn off
        :bool dry_run: false if running actual commands; true for a dry run
    """
    command = ['xrandr']
    offset = 0

    if primary in off:
        off.remove(primary)

    if on:
        primary_index = on.index(primary)
        # get monitors left of primary
        for i, m in enumerate(on[:primary_index]):
            anchor = on[i+1]
            command.extend(['--output', m, '--left-of', anchor, '--auto', '--panning', '0x0+{}+0'.format(offset)])
            offset += resolutions[m]
            if m in off:
                off.remove(m)

        command.extend(['--output', primary, '--primary', '--auto', '--panning', '0x0+{}+0'.format(offset)])
        offset += resolutions[primary]

        # get monitors right of primary
        anchor = primary
        for m in on[primary_index+1:]:
            command.extend(['--output', m, '--right-of', anchor, '--auto', '--panning', '0x0+{}+0'.format(offset)])
            offset += resolutions[m]
            anchor = m
            if m in off:
                off.remove(m)

    for m in off:
        command.extend(['--output', m, '--off'])

    if dry_run or debug:
        logging.info('Executing: {}'.format(' '.join(command)))

    if not dry_run:
        subprocess.call(command)


def main():
    logging.basicConfig(filename=os.path.join(os.path.expanduser('~'), 'auto_xrandr.log'), level=logging.DEBUG,
                        format='%(asctime)s %(levelname)s: %(message)s')
    args = read_args()
    xrandr = read_xrandr()
    try:
        primary, on, resolutions = read_config(args.config, args.offset, xrandr, args.debug)
    except Exception as e:
        logging.exception(e)
        return

    off = find_enabled_monitors(xrandr)

    # we only want to run the command if something's changed
    if set(on) != set(off) or args.force:
        run_xrandr(primary, on, off, resolutions, args.dry_run, args.debug)


if __name__ == '__main__':
    main()
