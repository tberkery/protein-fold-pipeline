import sys
import pandas as pd
mem_usage_report_file = sys.argv[1]
use_next = False
df = pd.DataFrame(columns = ["data_structure", "sample", "memory_usage"])
data_structure_names = ["BWT-HMM", "BWT-HMM", "MLSE-Viterbi", "MLSE-Viterbi", "BWT-HMM-Merging", "BWT-HMM-Merging"]
sample_names = ["hypothetical_protein_test", "compressed_hypothetical_protein_test", "hypothetical_protein_test", "compressed_hypothetical_protein_test", "hypothetical_protein_test", "compressed_hypothetical_protein_test"]
i = 0
with open(mem_usage_report_file, "r") as fp:
    for line in fp.readlines():
        if use_next:
            if local_count == 2:
                line_split = line.split("    ") # this is not a tab, but rather a copy of a specific number of spaces
                mem_usage = line_split[2].split()
                memory_used = mem_usage[0]
                
                try:
                    fourth_local_line = fp.next()
                    line_split = fourth_local_line.split("    ") # this is not a tab, but rather a copy of a specific number of spaces
                    mem_usage = line_split[2].split()
                    memory_used = mem_usage[0]
                except:
                    useless = True # nothing to do here other than break out of the try
                df.loc[len(df.index)] = [data_structure_names[i % len(data_structure_names)], sample_names[i % len(data_structure_names)], memory_used]
                i += 1
                use_next = False
            else:
                local_count += 1
 
        if line[0:1] == "=":
            use_next = True
            local_count = 0

df.to_csv("memory_usage_updated.csv", index = False)