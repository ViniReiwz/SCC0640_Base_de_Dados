/* Descomente esta seção caso deseje remover todos os dados e começar do início, recriando 
todas as tabelas, tipos e triggers do zero. */
DROP TABLE IF EXISTS ATUA;
DROP TABLE IF EXISTS PONTO_OBSERVACAO;
DROP TABLE IF EXISTS PARTICIPACAO;
DROP TABLE IF EXISTS EXPEDICAO CASCADE;
DROP TABLE IF EXISTS ESTACAO CASCADE;
DROP TABLE IF EXISTS BASE_OPERACIONAL CASCADE;
DROP TABLE IF EXISTS PESQUISADOR CASCADE;
DROP TABLE IF EXISTS GUIA CASCADE;
DROP TABLE IF EXISTS PESSOA CASCADE;

DROP TYPE IF EXISTS guia_certif;
DROP TYPE IF EXISTS pesq_esp;
DROP TYPE IF EXISTS nivel_diff;
DROP TYPE IF EXISTS tipo_est;

DROP TRIGGER IF EXISTS trg_guia_aut_part ON EXPEDICAO;
DROP TRIGGER IF EXISTS trg_pesq_aut_part ON ATUA;
-- -- ============================================================================

-- Definição dos tipos ===========================================================
-- Tipo ENUM do certificado dos guias
CREATE TYPE guia_certif AS ENUM(
    'Iniciante',
    'Intermediario',
    'Experiente'
);

-- Tipo ENUM da especialização do pesquisador
CREATE TYPE pesq_esp AS ENUM(
    'Biologia',
    'Geologia',
    'Arqueologia',
    'Paleontologia',
    'Antropologia'
);

-- Tipo ENUM da dificuldade da espedição
CREATE TYPE nivel_diff AS ENUM(
    'Facil',
    'Medio',
    'Dificil'
);

-- Tipo ENUM do tipo da estação
CREATE TYPE tipo_est AS ENUM(
    'Descanso',
    'Pesquisa',
    'Reabastecimento'
);
-- ===============================================================================

-- Criação das tabelas e respectivas constraints =================================
-- Tablea pessoa ->> Possui CPF, nome e telefone, com CPF sendo a chave primária
CREATE TABLE PESSOA(
    CPF VARCHAR(11) PRIMARY KEY,
    NOME VARCHAR(100),
    TELEFONE VARCHAR(11)
);

-- Tabela guia ->> Possui CPF (Referenciando pessoa) como chave primária e o certificado do guia
CREATE TABLE GUIA(
    CPF VARCHAR(11) PRIMARY KEY,
    CERTIFICACAO guia_certif,

    CONSTRAINT guia_fk_pessoa 
        FOREIGN KEY (CPF) REFERENCES PESSOA(CPF)
            ON DELETE CASCADE ON UPDATE CASCADE
);

-- Tabela pesquisador ->> Possui CPF como chave primária (referencia pessoa) e a certificação do pesquisador
CREATE TABLE PESQUISADOR(
    CPF VARCHAR(11) PRIMARY KEY,
    CERTIFICACAO pesq_esp,

    CONSTRAINT pesq_fk_pessoa 
        FOREIGN KEY (CPF) REFERENCES PESSOA(CPF)
            ON DELETE CASCADE ON UPDATE CASCADE
);

-- Tabela base operacional ->> Possui ID como chave primária, nome e localização
CREATE TABLE BASE_OPERACIONAL(
    ID INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    NOME VARCHAR(100),
    LOCALIZACAO VARCHAR (100)
);

-- Tabela expedição ->> Possui id como chave primária, título, nivel de dificuldade, id da base e cpf do guia (sendo os dois últimos não-nulos) e foreign keys
CREATE TABLE EXPEDICAO(
    ID_EXPEDICAO INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    TITULO VARCHAR(20),
    NIVEL_DIFICULDADE nivel_diff,
    ID_BASE INTEGER NOT NULL,
    CPF_GUIA VARCHAR(11) UNIQUE NOT NULL,

    CONSTRAINT exped_fk_base
        FOREIGN KEY (ID_BASE) REFERENCES BASE_OPERACIONAL(ID)
            ON UPDATE CASCADE,
        
    CONSTRAINT exped_fk_guia
        FOREIGN KEY (CPF_GUIA) REFERENCES GUIA(CPF)
            ON UPDATE CASCADE
);

-- Tabela participacao ->> Possui CPF da pessao queparticipa e o ID da referente expedição (ambos compõe sua chave primária e são FKs). Além disso tem a data da participação
CREATE TABLE PARTICIPACAO(
    CPF_PESSOA VARCHAR(11),
    ID_EXPEDICAO INTEGER,
    DATA_PARTICIPACAO DATE,

    PRIMARY KEY (CPF_PESSOA, ID_EXPEDICAO),

    CONSTRAINT part_fk_pess
        FOREIGN KEY (CPF_PESSOA) REFERENCES PESSOA(CPF)
            ON DELETE CASCADE ON UPDATE CASCADE,
    
    CONSTRAINT part_fk_exp
        FOREIGN KEY (ID_EXPEDICAO) REFERENCES EXPEDICAO(ID_EXPEDICAO)
            ON DELETE CASCADE ON UPDATE CASCADE
);

-- Tabela ponto_observacao ->> Possui o id da expedicao e o número do ponto, ambos atuando como PK, sendo o primeiro uma FKs. Além disso, possui as coordenadas do ponto.
CREATE TABLE PONTO_OBSERVACAO(
    ID_EXPEDICAO INTEGER,
    NUMERO INTEGER,
    LATITUDE DOUBLE PRECISION,
    LONGITUDE DOUBLE PRECISION,

    PRIMARY KEY (ID_EXPEDICAO, NUMERO),

    CONSTRAINT po_fk_exp
        FOREIGN KEY (ID_EXPEDICAO) REFERENCES EXPEDICAO(ID_EXPEDICAO)
            ON DELETE CASCADE ON UPDATE CASCADE
);

CREATE TABLE ESTACAO(
    ID_ESTACAO INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    TIPO tipo_est,
    DESCRICAO VARCHAR(50)
);

-- Tabela atua ->> Possui o CPF do pesquisador, a expedição em que atua e a estação em que trabalha, sendo estes compositores da PK da tabela e FKs. Ainda contém o relatório do pesquisador.
CREATE TABLE ATUA(
    CPF_PESQUISADOR VARCHAR(11),
    ID_EXPEDICAO INTEGER,
    ID_ESTACAO INTEGER,
    RELATORIO VARCHAR(300),

    PRIMARY KEY (CPF_PESQUISADOR, ID_EXPEDICAO, ID_ESTACAO),

    CONSTRAINT atua_fk_pesq
        FOREIGN KEY (CPF_PESQUISADOR) REFERENCES PESQUISADOR(CPF)
            ON DELETE CASCADE ON UPDATE CASCADE,
    
    CONSTRAINT atua_fk_exp
        FOREIGN KEY (ID_EXPEDICAO) REFERENCES EXPEDICAO(ID_EXPEDICAO)
            ON DELETE CASCADE ON UPDATE CASCADE,

    CONSTRAINT atua_fk_est
        FOREIGN KEY (ID_ESTACAO) REFERENCES ESTACAO(ID_ESTACAO)
            ON DELETE CASCADE ON UPDATE CASCADE
);
-- ===============================================================================

-- Definição das funções =========================================================
CREATE OR REPLACE FUNCTION guia_participacao()
    RETURNS TRIGGER AS $$
        BEGIN
            INSERT INTO PARTICIPACAO (CPF_PESSOA, ID_EXPEDICAO) VALUES(
                NEW.CPF_GUIA,
                NEW.ID_EXPEDICAO
            );
            RETURN NULL;
        END;
    $$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION pesq_participacao()
    RETURNS TRIGGER AS $$
        BEGIN
            INSERT INTO PARTICIPACAO (CPF_PESSOA, ID_EXPEDICAO) VALUES(
                NEW.CPF_PESQUISADOR,
                NEW.ID_EXPEDICAO
            );
            RETURN NULL;
        END;
    $$ LANGUAGE plpgsql;
-- ===============================================================================

-- Definição dos triggers ========================================================
CREATE TRIGGER trg_guia_aut_part AFTER INSERT ON EXPEDICAO
    FOR EACH ROW EXECUTE FUNCTION guia_participacao();

CREATE TRIGGER trg_pesq_aut_part AFTER INSERT ON ATUA
    FOR EACH ROW EXECUTE FUNCTION pesq_participacao();
-- ===============================================================================
