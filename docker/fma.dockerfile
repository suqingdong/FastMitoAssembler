FROM suqingdong/fast-mito-assembler-env:latest

LABEL author.name="suqingdong" \
      author.mail="suqingdong1114@gmail.com" \
      description="Fast Assembler Workflow for MitoGenome" \
      github="https://github.com/suqingdong/FastMitoAssembler"

WORKDIR /work


ARG ORGANELLE_DB=animal_mt

COPY ../dist/FastMitoAssembler*.whl /work/
COPY taxdump.tar.gz /work/

RUN \
  python -m pip install -U FastMitoAssembler*.whl && \
  FastMitoAssembler prepare ncbitaxa --taxdump_file taxdump.tar.gz && \
  FastMitoAssembler prepare organelle --add {ORGANELLE_DB} && \
  rm -f FastMitoAssembler*.whl taxdump.tar.gz

CMD ['/bin/bash', '-c', 'source', '~/.bashrc', '&&']
