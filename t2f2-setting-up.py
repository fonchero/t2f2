import os
import yaml
from sqlalchemy import create_engine, MetaData, Table, Column, Integer, String, Float, JSON, TIMESTAMP, text
from sqlalchemy.dialects.postgresql import JSONB

# Cargar variables de entorno
POSTGRES_USER = os.getenv('POSTGRES_USER')
POSTGRES_PASSWORD = os.getenv('POSTGRES_PASSWORD')
POSTGRES_HOST = os.getenv('POSTGRES_HOST')
POSTGRES_PORT = os.getenv('POSTGRES_PORT')
POSTGRES_DB = os.getenv('POSTGRES_DB')

# Construir la cadena de conexión a PostgreSQL
DATABASE_URL = f"postgresql://{POSTGRES_USER}:{POSTGRES_PASSWORD}@{POSTGRES_HOST}:{POSTGRES_PORT}/{POSTGRES_DB}"

# Crear una conexión a la base de datos usando SQLAlchemy
engine = create_engine(DATABASE_URL)
metadata = MetaData()

# Valores válidos para validación
valid_engines = ['mssql', 'postgresql', 'mysql', 'oracle', 'db2']
valid_file_sources = ['ftp', 'fileserver', 's3', 'http']
valid_file_formats = ['audio', 'video', 'image', 'document']

# Función para validar el archivo YAML
def validate_yaml_structure(config):
    # Validar externalDBs
    if "externalDBs" in config:
        for db in config["externalDBs"]:
            if db["engine"] not in valid_engines:
                raise ValueError(f"Motor de base de datos no válido en 'externalDBs -> {db['name']}': {db['engine']}. Debe ser uno de {valid_engines}")
    
    # Validar fileSources
    if "fileSources" in config:
        for source in config["fileSources"]:
            if source["source_type"] not in valid_file_sources:
                raise ValueError(f"Tipo de fuente no válido en 'fileSources -> {source['name']}': {source['source_type']}. Debe ser uno de {valid_file_sources}")
            if source["file_format"] not in valid_file_formats:
                raise ValueError(f"Formato de archivo no válido en 'fileSources -> {source['name']}': {source['file_format']}. Debe ser uno de {valid_file_formats}")
    
    # Validar procesos
    if "processes" in config:
        for process_type, process_data in config["processes"].items():
            if "process_steps" not in process_data:
                raise ValueError(f"Falta la sección 'process_steps' en el tipo de archivo {process_type}")
    
    print("Validación del YAML exitosa.")

# Función para mostrar errores con detalles de la línea
def load_yaml_with_error_details(file_path):
    try:
        with open(file_path, 'r') as yaml_file:
            return yaml.safe_load(yaml_file)
    except yaml.YAMLError as exc:
        if hasattr(exc, 'problem_mark'):
            mark = exc.problem_mark
            print(f"Error en el archivo YAML en la línea {mark.line + 1}, columna {mark.column + 1}: {exc.problem}")
        else:
            print(f"Error al procesar el archivo YAML: {exc}")
        exit(1)

# Función para crear la tabla espejo
def create_mirror_table(table_name, schema):
    columns = []
    for column_name, column_props in schema.items():
        column_type = column_props['type'].upper()
        primary_key = column_props.get('primary_key', False)

        # Mapear tipos de datos
        if column_type == "SERIAL":
            col = Column(column_name, Integer, primary_key=primary_key)
        elif column_type.startswith("VARCHAR"):
            length = int(column_type.split('(')[1].split(')')[0])  # Extraer la longitud
            col = Column(column_name, String(length))
        elif column_type == "TIMESTAMP":
            col = Column(column_name, TIMESTAMP)
        elif column_type == "FLOAT[]":
            col = Column(column_name, Float, primary_key=primary_key)
        elif column_type == "JSONB":
            col = Column(column_name, JSONB)
        else:
            col = Column(column_name, String)  # Fallback para otros tipos

        columns.append(col)

    # Crear tabla en la base de datos
    table = Table(table_name, metadata, *columns, extend_existing=True)
    metadata.create_all(engine)

# Función principal
def main():
    # Leer el archivo YAML de configuración
    config = load_yaml_with_error_details("/app/t2f2-config.yaml")

    # Validar el archivo YAML
    try:
        validate_yaml_structure(config)
    except ValueError as e:
        print(f"Error en la validación del YAML: {e}")
        exit(1)

    # Procesar las bases de datos externas desde el archivo YAML
    for external_db in config['externalDBs']:
        db_name = external_db['name']
        for table in external_db['tables']:
            for table_name, table_props in table.items():
                schema = table_props['schema']
                print(f"Creando la tabla espejo para: {table_name} en la base de datos local.")
                create_mirror_table(table_name, schema)

    print("Tablas espejo creadas exitosamente.")

# Ejecutar la función principal
if __name__ == "__main__":
    main()
