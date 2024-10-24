params.step = 0
params.zip = 'bzip2'


process SAYHELLO {
    debug true
    """
    echo Hello World!
    """
}

process SAYHELLO_PYTHON {
    debug true
    """
    #!/usr/bin/env python
    print('Hello world!')
    """
}

process SAYHELLO_PARAM {
    debug true
    input:
    val str

    """
    echo $str
    """

}
process SAYHELLO_FILE { 
    debug true
    input:
    val str

    """
    echo $str > helloworld.txt
    """
}
process UPPERCASE { 
    debug true
    input:
    val str

    output:
    path 'helloworld_uppercase.txt'

    """
    echo $str | tr '[a-z]' '[A-Z]' > helloworld_uppercase.txt
    """
}

process PRINTUPPER { 
    debug true
    input:
    path x


    """
    cat $x 
    """
}

process ZIPFILE {
    debug true
    stageInMode 'copy'
    input:
    path x
    output:
    path "zip_file.$params.zip"

    script:
    if( params.zip == 'zip' )
        """
        $params.zip zip_file.$params.zip $x
        """
    else if( params.zip == 'gzip' )
        """
        $params.zip -c $x > zip_file.$params.zip
        """
    else if( params.zip == 'bzip2' )
        """
        $params.zip -c $x > zip_file.$params.zip
        """
}

process ALLZIPFILE {
    debug true
    stageInMode 'copy'
    input:
    path x
    output:
    path "zip_file.zip", emit: zip_file
    path "gzip_file.gzip", emit: gzip_file
    path "bzip2_file.bzip2", emit: bzip2_file

    script:
    """
    zip zip_file.zip $x
    gzip -c $x > gzip_file.gzip
    bzip2 -c $x > bzip2_file.bzip2
    """
}

process WRITEFILE {
    debug true
    input:
    val in_ch
    output:
    path 'file.tsv', emit: row

    script:
    """
    echo ${in_ch.name},${in_ch.title} > file.tsv
    """
}

workflow {

    // Task 1 - create a process that says Hello World! (add debug true to the process right after initializing to be sable to print the output to the console)
    if (params.step == 1) {
        SAYHELLO()
    }

    // Task 2 - create a process that says Hello World! using Python
    if (params.step == 2) {
        SAYHELLO_PYTHON()
    }

    // Task 3 - create a process that reads in the string "Hello world!" from a channel and write it to command line
    if (params.step == 3) {
        greeting_ch = Channel.of("Hello world!")
        SAYHELLO_PARAM(greeting_ch)
    }

    // Task 4 - create a process that reads in the string "Hello world!" from a channel and write it to a file. WHERE CAN YOU FIND THE FILE?
    if (params.step == 4) {
        greeting_ch = Channel.of("Hello world!")
        SAYHELLO_FILE(greeting_ch)
    }

    // Task 5 - create a process that reads in a string and converts it to uppercase and saves it to a file as output. View the path to the file in the console
    if (params.step == 5) {
        greeting_ch = Channel.of("Hello world!")
        out_ch = UPPERCASE(greeting_ch)
        out_ch.view()
    }

    // Task 6 - add another process that reads in the resulting file from UPPERCASE and print the content to the console (debug true). WHAT CHANGED IN THE OUTPUT?
    if (params.step == 6) {
        greeting_ch = Channel.of("Hello world!")
        out_ch = UPPERCASE(greeting_ch)
        PRINTUPPER(out_ch)
    }

    
    // Task 7 - based on the paramater "zip" (see at the head of the file), create a process that zips the file created in the UPPERCASE process either in "zip", "gzip" OR "bzip2" format.
    //          Print out the path to the zipped file in the console
    if (params.step == 7) {
        greeting_ch = Channel.of("Hello world!")
        out_ch = UPPERCASE(greeting_ch)
        out_ch = ZIPFILE(out_ch)
        out_ch.view()
    }

    // Task 8 - Create a process that zips the file created in the UPPERCASE process in "zip", "gzip" AND "bzip2" format. Print out the paths to the zipped files in the console

    if (params.step == 8) {
        greeting_ch = Channel.of("Hello world!")
        out_ch = UPPERCASE(greeting_ch)
        out_ch = ALLZIPFILE(out_ch)
        out_ch.zip_file.view()
        out_ch.gzip_file.view()
        out_ch.bzip2_file.view()
    }
    
    
    // Task 9 - Create a process that reads in a list of names and titles from a channel and writes them to a file.
    //           Store the file in the "results" directory under the name "names.tsv"
    if (params.step == 9) {

        in_ch = channel.of(
            ['name': 'Harry', 'title': 'student'],
            ['name': 'Ron', 'title': 'student'],
            ['name': 'Hermione', 'title': 'student'],
            ['name': 'Albus', 'title': 'headmaster'],
            ['name': 'Snape', 'title': 'teacher'],
            ['name': 'Hagrid', 'title': 'groundkeeper'],
            ['name': 'Dobby', 'title': 'hero'],
        )
        WRITEFILE(in_ch) \
            | collectFile(
                name: 'names.tsv',
                storeDir: 'results',
                keepHeader: false,
                newLine: true
        )
    }
}