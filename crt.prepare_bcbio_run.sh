#!/bin/bash

# prepares a project (family) for bcbio run when input files are project/input/project_sample.bam or project_sample_1/2.fq.gz
project=$1

#template_type:
#    default (not set): crt.bcbio.default.yaml
#    noexpression: crt.bcbio.noexpression.yaml

cd $project

cp ~/cre/bcbio.sample_sheet_header.csv $project.csv

cd input

#there should be no other files except input fq.gz or bams in the input dir
ls | sed s/.bam// | sed s/.bai// | sed s/"_1.fq.gz"// | sed s/"_2.fq.gz"// | sort | uniq > ../samples.txt

cd ..

#no family is neede for single sample
while read sample
do
    echo $sample","$sample","$project",,," >> $project.csv
done < samples.txt

#default template
template=~/crt/crt.bcbio.default.yaml

if [ -n "$2" ]
then
    template_type=$2
    if [ $template_type == "noexpression" ]
    then
	template=~/crt/crt.bcbio.noexpression.yaml
    fi
fi

echo "Creating bcbio project for " $project " with template: " $template

bcbio_nextgen.py -w template $template $project.csv input/*

mv $project/config .
mv $project/work .
rm $project.csv
rmdir $project

cd ..
