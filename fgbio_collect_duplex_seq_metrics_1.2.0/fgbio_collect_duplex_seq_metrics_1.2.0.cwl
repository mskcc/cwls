class: CommandLineTool
cwlVersion: v1.0
$namespaces:
  dct: 'http://purl.org/dc/terms/'
  doap: 'http://usefulinc.com/ns/doap#'
  foaf: 'http://xmlns.com/foaf/0.1/'
  sbg: 'https://www.sevenbridges.com/'
id: fgbio_collect_duplex_seq_metrics_1_2_0
baseCommand:
  - fgbio
inputs:
  - id: memory_per_job
    type: int?
    doc: Memory per job in megabytes
  - id: memory_overhead
    type: int?
    doc: Memory overhead per job in megabytes
  - id: number_of_threads
    type: int?
  - id: input
    type: File
    inputBinding:
      position: 2
      prefix: '--input'
    doc: Input BAM file generated by GroupReadByUmi.
  - id: output_prefix
    type: string?
    doc: Prefix of output files to write.
  - id: intervals
    type: File?
    inputBinding:
      position: 2
      prefix: '--intervals'
    doc: 'Optional set of intervals over which to restrict analysis. [Optional].'
  - id: description
    type: string?
    inputBinding:
      position: 2
      prefix: '--description'
    doc: >-
      Description of data set used to label plots. Defaults to sample/library.
      [Optional].
  - id: duplex_umi_counts
    type: boolean?
    inputBinding:
      position: 2
      prefix: '--duplex-umi-counts'
    doc: >-
      If true, produce the .duplex_umi_counts.txt file with counts of duplex UMI
      observations. [Optional].
  - id: min_ab_reads
    type: int?
    inputBinding:
      position: 2
      prefix: '--min-ab-reads'
    doc: 'Minimum AB reads to call a tag family a ''duplex''. [Optional].'
  - id: min_ba_reads
    type: int?
    inputBinding:
      position: 2
      prefix: '--min-ba-reads'
    doc: 'Minimum BA reads to call a tag family a ''duplex''. [Optional].'
  - id: umi_tag
    type: string?
    inputBinding:
      position: 2
      prefix: '--umi-tag'
    doc: 'The tag containing the raw UMI. [Optional].'
  - id: mi_tag
    type: string?
    inputBinding:
      position: 2
      prefix: '--mi-tag'
    doc: 'The output tag for UMI grouping. [Optional].'
  - id: temporary_directory
    type: string?
    doc: 'Default value: null.'
  - id: async_io
    type: string?
    inputBinding:
      position: 0
      separate: false
      prefix: '--async-io='
    doc: >-
      'Use asynchronous I/O where possible, e.g. for SAM and BAM files [=true|false].'
outputs:
  - id: fgbio_collect_duplex_seq_metrics_family_size
    type: File
    outputBinding:
      glob: |-
        ${
             if(inputs.output_prefix){
                 return  inputs.output_prefix + '.family_sizes.txt'
             }
             else{
                 return inputs.input.basename.replace('.bam','.family_sizes.txt')
             }
        }
  - id: fgbio_collect_duplex_seq_metrics_duplex_family_size
    type: File
    outputBinding:
      glob: |-
        ${
            if(inputs.output_prefix){
                return  inputs.output_prefix + '.duplex_family_sizes.txt'
            }
            else{
                return inputs.input.basename.replace('.bam','.duplex_family_sizes.txt')
            }
        }
  - id: fgbio_collect_duplex_seq_metrics_duplex_yield_metrics
    type: File
    outputBinding:
      glob: |-
        ${
            if(inputs.output_prefix){
                return  inputs.output_prefix + '.duplex_yield_metrics.txt'
            }
            else{
                return inputs.input.basename.replace('.bam','.duplex_yield_metrics.txt')
            }
        }
  - id: fgbio_collect_duplex_seq_metrics_umi_counts
    type: File
    outputBinding:
      glob: |-
        ${
            if(inputs.output_prefix){
                return  inputs.output_prefix + '.umi_counts.txt'
            }
            else{
                return inputs.input.basename.replace('.bam','.umi_counts.txt')
            }
        }
  - id: fgbio_collect_duplex_seq_metrics_duplex_qc
    type: File?
    outputBinding:
      glob: |-
        ${
            if(inputs.output_prefix){
                return  inputs.output_prefix + '.duplex_qc.pdf'
            }
            else{
                return inputs.input.basename.replace('.bam','.duplex_qc.pdf')
            }
        }
  - id: fgbio_collect_duplex_seq_metrics_duplex_umi_counts
    type: File?
    outputBinding:
      glob: |-
        ${
            if(inputs.duplex_umi_counts){
                if(inputs.output_prefix){
                    return  inputs.output_prefix + '.duplex_umi_counts.txt'
                }
                else{
                    return inputs.input.basename.replace('.bam','.duplex_umi_counts.txt')
                }
            }
        }
doc: >-
  Collects a suite of metrics to QC duplex sequencing data.

  Inputs ------

  The input to this tool must be a BAM file that is either:

  1. The exact BAM output by the 'GroupReadsByUmi' tool (in the sort-order it
  was produced in) 2. A BAM file that has MI tags present on all reads (usually
  set by 'GroupReadsByUmi' and has been sorted with
     'SortBam' into 'TemplateCoordinate' order.

  Calculation of metrics may be restricted to a set of regions using the
  '--intervals' parameter. This can significantly affect results as off-target
  reads in duplex sequencing experiments often have very different properties
  than on-target reads due to the lack of enrichment.

  Several metrics are calculated related to the fraction of tag families that
  have duplex coverage. The definition of "duplex" is controlled by the
  '--min-ab-reads' and '--min-ba-reads' parameters. The default is to treat any
  tag family with at least one observation of each strand as a duplex, but this
  could be made more stringent, e.g. by setting '--min-ab-reads=3
  --min-ba-reads=3'. If different thresholds are used then '--min-ab-reads' must
  be the higher value.

  Outputs -------

  The following output files are produced:

  1. <output>.family_sizes.txt: metrics on the frequency of different types of
  families of different sizes 2. <output>.duplex_family_sizes.txt: metrics on
  the frequency of duplex tag families by the number of observations
     from each strand
  3. <output>.duplex_yield_metrics.txt: summary QC metrics produced using 5%,
  10%, 15%...100% of the data 4. <output>.umi_counts.txt: metrics on the
  frequency of observations of UMIs within reads and tag families 5.
  <output>.duplex_qc.pdf: a series of plots generated from the preceding metrics
  files for visualization 6. <output>.duplex_umi_counts.txt: (optional) metrics
  on the frequency of observations of duplex UMIs within reads
     and tag families. This file is only produced if the '--duplex-umi-counts' option is used as it requires significantly
     more memory to track all pairs of UMIs seen when a large number of UMI sequences are present.

  Within the metrics files the prefixes 'CS', 'SS' and 'DS' are used to mean:

  * CS: tag families where membership is defined solely on matching genome
  coordinates and strand * SS: single-stranded tag families where membership is
  defined by genome coordinates, strand and UMI; ie. 50/A and
    50/B are considered different tag families.
  * DS: double-stranded tag families where membership is collapsed across
  single-stranded tag families from the same
    double-stranded source molecule; i.e. 50/A and 50/B become one family

  Requirements ------------

  For plots to be generated R must be installed and the ggplot2 package
  installed with suggested dependencies. Successfully executing the following in
  R will ensure a working installation:

  install.packages("ggplot2", repos="http://cran.us.r-project.org",
  dependencies=TRUE)
label: fgbio_collect_duplex_seq_metrics_1.2.0
arguments:
  - position: 0
    valueFrom: |-
      ${
        if(inputs.memory_per_job && inputs.memory_overhead) {
          if(inputs.memory_per_job % 1000 == 0) {
            return "-Xmx" + (inputs.memory_per_job/1000).toString() + "G"
          }
          else {
            return "-Xmx" + Math.floor((inputs.memory_per_job/1000)).toString() + "G"
          }
        }
        else if (inputs.memory_per_job && !inputs.memory_overhead){
          if(inputs.memory_per_job % 1000 == 0) {
            return "-Xmx" + (inputs.memory_per_job/1000).toString() + "G"
          }
          else {
            return "-Xmx" + Math.floor((inputs.memory_per_job/1000)).toString() + "G"
          }
        }
        else if(!inputs.memory_per_job && inputs.memory_overhead){
          return "-Xmx12G"
        }
        else {
            return "-Xmx12G"
        }
      }
  - position: 0
    valueFrom: '-XX:-UseGCOverheadLimit'
  - position: 1
    valueFrom: CollectDuplexSeqMetrics
  - position: 0
    prefix: '--tmp-dir='
    separate: false
    valueFrom: |-
      ${
          if(inputs.temporary_directory)
              return inputs.temporary_directory;
            return runtime.tmpdir
      }
  - position: 2
    prefix: '--output'
    valueFrom: |-
      ${
          if(inputs.output_prefix){
              return inputs.output_prefix
          }
          else{
              return inputs.input.basename.replace(/.bam/,'')
          }
      }
requirements:
  - class: ResourceRequirement
    ramMin: 16000
    coresMin: 2
  - class: DockerRequirement
    dockerPull: 'ghcr.io/msk-access/fgbio:1.2.0'
  - class: InlineJavascriptRequirement
'dct:contributor':
  - class: 'foaf:Organization'
    'foaf:member':
      - class: 'foaf:Person'
        'foaf:mbox': 'mailto:murphyc4@mskcc.org'
        'foaf:name': Charles Murphy
    'foaf:name': Memorial Sloan Kettering Cancer Center
'dct:creator':
  - class: 'foaf:Organization'
    'foaf:member':
      - class: 'foaf:Person'
        'foaf:mbox': 'mailto:murphyc4@mskcc.org'
        'foaf:name': Charles Murphy
    'foaf:name': Memorial Sloan Kettering Cancer Center
'doap:release':
  - class: 'doap:Version'
    'doap:name': fgbio CollectDuplexSeqMetrics
    'doap:revision': 1.2.0
