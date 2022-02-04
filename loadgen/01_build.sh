echo START $(date)

#array=( projet-1 projet-2 projet-3 )

#TODO set your project instead below
array=( cagip-hackathon-eqXX-inno0-b0 )
    

export TF_LOG="INFO"
export TF_LOG_PATH="terraform.log"

image="${REPO}/${REPO_PREFIX}/loadgenerator:$TAG"
echo $image

cd 01_terraform/
for i in "${array[@]}"
do
	echo " create env for project $i"
    export TF_LOG_PATH="terraform-$i.log"
    terraform init
    gcloud config set project  $i
    gcloud beta compute routes create internet --project=$i --network=default --priority=1000 --destination-range=0.0.0.0/0 --next-hop-gateway=default-internet-gateway
    #terraform destroy -auto-approve -var project_id=$i -var external_ip=0.0.0.0 -var image=$image
    terraform apply -auto-approve -var project_id=$i -var external_ip=0.0.0.0 -var image=$image
    gcloud beta compute routes create internet --project=$i --network=default --priority=1000 --destination-range=0.0.0.0/0 --next-hop-gateway=default-internet-gateway
done


echo END $(date)
cd ..