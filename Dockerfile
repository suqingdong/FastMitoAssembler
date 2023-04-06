FROM suqingdong/centos7-miniconda3:latest

LABEL author.name="suqingdong" \
      author.mail="suqingdong1114@gmail.com" \
      description="Fast Assembler for MitoGenome" \
      github="https://github.com/suqingdong/FastMitoAssembler"

WORKDIR /data

COPY environment.yml /data/
COPY FastMitoAssembler-1.0.1-py3-none-any.whl /data/

RUN \
  conda env create -f environment.yml && \
  echo "conda activate FastMitoAssembler" >> ~/.bashrc && \
  conda activate FastMitoAssembler && \
  python -m pip install FastMitoAssembler-1.0.1-py3-none-any.whl -y && \
  rm -f environment.yml FastMitoAssembler-1.0.1-py3-none-any.whl
