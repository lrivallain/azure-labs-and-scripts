# Hub and spoke model applied to AVS with a third party NVA

This folder contains a step-by-step guide to configure AVS in a hub and spoke model with a third party NVA appliance.

In the `current` folder, we will construct, step-by-step, a lab environment where we progressively add the requirements to achieve the AVS integration in a hub and spoke topology.

## Step 0: prepare the base environment

Go in the `./current` folder and copy files using the `prepare.sh` script:

```bash
../step0/prepare.sh
```

### Configuration

Edit the `terraform.tfvars` file and set **at least** the following variables:

```bash
grep to-be-changed current/terraform.tfvars
```

```tf
subscription_name = "to-be-changed"
subscription_id   = "to-be-changed"
vm_admin_password = "to-be-changed"
#echo 'to-be-changed' | mkpasswd --method=SHA-512 --rounds=4096 -s
azure_global_prefix = "to-be-changed"
hub_vpn_aad_tenant_id = "to-be-changed"
avs_er_auth_key = "to-be-changed"
avs_er_circuit_id = "to-be-changed"
avs_mgnt_route_to_announce = "to-be-changed"
avs_wkld_route_to_announce = "to-be-changed"
my_ip = "to-be-changed"
```

### Initialize environment

```bash
cd current
terraform init
```

### Deploy

```bash
terraform apply
```

## Step 1 to 9

Repeat the `prepare.sh` and `terraform apply` for each step:

```bash
../step1/prepare.sh
terraform apply

../step2/prepare.sh
terraform apply

../step3/prepare.sh
terraform apply

../step4/prepare.sh
terraform apply

../step5/prepare.sh
terraform apply

../step6/prepare.sh
terraform apply

../step7/prepare.sh
terraform apply

../step8/prepare.sh
terraform apply

../step9/prepare.sh
terraform apply
```

# Cleanup

```bash
terraform destroy
```
