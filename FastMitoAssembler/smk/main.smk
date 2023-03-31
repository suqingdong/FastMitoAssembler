"""Fast Assembler Workflow for MitoGenome

Author: Qingdong Su
"""
import os
import sys
from pathlib import Path
from functools import partial

FastMitoAssemblerPath = config.get(
    "FastMitoAssemblerPath",
    "/PUBLIC/software/Disease/suqingdong/Code/FastMitoAssembler",
)
sys.path.insert(0, FastMitoAssemblerPath)

from FastMitoAssembler.config import NOVOPLASTY_CONFIG_TPL
from FastMitoAssembler.util import safe_open

# CONFIG
SAMPLES = config.get("samples") or ["XMYGLZHB02", "SRR039541.3"]
ORGANELLE_DB = config.get("organelle_database", "animal_mt")
MEANGS_PATH = config.get(
    "MEANGS_PATH",
    "/PUBLIC/software/Disease/suqingdong/software/bio/meangs/MEANGS-master",
)

# OUTPUT DIRECTORY
RESULT_DIR = Path(config.get("result_dir", "result")).resolve()
SAMPLE_DIR = partial(os.path.join, RESULT_DIR, "{sample}")
MEANGS_DIR = partial(SAMPLE_DIR, "1.MEANGS")
NOVOPLASTY_DIR = partial(SAMPLE_DIR, "2.NOVOPlasty")
ORGANELL_DIR = partial(SAMPLE_DIR, "3.GetOrganelle")
MITOZ_ANNO_DIR = partial(SAMPLE_DIR, "4.MitozAnnotate")

# READS PATTERN
READS_DIR = Path(config.get("reads_dir", ".")).resolve()
FQ1 = READS_DIR.joinpath("{sample}_1.clean.fq.gz")
FQ2 = READS_DIR.joinpath("{sample}_2.clean.fq.gz")

# Params
CLADE = config.get('clade', 'Annelida-segmented-worms')


# rule all as default run
rule all:
    input:
        expand(
            MITOZ_ANNO_DIR(f"{{sample}}.{ORGANELLE_DB}.K127.complete.graph1.1.path_sequence.fasta.result", "circos.png"),
            sample=SAMPLES,
        ),

rule MEANGS:
    """
    https://github.com/YanCCscu/MEANGS/

    Input: fq1, fq2
    Output: the longest fasta

    *_Meangs_detected_mito.fas 中第一行 fasta 文件，并传递给参数“-s”;
    """
    input:
        fq1=FQ1,
        fq2=FQ2,
    output:
        meangs_fas=MEANGS_DIR("{sample}_deep_detected_mito.fas"),
    params:
        outdir=MEANGS_DIR(),
    message:
        "MEANGS for sample: {wildcards.sample}"
    shell:
        """
        export PATH=$PATH:{MEANGS_PATH}

        mkdir -p {params.outdir}
        cd {params.outdir}

        meangs.py \\
            -1 {input.fq1} \\
            -2 {input.fq2} \\
            -o {wildcards.sample} \\
            -t 2 \\
            -n 2000000 \\
            -i 350 \\
            --deepin

        # keep the first reads only
        seqkit head -n1 -w0 \\
            -o {output.meangs_fas} \\
            {wildcards.sample}/{wildcards.sample}_deep_detected_mito.fas
        """

rule NOVOPlasty_config:
    input:
        fq1=FQ1,
        fq2=FQ2,
        meangs_fas=MEANGS_DIR("{sample}_deep_detected_mito.fas"),
    output:
        novoplasty_config=NOVOPLASTY_DIR("config.txt"),
    params:
        output_path=NOVOPLASTY_DIR() + os.path.sep,
    run:
        with safe_open(output.novoplasty_config, "w") as out:
            context = NOVOPLASTY_CONFIG_TPL.render(
                seed_fasta=input.meangs_fas,
                sample=wildcards.sample,
                fq1=input.fq1,
                fq2=input.fq2,
                output_path=params.output_path,
                genome_min_size=12000,
                genome_max_size=30000,
                kmer_size=39,
                max_mem_gb=8,
                read_length=150,
                insert_size=300,
            )
            out.write(context)

rule NOVOPlasty:
    """
    https://github.com/Edith1715/NOVOplasty

    Project name          = {sample}
    Type                  = mito
    Genome Range          = 12000-30000
    K-mer                 = 39 [21-39]
    Max memory            = 4  [limit memory, unit GB]

    novoplasty 运行结果作为下游 Getorganelle 软件参数：-s“； novo 结果若没
    有成环，会生成如下格式，需要去除”+“.
    """
    input:
        novoplasty_config=NOVOPLASTY_DIR("config.txt"),
    output:
        novoplasty_contigs=NOVOPLASTY_DIR("Contigs_1_{sample}.fasta"),
        novoplasty_contigs_new=NOVOPLASTY_DIR("Contigs_1_{sample}.new.fasta"),
    shell:
        """
        NOVOPlasty.pl -c {input.novoplasty_config}

        # remove +xxx
        seqkit replace -w0 \\
            -p "\+.+" -r "" \\
            -o {output.novoplasty_contigs_new} \\
            {output.novoplasty_contigs}
        """

rule GetOrganelle:
    """
    https://github.com/Kinggerm/GetOrganelle

    组装线粒体基因组，优先使用 5G 数据，超过 5G,
    使用 seqtk 等软件，随机选择 5G 数据进行组装
    """
    input:
        fq1=FQ1,
        fq2=FQ2,
        novoplasty_contigs_new=NOVOPLASTY_DIR("Contigs_1_{sample}.new.fasta"),
    output:
        organelle_fasta=ORGANELL_DIR(f"{ORGANELLE_DB}.K127.complete.graph1.1.path_sequence.fasta"),
        organelle_fasta_new=ORGANELL_DIR(f"{ORGANELLE_DB}.K127.complete.graph1.1.path_sequence.new.fasta"),
    params:
        output_path=ORGANELL_DIR()
    shell:
        """
        # get 5G data
        mkdir -p {params.output_path}
        cd {params.output_path}

        reads_num_5G=$(python -c "print(round(5e9 / 2 / 150))")

        seqkit stats {input.fq1} > {wildcards.sample}.fq1.stats.txt
        reads_num_fq1=$(awk 'NR==2{{print $4}}' {wildcards.sample}.fq1.stats.txt | sed 's#,##g')
        echo "reads num of fq1: $reads_num_fq1"

        if [ $reads_num_fq1 -gt $reads_num_5G ];then
            seqkit head -n $reads_num_5G -w0 {input.fq1} -j4 -o {wildcards.sample}_1.5G.fq.gz
            seqkit head -n $reads_num_5G -w0 {input.fq2} -j4 -o {wildcards.sample}_2.5G.fq.gz
        else
            ln -sf {input.fq1} {wildcards.sample}_1.5G.fq.gz
            ln -sf {input.fq2} {wildcards.sample}_2.5G.fq.gz
        fi

        get_organelle_from_reads.py \\
            -1 {wildcards.sample}_1.5G.fq.gz\\
            -2 {wildcards.sample}_1.5G.fq.gz \\
            -R 20 \\
            -k 21,33,45,55,65,75,85,95,105,111,127 \\
            -F {ORGANELLE_DB} \\
            -o {params.output_path} \\
            --reduce-reads-for-coverage inf \\
            --max-reads inf \\
            -s {input.novoplasty_contigs_new}

        # replace '+', 'circular' characters
        seqkit replace -w0\\
            -p ".*(circulars).*" -r "{wildcards.sample} topology=circular" \\
            -p ".+" -r "{wildcards.sample} topology=linear" \\
            -o {output.organelle_fasta_new} \\
            {output.organelle_fasta}
    """

rule MitozAnnotate:
    """
    https://github.com/linzhi2013/MitoZ

    使用 Mitoz 注释； Getorganelle 组装结果，fasta 表头，存在“+“，
    ‘circular‘等字符，下游 Mitoz 识别不了，需要修改；若出现”（circular）”即
    将即替换为{”空格“+ topology=circular},否则替换为{空格+ topology=linear}；
    """
    input:
        fq1=FQ1,
        fq2=FQ2,
        organelle_fasta_new=ORGANELL_DIR(f"{ORGANELLE_DB}.K127.complete.graph1.1.path_sequence.new.fasta"),
    output:
        circos=MITOZ_ANNO_DIR(f"{{sample}}.{ORGANELLE_DB}.K127.complete.graph1.1.path_sequence.fasta.result", "circos.png"),
    params:
        outdir=MITOZ_ANNO_DIR()
    shell:
        """
        mkdir -p {params.outdir}

        mitoz annotate \\
            --workdir {params.outdir} \\
            --outprefix {wildcards.sample} \\
            --thread_number 20 \\
            --fastafiles {input.organelle_fasta_new} \\
            --fq1 {input.fq1} \\
            --fq2 {input.fq2} \\
            --species_name "{wildcards.sample}" \\
            --genetic_code 5 \\
            --clade {CLADE}
        """
