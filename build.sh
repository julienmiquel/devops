echo START $(date)
gsutil mb -l eu gs://tf_state_devops_hackathon

array=( projet-1 projet-2 projet-3 )

for i in "${array[@]}"
do
	echo " create env for project $i"
    terraform apply -auto-approve -var project=$i
done

echo END $(date)