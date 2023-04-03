import json
from pathlib import Path

BASE_DIR = Path(__file__).resolve().parent
MAIN_SMK = BASE_DIR.joinpath('smk', 'main.smk')
CONFIG_DEFAULT = BASE_DIR.joinpath('smk', 'config.yaml')

BASE_DIR = Path(__file__).resolve().parent
VERSION = json.load(BASE_DIR.joinpath('version.json').open())
__version__ = VERSION['version']

BANNER = BASE_DIR.joinpath('banner.txt').read_text().format(version=__version__)