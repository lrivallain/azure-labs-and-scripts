# Azure Labs & Scripts

This repository contains some scripts and tools used to create labs and demo environments for Azure resources. Most of the content, as of today, is based on Terraform and the [AzureRM Terraform Provider](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs).

> (!) This content is not provided nor supported by Microsoft and should be used at your own risk. (!)

## Network

### Hub & Spoke topology

* [Hub and spoke model using a Linux based NVA](./hub-and-spoke-linux-based-nva): A Linux based NVA to illustrate an H&S model, cross vNet and Internet connectivity.
* [Default route injection to promote Azure Firewall as next hop](./hub-and-spoke-azfw-route-injection): This set of azure resources was used to illustrate a route injection scenario for **Azure VMware Solution** to use **Azure Firewall** as its next hop.

> The original idea comes from @erjosito who mentioned this route injection method in this blog post: [Azure Firewall’s sidekick to join the BGP superheroes](https://blog.cloudtrooper.net/2022/05/02/azure-firewalls-sidekick-to-join-the-bgp-superheroes/)

### Load Balancing

With a very simple HTTP backend displaying some data about the used worker (hostname, IP, etc):

* [Application Gateway](./application-gateway)
* [Traffic Manager](./traffic-manager)
