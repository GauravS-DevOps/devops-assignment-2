# CI/CD Pipeline with Docker, GitHub Actions and Kubernetes (Kind)

## Overview

This project demonstrates a simple **CI/CD pipeline** that automates linting, testing, Docker image creation, image publishing, and deployment to a **staging Kubernetes environment**.

The pipeline is implemented using **GitHub Actions** and deploys a containerized Node.js application to a **Kubernetes cluster created using Kind (Kubernetes in Docker)**.

The goal of this assignment is to simulate a real-world DevOps workflow where code changes automatically trigger build, test, and deployment processes.

---

# Project Architecture

Pipeline Flow

```
Developer Push
      ↓
GitHub Actions Trigger
      ↓
Lint & Test
      ↓
Build Docker Image
      ↓
Push Image to DockerHub
      ↓
Create Kubernetes Cluster (Kind)
      ↓
Deploy Application to Staging
```

---

# Project Structure

```
task2/
│
├── .github/
│   └── workflows/
│       └── deploy.yml        # GitHub Actions pipeline
│
├── k8s/
│   ├── deployment.yaml       # Kubernetes deployment manifest
│   └── service.yaml          # Kubernetes service manifest
│
├── app.js                    # Simple Node.js demo application
├── package.json              # Node dependencies
├── Dockerfile                # Docker build configuration
└── README.md                 # Project documentation
```

---

# Application

A lightweight **Node.js application** is used for demonstration.
The application runs on **port 3000** and is containerized using Docker.

---

# Dockerization

The application is containerized using a **Dockerfile**.

### Build Image

```
docker build -t cicd-demo .
```

### Run Container

```
docker run -p 3000:3000 cicd-demo
```

---

# GitHub Secrets

The pipeline requires Docker Hub credentials to push the built image.

Add the following secrets in the repository:

```
DOCKER_USERNAME
DOCKER_PASSWORD
```

These are configured in:

```
Repository → Settings → Secrets → Actions
```

---

# CI/CD Pipeline

The CI/CD pipeline is implemented using **GitHub Actions**.

The workflow file is located at:

```
.github/workflows/deploy.yml
```

The pipeline runs automatically whenever code is pushed to the **main branch**.

---

# Pipeline Stages

## 1. Lint and Test

The first stage ensures code quality and basic validation.

Steps performed:

* Checkout repository
* Install Node.js
* Install project dependencies
* Run lint checks
* Execute tests

Purpose:
This stage ensures that **only validated code proceeds further in the pipeline**.

---

## 2. Build Docker Image

After successful testing, the pipeline builds the application container.

```
docker build -t <dockerhub-username>/cicd-demo:latest .
```

Purpose:
Create a **portable container image** that can run consistently across environments.

---

## 3. Push Image to DockerHub

The built image is pushed to DockerHub.

```
docker push <dockerhub-username>/cicd-demo:latest
```

Purpose:
DockerHub acts as the **container registry** from which Kubernetes pulls images.

---

## 4. Create Kubernetes Cluster (Kind)

During the deployment stage, the pipeline creates a temporary Kubernetes cluster using **Kind**.

```
kind create cluster --name staging
```

Kind runs Kubernetes **inside Docker**, allowing us to simulate a real cluster in CI.

---

## 5. Deploy to Staging Environment

The application is deployed using Kubernetes manifests.

```
kubectl apply -f k8s/deployment.yaml
kubectl apply -f k8s/service.yaml
```

Resources created:

* **Deployment**
* **Service**

The service exposes the application internally within the cluster.

---

## Deployment Verification

After deployment, the pipeline verifies that the application is running.

```
kubectl rollout status deployment/cicd-demo
kubectl get pods
kubectl get svc
```

This ensures the deployment has successfully started.

---

# Staging Environment Behavior

The Kubernetes cluster created by **Kind** exists only during the GitHub Actions job.

This means:

* The cluster is temporary
* It runs inside the GitHub Actions runner
* It is destroyed automatically after the pipeline finishes

This setup is suitable for **CI validation and staging simulation**.

---

# Rollback Strategy (Staging)

In Staging environments, one commonly used rollback strategy is **Rolling Update with Rollback**.

Kubernetes deployments support rolling updates by default, which means new application versions are gradually deployed without stopping the existing running instances.

If a new version causes issues, Kubernetes allows an immediate rollback to the previously stable version:

```
kubectl rollout undo deployment cicd-demo
```

This strategy ensures:

* No downtime for users
* Traffic continues to be served by healthy pods
* Faulty versions can be reverted quickly

Because Kubernetes replaces pods gradually, the rollback happens smoothly without disrupting active traffic.

---

# Conclusion

This project demonstrates a practical CI/CD implementation that includes:

* Automated code validation
* Docker image creation
* Container registry integration
* Kubernetes-based staging deployment
* Deployment verification
* Safe rollback strategy

The pipeline simulates a realistic DevOps workflow used in modern cloud-native environments.
