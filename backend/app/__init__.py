import os
from flask import Flask
from flask_sqlalchemy import SQLAlchemy

# 1. Initialize the Flask instance
app = Flask(__name__)

# 2. Configure the Database Connection URI BEFORE initializing SQLAlchemy
# Adjust the values if your PostgreSQL credentials inside docker-compose are different!
app.config['SQLALCHEMY_DATABASE_URI'] = os.environ.get(
    'DATABASE_URL', 
    'postgresql://postgres:postgres@database:5432/postgres'
)
app.config['SQLALCHEMY_TRACK_MODIFICATIONS'] = False

# 3. Initialize the extension now that the config is present
db = SQLAlchemy(app)

# 4. Import routes to prevent circular blocks
from app import main

# 5. Create tables safely inside the application context
with app.app_context():
    db.create_all()