import os

import yaml
import click
import snakemake

from FastMitoAssembler import MAIN_SMK, CONFIG_DEFAULT, VERSION, BANNER


CONTEXT_SETTINGS = dict(help_option_names=['-?', '-h', '--help'], max_content_width=800,)
BANNER = '\b\n'.join(BANNER.split('\n'))
HELP = f'''\n\n\b\n{BANNER}\n'''


@click.group(
    help=click.style(HELP, fg='cyan', italic=True),
    name=VERSION['prog'],
    context_settings=CONTEXT_SETTINGS,
)
def cli():
    pass


@cli.command(
    help='run the workflow',
    no_args_is_help=True,
)
@click.option('-r', '--reads-dir', help='the directory of reads', required=True)
@click.option('-o', '--result-dir', help='the directory of result', default='./result', show_default=True)
@click.option('-d', '--organelle_database', help='the database for GetOrganelle', default='animal_mt', show_default=True)
@click.option('-s', '--sample', help='the sample name', multiple=True, required=True)
@click.option('--meangs-path', help='the path of MEANGS software', required=True)
@click.option('--cores', help='the cores for snakemake', type=int, default=4, show_default=True)
@click.option('--genes', help='the specific genes')
@click.option('--gencode', help='the genetic code table', default=5, show_default=True)
@click.option('--max_mem_gb', help='limit of RAM usage for NOVOPlasty', default=5, show_default=True)
@click.option('--snakefile', help='the main snakefile', default=MAIN_SMK, show_default=True)
@click.option('--configfile', help='the configfile of snakefile', default=CONFIG_DEFAULT, show_default=True)
def run(**kwargs):

    config = {}
    if os.path.isfile(kwargs['config']):
        with open(kwargs['config']) as f:
            config = yaml.load(f, Loader=yaml.FullLoader)

    config.update({

        'organelle_database': kwargs['organelle_database'],
        'samples': kwargs['sample'],
        'MEANGS_PATH': kwargs['meangs_path'],
        'reads_dir': kwargs['reads_dir'],
    })

    options = {
        'cores': kwargs['cores'],
        'printshellcmds': True,
    }

    snakemake.snakemake(kwargs['snakefile'], config=config, **options)


def main():
    cli()


if __name__ == '__main__':
    main()
