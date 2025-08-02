FROM python:3.10-slim

# התקנות מערכת כולל GDAL ו־GeoPandas
RUN apt-get update && apt-get install -y \
    gdal-bin \
    libgdal-dev \
    gcc \
    g++ \
    python3-dev \
    libpq-dev \
    libgeos-dev \
    libspatialindex-dev \
    libproj-dev \
    curl \
    && rm -rf /var/lib/apt/lists/*

# משתני סביבה ש־GDAL צריך
ENV CPLUS_INCLUDE_PATH=/usr/include/gdal
ENV C_INCLUDE_PATH=/usr/include/gdal

# תיקיית עבודה
WORKDIR /app

# העתקת הדרישות
COPY requirements.txt .

# התקנת pip והספריות
RUN pip install --upgrade pip setuptools wheel && \
    pip install numpy && \
    pip install --no-cache-dir -r requirements.txt

# העתקת קוד האפליקציה
COPY app/ ./app/

# הפעלת הקוד
CMD ["python", "app/handler.py"]
