import os
import click
import snakemake

from FastMitoAssembler import TOOLS_DIR, MAIN_SMK
from FastMitoAssembler.config import NOVOPLASTY_CONFIG_TPL

@click.group(
    help=click.style('FastMitoAssembler', fg='cyan')
)
def cli(**kwargs):
    pass


@cli.command(
    help='run the workflow',
)
@click.option('-r', '--reads-dir', help='the directory of reads', required=True)
@click.option('-o', '--result-dir', help='the directory of result', default='./result', show_default=True)
@click.option('-d', '--organelle_database', help='the database for GetOrganelle', default='animal_mt', show_default=True)
@click.option('--meangs-path', help='the path of MEANGS software', required=True)
@click.option('-s', '--sample', help='the sample name', multiple=True, required=True)
@click.option('--options', help='the options of snakemake', nargs=2, multiple=True)
def run(**kwargs):
    config = {
        'organelle_database': kwargs['organelle_database'],
        'samples': kwargs['sample'],
        'MEANGS_PATH': kwargs['meangs_path'],
        'reads_dir': kwargs['reads_dir'],
    }

    options = {
        'cores': 4,
        'printshellcmds': True,
        **dict(kwargs['options']),
        # 'report': 'report.html',
    }

    snakemake.snakemake(MAIN_SMK, config=config, **options)


def main():
    cli()



    

if __name__ == '__main__':
    main()
