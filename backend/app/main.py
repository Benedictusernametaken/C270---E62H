from flask import Flask, jsonify
import pandas as pd
import psycopg2
from psycopg2.extras import RealDictCursor

app = Flask(__name__)

@app.route('/')
def home():
    return jsonify({
        "status": "online",
        "message": "Welcome to the NutriTrack Backend API Tiers!"
    })

# --- THIS IS THE NEW REPLACED BLOCK ---
@app.route('/health-check')
def health_check():
    connection = None
    try:
        # Establish connection using the credentials from docker-compose
        connection = psycopg2.connect(
            host="database",
            database="nutritrack_db",
            user="nutri_admin",
            password="nutri_password"
        )
        cursor = connection.cursor(cursor_factory=RealDictCursor)
        
        # Query the seed data we injected into init.sql
        cursor.execute("SELECT * FROM vendors;")
        db_vendors = cursor.fetchall()
        
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
# --- END OF REPLACED BLOCK ---

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5000)