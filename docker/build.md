```bash
# build env
cp -f ../environment.yml .
docker build -f fma.env.dockerfile -t suqingdong/fast-mito-assembler-env:latest .


# build FastMitoAssembler
cp -f ../dist/FastMitoAssembler*whl .
if [ ! -f taxdump.tar.gz ];then
    wget -c ftp.ncbi.nlm.nih.gov/pub/taxonomy/taxdump.tar.gz
fi
docker build -f fma.dockerfile -t suqingdong/fast-mito-assembler:latest .

# docker login

# push image
docker push suqingdong/fast-mito-assembler-env:latest 
docker push suqingdong/fast-mito-assembler:latest 

# push README
docker-pushrm suqingdong/fast-mito-assembler:latest 
```
