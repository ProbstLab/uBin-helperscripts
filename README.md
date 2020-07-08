# uBin
Software for manual curation of genomes from metagenomes
Contact: till.bornemann@uni-duisburg-essen.de

# Creating input files for uBin
Prerequisites. The uBin input generator (uBin_wrapper.sh) is bourne-shell-based, requiring an UNIX-based operating system. Users with a Windows OS need to generate a virtual UNIX environment, e.g. using VirtualBox (https://www.virtualbox.org/ ) and we recommend creating an Ubuntu-based UNIX system.

Software dependencies. Software dependencies can be resolved by installing the required software using the conda package management system (https://docs.conda.io/en/latest/) and the supplied uBin_wrapper_reqs.yaml file containing the required software with the respective versions.

$ conda env create -f uBin_wrapper_reqs.yaml
will generate a conda environment called uBin_input_generator_pyt37 that has all the software requirements resolved. It can be activated using 
$ conda activate uBin_input_generator_pyt37 
and should be active whenever the wrapper will be used.

Ruby version and gems. The ruby version most of the scripts are written in is not available via conda and thus needs to be installed separately. For this, a ruby package (“gem”) manager like rvm (https://rvm.io/) is recommended. Using rvm, ruby version 2.3.1 can be installed using
$ rvm install 2.3

and loaded using
$ rvm use 2.3
or set as default using
$ rvm use 2.1 --default
After loading  the respective ruby version, the gems with the coresponding versions listed in ruby_gemlist.info can be installed using 
$ rvm gem install {gemname} -v {version}

For the gem nu, the required version 2.0.1 is not available in public repositories and thus nu.2.0.1 is supplied as nu.gemspec along with the wrapper. The gem can be build installed by the following commands:
$ gem build nu.gemspec
$ gem install nu-2.0.1.gem  

Now all dependencies should be installed.

Databases. Databases for single copy genes are supplied in the /src/ directory and this directory is assumed to be in the same folder as the wrapper script. The FunTaxDB (Uniref100 database along with the taxonomic information for each gene) can be downloaded from the link https://uni-duisburg-essen.sciebo.de/s/pi4cuYwyZ3KJVMl and must also be placed into the /src/ directory (size of the database: 71.06 GB). The path of the Uniref100 database can be modified but should be adjusted at the start of the wrapper script. The fasta files needs to be formatted once:
$ diamond makedb --in FunTaxDBv1.1.fasta -d FunTaxDBv1.1

Usage. There are two basic modes of operation for uBin_wrapper.sh:
1) RUNS all processing steps starting from the assembly fasta file and the respective unshuffled reads and ending up with prepared uBin input. Bin assignments can also be added if needed.
2) COLLECTS GC, coverage, taxonomy, length and bin assignments, RUNS single copy gene prediction on already predicted ORFs, and PREPARES uBin input tables from previously calculated results. All information needs to be provided as flatfiles with scaffold to information.
Switching between the modes is enabled through the -g / --gatherfiles flag, with 1) being the default application. Type 
$ bash uBin_wrapper.sh -h to see all possible commands. 

Example usage for 1):
$ bash uBin_wrapper.sh -s scaffolds.fasta -p pdbg -r1 BG_1_S1_L001_interleaved_trim_clean.PE.1.fastq.gz -r2 BG_1_S1_L001_interleaved_trim_clean.PE.2.fastq.gz -e diamond -t 10 -b das_tool_DASTool_scaffolds2bin.txt

Example usage for 2): 
$ bash uBin_wrapper.sh -g true -p pdbg -e diamond -t 10 -b das_tool_DASTool_scaffolds2bin.txt -c scaffold2cov.txt -y scaffold2gc.txt -l scaffold2len.txt -x scaffold2taxonomy.txt

Example datasets are provided as XXX.

# Installing uBin
For the time being, uBin is hosted here: https://github.com/Shin--/uBin/releases/tag/0.9.14
Use the following files for installation of uBin on the respective operating platform:
uBin-Setup-0.9.14.exe for Windows
uBin-0.9.14.dmg for MacOS
ubin_0.9.14_amd64.deb for Linux
Required are 8 GB of RAM. We use 16 GB to ensure smooth operations (this of course also depends on your dataset).
