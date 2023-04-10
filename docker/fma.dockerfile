FROM suqingdong/fast-mito-assembler-env:latest

LABEL author.name="suqingdong" \
      author.mail="suqingdong1114@gmail.com" \
      description="Fast Assembler Workflow for MitoGenome" \
      github="https://github.com/suqingdong/FastMitoAssembler"

WORKDIR /work

COPY FastMitoAssembler*.whl /work/
COPY etetoolkit /root/.etetoolkit
COPY GetOrganelleDB /root/.GetOrganelle

RUN \
  source ~/.bashrc && \
  python -m pip install -U FastMitoAssembler*.whl && \
  rm -f FastMitoAssembler*.whl


ENTRYPOINT ["/bin/bash", "-c", "source ~/.bashrc && exec \"$@\"", "--"]

CMD ["FastMitoAssembler"]
