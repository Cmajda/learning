DRAFT
<!-- TOC -->
- [1. Úkol](#1-úkol)
- [2. Návrh](#2-návrh)
- [3. Postup](#3-postup)
	- [3.1. CI/CD Infra (done)](#31-cicd-infra-done)
		- [3.1.1. Pipeline create Infra](#311-pipeline-create-infra)
	- [3.2. CI/CD application (In progress)](#32-cicd-application-in-progress)
		- [3.2.1. Pipeline application](#321-pipeline-application)
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
- dvě pipeline
  - první na vytvoření infra
  - duhá na build a deploy aplikace
- aplikace nginx statický web server (from image nginx)
- vytvořit index.html obsah "Hurá CI/CD"
- Vytvořit AKS (Azure kubernetes services) - by terraform
- Vytvořit ACR (Azure container registry) - by terraform
- repository GitLab
- CI/CD GitLab

# 3. Postup

## 3.1. CI/CD Infra (done)
- Terraform vytvoří:
    - AKS (done)
    - ACR (done)
- prereqizity
  - Backend pro tf.state  (done)
    - RG (done)
    - ST (done)
    - Container (done)

### 3.1.1. Pipeline create Infra
 - terraform validate (done)
 - terraform init (done)
 - terraform plan (done)
 - terraform apply (done)

## 3.2. CI/CD application (In progress)

### 3.2.1. Pipeline application
 - build image
 - push
 - deploy

# 4. výsledek
web server v azure automatický deploy/ release při změně kódu 