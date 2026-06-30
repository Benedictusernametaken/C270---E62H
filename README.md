## 🛠️ Team Development & CI/CD Workflow

We use a standardized infrastructure powered by **GitHub, Docker Compose, and Jenkins** to ensure consistency across all environments. 

### 1. Local Environment Setup
To protect secrets, database passwords and application environment variables are abstracted out of our source code. 

To spin up your local instance:
1. Copy the environment template: `cp .env.example .env`
2. Open the newly created `.env` file and customize your local variables (e.g., `POSTGRES_PASSWORD`).
3. Launch the standardized application stack:
   ```bash
   docker compose up -d --build