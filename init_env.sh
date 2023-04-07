# install conda if not conda is not installed 
# wget -c https://mirrors.tuna.tsinghua.edu.cn/anaconda/miniconda/Miniconda3-latest-Linux-x86_64.sh
# sh Miniconda3-latest-Linux-x86_64.sh -bfp /opt/miniconda3
# echo 'export PATH=/opt/miniconda3/bin:$PATH' >> ~/.bashrc

conda install mamba -c conda-forge -y
mamba env create -f environment.yml
