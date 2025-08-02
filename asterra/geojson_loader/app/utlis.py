import geojson

def validate_geojson(data):
    try:
        geojson_obj = geojson.loads(str(data))
        return geojson_obj.is_valid
    except Exception:
        return False
