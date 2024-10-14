-- Crear tablas para la plataforma T2f2_Data en PostgreSQL

CREATE TABLE archivos (
  id SERIAL PRIMARY KEY,
  nombre_archivo VARCHAR(255),
  tipo_archivo VARCHAR(50),
  ruta_archivo VARCHAR(500),
  fuente VARCHAR(255),
  descripcion TEXT,
  tags VARCHAR[],
  ubicacion VARCHAR(255),
  fecha_publicacion TIMESTAMP,
  coordenadas_geograficas JSONB,
  fecha_ingreso TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  estado VARCHAR(50) DEFAULT 'pendiente'
);

CREATE INDEX idx_nombre_archivo ON archivos (nombre_archivo);
CREATE INDEX idx_tipo_archivo ON archivos (tipo_archivo);

CREATE TABLE redes_sociales (
  id_red_social SERIAL PRIMARY KEY,
  id_archivo INT REFERENCES archivos(id),
  plataforma VARCHAR(50),
  id_publicacion VARCHAR(255),
  autor VARCHAR(255),
  fecha_publicacion TIMESTAMP,
  hashtags VARCHAR[],
  comentarios JSONB,
  likes INT,
  ubicacion VARCHAR(255),
  url_post VARCHAR(500),
  fecha_procesado TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE personas_detectadas (
  id_persona SERIAL PRIMARY KEY,
  id_archivo INT REFERENCES archivos(id),
  nombre_asociado VARCHAR(255),
  coordenadas_rostro JSONB,
  extracto_facial FLOAT[],
  confianza_deteccion FLOAT,
  fecha_detectado TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  id_persona_original INT,
  tipo_deteccion VARCHAR(50),
  edad_aproximada INT,
  genero VARCHAR(50)
);

CREATE INDEX idx_tipo_deteccion ON personas_detectadas (tipo_deteccion);
CREATE INDEX idx_nombre_asociado ON personas_detectadas (nombre_asociado);

CREATE TABLE objetos_detectados (
  id_objeto SERIAL PRIMARY KEY,
  id_archivo INT REFERENCES archivos(id),
  tipo_objeto VARCHAR(100),
  coordenadas_objeto JSONB,
  fecha_detectado TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_tipo_objeto ON objetos_detectados (tipo_objeto);

CREATE TABLE eventos (
  id_evento SERIAL PRIMARY KEY,
  nombre_evento VARCHAR(255),
  descripcion TEXT,
  fecha_evento TIMESTAMP,
  ubicacion_evento VARCHAR(255),
  tipo_evento VARCHAR(100)
);

-- Mover la creación de "entidades_relacionadas" aquí
CREATE TABLE entidades_relacionadas (
  id_entidad SERIAL PRIMARY KEY,
  nombre_entidad VARCHAR(255),
  tipo_entidad VARCHAR(50),
  descripcion TEXT,
  id_evento INT REFERENCES eventos(id_evento),
  fecha_aparicion TIMESTAMP
);

CREATE TABLE correlaciones (
  id_correlacion SERIAL PRIMARY KEY,
  id_archivo_origen INT REFERENCES archivos(id),
  id_archivo_relacionado INT REFERENCES archivos(id),
  id_persona INT REFERENCES personas_detectadas(id_persona),
  id_entidad INT REFERENCES entidades_relacionadas(id_entidad),
  id_evento INT REFERENCES eventos(id_evento),
  tipo_relacion VARCHAR(50),
  tipo_correlacion VARCHAR(50)
);

CREATE INDEX idx_id_entidad ON correlaciones (id_entidad);
CREATE INDEX idx_id_evento ON correlaciones (id_evento);
CREATE INDEX idx_tipo_relacion ON correlaciones (tipo_relacion);

CREATE TABLE transcripciones (
  id_transcripcion SERIAL PRIMARY KEY,
  id_archivo INT REFERENCES archivos(id),
  texto_transcripcion TEXT,
  idioma_detectado VARCHAR(50),
  numero_locutores INT,
  fecha_procesado TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  embedding_locutor FLOAT[],
  confianza_locutor FLOAT
);

CREATE TABLE imagenes_procesadas (
  id_imagen SERIAL PRIMARY KEY,
  id_archivo INT REFERENCES archivos(id),
  metadatos JSONB,
  fecha_procesado TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE videos_procesados (
  id_video SERIAL PRIMARY KEY,
  id_archivo INT REFERENCES archivos(id),
  duracion_segundos INT,
  metadatos JSONB,
  fecha_procesado TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_duracion_segundos ON videos_procesados (duracion_segundos);
