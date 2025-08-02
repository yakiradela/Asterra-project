import os
from flask import Flask, request, jsonify
from app.utlis import validate_geojson
from app.db import insert_geojson

app = Flask(__name__)

@app.route('/upload', methods=['POST'])
def upload():
    geojson = request.get_json()
    if not validate_geojson(geojson):
        return jsonify({"error": "Invalid GeoJSON"}), 400
    
    success = insert_geojson(geojson)
    if not success:
        return jsonify({"error": "Failed to insert into DB"}), 500
    
    return jsonify({"message": "GeoJSON inserted successfully"}), 200

if __name__  == "__main__":
    app.run(host="0.0.0.0", port=5000)
