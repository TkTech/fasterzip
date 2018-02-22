# Fasterzip

Fasterzip is a self-contained Python3.6+ and pypy3 cython module wrapping a
subset of the [miniz] library to provide *fast* decompression of ZIP files
when compared to the built-in [zipfile] module. Extraction of ZIP files with
many entries is typically around ~33% faster.

## Performance

| Sample | CPython zipfile | fasterzip | Speedup |
| --- | --- | --- | --- |
| Reading 100000 1-byte files | ~3.43ms | ~1.24ms | 63% |
| 

[miniz]: https://github.com/richgel999/miniz 
[zipfile]: https://docs.python.org/3/library/zipfile.html