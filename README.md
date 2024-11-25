# Assessing individual sensitivity to the Thermal Grill Illusion: a two-dimensional adaptive psychophysical approach 


## Table of contents
1. [Introduction](#introduction)
2. [Directory Structure](#directory-structure)

## Introduction
This is all the scripts used to run and generate the results and analyses as well as the manuscript for the paper:
"Assessing Individual Sensitivity to the Thermal Grill Illusion:  A Two-Dimensional Adaptive Psychophysical Approach".
## Directory structure

The repository is structured in the following way:

```         
Thermal Pain Learning/
├── README.md             # Overview of the project.
│
├── Figures/              # Figures generated from code to the from the final manuscript.
│   └── ... 
│
├── Manuscripts/          # Folder containing everything needed to recreate the final manuscript in pdf,docx and html.
│   ├── Manuscript.Rmd                # Rmarkdown for the final manuscript.
│   ├── Supplementary material.Rmd    # Rmarkdown for the supplementary material of the final manuscript.
│   └── Kntting files/                # Files used for knitting the manuscript.
│
├── Markdowns/            # Folder containing markdowns for running the analyses and plots.
│   ├── Analysis.Rmd                           # Rmarkdown for for running the main analyses in the manuscript.
│   ├── Supplementary material Analysis.Rmd    # Rmarkdown for the supplementary analyses in the manuscript.
│   └── plots.Rmd                              # Rmarkdown for the plots used in the manuscript.
│
├── scripts/              # Directory containing all R scripts in the project
│   ├── fig2_matlab/            # Code to reproduce figure 2 in matlab
│   ├── experiment/             # Code to reproduce the experiment with the main script being Multi_wrapper.m
│   ├── Utility_functions.R     # Utility functions to gather data, extract summary statistics etc.
│   └── plot.R                  # Functions used to produced the figures in the final manuscript.
│
└── data/                # Directory of data


```
