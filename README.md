# stg embedding

![](https://user-images.githubusercontent.com/6005346/125205442-46526c80-e250-11eb-9673-192e504822a1.png)

This repository contains code to reproduce every figure in 

[Mapping circuit dynamics during function and dysfunction](https://www.biorxiv.org/content/10.1101/2021.07.06.451370v1.full.pdf)



## Installation and prerequisites 

You will need MATLAB. 

Download the following repositories and add them to your MATLAB path:

```
https://github.com/sg-s/stg-embedding
https://github.com/sg-s/srinivas.gs_mtools
https://github.com/sg-s/crabsort
https://github.com/KlugerLab/FIt-SNE

```

## Data

The raw data is >30TB and getting it into your hands is not easy. Instead we provide [reduced data](https://en.wikipedia.org/wiki/Data_reduction) consisting of spiketimes, metadata and various annotations. This should allow you to reproduce every figure in the paper. 

To get the data, download it from [Zenodo](https://zenodo.org/record/5090130). 

## How to regenerate figures 


1. First, download the code and add to path (see above).
2. Then, [download the data](https://zenodo.org/record/5090130) and put it in a folder called "reduced-data" within your "stg-embedding" folder. You will have to create this if needed. 
3. Then, navigate to the `paper-figures` folder and run any script to generate that figure. For example, to generate Figure 2, run: `fig_embedding`. 

## License 

GPL v3