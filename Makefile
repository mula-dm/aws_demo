usage:
	@echo "Available commands: "
	@echo
	@echo ===================
	@echo "\t\033[92mhelp\033[0m - Show help."
	@echo "\t\033[92minit\033[0m - General init."
	@echo "\t\033[92mtf_init\033[0m - Terraform init."
	@echo "\t\033[92mtf_plan\033[0m - Terraform plan."
	@echo "\t\033[92mtf_apply\033[0m - Terraform apply."
	@echo "\t\033[92mtf_destroy\033[0m - Terraform destroy."
	@echo "\t\033[92mscript_init\033[0m - Build docker image for script."
	@echo "\t\033[92mlist_all\033[0m - List all resources."
	@echo "\t\033[92mlist_ec2\033[0m - List ec2 resources."
	@echo "\t\033[92mlist_vpc\033[0m - List vpc resources."
	@echo ===================
	@echo

# ---------------------------------------------------------------------------------------------------------------------
# Variables
# ---------------------------------------------------------------------------------------------------------------------

TERRAFORM_VERSION ?= latest
TERRAFORM_IMAGE ?= hashicorp/terraform
TERRAFORM ?= @docker run --rm  -i -t -v ~/.aws:/root/.aws --mount type=bind,source="$$(pwd)"/terraform/,target=/terraform -w /terraform ${TERRAFORM_IMAGE}:${TERRAFORM_VERSION}

# ---------------------------------------------------------------------------------------------------------------------
# Include common variables
# ---------------------------------------------------------------------------------------------------------------------

# ---------------------------------------------------------------------------------------------------------------------
# Targets
# ---------------------------------------------------------------------------------------------------------------------

.PHONY: usage
.PHONY: help
help: usage

.PHONY: init
init:
	@make tf_init
	make script_init

.PHONY: tf_init
tf_init:
	${TERRAFORM} init

.PHONY: tf_plan
tf_plan:
	${TERRAFORM} plan

.PHONY: tf_apply
tf_apply:
	${TERRAFORM} apply

.PHONY: tf_destroy
tf_destroy:
	${TERRAFORM} destroy

.PHONY: script_init
script_init:
	@cd src && docker build . -t demo

.PHONY: list_all
list_all:
	@docker run -it -v ~/.aws:/root/.aws demo:latest -e all

.PHONY: list_ec2
list_ec2:
	@docker run -it -v ~/.aws:/root/.aws demo:latest -e ec2

.PHONY: list_vpc
list_vpc:
	@docker run -it -v ~/.aws:/root/.aws demo:latest -e vpc
