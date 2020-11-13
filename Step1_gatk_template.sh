source ~/.bash_profile
hash -r

parentDIR=/pdiskdata/zhenyinggroupADS/huangruoshi/wgsdata/

# For this script, you can totally make a TASK_ID file 
# with all the folder paths, file names, populations, code and individuals
# and run using one script.
# But since I did not process them altogether
# and sometimes the individuals have more than one SRA runs
# (for that case you need to run the MarkDuplication again 
# with multiple input file names)
# It is also easier for me to keep track
# or rerun some of the experiments by running them
# seperately by population, hence the pop parameter. 

# This is for naming and dirctory purposes. Change upon use.
#pop=AAAA
#popdecap=BBBB

id=`head -n $SGE_TASK_ID run_sample.txt | tail -n1 | awk '{print $1}'`
indv=`head -n $SGE_TASK_ID single_sample.txt | tail -n1 | awk '{print $1}'`


gatk=/backup/home/zhenying_Group/huangruoshi/biosoft/gatk-4.1.2.0/gatk-package-4.1.2.0-local.jar
trimmomatic=/backup/home/zhenying_Group/huangruoshi/biosoft/Trimmomatic-0.39/trimmomatic-0.39.jar
samtools=/backup/home/zhenying_Group/huangruoshi/biosoft/samtools-1.10/samtools
bwa=/usr/local/bwa-0.7.16a/bwa
picard=/usr/local/picard2.19.0/picard.jar
fastqc=/backup/home/zhenying_Group/bin/FastQC/fastqc
parallel=/usr/local/parallel20190422/bin/parallel

# This is the adaptor file required for trimmomatic. Pair end, truseq 3. Change upon use.
TruSeq3PE=/backup/home/zhenying_Group/huangruoshi/biosoft/Trimmomatic-0.39/adapters/TruSeq3-PE.fa


REFDIR=/pdiskdata/zhenyinggroupADS/huangruoshi/wgsdata/chicken_ref/

ref_genome=$REFDIR/Gallus_gallus.GRCg6a.dna.toplevel.fa

# You need to create the bwa refenrece files. It can be easily obteined online. I created it months ago so no pipeline for this. 
ref_bwa=$REFDIR/RefSeq

# Downloaded from public database. If your species don't have one, do the BQSR bootstrapping. Not shown in this pipeline.
dbsnp=$REFDIR/newdbSNP.vcf.gz

# Chrmosome of interest. One per line
autosome=/pdiskdata/zhenyinggroupADS/huangruoshi/wgsdata/auto_chrm.txt



SRAfileDir=/pdiskdata/zhenyinggroupADS/huangruoshi/SRA_files/${pop}_luo2020
mkdir -p /pdiskdata/zhenyinggroupADS/huangruoshi/SRA_files/fqfile/${pop}lfq/
INPUTDIR=/pdiskdata/zhenyinggroupADS/huangruoshi/SRA_files/fqfile/${pop}lfq/

POPDIR=/pdiskdata/zhenyinggroupADS/huangruoshi/wgsdata/${popdecap}l ###NOTE: here the folder names are customized for the luo_2020 population. Notice the "l".


# Step1: process the SRA file
# make it fastq and trim off the adaptor

fastq-dump --split-files $SRAfileDir/${id}
mv ${id}_1.fastq $SRAfileDir/${id}_1.fastq
mv ${id}_2.fastq $SRAfileDir/${id}_2.fastq

gzip $SRAfileDir/${id}_1.fastq
gzip $SRAfileDir/${id}_2.fastq

$fastqc -t 4 $SRAfileDir/${id}_1.fastq.gz $SRAfileDir/${id}_2.fastq.gz

java -jar $trimmomatic PE -phred33 \
$SRAfileDir/${id}_1.fastq.gz $SRAfileDir/${id}_2.fastq.gz \
$SRAfileDir/${id}_1_paired.fq.gz $SRAfileDir/${id}_1_unpaired.fq.gz \
$SRAfileDir/${id}_2_paired.fq.gz $SRAfileDir/${id}_2_unpaired.fq.gz \
ILLUMINACLIP:$TruSeq3PE:2:30:10 LEADING:3 TRAILING:3 SLIDINGWINDOW:4:15 MINLEN:51


$fastqc -t 4 $SRAfileDir/${id}_1_paired.fq.gz $SRAfileDir/${id}_2_paired.fq.gz

# Step2: map the reads to reference
# Change read group upon use.

$bwa mem -t 4 -M \
-R "@RG\tID:${id}\tLB:${pop}\tPL:illumina\tPU:ncbi\tSM:${indv}" \
$ref_bwa \
$SRAfileDir/${id}_1_paired.fq.gz $SRAfileDir/${id}_2_paired.fq.gz > $POPDIR/${indv}.sam

$samtools flagstat $POPDIR/${indv}.sam > $POPDIR/samstats_${indv}.txt

# Step3: quality control:
# sort, mark duplicates, and recalibrate

java -jar $picard SortSam \
I=$POPDIR/${indv}.sam \
O=$POPDIR/${indv}_sorted.bam \
SO=coordinate

# Soecific the name and directory of metrics file. It will be created by the algorism.
java -jar $picard MarkDuplicates \
I=$POPDIR/${indv}_sorted.bam \
O=$POPDIR/${indv}_dedup.bam \
M=$POPDIR/${indv}.metrics \
REMOVE_DUPLICATES=FALSE

java -jar $gatk BaseRecalibrator \
-I $POPDIR/${indv}_dedup.bam \
-R $ref_genome \
--known-sites $dbsnp \
-O $POPDIR/${indv}_recal.table

java -jar $gatk ApplyBQSR \
-R $ref_genome \
-I $POPDIR/${indv}_dedup.bam \
--bqsr-recal-file $POPDIR/${indv}_recal.table \
-O $POPDIR/${indv}_recal.bam

# Step4: Varient calling per individual

mkdir -p $POPDIR/${indv}_raw_chrms_vcfs/
RAWOUTPUTDIR=$POPDIR/${indv}_raw_chrms_vcfs

$parallel java -jar -Xmx8G \
$gatk HaplotypeCaller \
-L {} -R $ref_genome \ #-L: to specify output chromosome
-I $POPDIR/${indv}_recal.bam \
-ERC BP_RESOLUTION \ #to output every position, no matter if it is ref or alt. This is mainly for callable site counting in future. If just for SNP calling it doesn't matter which para.
-output-mode EMIT_ALL_SITES \
--dbsnp $dbsnp \
-O $RAWOUTPUTDIR/${indv}_{}.raw.g.vcf.gz \
:::: $autosome

# at the end you should have raw input vcf per individuals (or even per chromosome.)
