
# The MIT License (MIT)
# Copyright (c) 2017 Alexander J Probst

# Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

# The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

require "trollop"

opts=Trollop::options do
    banner <<-EOS

Reads four different files
scaffold2GC
scaffold2cov
scaffold2tax
scaffold2length
and creates an overview table for binning purposes. Writes to standard out.

Usage:
        ruby astats.rb [option] > output.txt
where [options] are:
EOS
 	opt :gc, "scaffold2GC", :type => :string, :required => true
	opt :cov, "scaffold2cov", :type => :string, :required => true
	opt :tax, "scaffold2taxonomy", :type => :string, :required => true
	opt :len, "scaffold2length", :type => :string, :required => true
	opt :min, "minimum length, recommended is 1000", :type => :float, :required => true
end

gc_file=opts[:gc]
cov_file=opts[:cov]
tax_file=opts[:tax]
len_file=opts[:len]
cutoff=opts[:min]


#iterate over each file and collect values in hashes
g=Hash.new
File.open(gc_file).each do |line|
	line.chomp!
	g[line.split("\t")[0]]=line.split("\t")[1]
end

c=Hash.new
File.open(cov_file).each do |line|
        line.chomp!
        c[line.split("\t")[0]]=line.split("\t")[1]
end

t=Hash.new
File.open(tax_file).each do |line|
        line.chomp!
        t[line.split("\t")[0]]=line.split("\t")[1]
end

l=Hash.new
File.open(len_file).each do |line|
        line.chomp!
        l[line.split("\t")[0]]=line.split("\t")[1]
end


#the only hash missing scaffolds should be the coverage hash, so iterate over that one and output everything into a table
puts "scaffold\tGC\tcoverage\tlength\ttaxonomy"
c.each do | scaff, cov|
	if ( l[scaff].to_f >= cutoff )
		puts "#{scaff}\t#{g[scaff]}\t#{cov}\t#{l[scaff]}\t#{t[scaff]}"
	end
end
