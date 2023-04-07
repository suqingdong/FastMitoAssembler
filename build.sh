rm -rf build dist *egg-info

python setup.py build sdist bdist_wheel

rm -rf build *egg-info
