class: CommandLineTool
cwlVersion: v1.0
$namespaces:
  dct: 'http://purl.org/dc/terms/'
  doap: 'http://usefulinc.com/ns/doap#'
  foaf: 'http://xmlns.com/foaf/0.1/'
  sbg: 'https://www.sevenbridges.com/'
id: fgbio_filter_consensus_reads_1_2_0
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
      position: 0
      prefix: '--input'
      shellQuote: false
    doc: The input SAM or BAM file.
  - id: output_file_name
    type: string?
    doc: Output SAM or BAM file to write consensus reads.
  - id: reference_fasta
    type: File
    inputBinding:
      position: 0
      prefix: '--ref'
    doc: Reference fasta file.
    secondaryFiles:
      - .fai
      - ^.dict
  - id: reverse_per_base_tags
    type: boolean?
    inputBinding:
      position: 0
      prefix: '--reverse-per-base-tags'
    doc: 'Reverse [complement] per base tags on reverse strand reads.'
  - id: min_reads
    type: 'int[]?'
    inputBinding:
      position: 0
      prefix: '--min-reads'
      itemSeparator: ' '
      shellQuote: false
    doc: >-
      The minimum number of reads supporting a consensus base/read. (Max 3
      values)
  - id: max_read_error_rate
    type: 'float[]?'
    inputBinding:
      position: 0
      prefix: '--max-read-error-rate'
      itemSeparator: ' '
    doc: >-
      The maximum raw-read error rate across the entire consensus read. (Max 3
      values)
  - id: max_base_error_rate
    type: 'float[]?'
    inputBinding:
      position: 0
      prefix: '--max-base-error-rate'
      itemSeparator: ' '
    doc: The maximum error rate for a single consensus base. (Max 3 values)
  - id: min_base_quality
    type: int
    inputBinding:
      position: 0
      prefix: '--min-base-quality'
    doc: Mask (make N) consensus bases with quality less than this threshold.
  - id: max_no_call_fraction
    type: float?
    inputBinding:
      position: 0
      prefix: '--max-no-call-fraction'
    doc: Maximum fraction of no-calls in the read after filtering
  - id: min_mean_base_quality
    type: int?
    inputBinding:
      position: 0
      prefix: '--min-mean-base-quality'
    doc: The minimum mean base quality across the consensus read
  - id: require_single_strand_agreement
    type: boolean?
    inputBinding:
      position: 0
      prefix: '--require-single-strand-agreement'
    doc: >-
      Mask (make N) consensus bases where the AB and BA consensus reads disagree
      (for duplex-sequencing only).
  - id: temporary_directory
    type: string?
    doc: 'Default value: null.'
outputs:
  - id: fgbio_filter_consensus_reads_bam
    type: File
    outputBinding:
      glob: |-
        ${
            if(inputs.output_file_name)
                return inputs.output_file_name;
            return  inputs.input.basename.replace(/.bam/,'_filtered.bam');
        }
    secondaryFiles:
      - ^.bai
doc: >-
  Filters consensus reads generated by CallMolecularConsensusReads or
  CallDuplexConsensusReads. Two kinds of filtering are performed:


  1. Masking/filtering of individual bases in reads

  2. Filtering out of reads (i.e. not writing them to the output file)


  Base-level filtering/masking is only applied if per-base tags are present (see
  CallDuplexConsensusReads and CallMolecularConsensusReads for descriptions of
  these tags). Read-level filtering is always applied. When filtering reads,
  secondary alignments and supplementary records may be removed independently if
  they fail one or more filters; if either R1 or R2 primary alignments fail a
  filter then all records for the template will be filtered out.


  The filters applied are as follows:


  1. Reads with fewer than min-reads contributing reads are filtered out

  2. Reads with an average consensus error rate higher than max-read-error-rate
  are filtered out

  3. Reads with mean base quality of the consensus read, prior to any masking,
  less than min-mean-base-quality are filtered out (if specified)

  4. Bases with quality scores below min-base-quality are masked to Ns

  5. Bases with fewer than min-reads contributing raw reads are masked to Ns

  6. Bases with a consensus error rate (defined as the fraction of contributing
  reads that voted for a different base than the consensus call) higher than
  max-base-error-rate are masked to Ns

  7. For duplex reads, if require-single-strand-agreement is provided, masks to
  Ns any bases where the base was observed in both single-strand consensus reads
  and the two reads did not agree

  8. Reads with a proportion of Ns higher than max-no-call-fraction after
  per-base filtering are filtered out
label: fgbio_filter_consensus_reads_1.2.0
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
  - position: 0
    valueFrom: FilterConsensusReads
  - position: 0
    prefix: '--tmp-dir'
    valueFrom: |-
      ${
          if(inputs.temporary_directory)
              return inputs.temporary_directory;
            return runtime.tmpdir
      }
  - position: 0
    prefix: '--output'
    shellQuote: false
    valueFrom: |-
      ${
          if(inputs.output_file_name)
              return inputs.output_file_name;
            return  inputs.input.basename.replace(/.bam/,'_filtered.bam');
      }
requirements:
  - class: ShellCommandRequirement
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
        'foaf:mbox': 'mailto:shahr2@mskcc.org'
        'foaf:name': Ronak Shah
    'foaf:name': Memorial Sloan Kettering Cancer Center
'dct:creator':
  - class: 'foaf:Organization'
    'foaf:member':
      - class: 'foaf:Person'
        'foaf:mbox': 'mailto:shahr2@mskcc.org'
        'foaf:name': Ronak Shah
    'foaf:name': Memorial Sloan Kettering Cancer Center
'doap:release':
  - class: 'doap:Version'
    'doap:name': fgbio FilterConsensusReads
    'doap:revision': 1.2.0
