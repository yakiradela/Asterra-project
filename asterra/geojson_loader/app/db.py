import os
import psycopg2
import json

def insert_geojson(geojson_data):
    try:
        conn = psycopg2.connect(
            dbname=os.environ['POSTGRES_DB'],
            user=os.environ['POSTGRES_USER'],
            password=os.environ['POSTGRES_PASSWORD'],
            host=os.environ['POSTGRES_HOST'], 
            port=5432
        )
        cur = conn.cursor()
        cur.execute("""
            CREATE TABLE IF NOT EXISTS geojson_data (
                    id SERIAL PRIMARY KEY,
                    data JSONB
            )
        """)
        cur.execute("INSERT INTO geojson_data (data) VALUES (%s)", [json.dumps(geojson_data)])
        conn.commit()
        cur.close()
        conn.close()
        return True 
    except Exception as e:
        print(f"DB Insert Error: {e}")
        return False
