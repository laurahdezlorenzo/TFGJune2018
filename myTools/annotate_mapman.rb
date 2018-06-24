# annotate_mapman.rb

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
       

def create_matrix (data, degs)
  
  data.each do |l|
    line = l.split("\t")
    
    transcript = line[2]
    bin_name = line[1]
    
    if degs.keys.include? transcript
      degs[transcript] << bin_name
      
    else
      degs[transcript] = Array.new
      degs[transcript] << bin_name
      
    end
    
  end
  
  return degs
  
end

def get_result(result_file, degs)
  
  output = File.open(result_file, "w")
  
  output.write("Transcript_ID\tBIN_name\n")
  
  degs.keys.each do |id|
    
    bin_name = degs[id].to_s
    output.write("#{id.to_s}\t#{bin_name}\n")
  end
  
  output.close
  
end

inputs = [ARGV[0], ARGV[1], ARGV[2], ARGV[3]]
output = ARGV[4]

degs = Hash.new # Hash with [transcript_ID => {BIN name in MapMan}]

inputs.each do |file|
  data = open_file(file)
  degs = create_matrix(data, degs)
end

degs.keys.each do |id|
  degs[id] = degs[id].uniq
end

get_result(output, degs)