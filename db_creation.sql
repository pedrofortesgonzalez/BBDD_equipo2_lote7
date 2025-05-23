-- 0.Crear la base de datos
CREATE DATABASE IF NOT EXISTS tallergrupal_equipo2_lote7;
USE tallergrupal_equipo2_lote7;

-- 1. Tabla GENE
CREATE TABLE IF NOT EXISTS GENE (
    GENE_ID VARCHAR(50) PRIMARY KEY NOT NULL,  -- NOT NULL restriction
    SUMMARY TEXT NOT NULL, -- NOT NULL restriction
    CHROMOSOMIC_POSITION VARCHAR(50)
) ENGINE=InnoDB;

-- 2. Tabla SEQUENCES
CREATE TABLE IF NOT EXISTS SEQUENCE (
    SEQUENCE_ID VARCHAR(100) PRIMARY KEY NOT NULL, -- NOT NULL restriction
    POSITION_RELATIVE_TO_GENE INT NOT NULL, -- NOT NULL, positive integer
    DNA_CHAIN VARCHAR(1000) CHECK (CHAR_LENGTH(DNA_CHAIN) >= 10), 
    SEQ_TYPE VARCHAR(50)
) ENGINE=InnoDB;

-- 3. Tabla VARIANTS
CREATE TABLE IF NOT EXISTS VARIANTS (
	VAR_ID VARCHAR(50) PRIMARY KEY,
    VAR_TYPE VARCHAR(50),
    REFERENCE_ALLELE VARCHAR(1000) DEFAULT "«-»", -- DEFAULT <<.>>
    MUTATED_ALLELE VARCHAR(1000) DEFAULT "«-»", -- DEFAULT <<.>>
    POSITION_RELATIVE_TO_GENE INT NOT NULL CHECK (POSITION_RELATIVE_TO_GENE >0 )-- NOT NULL, positive integer
) ENGINE=InnoDB;

-- 4. Tabla ANNOTATIONS
CREATE TABLE IF NOT EXISTS ANNOTATIONS (
	ANNOTATION_ID VARCHAR(50) PRIMARY KEY, 
    ANNOT_TYPE VARCHAR(50),
    SUMMARY TEXT,
    RELATION_TO_GENE VARCHAR(50)
) ENGINE=InnoDB;

-- 5. Tabla STUDIES
CREATE TABLE IF NOT EXISTS STUDIES (
	DOI VARCHAR(8) PRIMARY KEY CHECK(DOI REGEXP '^[A-Za-z]{4}/[0-9]{3}$'), -- restricción 4 letras y 3 nºs
    TITLE TEXT,
    PUBLICATION_DATE DATE
) ENGINE=InnoDB;

-- 6. Tablas intermedias y claves foráneas
	-- Para "sequence" y "variants" introduzco clave foránea
ALTER TABLE SEQUENCE
ADD COLUMN GENE_ID VARCHAR(50),
ADD CONSTRAINT fk_sequence_gene FOREIGN KEY (GENE_ID) REFERENCES GENE(GENE_ID);

ALTER TABLE VARIANTS
ADD COLUMN GENE_ID VARCHAR(50),
ADD CONSTRAINT fk_variant_gene FOREIGN KEY (GENE_ID) REFERENCES GENE(GENE_ID);

	-- Tablas intermedias
CREATE TABLE IF NOT EXISTS geneannotations (
    ANNOTATION_ID VARCHAR(50),
    GENE_ID VARCHAR(50),
    PRIMARY KEY (ANNOTATION_ID, GENE_ID),
    FOREIGN KEY (ANNOTATION_ID) REFERENCES ANNOTATIONS(ANNOTATION_ID),
    FOREIGN KEY (GENE_ID) REFERENCES GENE(GENE_ID)
);

CREATE TABLE IF NOT EXISTS annotationvariant (
    ANNOTATION_ID VARCHAR(50),
    VAR_ID VARCHAR(50),
    PRIMARY KEY (ANNOTATION_ID, VAR_ID),
    FOREIGN KEY (ANNOTATION_ID) REFERENCES ANNOTATIONS(ANNOTATION_ID),
    FOREIGN KEY (VAR_ID) REFERENCES VARIANTS(VAR_ID)
);

CREATE TABLE IF NOT EXISTS genstudy (
    DOI VARCHAR(8),
    GENE_ID VARCHAR(50),
    PRIMARY KEY (DOI, GENE_ID),
    FOREIGN KEY (DOI) REFERENCES STUDIES(DOI),
    FOREIGN KEY (GENE_ID) REFERENCES GENE(GENE_ID)
);

CREATE TABLE IF NOT EXISTS variantstudy (
    DOI VARCHAR(8),
    VAR_ID VARCHAR(50),
    PRIMARY KEY (DOI, VAR_ID),
    FOREIGN KEY (DOI) REFERENCES STUDIES(DOI),
    FOREIGN KEY (VAR_ID) REFERENCES VARIANTS(VAR_ID)
);

-- 7. Introducción de datos ficticios
-- - Tablas ppales
INSERT INTO GENE (GENE_ID, SUMMARY, CHROMOSOMIC_POSITION) 
VALUES ('GENE001', 'Este gen está involucrado en la regulación del ciclo celular.', '1q23.3');

INSERT INTO SEQUENCE (SEQUENCE_ID, POSITION_RELATIVE_TO_GENE, DNA_CHAIN, SEQ_TYPE, GENE_ID) 
VALUES ('SEQ001', 123, 'ATGCGTACGTGACTGAGTCGATCGA', 'cDNA', 'GENE001');

INSERT INTO VARIANTS (VAR_ID, VAR_TYPE, REFERENCE_ALLELE, MUTATED_ALLELE, POSITION_RELATIVE_TO_GENE, GENE_ID) 
VALUES ('VAR001', 'SNP', 'A', 'G', 150, 'GENE001');

INSERT INTO ANNOTATIONS (ANNOTATION_ID, ANNOT_TYPE, SUMMARY, RELATION_TO_GENE) 
VALUES ('ANNOT001', 'Functional', 'Esta variante afecta la función de la proteína', 'GENE001');

INSERT INTO STUDIES (DOI, TITLE, PUBLICATION_DATE) 
VALUES ('GENE/123', 'Estudio sobre la función de GENE001', '2023-06-15');

-- - Tablas intermedias
-- - - Tablas intermedias
INSERT INTO annotationvariant (ANNOTATION_ID, VAR_ID)
VALUES ('ANNOT001', 'VAR001');

INSERT INTO geneannotations (ANNOTATION_ID, GENE_ID)
VALUES ('ANNOT001', 'GENE001');

INSERT INTO genstudy (DOI, GENE_ID)
VALUES ('GENE/123', 'GENE001');

INSERT INTO variantstudy (DOI, VAR_ID)
VALUES ('GENE/123', 'VAR001');
