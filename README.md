# uBin
Software for manual curation of genomes from metagenomes

Contact: till.bornemann@uni-duisburg-essen.de

The uBin App is located in the repository https://github.com/ProbstLab/uBin.

The input Generation script as well as test files are located in https://github.com/ProbstLab/uBin-helperscripts.

# Creating input files for uBin
Prerequisites. The uBin input generator (uBin_wrapper.sh) is bourne-shell-based, requiring an UNIX-based operating system. Users with a Windows OS need to generate a virtual UNIX environment, e.g. using VirtualBox (https://www.virtualbox.org/) and we recommend creating an Ubuntu-based UNIX system.

Software dependencies. Software dependencies can be resolved by installing the required software using the conda package management system (https://docs.conda.io/en/latest/) and the supplied uBin_wrapper_reqs.yaml file containing the required software with the respective versions.

$ conda env create -f uBin_wrapper_reqs.yaml

will generate a conda environment called uBin_input_generator_pyt37 that has all the software requirements resolved. It can be activated using 
$ conda activate uBin_input_generator_pyt37 

and should be active whenever the wrapper will be used.

Ruby version and gems. The ruby version most of the scripts are written in is not available via conda and thus needs to be installed separately. For this, a ruby package (“gem”) manager like rvm (https://rvm.io/) is recommended. Some users have reported problems installing rvm as the required libssl1.0-dev is not available in all Unix distributions. Fixes for this problem have been described in https://github.com/rvm/rvm/issues/4915.

Using rvm, ruby version 2.3 can be installed using

$ rvm install 2.3

and loaded using

$ rvm use 2.3

or set as default using

$ rvm use 2.3 --default

The bundler gem can be installed using

$ gem install bundler -v 1.16

The bundler gem then allows the direct installation of the ruby gems (defined in the 'Gemfile') with the requisite versions using the command

$ bundle install

If there are errors during the installation, you may try to install the gems (defined in the Gemfile) separately using the command

$ rvm gem install {gemname} -v {version}

If errors still occur, try 

$ rvm gem install {gemname} 

without the version specification.

For the gem nu, the required version 2.0.1 is not available in public repositories and thus nu.2.0.1 is supplied as the gem file nu-2.0.1.gem along with the wrapper. You can find the license for the nu gem at https://github.com/bcthomas/mgnu. The gem is installed by the following command:

$ gem install --local nu-2.0.1.gem

Now all dependencies should be installed.

Databases. Databases for single copy genes are supplied in the /bin/SCG/ directory and this directory is assumed to be in the same folder as the wrapper script. The FunTaxDB (Uniref100 database along with the taxonomic information for each gene) can be downloaded from the link https://uni-duisburg-essen.sciebo.de/s/pi4cuYwyZ3KJVMl and must also be placed into the /bin/SCG/ directory. The path of the Uniref100 database can be modified but should be adjusted at the start of the wrapper script. The fasta files needs to be formatted once:

$ diamond makedb --in FunTaxDBv1.1.fasta -d FunTaxDBv1.1

Usage. There are two basic modes of operation for uBin_wrapper.sh:

1) RUNS all processing steps starting from the assembly fasta file and the respective unshuffled reads and ending up with prepared uBin input. Bin assignments can also be added if needed. You currently need to execute this mode from the folder with your assembly file.

2) COLLECTS GC, coverage, taxonomy, length and bin assignments, RUNS single copy gene prediction on already predicted ORFs, and PREPARES uBin input tables from previously calculated results. All information needs to be provided as flatfiles with scaffold to information (tab-separated).
Switching between the modes is enabled through the -g / --gatherfiles flag, with 1) being the default application. Type 

$ bash uBin_wrapper.sh -h to see all possible commands. 

3) If you already have an overview file summarizing GC, coverage, taxonomy and length information for each scaffold and following the required format (for details see below) and just want to add the bin information to this table, you can also use the script https://github.com/ProbstLab/uBin-helperscripts.git/bin/09_additionbincol.sh directly to add the Bin information to the overview file. 

Required format of overview file(tab-separated columns with the taxonomic levels being ';'-separated and the column names need to be the same as in the format example):
```
scaffold	GC	coverage	length	taxonomy
PD_BG_1_1000_length_2754_cov_3_432753	51.6	5.6	2754	Bacteria;Proteobacteria;Gammaproteobacteria;Methylococcales;Methylomonas;unclassified
```

$ bash 09_additionbincol.sh {scaf2bin-file} {overviewfile} > {overviewfile_with_bincol}.txt

Example usage for 1):

$ bash uBin_wrapper.sh -s scaffolds.fasta -p pdbg -r1 BG_1_S1_L001_interleaved_trim_clean.PE.1.fastq.gz -r2 BG_1_S1_L001_interleaved_trim_clean.PE.2.fastq.gz -e diamond -t 10 -b das_tool_DASTool_scaffolds2bin.txt

Example usage for 2): 

$ bash uBin_wrapper.sh -g true -p pdbg -e diamond -t 10 -b das_tool_DASTool_scaffolds2bin.txt -c scaffold2cov.txt -y scaffold2gc.txt -l scaffold2len.txt -x scaffold2taxonomy.txt

Example usage for 3):

$ bash 09_additionbincol.sh das_tool_DASTool_scaffolds2bin.txt pdbg_min1000.fasta.overview.txt > pdbg_min1000.fasta.overview_bincol.txt

An example dataset from Gulliver et al. 2019 DOI:10.1111/1758-2229.12675 is provided in 'example_dataset' for testing the uBin_wrapper.sh.

# Installing uBin

The current release of uBin can be downloaded from https://github.com/ProbstLab/uBin/releases/tag/0.9.14
Use the following files for installation of uBin on the respective operating platform (recommended):

uBin-Setup-0.9.14.exe for Windows

uBin-0.9.14.dmg for MacOS

ubin_0.9.14_amd64.deb for Linux

Required are 8 GB of RAM. We use 16 GB to ensure smooth operations (this of course also depends on your dataset). 
Alternatively, you can also compile it yourself by following the instructions in the uBin repository https://github.com/ProbstLab/uBin.

Three example datasets from the CAMI challenge are provided in 'CAMI_test_dataset' for testing the uBin software (low, medium and high complexity datasets).

# The uBin interface

The uBin interface consists of two parts, an Import tab and a Samples tab. 

# Import tab

The following figure shows the import tab, accessible via the 'Import' button in the top left of the uBin interface. Here, new samples can be imported. 

![Figure 1: Import tab](./uBin_interface_explanation/import_tab.pdf?raw=true)

Their format needs to be in accordance to the output of the described input generator and consists of a tab-separated overview table (called taxonomy file in the interface), containing (in that order) the scaffold name, the GC content, the coverage, the length, the consensus taxonomy and finally the Bin column. The Bin column can be empty apart from the header if uBin is to be used as a direct binning software. There should be no blanks in the file and the column headers should be the same as in the supplied test files. The second file contains comma-separated single copy gene (scg) information for universal scgs of both Bacteria and Archaea. The software was developed with the genome curation/binning of prokaryotes in mind.

Import troubleshooting
- please check that there are no blanks in the import files and that the headers are in accordance to the sample files
- if the Bin column is empty, please check that the scaffold names in the overview file and the scaffold2bin file are identical
- the sample names need to be unique, thus check if you already have an imported file with the given sample name

# Samples tab

The following shows the Samples tab, which is the tab opening upon starting uBin and can be accessed via the button in the top left.
![Figure 2: Samples tab](./uBin_interface_explanation/Sample_tab.pdf?raw=true)

the Samples interface has multiple plots showing specific characteristics of your selected Bin in various views. All plots apart from the SCG plots (the two barcharts on the right) are interactive, meaning if you change the selection in one plot, the selection in the other plots will follow suit. Different filtering options are available
1) barcharts for GC and coverage at the bottom that allow the definition of an acceptable range of Cov/GC values by moving the borders with your cursor
2) A Sunburst-chart (here, affectionately called "taxonomy wheel") displaying the consensus taxonomy of the bin from domain (inner ring) to species (outer ring).
- taxonomies (of any taxonomic level) can be selected by clicking on them, filtering also the other charts
- taxonomies can also be excluded by pressing the 'e'-key ( for "exclude") while klicking on the taxonomy
3) A GC vs Coverage scatterplot, combining the information of both barcharts
- the data points in this graph are aggregated if they are close together to allow for faster rendering so dont be surprised if there are less dots than scaffolds.
- you can switch between scaling the coverage to log10 or not, both have their suitability in some scaffold distributions accross the plot

By default, uBin only shows the binned scaffolds, even if you have imported all scaffolds or just the unbinned scaffolds. You can change this behaviour by clicking on "Show all (filtered) scaffolds" on the top, or "Limit to Bin" if you want to go back to just viewing binned scaffolds.

# Video introduction
A video introduction into the usage of uBin as a genome curation tool is given in the subfolder ./uBin_interface_explanation/uBin_intro.mov, showing you how to 
the steps
1) going to the Import tab
2) importing a sample into uBin
3) changing to Samples tab
4) selecting the newly imported sample
5) selecting a not yet curated bin
6) adjusting GC/coverage bar charts and accessing the taxonomy and completeness/contamination to define the bin
7) saving it
8) doing the same with a new bin
9) exporting the newly defined Bin

In the video, step 9) just exports a table as no fasta file was supplied containing the respective scaffold fasta sequences of the metagenome. If you supply a .fasta file here containing the scaffolds (beware that the fasta-headers need to match the scaffold names in the overview/SCG file), then in addition to getting basically a modified overview table with your curated bin information, you will also get each newly curated genomic bin exported as an individual .fasta file. 
