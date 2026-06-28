from flask import Flask, jsonify
import pandas as pd

app = Flask(__name__)

@app.route('/')
def home():
    return jsonify({
        "status": "online",
        "message": "Welcome to the NutriTrack Backend API Tiers!"
    })

@app.route('/health-check')
def health_check():
    # Simple verification that Pandas is imported and working
    df = pd.DataFrame({"status": ["healthy"]})
    return jsonify({
        "database_connectivity": "pending",
        "pandas_version": pd.__version__,
        "engine_status": df["status"].iloc[0]
    })

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5000)