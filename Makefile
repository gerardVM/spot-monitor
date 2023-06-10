TF_COMPONENT    ?= aws
TF_DIR          := ${PWD}/ops/terraform/${TF_COMPONENT}
DECRYPT 		?= false

decrypt:
	@if [ ${DECRYPT} = true ]; then sops -d config.enc.yaml > config.dec.yaml; fi

tf-init: decrypt
	@cd ${TF_DIR} && terraform init -reconfigure

tf-validate: tf-init
	@cd ${TF_DIR} && terraform validate

tf-plan: decrypt
	@cd ${TF_DIR} && terraform init -reconfigure
	@cd ${TF_DIR} && terraform plan -out=tfplan.out

tf-apply: decrypt
	@cd ${TF_DIR} && terraform apply tfplan.out

tf-output: decrypt
	@cd ${TF_DIR} && terraform output -json

tf-import: decrypt
	@cd ${TF_DIR} && terraform import ${TF_RESOURCE} ${TF_ID}

tf-destroy: decrypt
	@cd ${TF_DIR} && terraform destroy

tf-deploy: tf-plan tf-apply