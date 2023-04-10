# Fast Assembler Workflow for MitoGenome
> `FastMitoAssembler` is a software for fast, accurate assembly of mitochondrial genomes and generation of annotation documents.

### Installation
#### 1. create environment
```bash
# method 1: use conda [slowly and need large resources]
conda env create -f environment.yml

# method 2: use mamba [*recommended*]
conda install mamba -c conda-forge -y
mamba env create -f environment.yml

# method 3: install manually
conda config --add channels yccscucib
conda config --add channels bioconda
conda config --add channels conda-forge

mamba create -n FastMitoAssembler -y python==3.9.*
mamba install -n FastMitoAssembler -y snakemake
mamba install -n FastMitoAssembler -y NOVOPlasty
mamba install -n FastMitoAssembler -y GetOrganelle
mamba install -n FastMitoAssembler -y spades
mamba install -n FastMitoAssembler -y blast
mamba install -n FastMitoAssembler -y mitoz
mamba install -n FastMitoAssembler -y seqkit
mamba install -n FastMitoAssembler -y meangs

mamba install -n FastMitoAssembler -y click
mamba install -n FastMitoAssembler -y jinja2 
mamba install -n FastMitoAssembler -y pyyaml

source $(dirname `which conda`)/activate FastMitoAssembler
python -m pip insatll genbank
```

#### 2. activate environment 
```bash
source $(dirname `which conda`)/activate FastMitoAssembler
```

#### 3. install FastMitoAssembler
```bash
python -m pip install -U FastMitoAssembler
# or
python -m pip install -U dist/FastMitoAssembler*whl
```

### Prepare Database
```bash
FastMitoAssembler prepare

# 1. prepare ete3.NCBITaxa
FastMitoAssembler prepare ncbitaxa # download taxdump.tar.gz automaticlly
FastMitoAssembler prepare ncbitaxa --taxdump_file taxdump.tar.gz 

# 2. prepare database for GetOrganelle
FastMitoAssembler prepare organelle --list  # list configured databases
FastMitoAssembler prepare organelle -a animal_mt  # config a single database
FastMitoAssembler prepare organelle -a animal_mt -a embplant_mt # config multiple databases
FastMitoAssembler prepare organelle -a all  # config all databases
```

### Run Workflow

`config.yaml` example:
```yaml
reads_dir: '../data/'
samples: ['2222-4']
fq_path_pattern: '{sample}/{sample}_1.clean.fq.gz' # the reads 1 path pattern relative to `reads_dir`
```
see the main Snakefile and Template configfile with: `FastMitoAssembler --help` 
#### Use with Client
```bash
FastMitoAssembler --help

FastMitoAssembler run --help

# run with configfile [recommended]
FastMitoAssembler run --configfile config.yaml

# run with parameters
FastMitoAssembler run --reads_dir ../data --samples S1 --samples S2

# set cores
FastMitoAssembler run --configfile config.yaml --cores 8

# dryrun the workflow
FastMitoAssembler run --configfile config.yaml --dryrun
```
#### Use with Snakemake
```bash
# the `main.smk` and `config.yaml` template can be found with command: `FastMitoAssembler`
snakemake -s /path/to/FastMitoAssembler/smk/main.smk -c config.yaml --cores 4

snakemake -s /path/to/FastMitoAssembler/smk/main.smk -c config.yaml --cores 4 --printshellcmds

snakemake -s /path/to/FastMitoAssembler/smk/main.smk -c config.yaml --printshellcmds --dryrun
```

#### Use with Docker
[docker-readme](./docker/README.md)


##### Softwares Used
- [MEANGS](https://github.com/YanCCscu/meangs)
- [NOVOplasty](https://github.com/Edith1715/NOVOplasty)
- [GetOrganelle](https://github.com/Kinggerm/GetOrganelle)
- [SPAdes](https://github.com/ablab/spades)
- [MitoZ](https://github.com/linzhi2013/MitoZ)
- [NCBI-Blast](https://blast.ncbi.nlm.nih.gov/doc/blast-help/downloadblastdata.html)
