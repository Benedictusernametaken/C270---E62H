from flask import Flask
from flask_sqlalchemy import SQLAlchemy

# 1. Initialize the extensions
app = Flask(__name__)
db = SQLAlchemy(app)

# 2. Import routes AFTER extensions exist to prevent circular blocks
from app import main

# 3. Create tables safely inside the application context
with app.app_context():
    db.create_all()