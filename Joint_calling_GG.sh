source ~/.bash_profile
hash -r

gatk=/backup/home/zhenying_Group/huangruoshi/biosoft/gatk-4.1.2.0/gatk-package-4.1.2.0-local.jar
REFDIR=/pdiskdata/zhenyinggroupADS/huangruoshi/wgsdata/chicken_ref/

ref_genome=$REFDIR/Gallus_gallus.GRCg6a.dna.toplevel.fa
ref_bwa=$REFDIR/RefSeq
dbsnp=$REFDIR/newdbSNP.vcf.gz
autosome=/pdiskdata/zhenyinggroupADS/huangruoshi/wgsdata/auto_chrm.txt
          
         
chrmfile=/pdiskdata/zhenyinggroupADS/huangruoshi/wgsdata/txt_might_be_useful/GGchrm_regions.txt
chrm=`head -n $SGE_TASK_ID $chrmfile | tail -n1 | awk '{print $1}'`
region=`head -n $SGE_TASK_ID $chrmfile | tail -n1 | awk '{print $2}'`
dirname=`head -n $SGE_TASK_ID $chrmfile | tail -n1 | awk '{print $3}'`

# preparation. Change the directory upon use. 
# Do create a folder for tmp directory but NOT for my_database
# OUTDIR=/pdiskdata/zhenyinggroupADS/huangruoshi/wgsdata/70/snp/outputvcfs/
# mkdir -p /pdiskdata/zhenyinggroupADS/huangruoshi/wgsdata/70/snp/GGprocess/tmp_dir_${dirname}

java -jar -Xmx8G $gatk GenomicsDBImport -R $ref_genome \
-V /path/to/your/raw/vcfoutput/per/individual/per/chrm/SAMPLE1_${chrm}.raw.g.vcf.gz \
-V /path/to/your/raw/vcfoutput/per/individual/per/chrm/SAMPLE2_${chrm}.raw.g.vcf.gz \
 --genomicsdb-workspace-path /pdiskdata/zhenyinggroupADS/huangruoshi/wgsdata/70/snp/my_database_${dirname} \
 --tmp-dir=/pdiskdata/zhenyinggroupADS/huangruoshi/wgsdata/70/snp/GGprocess/tmp_dir_${dirname} \
 -L ${region} \
 --reader-threads 5
 
 
 java -jar -Xmx8G $gatk GenotypeGVCFs \
 -R $ref_genome \
 -V gendb://my_database_${dirname}/ \
 -O $OUTDIR/output_${dirname}.vcf.gz \
 --tmp-dir=/pdiskdata/zhenyinggroupADS/huangruoshi/wgsdata/70/snp/GGprocess/tmp_dir_${dirname}
 
 
