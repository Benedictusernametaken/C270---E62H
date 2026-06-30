from flask import jsonify
import pandas as pd
import psycopg2
import os
from psycopg2.extras import RealDictCursor
# Import the shared master app instance from your package folder
from app import app 

@app.route('/')
def home():
    return jsonify({
        "status": "online",
        "message": "Welcome to the NutriTrack Backend API Tiers!"
    })

@app.route('/health-check')
def health_check():
    connection = None
    try:
        # 2. REPLACE THE OLD psycopg2.connect BLOCK WITH THIS:
        db_url = os.environ.get(
            "DATABASE_URL", 
            "postgresql://nutri_admin:your_secure_password@database:5432/nutritrack_db"
        )
        connection = psycopg2.connect(db_url)
        cursor = connection.cursor(cursor_factory=RealDictCursor)
        
        # Query the seed data we injected into init.sql
        cursor.execute("SELECT * FROM vendors;")
        db_vendors = cursor.fetchall()  # Fixed indentation!
        
        cursor.close()
        return jsonify({
            "status": "healthy",
            "database_connectivity": "CONNECTED",
            "seed_data_found": db_vendors
        })
        
    except Exception as e:
        return jsonify({
            "status": "degraded",
            "database_connectivity": f"FAILED: {str(e)}"
        }), 500
        
    finally:
        if connection:
            connection.close()

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5000)