# Fast Assembler Workflow for MitoGenome
> `FastMitoAssembler` is a software for fast, accurate assembly of mitochondrial genomes and generation of annotation documents.

## Use in Docker
```bash
# help
docker run --rm -it suqingdong/fast-mito-assembler:latest
docker run --rm -it suqingdong/fast-mito-assembler:latest FastMitoAssembler run

# use FastMitoAssembler
docker run --rm -it \
  -v $PWD/data:/work/data \
  -v $PWD/config.yaml:/work/config.yaml \
  suqingdong/fast-mito-assembler \
  FastMitoAssembler run --configfile config.yaml --dryrun

# use Snakemake
docker run --rm -it \
  -v $PWD/data:/work/data \
  -v $PWD/config.yaml:/work/config.yaml \
  suqingdong/fast-mito-assembler \
  snakemake -s /opt/miniconda3/envs/FastMitoAssembler/lib/python3.9/site-packages/FastMitoAssembler/smk/main.smk --configfile config.yaml --dryrun
```
`config.yaml`
```yaml
reads_dir: 'data'
samples: ['2222-4']
fq_path_pattern: '{sample}/{sample}_1.clean.fq.gz'
seed_input: '2222-4_deep_detected_mito.fas'
```

## Use in DockerCompose
```yaml
# docker-compose.yml
version: "3"

services:
  fast_mito_assembler:
    image: suqingdong/fast-mito-assembler:latest
    volumes:
      - ./data:/work/data
      - ./config.yaml:/work/config.yaml
      - ./2222-4_deep_detected_mito.fas:/work/2222-4_deep_detected_mito.fas
    command: FastMitoAssembler run --configfile config.yaml --dryrun
```
```bash
docker-compose up
```