# Fast Assembler for MitoGenome
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
conda env create -f envs/environment.yml

# method 2: use mamba
conda install mamba -c conda-forge
mamba env create -f envs/environment.yml

# method 3: install manually
conda create -n FastMitoAssembler -y python==3.9.*
conda install -n FastMitoAssembler -y snakemake
conda install -n FastMitoAssembler -y NOVOPlasty
conda install -n FastMitoAssembler -y GetOrganelle
conda install -n FastMitoAssembler -y spades
conda install -n FastMitoAssembler -y blast
conda install -n FastMitoAssembler -y mitoz
conda install -n FastMitoAssembler -y seqkit

conda install -n FastMitoAssembler -y flask
conda install -n FastMitoAssembler -y jinja2 
conda install -n FastMitoAssembler -y pygraphviz

```
#### 2. activate environment 
```bash
source activate FastMitoAssembler
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

# 3. config MEANGS
- Install `MEANGS` according to: https://github.com/YanCCscu/MEANGS
# you can set `MEANGS_PATH` to your environment file(eg. ~/.bash_profile)
echo 'export MEANGS_PATH=$PATH:/path/to/your/meangs_dir' >> ~/.bash_profile
# you can also use the path by parameter in the workflow below
--meangs-path /path/to/your/meangs_dir
```

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
