FROM suqingdong/centos7-miniconda3:latest

LABEL author.name="suqingdong" \
      author.mail="suqingdong1114@gmail.com" \
      description="Base Environment for FastMitoAssembler" \
      github="https://github.com/suqingdong/FastMitoAssembler"

WORKDIR /work


COPY ../environment.yml /work/

RUN \
  mamba env create -f environment.yml && \
  echo "source /opt/miniconda3/bin/activate FastMitoAssembler" >> ~/.bashrc && \
  rm -f environment.yml