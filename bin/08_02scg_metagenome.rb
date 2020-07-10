require "trollop"
require 'csv'
require 'nu'

opts=Trollop::options do
    banner <<-EOS

This table will create a bacterial (51) and archaeal (38) SCG overview table for a metagenome containing all scaffolds.

Usage
ruby scg_metagenome.rb [options]
where options are:
EOS
  opt :scaffolds, "scaff_min1000 file from the assembly, ending with .fasta", :type => :string, :required => true
  opt :proteins, "prodigal predicted aminoacid sequencesi, ending with .faa", :type => :string, :required => true
  opt :dbdirectory, "directory with scripts and databases",:type => :string, :required => true
  opt :engine_search, "search engine to use: [diamond | usearch | blast]",:type => :string, :required => true
  opt :threads, "threads to use, integer",:type => Integer, :required => true
end

sca=opts[:scaffolds]
pro=opts[:proteins]
dbdir=opts[:dbdirectory]
engine=opts[:engine_search]
threads=opts[:threads]
#puts "#{sca} #{pro} #{dbdir} #{engine} #{threads}"
# read all scaffolds
scaff = []
Nu::Parser::Fasta.new(sca).each do |seq|
	scaff.push(seq.header.split(" ")[0])
end


# list of all possible bacterial and archaeal single copy genes
scgs = ["B_Histidyl-tRNA_synthetase", "B_Phenylalanyl-tRNA_synthetase_alpha", "B_Preprotein_translocase_subunit_SecY", "B_Valyl-tRNA_synthetase", "B_alanyl_tRNA_synthetase", "B_arginyl_tRNA_synthetase", "B_aspartyl_tRNA_synthetase", "B_gyrA", "B_leucyl-tRNA_synthetase", "B_recA", "B_ribosomal_protein_L1", "B_ribosomal_protein_L10", "B_ribosomal_protein_L11", "B_ribosomal_protein_L13", "B_ribosomal_protein_L14", "B_ribosomal_protein_L15", "B_ribosomal_protein_L16-L10E", "B_ribosomal_protein_L17", "B_ribosomal_protein_L18", "B_ribosomal_protein_L19", "B_ribosomal_protein_L2", "B_ribosomal_protein_L20", "B_ribosomal_protein_L21", "B_ribosomal_protein_L22", "B_ribosomal_protein_L23", "B_ribosomal_protein_L24", "B_ribosomal_protein_L27", "B_ribosomal_protein_L29", "B_ribosomal_protein_L3", "B_ribosomal_protein_L30", "B_ribosomal_protein_L4", "B_ribosomal_protein_L5", "B_ribosomal_protein_L6P-L9E", "B_ribosomal_protein_S10", "B_ribosomal_protein_S11", "B_ribosomal_protein_S12", "B_ribosomal_protein_S13", "B_ribosomal_protein_S15", "B_ribosomal_protein_S16", "B_ribosomal_protein_S17", "B_ribosomal_protein_S18", "B_ribosomal_protein_S19", "B_ribosomal_protein_S2", "B_ribosomal_protein_S20", "B_ribosomal_protein_S3", "B_ribosomal_protein_S4", "B_ribosomal_protein_S5", "B_ribosomal_protein_S6", "B_ribosomal_protein_S7", "B_ribosomal_protein_S8", "B_ribosomal_protein_S9", "A_CCA-adding_enzyme", "A_DNA-directed_RNA_polymerase", "A_DNA-directed_RNA_polymerase_subunit_N", "A_Dimethyladenosine_transferase", "A_Diphthamide_biosynthesis_protein", "A_Fibrillarin-like_rRNA/tRNA_2'-O-methyltransferase", "A_Glycyl-tRNA_synthetase", "A_KH_type_1_domain_protein", "A_Methionyl-tRNA_synthetase", "A_Non-canonical_purine_NTP_pyrophosphatase", "A_PUA_domain_containing_protein", "A_Phenylalanyl-tRNA_synthetase_alpha_subunit", "A_Phenylalanyl-tRNA_synthetase_beta_subunit", "A_Pre-mRNA_processing_ribonucleoprotein", "A_Prolyl-tRNA_synthetase", "A_Protein_pelota_homolog", "A_Ribosomal_protein_L10e", "A_Ribosomal_protein_L13", "A_Ribosomal_protein_L18e", "A_Ribosomal_protein_L21e", "A_Ribosomal_protein_L3", "A_Ribosomal_protein_L7Ae/L8e", "A_Ribosomal_protein_S13", "A_Ribosomal_protein_S15", "A_Ribosomal_protein_S19e", "A_Ribosomal_protein_S2", "A_Ribosomal_protein_S28e", "A_Ribosomal_protein_S3Ae", "A_Ribosomal_protein_S6e", "A_Ribosomal_protein_S7", "A_Ribosomal_protein_S9", "A_Ribosome_maturation_protein_SDO1_homolog", "A_Signal_recognition_particle_54_kDa_protein", "A_Transcription_elongation_factor_Spt5", "A_Translation_initiation_factor_5A", "A_Translation_initiation_factor_IF-2_subunit_gamma", "A_Valyl-tRNA_synthetase", "A_tRNA_N6-adenosine_threonylcarbamoyltransferase"]

# 2. Predict Single Copy Genes
# #
# #bscg=$proteins\.bacteria.scg
# #ascg=$proteins\.archaea.scg
# #if [ ! -f $bscg ] || [ ! -f $ascg ] || [ $executed_prodigal == 1 ]; then
# #       command -v ruby >/dev/null 2>&1 || { echo >&2 "Can't find ruby. Please make sure ruby is installed on your system. Aborting."; exit 1; }
# #       command -v pullseq >/dev/null 2>&1 || { echo >&2 "Can't find pullseq. Please make sure pullseq is installed on your system. Aborting."; exit 1; }
# #       echo "identifying single copy genes using $search_engine"
# #       #predict bacterial SCGs
# #       ruby $DIR\/src/scg_blank_$search_engine\.rb $search_engine $proteins $db_dir\/bac.all.faa $db_dir\/bac.scg.faa $db_dir\/bac.scg.lookup $threads > /dev/null 2>&1
# #       mv $proteins\.scg $bscg
# #       #predict archaeal SCGs
# #       ruby $DIR\/src/scg_blank_$search_engine\.rb $search_engine $proteins $db_dir\/arc.all.faa $db_dir\/arc.scg.faa $db_dir\/arc.scg.lookup $threads > /dev/null 2>&1
# #       mv $proteins\.scg $ascg
# #       rm $proteins\.findSCG.b6 $proteins\.scg.candidates.faa $proteins\.all.b6
# #else
# #         echo found predicted single copy genes:
# #           echo "  " $bscg
# #             echo "  " $ascg
# #               echo skipping single copy gene identification
# #       fi
# #
# #       if [ ! -f $bscg ] || [ ! -f $ascg ]; then
# #               echo "single copy gene prediction using $search_engine failed. Aborting"
# #                 exit 1
# #         fi

bscg="#{pro}.bacteria.scg"
ascg="#{pro}.archaea.scg"
puts "#{bscg} #{ascg}"
## bacterial blast bacteria_all.faa
puts "running blast for bacterial SCGs... this may take a while..."
`ruby #{dbdir}/src/scg_blank_#{engine}.rb #{engine} #{pro} #{dbdir}/SCG/bacteria_all.faa #{dbdir}/SCG/bacteria_all.scg.faa #{dbdir}/SCG/bacteria_all.scg.lookup #{threads}`
`mv #{pro}.scg #{bscg}`

##archaeal blast
`ruby #{dbdir}/src/scg_blank_#{engine}.rb #{engine} #{pro} #{dbdir}/SCG/archaea_all.faa #{dbdir}/SCG/archaea_all.scg.faa #{dbdir}/SCG/archaea_all.scg.lookup #{threads}`
`mv #{pro}.scg #{ascg}`

#check if SCG prediction worked
if(File.exist?("#{bscg}") && File.exist?("#{ascg}"))
  puts 'SCG prediction worked'
  else
    puts `SCG prediction failed with search engine #{engine}`
    end



# run the blasts
#puts "running blast for bacterial SCGs... this may take a while..."
#`ruby #{dbdir}/08_02_01scg.rb -u /opt/bin/bio/usearch -p #{pro} -d #{dbdir}/SCG/bacteria_all.faa -s #{dbdir}/SCG/bacteria_all.scg.faa -l #{dbdir}/SCG/MET_bacteria_all.scg.lookup`
#`mv #{pro}.scg #{pro}.bacteria.scg`
#`rm #{pro}.findSCG.b6 #{pro}.scg.candidates.faa #{pro}.all.b6`
#puts "done with bacterial SCGs"

#puts "running blast for archaeal SCGs... this may take a while..."
#`ruby #{dbdir}/08_02_01scg.rb -u /opt/bin/bio/usearch -p #{pro} -d #{dbdir}/SCG/archaea_all.faa -s #{dbdir}/SCG/archaea_all.scg.faa -l #{dbdir}/SCG/MET_archaea_all.scg.lookup`
#`mv #{pro}.scg #{pro}.archaea.scg`
#`rm #{pro}.findSCG.b6 #{pro}.scg.candidates.faa #{pro}.all.b6`
#puts "done with archaeal SCGs"

# create scaffold hash with necessary SCGs
scaff_scgs = Hash.new{|h,k| h[k]=[]}
File.open("#{pro}.bacteria.scg").each do | line |
  line.chomp!
  cols = line.split(/\t/)
  scaff_t = cols[0].split("_")[0...-1].join("_") # feature gets deleted, only works with prodigal
  scg_t = cols[1]
  s = scaff_scgs[scaff_t]
  s.push(scg_t)
end

File.open("#{pro}.archaea.scg").each do | line |
  line.chomp!
  cols = line.split(/\t/)
  scaff_t = cols[0].split("_")[0...-1].join("_") # feature gets deleted, only works with prodigal
  scg_t = cols[1]
  s = scaff_scgs[scaff_t]
  s.push(scg_t)
end

# create big table
table = []

# create rownames
scaff_rw = []
scaff_rw.push("scaffolds")
scaff_scgs.each do |sc, val|
  scaff_rw.push(sc)
end
table.push(scaff_rw)

# create columns
scgs.each do | sg |
  array=[]
  array.push(sg)
	scaff_scgs.each do |sc, val|
		if val.include? sg
      			array.push(1)
    		else
      			array.push(0)
    		end
  	end
  table.push(array)
end

# dump table
base = sca.gsub(/.fasta/,'')
CSV.open("#{base}_scg_overview_included.csv", "w") do |csv|
  table.transpose.each do | ar |
    csv << ar
  end
end

# dump a table of scaffolds that do not contain any scgs
table2 =[]
scaff.each do |sc|
	empty=[sc,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0]
	unless scaff_scgs.keys.include?(sc)
		table2.push(empty)
	end
end

CSV.open("#{base}_scg_overview_excluded.csv", "w") do |csv|
	table2.each do | ar |
		csv << ar
	end
end

# combine tables
`cat #{base}_scg_overview_included.csv #{base}_scg_overview_excluded.csv > #{base}_SCGS.csv`

# clean up
`rm #{base}_scg_overview_included.csv #{base}_scg_overview_excluded.csv`
