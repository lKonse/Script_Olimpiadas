-- Database: PracticaMIA

-- DROP DATABASE "PracticaMIA";

CREATE DATABASE "PracticaMIA"
    WITH 
    OWNER = postgres
    ENCODING = 'UTF8'
    LC_COLLATE = 'es_ES.UTF-8'
    LC_CTYPE = 'es_ES.UTF-8'
    TABLESPACE = pg_default
    CONNECTION LIMIT = -1;
	
CREATE TABLE PROFESION(
	cod_prof INTEGER NOT NULL,
	nombre VARCHAR(50) UNIQUE NOT NULL,
	PRIMARY KEY(cod_prof)
);

CREATE TABLE PAIS(
	cod_pais INTEGER NOT NULL,
	nombre VARCHAR(50) UNIQUE NOT NULL 
);
ALTER TABLE PAIS ADD CONSTRAINT pais_pk PRIMARY KEY (cod_pais);

CREATE TABLE PUESTO(
	cod_puesto INTEGER NOT NULL,
	nombre VARCHAR(50) UNIQUE NOT NULL 
);
ALTER TABLE PUESTO ADD CONSTRAINT puesto_pk PRIMARY KEY (cod_puesto);

CREATE TABLE DEPARTAMENTO(
	cod_depto INTEGER NOT NULL,
	nombre VARCHAR(50) UNIQUE NOT NULL,
	PRIMARY KEY(cod_depto)
);

CREATE TABLE MIEMBRO(
	cod_miembro INTEGER NOT NULL,
	nombre VARCHAR(100) NOT NULL,
	apellido VARCHAR(100) NOT NULL,
	edad INTEGER NOT NULL,
	telefono INTEGER NULL,
	residencia VARCHAR(100) NULL,
	PAIS_cod_pais INTEGER NOT NULL,
	PROFESION_cod_prof INTEGER NOT NULL,
	
	PRIMARY KEY(cod_miembro),
	FOREIGN KEY (PAIS_cod_pais) REFERENCES PAIS(cod_pais) ON DELETE CASCADE,
	FOREIGN KEY (PROFESION_cod_prof) REFERENCES PROFESION(cod_prof) ON DELETE CASCADE
);

CREATE TABLE PUESTO_MIEMBRO(
	MIEMBRO_cod_miembro INTEGER NOT NULL,
	PUESTO_cod_puesto INTEGER NOT NULL,
	DEPARTAMENTO_cod_depto INTEGER NOT NULL,
	fecha_inicio DATE NOT NULL,
	fecha_fin DATE NULL,
	
	FOREIGN KEY (MIEMBRO_cod_miembro) REFERENCES MIEMBRO(cod_miembro) ON DELETE CASCADE,
	FOREIGN KEY (PUESTO_cod_puesto) REFERENCES PUESTO(cod_puesto) ON DELETE CASCADE,
	FOREIGN KEY (DEPARTAMENTO_cod_depto) REFERENCES DEPARTAMENTO(cod_depto) ON DELETE CASCADE,
	PRIMARY KEY (MIEMBRO_cod_miembro,PUESTO_cod_puesto,DEPARTAMENTO_cod_depto)
); 

CREATE TABLE TIPO_MEDALLA(
	cod_tipo INTEGER NOT NULL,
	medalla VARCHAR(20) UNIQUE NOT NULL,
	
	PRIMARY KEY(cod_tipo)
);

CREATE TABLE MEDALLERO(
	PAIS_cod_pais INTEGER NOT NULL,
	cantidad_medallas INTEGER NOT NULL,
	TIPO_MEDALLA_cod_tipo INTEGER NOT NULL,
	
	FOREIGN KEY (PAIS_cod_pais) REFERENCES PAIS(cod_pais) ON DELETE CASCADE,
	FOREIGN KEY (TIPO_MEDALLA_cod_tipo) REFERENCES TIPO_MEDALLA(cod_tipo) ON DELETE CASCADE,
	PRIMARY KEY(PAIS_cod_pais,TIPO_MEDALLA_cod_tipo)
);

CREATE TABLE DISCIPLINA(
	cod_disciplina INTEGER NOT NULL,
	nombre VARCHAR(50) NOT NULL,
	descripcion VARCHAR(150) NULL,
	
	PRIMARY KEY(cod_disciplina)
);

CREATE TABLE ATLETA(
	cod_atleta INTEGER NOT NULL,
	nombre VARCHAR(50) NOT NULL,
	apellido VARCHAR(50) NOT NULL,
	edad INTEGER NOT NULL,
	Participaciones VARCHAR(100) NOT NULL,
	DISCIPLINA_cod_disciplina INTEGER NOT NULL,
	PAIS_cod_pais INTEGER,
	
	FOREIGN KEY (DISCIPLINA_cod_disciplina) REFERENCES DISCIPLINA(cod_disciplina) ON DELETE CASCADE,
	FOREIGN KEY (PAIS_cod_pais) REFERENCES PAIS(cod_pais) ON DELETE CASCADE,
	PRIMARY KEY(cod_atleta)
);

CREATE TABLE CATEGORIA(
	cod_categoria INTEGER NOT NULL,
	categoria VARCHAR(50) NOT NULL,
	
	PRIMARY KEY(cod_categoria)
);

CREATE TABLE TIPO_PARTICIPACION(
	cod_participacion INTEGER NOT NULL,
	tipo_participacion VARCHAR(100) NOT NULL,
	
	PRIMARY KEY(cod_participacion)
);

CREATE TABLE EVENTO(
	cod_evento INTEGER NOT NULL,
	fecha DATE NOT NULL,
	ubicacion VARCHAR(50) NOT NULL,
	hora DATE NOT NULL,
	DISCIPLINA_cod_disciplina INTEGER NOT NULL,
	TIPO_PARTICIPACION_cod_participacion INTEGER NOT NULL,
	CATEGORIA_cod_categoria INTEGER NOT NULL,
	
	FOREIGN KEY (DISCIPLINA_cod_disciplina) REFERENCES DISCIPLINA(cod_disciplina) ON DELETE CASCADE,
	FOREIGN KEY (TIPO_PARTICIPACION_cod_participacion) REFERENCES TIPO_PARTICIPACION(cod_participacion) ON DELETE CASCADE,
	FOREIGN KEY (CATEGORIA_cod_categoria) REFERENCES CATEGORIA(cod_categoria) ON DELETE CASCADE,
	PRIMARY KEY(cod_evento)
);

CREATE TABLE EVENTO_ATLETA(
	ATLETA_cod_atleta INTEGER NOT NULL,
	EVENTO_cod_evento INTEGER NOT NULL,
	
	FOREIGN KEY (ATLETA_cod_atleta) REFERENCES ATLETA(cod_atleta) ON DELETE CASCADE,
	FOREIGN KEY (EVENTO_cod_evento) REFERENCES EVENTO(cod_evento) ON DELETE CASCADE,
	PRIMARY KEY(ATLETA_cod_atleta,EVENTO_cod_evento)
);

CREATE TABLE TELEVISORA(
	cod_televisora INTEGER NOT NULL,
	nombre VARCHAR(50) NOT NULL,
	
	PRIMARY KEY(cod_televisora)
);

CREATE TABLE COSTO_EVENTO(
	EVENTO_cod_evento INTEGER NOT NULL,
	TELEVISORA_cod_televisora INTEGER NOT NULL,
	Tarifa INTEGER NOT NULL,
	
	FOREIGN KEY (EVENTO_cod_evento) REFERENCES EVENTO(cod_evento) ON DELETE CASCADE,
	FOREIGN KEY (TELEVISORA_cod_televisora) REFERENCES TELEVISORA(cod_televisora) ON DELETE CASCADE,
	PRIMARY KEY(EVENTO_cod_evento)
);

-- En la tabla “Evento” se decidió que la fecha y hora se trabajaría en una sola columna
ALTER TABLE EVENTO DROP COLUMN fecha;
ALTER TABLE EVENTO DROP COLUMN hora;
ALTER TABLE EVENTO ADD fecha_hora TIMESTAMP NOT NULL;

--Todos los eventos de las olimpiadas deben ser programados del 24 de julio
--de 2020 a partir de las 9:00:00 hasta el 09 de agosto de 2020 hasta las
--20:00:00.

ALTER TABLE EVENTO 
ADD CONSTRAINT fecha_hora CHECK (fecha_hora >= '24-07-2020 09:00:00-00' AND fecha_hora <= '09-08-2020 20:00:00-00');

-- Se decidió que las ubicación de los eventos se registrarán previamente en
-- una tabla y que en la tabla “Evento” sólo se almacenara la llave foránea
CREATE TABLE SEDE(
	cod_sede INTEGER NOT NULL,
	sede VARCHAR(50) NOT NULL,
	
	PRIMARY KEY(cod_sede)
);

ALTER TABLE EVENTO ALTER COLUMN ubicacion TYPE INTEGER USING ubicacion::integer;

ALTER TABLE EVENTO 
ADD CONSTRAINT fk_SEDE_cod_sede FOREIGN KEY (ubicacion) REFERENCES SEDE(cod_sede) ON DELETE CASCADE;

--Se revisó la información de los miembros que se tienen actualmente y antes
--de que se ingresen a la base de datos el Comité desea que a los miembros
--que no tengan número telefónico se le ingrese el número por Default 0 al
--momento de ser cargados a la base de datos.

ALTER TABLE MIEMBRO
ALTER COLUMN telefono SET DEFAULT 0;

--INSERCION DE DATOS

INSERT INTO PAIS(cod_pais,nombre) 
VALUES
	(1,'Guatemala'),
	(2,'Francia'),
	(3,'Argentina'),
	(4,'Alemania'),
	(5,'Italia'),
	(6,'Brasil'),
	(7,'Estados Unidos');

INSERT INTO PROFESION(cod_prof,nombre) 
VALUES
	(1,'Médico'),
	(2,'Arquitecto'),
	(3,'Ingeniero'),
	(4,'Secretaria'),
	(5,'Auditor');
	

INSERT INTO MIEMBRO(cod_miembro,nombre,apellido,edad,
					 residencia,PAIS_cod_pais,PROFESION_cod_prof) 
VALUES
	(1,'Scott','Mitchell',32,'1092 Highland Drive Manitowoc, WI 54220',7,3);
	
INSERT INTO MIEMBRO(cod_miembro,nombre,apellido,edad,telefono,
					 residencia,PAIS_cod_pais,PROFESION_cod_prof) 
VALUES
	(2,'Fanette','Poulin',25,25075853,'49, boulevard Aristide Briand 76120 LE GRAND-QUEVILLY',2,4);
	
INSERT INTO MIEMBRO(cod_miembro,nombre,apellido,edad,
					 residencia,PAIS_cod_pais,PROFESION_cod_prof) 
VALUES
	(3,'Laura','Cunha Silva',55,'Rua Onze, 86 UberabaMG',6,5);

INSERT INTO MIEMBRO(cod_miembro,nombre,apellido,edad,telefono,
					 residencia,PAIS_cod_pais,PROFESION_cod_prof) 
VALUES
	(4,'Juan José','López',38,36985247,'26 calle 4-10 zona 11',1,2);
	
INSERT INTO MIEMBRO(cod_miembro,nombre,apellido,edad,telefono,
					 residencia,PAIS_cod_pais,PROFESION_cod_prof) 
VALUES
	(5,'Arcangela','Panicucci',39,391664921,'Via Santa Teresa, 114 90010-Geraci Siculo PA',5,1);
	
INSERT INTO MIEMBRO(cod_miembro,nombre,apellido,edad,
					 residencia,PAIS_cod_pais,PROFESION_cod_prof) 
VALUES
	(6,'Jeuel','Villalpando',31,'Acuña de Figeroa 6106 80101 Playa Pascual',3,5);
	
SELECT * FROM MIEMBRO;

INSERT INTO DISCIPLINA(cod_disciplina,nombre,descripcion) VALUES
(1,'Atletismo','Saltos de longitud y triples, de altura y con pértiga o garrocha; las pruebas de lanzamiento de martillo, jabalina y disco'),
(2,'Bádminton',NULL),
(3,'Ciclismo',NULL),
(4,'Judo','Es un arte marcial que se originó en Japón alrededor de 1880'),
(5,'Lucha',NULL),
(6,'Tenis de mesa',NULL),
(7,'Boxeo',NULL),
(8,'Natación','Está presente como deporte en los Juegos desde la primera edición de la era moderna, en Atenas, Grecia, en 1896, donde se disputo en aguas abiertas.'),
(9,'Esgrima',NULL),
(10,'Vela',NULL);

INSERT INTO TIPO_MEDALLA(cod_tipo,medalla)
VALUES
	(1,'Oro'),
	(2,'Plata'),
	(3,'Bronce'),
	(4,'PLatino');
	
INSERT INTO CATEGORIA(cod_categoria,categoria)
VALUES
	(1,'Clasificatorio'),
	(2,'Eliminatorio'),
	(3,'Final');

INSERT INTO TIPO_PARTICIPACION(cod_participacion,tipo_participacion)
VALUES
	(1,'Individual'),
	(2,'Parejas'),
	(3,'Equipos');
	
INSERT INTO MEDALLERO(PAIS_cod_pais,TIPO_MEDALLA_cod_tipo,cantidad_medallas)
VALUES
	(5,1,3),
	(2,1,5),
	(6,3,4),
	(4,4,3),
	(7,3,10),
	(3,2,8),
	(1,1,2),
	(1,4,5),
	(5,2,7);
	
INSERT INTO SEDE(cod_sede,sede)
VALUES
	(1,'Gimnasio Metropolitano de Tokio'),
	(2,'Jardín del Palacio Imperial de Tokio'),
	(3,'Gimnasio Nacional Yoyogi'),
	(4,'Nippon Budokan'),
	(5,'Estadio Olímpico');
	
INSERT INTO EVENTO(cod_evento,fecha_hora,ubicacion,DISCIPLINA_cod_disciplina,
				   TIPO_PARTICIPACION_cod_participacion,CATEGORIA_cod_categoria)
VALUES
	(1,'24-07-2020 11:00:00-00',3,2,2,1),
	(2,'26-07-2020 10:30:00-00',1,6,1,3),
	(3,'30-07-2020 18:45:00-00',5,7,1,2),
	(4,'01-08-2020 12:15:00-00',2,1,1,1),
	(5,'08-08-2020 19:35:00-00',3,2,2,1);
	
--el Comité Olímpico Internacional tomó la decisión 
--de eliminar la restricción “UNIQUE”

ALTER TABLE PAIS DROP CONSTRAINT PAIS_nombre_key;
ALTER TABLE TIPO_MEDALLA DROP CONSTRAINT TIPO_MEDALLA_medalla_key;
ALTER TABLE DEPARTAMENTO DROP CONSTRAINT DEPARTAMENTO_nombre_key;

--Después de un análisis más profundo se decidió que los Atletas pueden
--participar en varias disciplinas y no sólo en una como está reflejado
--actualmente en las tablas

ALTER TABLE ATLETA DROP COLUMN DISCIPLINA_cod_disciplina;

CREATE TABLE DISCIPLINA_ATLETA(
	ATLETA_cod_atleta INTEGER NOT NULL,
	DISCIPLINA_cod_disciplina INTEGER NOT NULL,
	
	FOREIGN KEY (ATLETA_cod_atleta) REFERENCES ATLETA(cod_atleta) ON DELETE CASCADE,
	FOREIGN KEY (DISCIPLINA_cod_disciplina) REFERENCES DISCIPLINA(cod_disciplina) ON DELETE CASCADE,
	PRIMARY KEY(ATLETA_cod_atleta,DISCIPLINA_cod_disciplina)
);

--En la tabla “Costo_Evento” se determinó que la columna “tarifa” no debe
--ser entero sino un decimal con 2 cifras de precisión.

ALTER TABLE COSTO_EVENTO
ALTER COLUMN tarifa TYPE NUMERIC(7,2) USING tarifa::numeric;

--Generar el Script que borre de la tabla “Tipo_Medalla”, el registro siguiente:4
DELETE FROM TIPO_MEDALLA WHERE cod_tipo = 4;

--Eliminar tabla de televisoras y costo_evento
DROP TABLE TELEVISORA CASCADE;
DROP TABLE COSTO_EVENTO CASCADE;

--. El comité olímpico quiere replantear las disciplinas que van a llevarse a cabo,
--por lo cual pide generar el script que elimine todos los registros contenidos
--en la tabla “DISCIPLINA”.

DELETE FROM DISCIPLINA;

--Los miembros que no tenían registrado su número de teléfono en sus
--perfiles fueron notificados, por lo que se acercaron a las instalaciones de
--Comité para actualizar sus datos.
SELECT * FROM MIEMBRO
UPDATE MIEMBRO SET telefono = 55464601 WHERE nombre = 'Laura' AND apellido = 'Cunha Silva';
UPDATE MIEMBRO SET telefono = 91514243 WHERE nombre = 'Jeuel' AND apellido = 'Villalpando';
UPDATE MIEMBRO SET telefono = 920686670 WHERE nombre = 'Scott' AND apellido = 'Mitchell';

--El Comité decidió que necesita la fotografía en la información de los atletas
--para su perfil, por lo que se debe agregar la columna “Fotografía” a la tabla
--Atleta,

ALTER TABLE ATLETA ADD COLUMN fotografia VARCHAR(150) NULL;

--Todoslos atletas que se registren deben cumplir con ser menores a 25 años.
--De lo contrario no se debe poder registrar a un atleta en la base de datos.

ALTER TABLE ATLETA ADD CONSTRAINT edad CHECK (edad < 25);









