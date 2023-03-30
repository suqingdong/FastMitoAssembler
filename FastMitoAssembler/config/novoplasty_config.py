import jinja2

NOVOPLASTY_CONFIG_TPL = jinja2.Template('''
Project:
-----------------------
Project name          = {{sample}}
Type                  = mito
Genome Range          = {{genome_min_size}}-{{genome_max_size}}
K-mer                 = {{kmer_size}}
Max memory            = {{max_mem_gb}}
Extended log          = 0
Save assembled reads  = no
Seed Input            = {{seed_fasta}}
Extend seed directly  = no
Reference sequence    = 
Variance detection    = 
Chloroplast sequence  = 

Dataset 1:
-----------------------
Read Length           = {{read_length or 150}}
Insert size           = {{insert_size or 300}}
Platform              = illumina
Single/Paired         = PE
Combined reads        = 
Forward reads         = {{fq1}}
Reverse reads         = {{fq2}}
Store Hash            =

Heteroplasmy:
-----------------------
MAF                   = 
HP exclude list       = 
PCR-free              = 

Optional:
-----------------------
Insert size auto      = yes
Use Quality Scores    = no
Output path           = {{output_path}}
''')
