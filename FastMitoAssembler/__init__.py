import json
from pathlib import Path

from FastMitoAssembler import util


BASE_DIR = Path(__file__).resolve().parent
MAIN_SMK = BASE_DIR.joinpath('smk', 'main.smk')
DEFAULT_CONFIG_FILE = BASE_DIR.joinpath('smk', 'config.yaml')
DEFAULT_OPTION_FILE = BASE_DIR.joinpath('smk', 'options.yaml')
DEFAULT_CONFIG = util.read_yaml(DEFAULT_CONFIG_FILE)
DEFAULT_OPTIONS = util.read_yaml(DEFAULT_OPTION_FILE)

BASE_DIR = Path(__file__).resolve().parent
VERSION = json.load(BASE_DIR.joinpath('version.json').open())
__version__ = VERSION['version']

BANNER = BASE_DIR.joinpath('banner.txt').read_text().format(version=__version__)