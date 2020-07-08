
require "nu"
require "trollop"

#######################

opts=Trollop::options do
    banner <<-EOS
Parses blast output for lineage information (per scaffold)

Usage:
  ruby classifer.rb [options]  > [output_file]
where [options] are:
EOS
  opt :blast, "blast output (tabular)", :type => :string, :required => true, :short => :b
  opt :seqs, "scaffolds (fasta)", :type => :string, :short => :s
  opt :genes, "genes (prodigal output)", :type => :string, :required => true, :short => :g
end

blast = opts[:blast]
seqs = opts[:seqs]
genes = opts[:genes]

#######################

db = Hash.new{|h,k| h[k]=[]}   #scaffolds and lineage information
seq_counts = Array.new   #total scaffolds (incl. scaffolds with no genes)
gene_counts = Hash.new   #number of genes per scaffold


#tracking the number of scaffolds
Nu::Parser::Fasta.new(seqs).each do |scaffold|
  seq_counts << scaffold.header.split(/ /).first
end

#tracking number of genes per scaffold
Nu::Parser::Fasta.new(genes).each do |gene_seq|
  scaffold_name = gene_seq.header.split(/ /).first.split(/_/)[0..-2].join("_")
  gene_counts[scaffold_name] ? gene_counts[scaffold_name] += 1 : gene_counts[scaffold_name] = 1    
end


#parse blastout by scaffold
File.open(blast).each do |line|
  blastcols = line.chomp.split(/\t/)
  scaffold_name = blastcols[0].split("_")[0..-2].join("_")
  full_lineage = blastcols[9].split(/^Taxonomy=/).last  #will have nils
  db[scaffold_name] << full_lineage
end

######################

db.sort.each do |scaffold_id, all_lineages|

  num_of_genes = gene_counts[scaffold_id]  #add gene count filter here (if genes < 2, etc.)
  
  domain = Array.new 
  phylum = Array.new
  clas = Array.new
  order = Array.new
  genus = Array.new
  species = Array.new

  all_lineages.each do |one_lineage|
    
    next if one_lineage == nil
    unparsed_lineage = one_lineage.split(";")
    
    dom = unparsed_lineage[0]
    phy = unparsed_lineage[1]
    cla = unparsed_lineage[2]
    ord = unparsed_lineage[3]
    unless unparsed_lineage[-3] == nil
      if unparsed_lineage[-3].include?"family" or unparsed_lineage[-3].include?"ceae"
        gen = unparsed_lineage[-2]
        spe = unparsed_lineage[-1]
      elsif unparsed_lineage[-2].include?"family" or unparsed_lineage[-2].include?"ceae"
        gen = unparsed_lineage[-1]
      end
    end

    domain << dom
    phylum << phy
    clas << cla
    order << ord
    genus << gen
    species << spe

  end

  final_lineage = [] # final lineage for that scaffold; check for each taxon level if it's top hit is represented > 0.5 of all genes on the scaffold. if so, add it to the lineage.
  
  d_h = domain.reduce(Hash.new(0)) { |a, b| a[b] += 1; a }
  if (  d_h[d_h.key(d_h.values.max)] > gene_counts[scaffold_id]*0.5)
    final_lineage << d_h.key(d_h.values.max)
  else
    final_lineage << "unclassified"
  end

  p_h = phylum.reduce(Hash.new(0)) { |a, b| a[b] += 1; a }
  if (  p_h[p_h.key(p_h.values.max)] > gene_counts[scaffold_id]*0.5)
    final_lineage << p_h.key(p_h.values.max)
  else
    final_lineage << "unclassified"
  end
  
  c_h = clas.reduce(Hash.new(0)) { |a, b| a[b] += 1; a }
  if (  c_h[c_h.key(c_h.values.max)] > gene_counts[scaffold_id]*0.5)
    final_lineage << c_h.key(c_h.values.max)
  else
    final_lineage << "unclassified"
  end
  
  o_h = order.reduce(Hash.new(0)) { |a, b| a[b] += 1; a }
  if (  o_h[o_h.key(o_h.values.max)] > gene_counts[scaffold_id]*0.5)
    final_lineage << o_h.key(o_h.values.max)
  else
    final_lineage << "unclassified"
  end
  
  g_h = genus.reduce(Hash.new(0)) { |a, b| a[b] += 1; a }
  if (  g_h[g_h.key(g_h.values.max)] > gene_counts[scaffold_id]*0.5)
    final_lineage << g_h.key(g_h.values.max)
  else
    final_lineage << "unclassified"
  end
  
  s_h = species.reduce(Hash.new(0)) { |a, b| a[b] += 1; a }
  if (  s_h[s_h.key(s_h.values.max)] > gene_counts[scaffold_id]*0.5)
    final_lineage << s_h.key(s_h.values.max)
  else
    final_lineage << "unclassified"
  end
  
  puts "#{scaffold_id}\t#{final_lineage.join(";").gsub(/\;\;/,"").gsub(/\;\;/,"").gsub(/\;\;/,"").gsub(/\;\;/,"")}"

end

seq_counts.each do |scaff|
  if db.keys.include?(scaff) == false
    puts "#{scaff}\tunclassified;unclassified;unclassified;unclassified;unclassified;unclassified;"
  end
end

__END__
