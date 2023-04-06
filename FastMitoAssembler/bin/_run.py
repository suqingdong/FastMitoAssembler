import os
import json

import yaml
import click
import snakemake

from FastMitoAssembler import MAIN_SMK, CONFIG_DEFAULT


@click.command(help='run the workflow', no_args_is_help=True)
# custom configs
@click.option('-r', '--reads-dir', help='the directory of reads')
@click.option('-o', '--result-dir', help='the directory of result', default='./result', show_default=True)
@click.option('-d', '--organelle_database', help='the database for GetOrganelle', default='animal_mt', show_default=True)
@click.option('-s', '--samples', help='the sample name', multiple=True)
@click.option('--fq_path_pattern', help='the path pattern of fastq file', default='{sample}/{sample}_1.clean.fq.gz', show_default=True)
@click.option('--meangs-path', help='the path of MEANGS software', envvar='MEANGS_PATH', show_envvar=True)

# optional configs
@click.option('--genetic_code', help='the genetic code table', type=int, default=5, show_default=True)
@click.option('--genome_min_size', help='the min size of genome', type=int, default=12000, show_default=True)
@click.option('--genome_max_size', help='the max size of genome', type=int, default=22000, show_default=True)
@click.option('--insert_size', help='the in', type=int, default=39, show_default=True)
@click.option('--kmer_size', help='the K-mer size used in NOVOPlasty assembly', type=int, default=39, show_default=True)
@click.option('--read_length', help='the read length of Illumina short reads', type=int, default=150, show_default=True)
@click.option('--max_mem_gb', help='the limit of RAM usage for NOVOPlasty (unit: GB)', type=int, default=5, show_default=True)

@click.option('--reference', help='the specific reference, .fasta or .gb')
@click.option('--genes', help='the specific genes')

# snakefile and configfile
@click.option('--snakefile', help='the main snakefile', default=MAIN_SMK, show_default=True)
@click.option('--configfile', help=f'the configfile for snakefile, template: {CONFIG_DEFAULT}')

## snakemke options
@click.option('--cores', help='use at most N CPU cores/jobs in parallel', type=int, default=4, show_default=True)
@click.option('--dryrun', help='do not execute anything, and display what would bedone', is_flag=True)
def run(**kwargs):

    config = {}
    arguments = (
        'reads_dir result_dir organelle_database samples meangs_path '
        'genetic_code genome_min_size genome_max_size insert_size kmer_size '
        'read_length max_mem_gb reference genes fq_path_pattern '
    ).strip().split()
    for key in arguments:
        if kwargs[key]:
            config[key] = kwargs[key]

    # higher priority
    if kwargs['configfile'] and os.path.isfile(kwargs['configfile']):
        click.secho('>>> reading config from file: {configfile}'.format(**kwargs), fg='green', err=True)
        with open(kwargs['configfile']) as f:
            data = yaml.load(f, Loader=yaml.FullLoader)
            for key, value in data.items():
                if value:
                    config[key] = value
    click.secho('>>> Configs:\n' + json.dumps(config, indent=2), fg='green', err=True)

    options = {
        'cores': kwargs['cores'],
        'dryrun': kwargs['dryrun'],
        'printshellcmds': True,
    }
    click.secho('>>> Options:\n' + json.dumps(options, indent=2), fg='green', err=True)

    snakemake.snakemake(kwargs['snakefile'], config=config, **options)

