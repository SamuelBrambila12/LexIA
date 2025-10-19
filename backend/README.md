# LexIA Backend

API REST para clasificación de imágenes usando TensorFlow y MobileNetV2.

## Instalación

```bash
pip install -r requirements.txt
```

## Ejecutar

```bash
python main.py
# o
uvicorn main:app --host 0.0.0.0 --port 8000 --reload
```

## Endpoints

- `GET /` - Información de la API
- `GET /health` - Estado del sistema
- `POST /predict` - Clasificar una imagen
- `POST /predict/batch` - Clasificar múltiples imágenes

## Uso

```bash
curl -X POST "http://localhost:8000/predict" \
     -H "accept: application/json" \
     -H "Content-Type: multipart/form-data" \
     -F "file=@image.jpg"
```