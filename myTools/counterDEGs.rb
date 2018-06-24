# Counting DEGs UP and DOWN

lines = Array.new
degs = Hash.new

input = ARGV[0]
output = ARGV[1]

## Opens the classification file and loads each line in lines Array
infile = File.new(input, "r")
#input.gets
while l = infile.gets   # gets each line of the file
  l = l.chomp   # deletes \n
  lines << l
end
infile. close

lines.each do |line|
  
  line = line.split("\t")            # splits the line by \t

  bin = line[1].split(".")[0].to_s   # gets the bin name
  log2FC = line[5].to_f              # gets the value of the log2FC
  
  if degs.keys.include? bin # if degs Hash contains bin_name
    if log2FC > 0           # if log2FC is positive
      degs[bin][0] += 1     # number of UP DEGs + 1
    elsif log2FC < 0        # if log2FC is negative
      degs[bin][1] += 1     # number of DOWN DEGs + 1
    end
    
  else                    # if bin_name doesn't exist in degs Hash
    if log2FC > 0         # if log2FC is positive
      degs[bin] = [1, 0]  # initializes number UP DEGs in 1
    elsif log2FC < 0      # if log2FC is negative
      degs[bin] = [0, 1]  # initializes number DOWN DEGs in 1
    end
    
  end
  
end

outfile = File.new(output, "w")
outfile.write("BIN\t\DEGs_UP\tDEGs_DOWN\n")
degs.keys.each do |bin|
  outfile.write("#{bin}\t#{degs[bin][0]}\t#{degs[bin][1]}\n")
end
outfile.close

