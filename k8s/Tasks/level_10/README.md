<!-- TOC -->
- [1. Úkol](#1-úkol)
- [2. Návrh](#2-návrh)
- [3. Postup](#3-postup)
	- [3.1. CI/CD Infra](#31-cicd-infra)
		- [3.1.1. Build Pipeline Terraform plan](#311-build-pipeline-terraform-plan)
		- [3.1.2. Release Pipeline Terraform plan](#312-release-pipeline-terraform-plan)
	- [3.2. CI/CD app](#32-cicd-app)
		- [3.2.1. Build Pipeline app](#321-build-pipeline-app)
		- [3.2.2. Release Pipeline app](#322-release-pipeline-app)
- [4. výsledek](#4-výsledek)
<!-- /TOC -->

# 1. Úkol  
- Libovolnou aplikaci
- libovolný CI-CD provider
- vytvořit pipeline která po změně kódu zdrojové aplikace vytvoří image
- udělá push image do vámi zvoleného CR
- vygeneruje nebo upraví Kubernetes manifesty pro deploy této aplikace.

pozn: apply těchto manifestů zatím vynecháme, tzn stačí je pouze vygenerovat a pak apply ručně

# 2. Návrh
- aplikace nginx statický web server (from image nginx)
- vytvořit index.html obsah "Hurá CI/CD"
- Vytvořit AKS (Azure kubernetes services) - by terraform
- Vytvořit ACR (Azure container registry) - by terraform
- repository AzureDevOps
- CI/CD Devops

# 3. Postup

## 3.1. CI/CD Infra
- Terraform vytvoří:
    - AKS
    - ACR

### 3.1.1. Build Pipeline Terraform plan
 - output tf plan (artefact)

### 3.1.2. Release Pipeline Terraform plan
 - apply tf plan

## 3.2. CI/CD app
- vytvoří app

### 3.2.1. Build Pipeline app
- create image

### 3.2.2. Release Pipeline app
 - apply tf plan

# 4. výsledek
web server v azure automatický deploy/ release při změně kódu 