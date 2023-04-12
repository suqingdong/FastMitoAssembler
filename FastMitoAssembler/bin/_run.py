import os
import json

import yaml
import click
import snakemake

from FastMitoAssembler import (
    MAIN_SMK,
    DEFAULT_CONFIG_FILE,
    DEFAULT_CONFIG,
    DEFAULT_OPTION_FILE,
    DEFAULT_OPTIONS,
    util,
)

@click.command(help=click.style('run the workflow', fg='cyan', bold=True), no_args_is_help=True)
# custom configs
@click.option('-r', '--reads_dir', help='the root directory of reads')
@click.option('-o', '--result_dir', help='the directory of result', default='result', show_default=True)
@click.option('-d', '--organelle_database', help='the database for GetOrganelle', default=DEFAULT_CONFIG['organelle_database'], show_default=True)
@click.option('-s', '--samples', help='the sample name', multiple=True)
@click.option('--fq_path_pattern', help='the path pattern of fastq file', default='{sample}/{sample}_1.clean.fq.gz', show_default=True)

# optional configs
@click.option('--genetic_code', help='the genetic code table', type=int, default=DEFAULT_CONFIG['genetic_code'], show_default=True)
@click.option('--genome_min_size', help='the min size of genome', type=int, default=DEFAULT_CONFIG['genome_min_size'], show_default=True)
@click.option('--genome_max_size', help='the max size of genome', type=int, default=DEFAULT_CONFIG['genome_max_size'], show_default=True)
@click.option('--insert_size', help='the in', type=int, default=DEFAULT_CONFIG['insert_size'], show_default=True)
@click.option('--kmer_size', help='the K-mer size used in NOVOPlasty assembly', type=int, default=DEFAULT_CONFIG['kmer_size'], show_default=True)
@click.option('--read_length', help='the read length of Illumina short reads', type=int, default=DEFAULT_CONFIG['read_length'], show_default=True)
@click.option('--max_mem_gb', help='the limit of RAM usage for NOVOPlasty (unit: GB)', type=int, default=DEFAULT_CONFIG['max_mem_gb'], show_default=True)

@click.option('--seed_input', help='use a specific seed input, .fasta, or .gb')
@click.option('--genes', help='the specific genes')

# snakefile, configfile and optionfile
@click.option('--snakefile', help='the main snakefile', default=MAIN_SMK, show_default=True)
@click.option('--configfile', help=f'the configfile for snakefile, template: {DEFAULT_CONFIG_FILE}')
@click.option('--optionfile', help=f'the optionfile for snakefile, template: {DEFAULT_OPTION_FILE}')

## snakemke options
@click.option('--cores', help='use at most N CPU cores/jobs in parallel', type=int, default=DEFAULT_OPTIONS['cores'], show_default=True)
@click.option('--dryrun', help='do not execute anything, and display what would bedone', is_flag=True)
def run(**kwargs):

    config = {}
    arguments = (
        'reads_dir result_dir organelle_database samples '
        'genetic_code genome_min_size genome_max_size insert_size kmer_size '
        'read_length max_mem_gb seed_input genes fq_path_pattern '
    ).strip().split()
    for key in arguments:
        if kwargs[key]:
            config[key] = kwargs[key]

    # higher priority
    if kwargs['configfile'] and os.path.isfile(kwargs['configfile']):
        click.secho('>>> reading config from file: {configfile}'.format(**kwargs), fg='green', err=True)
        data = util.read_yaml(kwargs['configfile'])
        for key, value in data.items():
            if value != '':
                config[key] = value
    click.secho('>>> Configs:\n' + json.dumps(config, indent=2), fg='green', err=True)

    if not all([isinstance(sample, str) for sample in config['samples']]):
        click.secho('sample name must be a string, please check your input: {samples}'.format(**config), fg='red')
        exit(1)

    options = {
        'cores': kwargs['cores'],
        'dryrun': kwargs['dryrun'],
        'printshellcmds': True,
    }
    if kwargs['optionfile'] and os.path.isfile(kwargs['optionfile']):
        click.secho('>>> reading options from file: {optionfile}'.format(**kwargs), fg='green', err=True)
        data = util.read_yaml(kwargs['optionfile'])
        for key, value in data.items():
            if value != '':
                options[key] = value

    click.secho('>>> Options:\n' + json.dumps(options, indent=2), fg='green', err=True)

    snakemake.snakemake(kwargs['snakefile'], config=config, **options)
