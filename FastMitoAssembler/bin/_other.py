
import click

from FastMitoAssembler import util

ORGANELLE_DB_LIST = ['all', 'embplant_pt', 'embplant_mt', 'embplant_nr', 'fungus_mt', 'fungus_nr', 'animal_mt', 'other_pt']

NCBI_TAXDUMP = 'https://ftp.ncbi.nih.gov/pub/taxonomy/taxdump.tar.gz'

@click.group(help=click.style('prepare database', fg='cyan', bold=True))
def prepare():
    pass


@prepare.command(help='prepare ete3.NCBITaxa')
@click.option('--taxdump_file', help=f'the taxdump file of NCBI, you can mamually download it from: {NCBI_TAXDUMP}')
def ncbitaxa(**kwargs):
    import ete3
    print('preparing ete3.NCBITaxa ...')
    ete3.NCBITaxa(taxdump_file=kwargs['taxdump_file'])
    print('ete3.NCBITaxa is ok!')


@prepare.command(help='prepare database for GetOrganelle', no_args_is_help=True)
@click.option('-a', '--add',
              help='add database for organelle type(s)',
              type=click.Choice(ORGANELLE_DB_LIST),
              show_choices=True,
              default=['animal_mt'],
              show_default=True,
              multiple=True,
)
@click.option('--list', help='list configured databases checking and exit', is_flag=True)
def organelle(**kwargs):
    cmd = 'get_organelle_config.py --list'
    status, output = util.getstatusoutput(cmd)
    configured_dbs = set([db.split()[0] for db in output.strip().split('\n') if db])
    if configured_dbs:
        click.secho(f'configured databases:\n{output}', fg='cyan')
    else:
        click.secho(f'no configured databases', fg='yellow')

    if not kwargs['list']:
        databases = ORGANELLE_DB_LIST[1:] if 'all' in kwargs['add'] else kwargs['add']
        for database in databases:
            if database in configured_dbs:
                if not click.confirm(f'"{database}" alreay configured, overwrite it?'):
                    continue
            click.secho(f'preparing database for GetOrganelle: {database}', fg='green')
            cmd = f'get_organelle_config.py --add {database}'
            status, output = util.getstatusoutput(cmd)
            click.secho(output)
