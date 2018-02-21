#!/usr/bin/env python
from setuptools import setup, find_packages
from distutils.extension import Extension
from Cython.Build import cythonize

setup(
    name='fasterzip',
    packages=find_packages(),
    version='1.0',
    description='A faster zip module.',
    author='Tyler Kennedy',
    author_email='tk@tkte.ch',
    url='http://github.com/TkTech/fasterzip',
    keywords=['java'],
    classifiers=[
        'Programming Language :: Python',
        'License :: OSI Approved :: MIT License',
        'Operating System :: OS Independent',
        'Development Status :: 3 - Alpha',
        'Intended Audience :: Developers',
    ],
    install_requires=[
        'Cython'
    ],
    tests_require=[
        'pytest>=2.10',
    ],
    ext_modules=cythonize([
        Extension(
            'fasterzip',
            [
                'fasterzip.pyx',
                'miniz.c'
            ]
        )
    ])
)
