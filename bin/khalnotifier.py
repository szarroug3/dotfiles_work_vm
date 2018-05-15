from __future__ import print_function

from datetime import datetime
import re
import subprocess


def read_khal():
    """
    Read in khal command

    Returns:
        str: khal output
    """
    try:
        out = subprocess.check_output(['khal', 'list', 'today', '--format', 'STARTDELIM{start} ;;; {title} ;;; {description}ENDDELIM'])
        return out.decode('utf-8')
    except OSError:
        sys.exit('khal must be installed and configured')

def find_events(khal):
    """
    Finds events from the khal output

    Args:
        :str khal: khal output

    Returns
        list: list of dictionary entries with keys for "title", "time", and "description"
    """
    events = []
    for m in re.finditer(r'STARTDELIM([\s\S]*?) ;;; ([\s\S]*?) ;;; ([\s\S]*?)ENDDELIM', khal):
        try:
            start_time = datetime.strptime(m.group(1), '%m/%d/%Y %I:%M %p')
        except:
            continue
        events.append({'time': start_time,
                       'title': m.group(2), 'description': m.group(3)})

    return events


def filter_events(events, minutes=[0, 5]):
    """
    Find events within the next specified amount of time

    Args:
        :list minutes: (optional) list of number of minutes to filter for

    Returns:
        list: list of events within the next specified amount of time
    """
    filtered_events = []
    now = datetime.now()
    for event in events:
        if int((event['time'] - now).total_seconds() / 60) in minutes:
            filtered_events.append(event)
    return filtered_events


def notify_events(events):
    """
    Notify of events found

    Args:
        :list events: events to notify of
    """
    if not events:
        return

    event_info = re.compile(r'Join Skype Meeting.+?meet\/(.+?)\/([a-zA-Z0-9]+)[\s\S]+?(\+\d-\d{3}-\d{3}-\d{4}) \(USA, Houston, TX\)')
    messages = []
    for event in events:
        message = [event['title'], '\tTime: {}'.format(datetime.strftime(event['time'], '%I:%M %p'))]
        m = re.search(event_info, event['description'])
        if m:
            message.append('\tEvent Owner:     {}'.format(m.group(1)))
            message.append('\tEvent ID:        {}'.format(m.group(2)))
            message.append('\tEvent Phone #:   {}'.format(m.group(3)))
        messages.append('\n'.join(message))
    subprocess.Popen(['notify-send', 'Meeting', '\n\n'.join(messages)])


def main():
    khal = read_khal()
    events = filter_events(find_events(khal))
    notify_events(events)

if __name__ == '__main__':
    main()
