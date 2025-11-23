CREATE TABLE public.candidatos_unicos (
    nr_cpf_candidato TEXT NOT NULL PRIMARY KEY, 
    dt_geracao TEXT,
    hh_geracao TEXT,
    ano_eleicao INTEGER,
    cd_tipo_eleicao TEXT,
    nm_tipo_eleicao TEXT,
    nr_turno TEXT,
    cd_eleicao TEXT,
    ds_eleicao TEXT,
    dt_eleicao TEXT,
    tp_abrangencia TEXT,
    sg_uf VARCHAR(2),
    sg_ue TEXT,
    nm_ue TEXT,
    cd_cargo TEXT,
    ds_cargo TEXT,
    sq_candidato TEXT,
    nr_candidato TEXT,
    nm_candidato TEXT,
    nm_urna_candidato TEXT,
    nm_social_candidato TEXT,
    ds_email TEXT,
    cd_situacao_candidatura TEXT,
    ds_situacao_candidatura TEXT,
    tp_agremiacao TEXT,
    nr_partido TEXT,
    sg_partido TEXT,
    nm_partido TEXT,
    nr_federacao TEXT,
    nm_federacao TEXT,
    sg_federacao TEXT,
    ds_composicao_federacao TEXT,
    sq_coligacao TEXT,
    nm_coligacao TEXT,
    ds_composicao_coligacao TEXT,
    sg_uf_nascimento TEXT,
    dt_nascimento DATE, 
    nr_titulo_eleitoral_candidato TEXT,
    cd_genero TEXT,
    ds_genero TEXT,
    cd_grau_instrucao TEXT,
    ds_grau_instrucao TEXT,
    cd_estado_civil TEXT,
    ds_estado_civil TEXT,
    cd_cor_raca TEXT,
    ds_cor_raca TEXT,
    cd_ocupacao TEXT,
    ds_ocupacao TEXT,
    cd_sit_tot_turno TEXT,
    ds_sit_tot_turno TEXT,
    rn INTEGER
);


CREATE TABLE public.despesas_campanha (
    id_despesa BIGSERIAL PRIMARY KEY,
    dt_geracao TEXT,
    hh_geracao TEXT,
    ano_eleicao TEXT,
    cd_tipo_eleicao TEXT,
    nm_tipo_eleicao TEXT,
    cd_eleicao TEXT,
    ds_eleicao TEXT,
    dt_eleicao TEXT,
    st_turno TEXT,
    tp_prestacao_contas TEXT,
    dt_prestacao_contas TEXT,
    sq_prestador_contas TEXT,
    sg_uf TEXT,
    sg_ue TEXT,
    nm_ue TEXT,
    nr_cnpj_prestador_conta TEXT,
    cd_cargo TEXT,
    ds_cargo TEXT,
    sq_candidato TEXT,
    nr_candidato TEXT,
    nm_candidato TEXT,
    nr_cpf_candidato TEXT, 
    nr_cpf_vice_candidato TEXT,
    nr_partido TEXT,
    sg_partido TEXT,
    nm_partido TEXT,
    cd_tipo_fornecedor TEXT,
    ds_tipo_fornecedor TEXT,
    cd_cnae_fornecedor TEXT,
    ds_cnae_fornecedor TEXT,
    nr_cpf_cnpj_fornecedor TEXT,
    nm_fornecedor TEXT,
    nm_fornecedor_rfb TEXT,
    cd_esfera_part_fornecedor TEXT,
    ds_esfera_part_fornecedor TEXT,
    sg_uf_fornecedor TEXT,
    cd_municipio_fornecedor TEXT,
    nm_municipio_fornecedor TEXT,
    sq_candidato_fornecedor TEXT,
    nr_candidato_fornecedor TEXT,
    cd_cargo_fornecedor TEXT,
    ds_cargo_fornecedor TEXT,
    nr_partido_fornecedor TEXT,
    sg_partido_fornecedor TEXT,
    nm_partido_fornecedor TEXT,
    ds_tipo_documento TEXT,
    nr_documento TEXT,
    cd_origem_despesa TEXT,
    ds_origem_despesa TEXT,
    sq_despesa TEXT,
    dt_despesa TEXT,
    ds_despesa TEXT,
    vr_despesa_contratada NUMERIC,
    aa_eleicao INTEGER
);

CREATE TABLE public.gastos_parlamentares (
    id_gasto BIGSERIAL PRIMARY KEY,
    txnomeparlamentar TEXT,
    cpf TEXT, 
    idecadastro TEXT,
    nucarteiraparlamentar TEXT,
    nulegislatura TEXT,
    sguf TEXT,
    sgpartido TEXT,
    codlegislatura TEXT,
    numsubcota TEXT,
    txtdescricao TEXT,
    numespecificacaosubcota TEXT,
    txtdescricaoespecificacao TEXT,
    txtfornecedor TEXT,
    txtcnpjcpf TEXT,
    txtnumero TEXT,
    indtipodocumento TEXT,
    datemissao TEXT,
    vlrdocumento NUMERIC,
    vlrglosa TEXT,
    vlrliquido NUMERIC,
    nummes TEXT,
    numano TEXT,
    numparcela TEXT,
    txtpassageiro TEXT,
    txttrecho TEXT,
    numlote TEXT,
    numressarcimento TEXT,
    datpagamentorestituicao TEXT,
    vlrrestituicao TEXT,
    nudeputadoid TEXT,
    idedocumento TEXT,
    urldocumento TEXT
);

ALTER TABLE public.despesas_campanha 
ADD CONSTRAINT fk_despesas_candidato 
FOREIGN KEY (nr_cpf_candidato) REFERENCES public.candidatos_unicos (nr_cpf_candidato);

ALTER TABLE public.gastos_parlamentares 
ADD CONSTRAINT fk_gastos_candidato 
FOREIGN KEY (cpf) REFERENCES public.candidatos_unicos (nr_cpf_candidato);

--- SELECOES ---

SELECT COUNT(*) AS total_de_candidatos
FROM candidatos_unicos;

SELECT ds_cargo, COUNT(*) AS total_candidatos
FROM candidatos_unicos
GROUP BY ds_cargo
ORDER BY total_candidatos DESC;

SELECT ds_genero, COUNT(*) AS total
FROM candidatos_unicos
GROUP BY ds_genero;

SELECT SUM(vr_despesa_contratada) AS gasto_total_campanhas
FROM despesas_campanha;

SELECT nr_cpf_candidato, ds_despesa, vr_despesa_contratada
FROM despesas_campanha
ORDER BY vr_despesa_contratada DESC
LIMIT 10;

SELECT SUM(vlrliquido) AS total_gasto_parlamentar
FROM gastos_parlamentares;

SELECT txnomeparlamentar, txtdescricao, vlrliquido
FROM gastos_parlamentares
ORDER BY vlrliquido DESC
LIMIT 10;

SELECT txtdescricao, SUM(vlrliquido) AS valor_total_gasto
FROM gastos_parlamentares
GROUP BY txtdescricao
ORDER BY valor_total_gasto DESC;

-- TESTE --

-- 1 --
WITH campanha AS (
    SELECT
        -- Normaliza o CNPJ (remove ./ - etc)
        regexp_replace(nr_cpf_cnpj_fornecedor, '[^0-9]', '', 'g') AS cnpj_limpo,
        MAX(nm_fornecedor) AS nome_fornecedor_campanha,
        SUM(vr_despesa_contratada) AS total_gasto_campanha
    FROM
        despesas_campanha
    WHERE
        -- Filtra para garantir que é um CNPJ (14 dígitos)
        LENGTH(regexp_replace(nr_cpf_cnpj_fornecedor, '[^0-9]', '', 'g')) = 14
    GROUP BY
        cnpj_limpo
),
cota AS (
    SELECT
        regexp_replace(txtcnpjcpf, '[^0-9]', '', 'g') AS cnpj_limpo,
        MAX(txtfornecedor) AS nome_fornecedor_cota,
        SUM(vlrliquido) AS total_gasto_cota
    FROM
        gastos_parlamentares
    WHERE
        LENGTH(regexp_replace(txtcnpjcpf, '[^0-9]', '', 'g')) = 14
    GROUP BY
        cnpj_limpo
)
SELECT
    COALESCE(c.nome_fornecedor_cota, camp.nome_fornecedor_campanha) AS fornecedor,
    camp.total_gasto_campanha,
    c.total_gasto_cota
FROM
    campanha camp
JOIN
    cota c ON camp.cnpj_limpo = c.cnpj_limpo
ORDER BY
    c.total_gasto_cota DESC
LIMIT 20;

-- 2 --

WITH despesas_limpas AS (
    SELECT
        regexp_replace(nr_cpf_cnpj_fornecedor, '[^0-9]', '', 'g') AS cnpj_fornecedor,
        nr_cpf_candidato AS cpf_candidato,
        MAX(nm_fornecedor) AS nome_fornecedor,
        SUM(vr_despesa_contratada) AS total_gasto_campanha
    FROM
        despesas_campanha
    WHERE
        LENGTH(regexp_replace(nr_cpf_cnpj_fornecedor, '[^0-9]', '', 'g')) = 14
    GROUP BY
        cnpj_fornecedor, cpf_candidato
),
gastos_limpos AS (
    SELECT
        regexp_replace(txtcnpjcpf, '[^0-9]', '', 'g') AS cnpj_fornecedor,
        cpf AS cpf_parlamentar,
        MAX(txtfornecedor) AS nome_fornecedor,
        SUM(vlrliquido) AS total_gasto_cota
    FROM
        gastos_parlamentares
    WHERE
        LENGTH(regexp_replace(txtcnpjcpf, '[^0-9]', '', 'g')) = 14
    GROUP BY
        cnpj_fornecedor, cpf_parlamentar
)

SELECT
    c.nm_candidato AS nome_politico,
    COALESCE(d.nome_fornecedor, g.nome_fornecedor) AS nome_fornecedor,
    d.total_gasto_campanha,
    g.total_gasto_cota
FROM
    candidatos_unicos c
JOIN
    despesas_limpas d ON c.nr_cpf_candidato = d.cpf_candidato
JOIN
    gastos_limpos g ON c.nr_cpf_candidato = g.cpf_parlamentar 
                   AND d.cnpj_fornecedor = g.cnpj_fornecedor
ORDER BY
    g.total_gasto_cota DESC
LIMIT 20;