SHELL = /bin/bash
tf = time terraform

init:
	$(tf) $@

plan output:
	$(tf) $@

apply destroy:
	$(tf) $@ --auto-approve


create: apply

delete: destroy


cluster_name = gitlab-no-ops
node_pool = pool-1
num_nodes = 3
zone = us-central1-a
machine_type = e2-standard-2
up:
	gcloud container node-pools create $(node_pool) \
		--cluster $(cluster_name) \
		--disk-size 100GB \
		--disk-type pd-standard \
		--machine-type $(machine_type) \
		--num-nodes $(num_nodes) \
		--preemptible \
		--enable-autoscaling \
		--max-nodes $(num_nodes) \
		--min-nodes $(num_nodes) \
		--zone $(zone) \
		--quiet

down:
	gcloud container node-pools delete $(node_pool) \
		--cluster $(cluster_name) \
		--zone $(zone) \
		--quiet
