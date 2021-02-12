# Description

this is just an example for terraform config to deploy to aws
for testing purposes there is used nginx to check is everything works correctly
so http request should respond with generic nginx message

## how to run config
1. create `terraform.tfvars` file (it is currently `'gitignored'`)
2. put into the file all required variables defined in variables section in `[file_name].tf`
3. initialize terraform with command `terraform init`
4. verify configuration with `terraform validate`
5. save exact plan of deployment `terraform plan -out [file_name].tfplan`
6. apply saved plan with `terraform apply [file_name].tfplan`

## revert deployment
run  `terraform destroy`
