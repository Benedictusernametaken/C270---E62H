import os
from flask import Flask

# 1. Initialize the master Flask instance once
app = Flask(__name__)

# 2. Import routes from main.py to attach them to the master app instance above
from app import main