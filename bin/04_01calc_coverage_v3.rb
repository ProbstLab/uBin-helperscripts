
# The MIT License (MIT)
# Copyright (c) 2017 Alexander J Probst

# Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

# The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

require "trollop"
require "nu"

opts=Trollop::options do
    banner <<-EOS

Counts the number reads per feature (scaffold, gene) in a sam file. sam file do NO need to be sorted but unmapped reads should have been removed (e.g. by using 'shrinksam' or 'mapped.py').
Writes to standard out in tab-delimited fashion.

Usage:
        ruby calc_coverage.rb [option] > output.txt
where [options] are:
EOS
 	opt :sam, "sam file", :type => :string, :required => true
	opt :fasta, "fasta file", :type => :string, :required => true
end

s_file=opts[:sam]
f_file=opts[:fasta]


#collect lengths of each scaffold
lengths=Hash.new
features=Hash.new
Nu::Parser::Fasta.new(f_file).each do |seq|
        lengths[seq.header.split("\t")[0].split(" ")[0]]=seq.sequence.gsub(/N/,'').gsub(/n/,'').length
        features[seq.header.split("\t")[0].split(" ")[0]]=0
end

# collect bases per scaffold covered
File.open(s_file).each do |line|
        line.chomp!
        next if line.start_with? '@'
        feat=line.split("\t")[2]
	features[feat] = (features[feat] + line.split("\t")[9].length).to_f
end


#put average coverage per scaffold to standard out.
features.each do | feat, count|
	puts "#{feat}\t#{(count/lengths[feat]).round(1)}"
end
