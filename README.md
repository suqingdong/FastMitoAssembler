# Fast Assembler Workflow for MitoGenome
> `FastMitoAssembler` is a software for fast, accurate assembly of mitochondrial genomes and generation of annotation documents.

### Softwares
- [MEANGS](https://github.com/YanCCscu/meangs)
- [NOVOplasty](https://github.com/Edith1715/NOVOplasty)
- [GetOrganelle](https://github.com/Kinggerm/GetOrganelle)
- [SPAdes](https://github.com/ablab/spades)
- [MitoZ](https://github.com/linzhi2013/MitoZ)
- [NCBI-Blast](https://blast.ncbi.nlm.nih.gov/doc/blast-help/downloadblastdata.html)

### Installation
#### 1. create environment
```bash
# method 1: use conda
conda env create -f environment.yml

# method 2: use mamba [recommended]
conda install mamba -c conda-forge -y
mamba env create -f environment.yml

# method 3: install manually
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
```

#### 2. activate environment 
```bash
source $(dirname `which conda`)/activate FastMitoAssembler
python -m pip insatll genbank
```

#### 3. install FastMitoAssembler
```bash
python -m pip install -U FastMitoAssembler
```

### Prepare
```bash
FastMitoAssembler prepare

# 1. prepare ete3.NCBITaxa
FastMitoAssembler prepare ncbitaxa

# 2. prepare database for GetOrganelle
FastMitoAssembler prepare organelle --list  # list configured databases
FastMitoAssembler prepare organelle -a animal_mt  # config a single database
FastMitoAssembler prepare organelle -a animal_mt -a embplant_mt # config multiple databaes
FastMitoAssembler prepare organelle -a all  # config all databases

### Usage
#### Use with Client
```bash
FastMitoAssembler

FastMitoAssembler run --help

# run with configfile [recommended]
FastMitoAssembler run --configfile config.yaml

# run with parameters
FastMitoAssembler run --reads-dir ../data --samples S1 --samples S2 --meangs-path /path/to/your/meangs_dir

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
