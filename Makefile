help:
	@echo "Usage: make [target]"
	@echo ""
	@echo "Targets:"
	@echo "  state-backend        - Initialize and setup Terraform backend on s3 bucket including dynamo-db locking"
	@echo "  setup-infra          - Initialize and setup Terraform Infrastucture which will trigger ansible instllations"
	
state-backend:
	# setup and run tf state backend
	cd terraform/backend && terraform init &&\
			terraform plan &&\
			terraform apply -auto-approve

setup-infra:
	# setup and run tf main Infra which will trigger ansible installations
	cd terraform/ && terraform init &&\
			terraform plan &&\
			terraform apply -auto-approve
