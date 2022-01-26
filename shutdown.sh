echo START $(date)
gsutil mb -l eu gs://tf_state_devops_hackathon

array=( projet-1 projet-2 projet-3 )


export TF_LOG="INFO"
export TF_LOG_PATH="terraform.log"

for i in "${array[@]}"
do
	echo " create env for project $i"
    export TF_LOG_PATH="terraform-$i.log"
    terraform destroy -auto-approve -var project=$i
done

echo END $(date)