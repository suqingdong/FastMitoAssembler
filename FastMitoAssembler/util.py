import subprocess as sp
from pathlib import Path

import click


def safe_open(filename, mode='r'):
    """open file safely
    """
    file = Path(filename)

    if 'w' in mode and not file.parent.exists():
        file.parent.mkdir(parents=True)

    if filename.endswith('.gz'):
        import gzip
        return gzip.open(filename, mode=mode)

    return file.open(mode=mode)


def getstatusoutput(cmd):
    click.secho(f'>>> run command: {cmd}', err=True, fg='green')
    return sp.getstatusoutput(cmd)