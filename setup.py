from distutils.core import setup
from distutils.extension import Extension
from Cython.Distutils import build_ext


setup(name = "genetic_algorithms",
    version = "0.0.1",
    description = "Genetic algorithm library",
    keywords = "cpuinfo",
    author = "Christian Fobel",
    url = "https://github.com/cfobel/python-genetic_algorithms",
    license = "GPL",
    long_description = """Currently, only contains a crossover operation""",
    cmdclass = {'build_ext': build_ext},
    packages = ['genetic_algorithms'],
    ext_modules = [Extension('genetic_algorithms.cCrossover',
                             ['src/cCrossover.pyx'])]
)
