class: CommandLineTool
cwlVersion: v1.0
$namespaces:
  dct: 'http://purl.org/dc/terms/'
  doap: 'http://usefulinc.com/ns/doap#'
  foaf: 'http://xmlns.com/foaf/0.1/'
  sbg: 'https://www.sevenbridges.com/'
id: general_stats_parse
baseCommand:
  - python
  - /app/bin/coverage_stats_single.py
inputs:
  - id: memory_per_job
    type: int?
    doc: Memory per job in megabytes
  - id: memory_overhead
    type: int?
    doc: Memory overhead per job in megabytes
  - id: number_of_threads
    type: int?
    doc: 'worker thread number, default is 2 (int [=2])'
  - id: file
    type: File
    inputBinding:
      position: 0
      prefix: '--file'
    doc: annotated bed file on which to generate report from
  - id: build
    type: File?
    inputBinding:
      position: 0
      prefix: '--build'
    doc: >-
      text file with build number used for alignment, output from mosdepth
      (optional) chromosome, start, end, gene, transcript, exon
  - id: outfile
    type: string?
    inputBinding:
      position: 0
      prefix: '--outfile'
    doc: >-
      output file name prefix, if not given the input file name will be used as
      the name prefix
  - id: thresholds
    type: 'int[]?'
    inputBinding:
      position: 999
      prefix: '--thresholds'
    doc: >-
      threshold values to calculate coverage for as comma seperated integers
      (default: 10, 20, 30, 50, 100)
  - id: output_name
    type: string?
    inputBinding:
      position: 900
      prefix: '--n'
    doc: >-
      (optional) Prefix for naming output file, if not given will use name from
      per base coverage file
  - id: flagstat
    type: string?
    inputBinding:
      position: 900
      prefix: '--flagstat'
    doc: 'file for sample, required for generating run statistics (in development)'
  - id: cores
    type: int?
    inputBinding:
      position: 900
      prefix: '--cores'
    doc: >-
      Number of CPU cores to utilise, for larger numbers of genes this will
      drastically reduce run time. If not given will use maximum available
outputs:
  - id: exon_stats_output
    label: exon_stats_output
    type: File
    outputBinding:
      glob: '*_exon_stats.tsv'
  - id: gene_stats_output
    label: gene_stats_output
    type: File
    outputBinding:
      glob: '*_gene_stats.tsv'
label: general_stats_parse
arguments:
  - position: 0
    prefix: '--thread'
    valueFrom: |-
      ${
          if(inputs.number_of_threads)
              return inputs.number_of_threads
          return runtime.cores
      }
requirements:
  - class: ResourceRequirement
    ramMin: 17000
    coresMin: 4
  - class: DockerRequirement
    dockerPull: 'ghcr.io/msk-access/athena:1.4.2'
  - class: InlineJavascriptRequirement
'dct:contributor':
  - class: 'foaf:Organization'
    'foaf:member':
      - class: 'foaf:Person'
        'foaf:mbox': 'mailto:johnsoni@mskcc.org'
        'foaf:name': Ian Johnson
    'foaf:name': Memorial Sloan Kettering Cancer Center
'dct:creator':
  - class: 'foaf:Organization'
    'foaf:member':
      - class: 'foaf:Person'
        'foaf:mbox': 'mailto:johnsoni@mskcc.org'
        'foaf:name': Ian Johnson
    'foaf:name': Memorial Sloan Kettering Cancer Center
