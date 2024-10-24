params.step = 0


workflow{

    // Task 1 - Read in the samplesheet.

    if (params.step == 1) {
        in_ch = channel.fromPath('samplesheet.csv').splitCsv(header:true)
        in_ch.view()
    }

    // Task 2 - Read in the samplesheet and create a meta-map with all metadata and another list with the filenames ([[metadata_1 : metadata_1, ...], [fastq_1, fastq_2]]).
    //          Set the output to a new channel "in_ch" and view the channel. YOU WILL NEED TO COPY AND PASTE THIS CODE INTO SOME OF THE FOLLOWING TASKS (sorry for that).

    if (params.step == 2) {
        in_ch = channel.fromPath('samplesheet.csv').splitCsv(header:true)
        in_ch = in_ch.map { row -> [['sample':row.sample,'strandedness':row.strandedness],[file(row.fastq_1),file(row.fastq_2)]] }
        in_ch.view()
    }

    // Task 3 - Now we assume that we want to handle different "strandedness" values differently. 
    //          Split the channel into the right amount of channels and write them all to stdout so that we can understand which is which.

    if (params.step == 3) {


        in_ch = channel.fromPath('samplesheet.csv').splitCsv(header:true)
        in_ch = in_ch.map { row -> [['sample':row.sample,'strandedness':row.strandedness],[row.fastq_1,row.fastq_2]] }
        in_ch.branch {
            reverse: it[0].strandedness =="reverse"
            auto: it[0].strandedness == "auto"
            forward: it[0].strandedness ==  "forward"
        }.set{result}

        reverse_channel = result.reverse.toList()
        auto_channel = result.auto.toList()
        forward_channel = result.forward.toList()
        
        reverse_channel.view()
        auto_channel.view()
        forward_channel.view()
    }

    // Task 4 - Group together all files with the same sample-id and strandedness value.

    if (params.step == 4) {


        in_ch = channel.fromPath('samplesheet.csv').splitCsv(header:true)
        in_ch = in_ch.map { row -> [['sample':row.sample,'strandedness':row.strandedness],[row.fastq_1,row.fastq_2]] }
        in_ch.branch {
            reverse: it[0].strandedness =="reverse"
            auto: it[0].strandedness == "auto"
            forward: it[0].strandedness ==  "forward"
        }.set{result}

        reverse_channel = result.reverse.groupTuple()
        auto_channel = result.auto.groupTuple()
        forward_channel = result.forward.groupTuple()

        reverse_channel.view()
        auto_channel.view()
        forward_channel.view()
    }



}