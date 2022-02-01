# Copyright 2019 Google LLC
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#      http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

# Let's create the GKE cluster! This one's pretty complicated so buckle up.

# This is another example of the random provider. Here we're using it to pick a
# zone at random - all different regions from where we provisioned
# the Hipster Shop.
resource "random_shuffle" "zone" {
  input = ["us-west1-a", "us-west1-b", "us-west1-c", "asia-east1-a", "europe-west2-a", "europe-west3-b", "europe-west2-c"]

  # Seeding the RNG is technically optional but while building this we
  # found that it returned the same zone every time unless we seeded it. Here
  # we're using the ID of the project as a seed because it is unique to the
  # project but will not change, thereby guaranteeing stability of the results.
  seed = var.project_id
}

resource "google_service_account" "sa-loadgenerator" {
  project = var.project_id
  account_id   = "sa-loadgenerator"
  display_name = "A service account used by loadgenerator pipeline"
}

# First we create the cluster. If you're wondering where all the sizing details
# are, they're below in the `google_container_node_pool` resource. We'll get
# back to that in a minute.
#
# One thing to note here is the name of the resource ("gke") is only used
# internally, for instance when you're referencing the resource (eg
# `google_container_cluster.gke.id`). The actual created resource won't know
# about it, and in fact you can specify the name for that in the resource
# itself.
#
# Finally, there are many, many other options available. The resource below
# replicates what the Hipster Shop README creates. If you want to see what else
# is possible, check out the docs: https://www.terraform.io/docs/providers/google/r/container_cluster.html
resource "google_container_cluster" "gke_loadgen" {
  # Here's how you specify the name of the cluster
  name = "loadgenerator"

  project = var.project_id

  # Set the zone by grabbing the result of the random_shuffle above. It
  # returns a list so we have to pull the first element off. If you're looking
  # at this and thinking "huh terraform syntax looks a clunky" you are NOT WRONG
  location = element(random_shuffle.zone.result, 0)

  # Using an embedded resource to define the node pool. Another
  # option would be to create the node pool as a separate resource and link it
  # to this cluster. There are tradeoffs to each approach.
  #
  # The embedded resource is convenient but if you change it you have to tear
  # down the entire cluster and rebuild it. A separate resource could be
  # modified independent of the cluster without the cluster needing to be torn
  # down.
  #
  # For this particular case we're not going to be modifying the node pool once
  # it's deployed, so it makes sense to accept the tradeoff for the convenience
  # of having it inline.
  #
  # Many of the paramaters below are self-explanatory so I'll only call out
  # interesting things.

  node_pool {
    node_config {
      service_account = google_service_account.sa-loadgenerator.email

      machine_type = "n1-standard-4"

      oauth_scopes = [
        "https://www.googleapis.com/auth/cloud-platform"
      ]

      labels = {
        environment = "dev",
        cluster     = "loadgenerator-main"
      }
    }

    initial_node_count = 20

    autoscaling {
      min_node_count = 1
      max_node_count = 30
    }

    management {
      auto_repair  = true
      auto_upgrade = true
    }
  }

  # Stores the zone of created loadgenerator gke cluster
  provisioner "local-exec" {
    command = "gcloud config set compute/zone ${element(random_shuffle.zone.result, 0)}"
  }
}


# Set current project 
resource "null_resource" "current_project" {
  provisioner "local-exec" {
    command = "gcloud config set project ${var.project_id}"
  }
}

# Setting kubectl context to currently deployed loadgenerator GKE cluster
resource "null_resource" "set_gke_context" {
  for_each = toset(local.locust_instance)

  provisioner "local-exec" {
    command = "gcloud container clusters get-credentials loadgenerator --zone ${element(random_shuffle.zone.result, 0)} --project ${var.project_id}"
  }

  depends_on = [
    google_container_cluster.gke_loadgen,
    null_resource.current_project
  ]
}

# Populate the ConfigMap with environment variables
resource "null_resource" "set_env_vars" {
  
  provisioner "local-exec" {
    command = "echo kubectl create configmap address-config --from-literal=FRONTEND_ADDR=http://${var.external_ip}"
    
  }
  depends_on = [null_resource.set_gke_context]
}

locals {
    locust_instance =  ["1", "2", "3", "4", "5", "6", "7", "8", "9", "10", "11", "12"]
}

# Deploy loadgenerator into GKE cluster 
resource "null_resource" "deploy_services" {
  for_each = toset(local.locust_instance)
  
  provisioner "local-exec" {
    command = "echo variables: $instance - $image"
    environment = {
        image = var.image
        instance = each.key
    }
  }

  provisioner "local-exec" {
    command = "cat ${path.module}/loadgenerator-manifests/loadgenerator.template.yaml > ${path.module}/loadgenerator-manifests/loadgenerator.tmp.${each.key}.yaml"
  }

  provisioner "local-exec" {
    command = "sed \"s|{instance}|${each.key}|\" ${path.module}/loadgenerator-manifests/loadgenerator.tmp.${each.key}.yaml > ${path.module}/loadgenerator-manifests/loadgenerator.tmp2.${each.key}.yaml"
    environment = {
        instance = each.key
    }
  }  

  provisioner "local-exec" {
    
    command = "sed \"s|{image}|${var.image}|\"  ${path.module}/loadgenerator-manifests/loadgenerator.tmp2.${each.key}.yaml   > ${path.module}/loadgenerator-manifests/loadgenerator.${each.key}.yaml"
      environment = {
        image = var.image
    }
  }
   
  provisioner "local-exec" {
    command = "rm ${path.module}/loadgenerator-manifests/loadgenerator.tmp*${each.key}.yaml"
  }



  provisioner "local-exec" {
    command = "kubectl apply -f ${path.module}/loadgenerator-manifests/loadgenerator.${each.key}.yaml"
  }

  provisioner "local-exec" {
    command = "kubectl wait --for=condition=available --timeout=600s deployment/loadgenerator-${each.key}"
  }

  depends_on = [
    null_resource.set_env_vars
  ]
}



resource "null_resource" "output" {
  triggers  =  { always_run = "${timestamp()}" }

  provisioner "local-exec" {
    command = "kubectl get services --all-namespaces -o json | jq -r '.items[] | { name: .metadata.name, ns: .metadata.namespace, ip: .status.loadBalancer?|.ingress[]?|.ip  }' > ${path.module}/output.txt"
  }

  depends_on = [
    null_resource.deploy_services
  ]

}
