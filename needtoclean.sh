date >>$logfile


for k in /data/szolo/reads/21_1_*.txt.gz ; do
        echo $k  "start"   >>$logfile
        date >> $logfile
        filename=`basename $k .txt.gz`
       second="${filename/_1_/_2_}"
       echo  $filename
       echo $second

#      this will make the second fastq.gz come after the firts one in the bwa mem command
        bwa mem -t 4   "${ensembl}" $k /data/szolo/reads/"${second}".txt.gz   2>"${logdir}"/"${filename}".memerr | 
        samtools view -Sb -t $datafai - 2>"${logdir}"/"${filename}"2.viewerr >"${basedir}"bam/"${filename}"unsorted.bam
       samtools sort  "${basedir}"bam/"${filename}"unsorted.bam  > "${basedir}"bam/both"${filename}".bam   2>"${logdir}"/"${filename}".sorterr 
        samtools index "${basedir}"bam/both"${filename}".bam  "${basedir}"bam/both"${filename}".bai
        echo "single $k ready"
       rm "${filename}"unsorted.bam
done
#singles done
#so far we have converted the sra-s to bam-s and bai-s


#-----------------
#if its not working, try sraprocess2.sh script 
#----------------

for p in ${basedir}bam/both*15*.bam

do

        filename=`basename $p .bam`

        samtools mpileup -uf $ensembl $p | bcftools call -mv -Oz  >${basedir}vcf/newest${filename}.vcf 2>${logdir}/${filename}.err
        echo "vcfstatting $k ready" >>$logfile

#-----------------------------------
#new version, hopefully it will run...
#----------------------------------

samtools mpileup -uvf $ensembl $p >${basedir}vcf/uvfes${filename}.vcf

#sweet, sweet tit licking baby of Mary and Joseph, these files are big if you dont gzip them.

samtools mpileup -uvf $ensembl $p |gzip --stdout >${basedir}vcf/uvfes${filename}.vcf.gz

done



date>>$logfile

exit
