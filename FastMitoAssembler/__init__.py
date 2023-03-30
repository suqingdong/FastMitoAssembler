from pathlib import Path

BASE_DIR = Path(__file__).resolve().parent
TOOLS_DIR = BASE_DIR.joinpath('tools')
MAIN_SMK = BASE_DIR.joinpath('smk', 'main.smk')