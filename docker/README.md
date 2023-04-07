# Fast Assembler Workflow for MitoGenome
> `FastMitoAssembler` is a software for fast, accurate assembly of mitochondrial genomes and generation of annotation documents.

# Use in Docker
```bash
docker run --rm -it suqingdong/FastMitoAssembler FastMitoAssembler

docker run --rm -it suqingdong/FastMitoAssembler FastMitoAssembler run

docker run --rm -it -v ../data:/work/data -v ./config.yaml:/work/config.yaml suqingdong/FastMitoAssembler FastMitoAssembler run --cofnigfile config.yaml
```