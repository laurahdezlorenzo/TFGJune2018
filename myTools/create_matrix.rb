# create_matrix.rb

# MSxES.txt, MSxET.txt, MTxES.txt, MTxET.txt

def open_file (file)
  
  data = Array.new
  input = File.new(file, "r")
  input.gets
  while line = input.gets   # gets each line of the file
    line.chomp!             # deletes \n
    data << line
  end
  input.close
  
  return data
  
end
       

def create_matrix (data, degs, num_files, i)
  
  data.each do |l|
    line = l.split("\t")
    
    transcript = line[0]
    gene = line[1]
    description = line[2]
    meanFC = line[3].to_f
    log2FC = line[4].to_f
    
    if degs.keys.include? gene
      degs[gene][2][i] = [meanFC, log2FC]
      
    else
      degs[gene] = Array.new
      degs[gene] << transcript
      degs[gene] << description
      
      c = Array.new(2, 0)
      combinations = Array.new(num_files, c)
      combinations[i] = [meanFC, log2FC]
      
      degs[gene] << combinations
      
    end
    
  end
  return degs
  
end

def get_result(output, inputs, degs)
  
  output = File.open(output, "w")
  puts "Note: the name of the columns in the result file is based on the name of the previous file."
  
  header = "Transcript_ID\tGene_ID\tDescription\tFC_MSxES\tlog2FC_MSxES\tFC_MSxET\tlog2FC_MSxET\tFC_MTxES\tlog2FC_MTxES\tFC_MTxET\tlog2FC_MTxET\n"
  
  output.write("#{header}")
  
  degs.keys.each do |id|
    
    transcript = degs[id][0].to_s
    description = degs[id][1].to_s
    combinations = degs[id][2].join("\t")
    
    output.write("#{transcript}\t#{id.to_s}\t#{description}\t#{combinations}\n")
  end
  
  output.close
  
end

inputs = [ARGV[0], ARGV[1], ARGV[2], ARGV[3]]
output = ARGV[4]
num_files = inputs.length

degs = Hash.new # Hash with [transcript_ID => {gene_ID, description, FC in each combination, log2FC in each combination}]

i = 0
inputs.each do |file|
  data = open_file(file)
  degs = create_matrix(data, degs, num_files, i)
  i += 1
end

get_result(output, inputs, degs)
