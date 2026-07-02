# 🍏 Nutritrack Application Suite

Welcome to **Nutritrack**! This repository contains a fully containerized web application suite consisting of a frontend interface, an API backend, and a dedicated database tracking system. 

The project features a complete **DevOps Automation Pipeline** powered by **Jenkins CI/CD** and **Ansible Infrastructure-as-Code (IaC)** for seamless, single-command deployments.

---


## 🏗️ Architecture Overview

The system is split into three main core application layers and managed by automated infrastructure systems:

* **Frontend:** User interface application.
* **Backend:** RESTful API service handling core business logic and routing.
* **Database:** Persistent storage layer for system and application data.
* **Jenkins:** Automation server executing continuous integration builds and code verification.
* **Ansible:** Configuration management engine ensuring identical deployment environments.


---


## 🌿 Contribution & Git Workflow

To keep our codebase clean and stable, always work out of a dedicated feature branch instead of making changes directly to the main production branches. Follow these step-by-step instructions to create, save, and push your work:

### 1. Create a New Feature Branch
Before writing any code, ensure you are on the latest development tracking branch and create a fresh branch named after the feature you are building:
```bash
# Switch to the primary development branch
git checkout develop

# Get the latest updates from GitHub
git pull origin develop

# Create and switch to your new feature branch
# Syntax: git checkout -b feature/your-feature-name
git checkout -b feature/add-nutrition-logs


### 2. Save Your Progress (Stage & Commit)
Once you have modified your files or updated the codebase, you need to snapshot your changes locally:

Bash
# Step A: Check which files you have modified
git status

# Step B: Stage your changes (tells Git to track these files)
git add .

# Step C: Commit your changes with a clear, descriptive message
git commit -m "feat: updated deploy.yml with optimized ansible synchronization"


### 3. Push Your Changes to GitHub
To publish your local commits to the remote repository so your teammates (or the Jenkins pipeline) can see it, run:

Bash
# Push your branch up to GitHub
git push origin feature/add-nutrition-logs



Before starting, make sure you have the following core tools installed on your local computer or workspace:

## ⚙️ Prerequisites for Beginners

To run this automated project, you only need to install **Ansible** on your local machine. Our automated playbook will handle setting up Docker, Docker Compose, and all other system dependencies for you!

### Install Ansible:
Open your terminal and run the command matching your operating system:

* **Ubuntu/Debian (or Linux Codespaces):**
  ```bash
  sudo apt update && sudo apt install -y ansible rsync

---


## 🚀 Quick Start: Manual Local Deployment

If you want to spin up the application suite manually on your local system without triggering the DevOps pipelines, follow these steps:

1.  **Clone the Repository:**
    ```bash
    git clone [https://github.com/YOUR_USERNAME/C270---E62H.git](https://github.com/YOUR_USERNAME/C270---E62H.git)
    cd C270---E62H
    ```

2.  **Launch the App via Docker Compose:**
    ```bash
    docker compose up -d
    ```

3.  **Verify the Services are Running:**
    ```bash
    docker ps
    ```
    You should see your frontend, backend, and database containers transition cleanly to an **`Up`** status.

---

## ⚡ Automated DevOps Deployment (Ansible)

Instead of running raw docker commands manually, we use **Ansible** to manage, configure, and orchestrate our environment deployments safely and instantly.

### How to run the Playbook manually:
From the root repository directory, execute the pre-configured deployment script:

```bash
ansible-playbook -i hosts.ini ansible/deploy.yml