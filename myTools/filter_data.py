## MICROARRAYS DATA FILTERING ##

import sys
import math
import os


def open_data_file (input_file):
    
    ## Opens the microarray data file
    
    with open(input_file) as f:
        # reads the content and loads each line without \n in each element of "data" list
        data = f.read().splitlines()
        
    header = data.pop(0) #removes header
    
    return data


def classify_data (data):
    
    ## Classifies microarray data in two temporary files: up-reg (upreg.txt) and down-reg genes (downreg.txt)
    ## Classifies microarray data in two hashes: upreg, downreg
    
    num_up = 0
    num_down = 0
    
    upreg = {}
    downreg = {}
    
    for line in data:
        
        line_data = line.split("\t")
        
        foldChange = float(line_data[0])  # FoldChange
        pval = float(line_data[7])        # pval (limma)
        gene_id = line_data[20]           # descripnueva1 = gene ID
        protein = line_data[21]           # descripnueva2 = description
        transcript_id = line_data[22]     # descripnueva3 = transcript_id
        
        # Selects the rows that don't have a "No_BLAST" or empty description
        # Selects only the rows with a p-value < 0.005
        
        if not ( gene_id == "No_BLAST" or gene_id == ""):
            
            if ( pval <= 0.005 ):
                
                if ( foldChange >= 2 ): # Up-reg genes, FC >= 2
                    
                    if gene_id in upreg:  # if the gene_id exists in the degs Dictionary                               
                        
                        upreg[gene_id][2] += round(foldChange, 2)  # +foldChange
                        upreg[gene_id][3] += 1                     # +1 number of times the gene is repeated
                    
                    else: # if the gene_id does not exist in the degs Dictionary
                        
                        upreg[gene_id] = [transcript_id, protein, foldChange, 1]
                        
                
                elif ( foldChange <= -2 ): # Down-reg genes, FC <= -2
                    
                    if gene_id in downreg: # if the gene_id exists in the degs Dictionary                                 
                        
                        downreg[gene_id][2] += round(foldChange, 2)  # +foldChange
                        downreg[gene_id][3] += 1                     # +1 number of times the gene is repeated
                    
                    else:  # if the gene_id does not exist in the degs Dictionary
                        downreg[gene_id] = [transcript_id, protein, round(foldChange, 2), 1]
    
    return upreg, downreg


def delete_duplicates(genes_up, genes_down):
    
    up = genes_up.copy()
    down = genes_down.copy()
    
    for id in genes_up:
        if id in genes_down:
            del up[id]
            del down[id]
    
    return up, down
        
        
def results(all_degs, output):

    file_genes = open (output, "w")
    file_genes.write("Transcript_ID\tGene_ID\tDescription\tFC_Mean\tlog2_FC\tNumber_times\n")

    for id in all_degs:
        
        transcript = all_degs[id][0]
        protein = all_degs[id][1]
        sum_FC = all_degs[id][2]
        num_times = all_degs[id][3]
        
        mean_FC = round ((sum_FC/num_times), 3) # FC mean, rounded to 3 decimals
        
        # Calculates the base 2 logarithm of the absolute value of mean_FC, with the sign of mean_FC, rounded 3 decimals
        log2_FC = round (math.log2(abs(mean_FC)), 3)
        
        if mean_FC < 0:
            log2_FC = -1*log2_FC
        
        # Writes the result
        file_genes.write(str(transcript) + "\t" + id + "\t" + str(protein) + "\t" + str(mean_FC) + "\t" + str(log2_FC) + "\t" + str(num_times) + "\n")
        
    file_genes.close()

def main():
    
    input = sys.argv[1]
    output = sys.argv[2]
    
    tmp_file_up = "upreg.txt"
    tmp_file_down = "downreg.txt"
    
    data = open_data_file(input)
    upreg, downreg = classify_data(data)
    
    up, down = delete_duplicates(upreg, downreg)
    
    print ("Number of genes UP = ", len(up))
    print ("Number of genes DOWN = ", len(down))
    
    all_degs = {**up, **down}
    
    results(all_degs, output)


if __name__ == "__main__":
    main()




