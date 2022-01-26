echo START $(date)

gsutil mb -l eu gs://tf_state_devops_hackathon

terraform apply -auto-approve 

echo END $(date)