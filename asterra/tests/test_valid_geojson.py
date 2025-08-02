import pytest
from geojson_loader.app.utlis import validate_geojson  

def test_valid_geojson():
    sample = {
        "type": "FeatureCollection",
        "features": [
            {
                "type": "Feature",
                "geometry": {
                    "type": "Point",
                    "coordinates": [125.6, 10.1]
                },
                "properties": {
                    "name": "Test Point"
                }
            }
        ]
    }
    assert validate_geojson(sample) is True

def test_invalid_geojson():
    sample = {
        "type": "InvalidType",
        "features": []
    }
    assert validate_geojson(sample) is False
