# Usa una imagen base oficial de Python
FROM python:3.9-slim

# Establecer directorio de trabajo
WORKDIR /app

# Copia el archivo de requisitos
COPY requirements.txt .

# Instala las dependencias del archivo requirements.txt
RUN pip install --no-cache-dir -r requirements.txt

# Copia los archivos de la aplicación
COPY . .

# Ejecutar el script cuando el contenedor se inicie
CMD ["python", "create_mirror_tables.py"]
