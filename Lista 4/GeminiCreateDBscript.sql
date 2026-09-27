-- ============================================================================
-- 1. DOMÍNIOS CUSTOMIZADOS (CREATE DOMAIN)
-- ============================================================================

-- Valida CPF com 11 dígitos numéricos via Expressão Regular
CREATE DOMAIN domain_cpf AS VARCHAR(11)
    CHECK (VALUE ~ '^[0-9]{11}$');

-- Valida os níveis de dificuldade permitidos para expedições
CREATE DOMAIN domain_nivel_dificuldade AS VARCHAR(20)
    CHECK (VALUE IN ('FACIL', 'MEDIO', 'DIFICIL', 'EXTREMO'));

-- ============================================================================
-- 2. CRIAÇÃO DAS TABELAS
-- ============================================================================

-- Sintaxe: PK declarada em linha (inline) e CHECK com REGEX no telefone
CREATE TABLE pessoa (
    cpf domain_cpf PRIMARY KEY,
    nome VARCHAR(100) NOT NULL,
    telefone VARCHAR(15) CHECK (telefone ~ '^\+?[0-9\s\-()]+$')
);

-- Sintaxe: PK e FK declaradas como CONSTRAINT nomeada no fim da tabela
CREATE TABLE guia (
    cpf domain_cpf,
    certificacao VARCHAR(50) NOT NULL,
    CONSTRAINT pk_guia PRIMARY KEY (cpf),
    CONSTRAINT fk_guia_pessoa FOREIGN KEY (cpf) 
        REFERENCES pessoa(cpf) ON DELETE CASCADE ON UPDATE CASCADE
);

-- Sintaxe: FK em linha diretamente na coluna
CREATE TABLE pesquisador (
    cpf domain_cpf PRIMARY KEY REFERENCES pessoa(cpf) ON DELETE CASCADE ON UPDATE CASCADE,
    especialidade VARCHAR(100) NOT NULL
);

-- Sintaxe: PK serial (auto-incremento nativo) em linha
CREATE TABLE base_operacional (
    id_base SERIAL PRIMARY KEY,
    nome VARCHAR(100) NOT NULL,
    localizacao VARCHAR(200) NOT NULL
);

-- Criada sem NOT NULL nas FKs para posterior aplicação com ALTER TABLE
CREATE TABLE expedicao (
    id_expedicao SERIAL,
    titulo VARCHAR(100) NOT NULL,
    nivel_dificuldade domain_nivel_dificuldade DEFAULT 'FACIL',
    id_base INT,
    cpf_guia domain_cpf,
    CONSTRAINT pk_expedicao PRIMARY KEY (id_expedicao),
    CONSTRAINT fk_expedicao_base FOREIGN KEY (id_base) 
        REFERENCES base_operacional(id_base) ON DELETE RESTRICT,
    CONSTRAINT fk_expedicao_guia FOREIGN KEY (cpf_guia) 
        REFERENCES guia(cpf) ON DELETE RESTRICT
);

-- Alteração para adicionar a restrição NOT NULL após a criação
ALTER TABLE expedicao 
    ALTER COLUMN id_base SET NOT NULL,
    ALTER COLUMN cpf_guia SET NOT NULL;

-- Sintaxe: PK composta e CHECKS de faixa numérica para coordenadas geográficas
CREATE TABLE ponto_observacao (
    id_expedicao INT NOT NULL,
    numero INT NOT NULL,
    latitude NUMERIC(8,6) NOT NULL CHECK (latitude BETWEEN -90.000000 AND 90.000000),
    longitude NUMERIC(9,6) NOT NULL CHECK (longitude BETWEEN -180.000000 AND 180.000000),
    CONSTRAINT pk_ponto_observacao PRIMARY KEY (id_expedicao, numero),
    CONSTRAINT fk_ponto_expedicao FOREIGN KEY (id_expedicao) 
        REFERENCES expedicao(id_expedicao) ON DELETE CASCADE
);

CREATE TABLE estacao (
    id_estacao SERIAL PRIMARY KEY,
    tipo VARCHAR(50) NOT NULL,
    descricao TEXT
);

-- Sintaxe: PK Composta Tripla e Múltiplas FKs com deleção em cascata
CREATE TABLE atua (
    cpf_pesquisador domain_cpf,
    id_expedicao INT,
    id_estacao INT,
    relatorio TEXT,
    CONSTRAINT pk_atua PRIMARY KEY (cpf_pesquisador, id_expedicao, id_estacao),
    CONSTRAINT fk_atua_pesquisador FOREIGN KEY (cpf_pesquisador) 
        REFERENCES pesquisador(cpf) ON DELETE CASCADE,
    CONSTRAINT fk_atua_expedicao FOREIGN KEY (id_expedicao) 
        REFERENCES expedicao(id_expedicao) ON DELETE CASCADE,
    CONSTRAINT fk_atua_estacao FOREIGN KEY (id_estacao) 
        REFERENCES estacao(id_estacao) ON DELETE CASCADE
);

CREATE TABLE participacao (
    cpf_pessoa domain_cpf,
    id_expedicao INT,
    data_participacao DATE NOT NULL DEFAULT CURRENT_DATE,
    CONSTRAINT pk_participacao PRIMARY KEY (cpf_pessoa, id_expedicao, data_participacao),
    CONSTRAINT fk_participacao_pessoa FOREIGN KEY (cpf_pessoa) 
        REFERENCES pessoa(cpf) ON DELETE CASCADE,
    CONSTRAINT fk_participacao_expedicao FOREIGN KEY (id_expedicao) 
        REFERENCES expedicao(id_expedicao) ON DELETE CASCADE
);

-- ============================================================================
-- 3. RECURSOS AVANÇADOS E AUTOMAÇÃO
-- ============================================================================

-- Otimização de Performance com Índices B-Tree nas Chaves Estrangeiras
CREATE INDEX idx_participacao_expedicao ON participacao(id_expedicao);
CREATE INDEX idx_ponto_coords ON ponto_observacao(latitude, longitude);

-- Automação da regra de negócio: Guia vira participante automaticamente ao criar/alterar expedição
CREATE OR REPLACE FUNCTION fn_participacao_guia_automatica()
RETURNS TRIGGER AS $$
BEGIN
    INSERT INTO participacao (cpf_pessoa, id_expedicao, data_participacao)
    VALUES (NEW.cpf_guia, NEW.id_expedicao, CURRENT_DATE)
    ON CONFLICT (cpf_pessoa, id_expedicao, data_participacao) DO NOTHING;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_participacao_guia
AFTER INSERT OR UPDATE OF cpf_guia ON expedicao
FOR EACH ROW
EXECUTE FUNCTION fn_participacao_guia_automatica();

-- Automação da regra de negócio: Pesquisador vira participante automaticamente ao atuar
CREATE OR REPLACE FUNCTION fn_participacao_pesquisador_automatica()
RETURNS TRIGGER AS $$
BEGIN
    INSERT INTO participacao (cpf_pessoa, id_expedicao, data_participacao)
    VALUES (NEW.cpf_pesquisador, NEW.id_expedicao, CURRENT_DATE)
    ON CONFLICT (cpf_pessoa, id_expedicao, data_participacao) DO NOTHING;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_participacao_pesquisador
AFTER INSERT ON atua
FOR EACH ROW
EXECUTE FUNCTION fn_participacao_pesquisador_automatica();

-- Visão (View) analítica para consolidar estatísticas das expedições
CREATE VIEW vw_resumo_expedicao AS
SELECT 
    e.id_expedicao,
    e.titulo,
    e.nivel_dificuldade,
    b.nome AS base_operacional,
    p_guia.nome AS guia_responsavel,
    COUNT(DISTINCT pt.numero) AS total_pontos_observacao,
    COUNT(DISTINCT par.cpf_pessoa) AS total_participantes
FROM expedicao e
JOIN base_operacional b ON e.id_base = b.id_base
JOIN pessoa p_guia ON e.cpf_guia = p_guia.cpf
LEFT JOIN ponto_observacao pt ON e.id_expedicao = pt.id_expedicao
LEFT JOIN participacao par ON e.id_expedicao = par.id_expedicao
GROUP BY e.id_expedicao, e.titulo, e.nivel_dificuldade, b.nome, p_guia.nome;
