
# The MIT License (MIT)
# Copyright (c) 2016 Alexander J Probst

# Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

# The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

require "nu"
require "trollop"

opts=Trollop::options do
    banner <<-EOS

Determines the GC content for each sequence in a fasta file individually. WRITES TO STANDARD OUT.
Usage:
        ruby gc_count.rb [option]
where [options] are:
EOS
  opt :fasta_file, "input fasta file", :type => :string, :required => true
end

fasta_file=opts[:fasta_file]

Nu::Parser::Fasta.new(fasta_file).each do |seq|
  	seq_len=seq.sequence.gsub(/N/,'').gsub(/n/,'').length
	c=seq.sequence.upcase.scan(/C/).count.to_f
	g=seq.sequence.upcase.scan(/G/).count.to_f
	gc=(((c+g)/seq_len)*100).round(1)
	puts "#{seq.header.split(" ")[0]}\t#{gc}"
end
