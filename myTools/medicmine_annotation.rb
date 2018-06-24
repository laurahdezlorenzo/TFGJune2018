require "rubygems"
require "intermine/service"

service = Service.new("http://medicmine.jcvi.org/medicmine", "31P6T3k3H6V613m5vcd9")

input = ARGV[0]
list_name = ARGV[1]
output1 = ARGV[2]
output2 = ARGV[3]

## Creates a list of genes in the MedicMine database

genes = Array.new
counter = 0
infile = File.new(input, "r")
infile.gets
while line = infile.gets     # gets each line of the file
  id = line.split("\t")[0]  # gets gene ID
  genes << id
  counter += 1
end
infile.close
puts "Number of genes in the list: #{counter}"

list = service.create_list(genes, "Gene", [], list_name, "Differential Expressed Genes in nodules in the four combinations: MSxES, MSxET, MTxES, MTxET" )
puts "The list #{list.name} has been created in MedicMine."


## Gene Ontology annotation from MedicMine database

query_go = service.new_query("Gene").
    select(["primaryIdentifier", "briefDescription", "goAnnotation.ontologyTerm.identifier", "goAnnotation.ontologyTerm.name"]).
    where("Gene" => {:in => "#{list.name}"})

output_go = File.open(output1, "w")
output_go.write("Gene_ID\tDescription\tGO_term_ID\tGO_term_name\n")
query_go.each_row do |row|
    r = row.to_a
    line = r.join("\t")
    output_go.write("#{line}\n")
end
output_go.close


## KEGG Pathways annotation from MedicMine database

query_pathways = service.new_query("Gene").
    select(["primaryIdentifier", "briefDescription", "pathways.identifier", "pathways.name"]).
    where("Gene" => {:in => "#{list.name}"})

output_pathways = File.open(output2, "w")
output_pathways.write("Gene_ID\tDescription\tPathway_ID\tPathway_name\n")
query_pathways.each_row do |row|
    r = row.to_a
    line = r.join("\t")
    output_pathways.write("#{line}\n")
end
output_pathways.close

