# CS3210 Assignment 2

## CUDA
### How to compile
Make sure you have `nvcc` installed.

Go to the `cuda/` directory.

Then, just run:
```bash
make
```

### How to run
```bash
./0123HomeWork <num_blocks> <num_threads> < input_file
```

For example:
```bash
./0123HomeWork 80 64 < input
```

## OpenMP
### How to compile
Make sure you have OpenMP installed.

Go to the `openmp/` directory.

Then, just run:
```bash
make
```

### How to run
```bash
./0123HomeWork-openmp <num_threads> < input_file
```

For example:
```bash
./0123HomeWork-openmp 20 < input_file
```

## Sample input file
We have included the sample input file in the `sample/` directory
