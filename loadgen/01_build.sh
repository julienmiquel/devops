echo START $(date)
#gsutil mb -l eu gs://tf_state_devops_hackathon

#array=( projet-1 projet-2 projet-3 )
# google.com:finance-practice finance-practice-demo cloud-ops-sandbox-2234836724)

array=( cloud-ops-sandbox-2234836724 )
    

export TF_LOG="INFO"
export TF_LOG_PATH="terraform.log"

cd 01_terraform/
for i in "${array[@]}"
do
	echo " create env for project $i"
    export TF_LOG_PATH="terraform-$i.log"
    gcloud config set project  $i
    gcloud beta compute routes create internet --project=$i --network=default --priority=1000 --destination-range=0.0.0.0/0 --next-hop-gateway=default-internet-gateway
    terraform apply -auto-approve -var project_id=$i -var external_ip=0.0.0.0
done


echo END $(date)
cd ..