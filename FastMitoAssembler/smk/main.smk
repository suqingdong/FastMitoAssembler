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

        seqkit head -n1 \\
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
    """
    input:
        novoplasty_config=NOVOPLASTY_DIR("config.txt"),
    output:
        novoplasty_contigs=NOVOPLASTY_DIR("Contigs_1_{sample}.fasta"),
    shell:
        """
        NOVOPlasty.pl -c {input.novoplasty_config}
        """

rule GetOrganelle:
    """
    https://github.com/Kinggerm/GetOrganelle
    """
    input:
        fq1=FQ1,
        fq2=FQ2,
        novoplasty_contigs=NOVOPLASTY_DIR("Contigs_1_{sample}.fasta"),
    output:
        organelle_fasta=ORGANELL_DIR(f"{ORGANELLE_DB}.K127.complete.graph1.1.path_sequence.fasta"),
    params:
        output_path=ORGANELL_DIR()
    shell:
        """
        get_organelle_from_reads.py \\
            -1 {input.fq1} \\
            -2 {input.fq2} \\
            -R 20 \\
            -k 21,33,45,55,65,75,85,95,105,111,127 \\
            -F ${ORGANELLE_DB} \\
            -o {params.output_path} \\
            --reduce-reads-for-coverage inf \\
            --max-reads inf \\
            -s {input.novoplasty_contigs}

        sed -i 's#>.*#>{wildcards.sample}#g' {output.organelle_fasta}
        """

rule MitozAnnotate:
    """
    https://github.com/linzhi2013/MitoZ
    """
    input:
        fq1=FQ1,
        fq2=FQ2,
        organelle_fasta=ORGANELL_DIR(f"{ORGANELLE_DB}.K127.complete.graph1.1.path_sequence.fasta"),
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
            --fastafiles {input.organelle_fasta} \\
            --fq1 {input.fq1} \\
            --fq2 {input.fq2} \\
            --species_name "{wildcards.sample}" \\
            --genetic_code 5 \\
            --clade Annelida-segmented-worms
        """
