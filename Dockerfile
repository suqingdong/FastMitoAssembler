FROM suqingdong/centos7-miniconda3:latest

WORKDIR /data

COPY environment.yml /data/

RUN \
  conda env create -f environment.yml && \
  echo "conda activate FastMitoAssembler" >> ~/.bashrc && \
  conda activate FastMitoAssembler && \
  python -m pip install 
