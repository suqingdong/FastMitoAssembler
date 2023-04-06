# 1. use conda
# conda env create -f envs/environment.yml

# 2. use mamba
# conda install mamba -c conda-forge
# mamba env create -f envs/environment.yml

# 3. install manually
conda config --add channels yccscucib
conda config --add channels bioconda
conda config --add channels conda-forge

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
# conda install -n FastMitoAssembler -y pygraphviz

# activate
source activate FastMitoAssembler