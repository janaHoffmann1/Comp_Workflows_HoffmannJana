#!/usr/bin/env nextflow

process SPLITLETTERS {
    debug true
    input:
    val in_ch
    output:
    path '*.txt', emit:out_path

    publishDir '.', mode: 'copy', pattern: '*.txt'

    script:
    """
    #!/usr/bin/env python
    input = "${in_ch}".replace('[', '').replace(']', '').replace("'", '') 
    input = input.split(',')
    input[2] = input[2].replace(' ','')
    splitted = [input[2][0+i:int(input[0][-1])+i] for i in range(0, len(input[2]),int(input[0][-1]))]
    for chunk in splitted:
        with open(input[1]+'.txt', 'a') as f:
            f.write(chunk+ '\\n') 
    """

} 

process CONVERTTOUPPER {
    debug true
    publishDir 'results', mode: 'copy', pattern: '*'
    input:
    path in_ch
    output:
    path in_ch

    script:
    """
    cat ${in_ch} | tr a-z A-Z 
    cat ${in_ch} | tr a-z A-Z > ${in_ch}
    """
} 

workflow { 
    // 1. Read in the samplesheet (samplesheet_2.csv)  into a channel. The block_size will be the meta-map
    // 2. Create a process that splits the "in_str" into sizes with size block_size. The output will be a file for each block, named with the prefix as seen in the samplesheet_2
    // 4. Feed these files into a process that converts the strings to uppercase. The resulting strings should be written to stdout

    // read in samplesheet}
    in_ch = channel.fromPath('samplesheet_2.csv').splitCsv(header:true).map{row -> [row.block_size,row.out_name,row.input_str]}
    
    // split the input string into chunks
    SPLITLETTERS(in_ch)

    // lets remove the metamap to make it easier for us, as we won't need it anymore
    // convert the chunks to uppercase and save the files to the results directory
    CONVERTTOUPPER(SPLITLETTERS.out.out_path)
    



}