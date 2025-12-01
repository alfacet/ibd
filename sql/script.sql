/**
 * trabalho pratico de banco de dados
 * universidade federal de minas gerais
 * * este arquivo contem todas as consultas utilizadas para a analise
 * exploratoria, critica e integrada dos dados publicos.
 */

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



/* ========================================================================== */
/* SECAO 5: ANALISE EXPLORATORIA DE DADOS                                     */
/* estatisticas descritivas, volumetria e identificacao de outliers           */
/* ========================================================================== */

/**
 * objetivo: levantar a volumetria total das tabelas.
 * usado em: secao 5.1 (tabela 6 do relatorio).
 */
SELECT COUNT(*) AS total_de_candidatos FROM candidatos_unicos;
SELECT SUM(vr_despesa_contratada) AS gasto_total_campanhas FROM despesas_campanha;
SELECT SUM(vlrliquido) AS total_gasto_parlamentar FROM gastos_parlamentares;

/**
 * objetivo: analisar a distribuicao de candidatos por cargo e genero.
 * usado em: secao 5 (analise descritiva).
 */
SELECT ds_cargo, COUNT(*) AS total_candidatos
FROM candidatos_unicos
GROUP BY ds_cargo
ORDER BY total_candidatos DESC;

SELECT ds_genero, COUNT(*) AS total
FROM candidatos_unicos
GROUP BY ds_genero;

/**
 * objetivo: identificar outliers (valores discrepantes) nos gastos.
 * usado em: secao 5 (analise de distribuicao).
 */
SELECT nr_cpf_candidato, ds_despesa, vr_despesa_contratada
FROM despesas_campanha
ORDER BY vr_despesa_contratada DESC
LIMIT 10;

SELECT txnomeparlamentar, txtdescricao, vlrliquido
FROM gastos_parlamentares
ORDER BY vlrliquido DESC
LIMIT 10;

SELECT txtdescricao, SUM(vlrliquido) AS valor_total_gasto
FROM gastos_parlamentares
GROUP BY txtdescricao
ORDER BY valor_total_gasto DESC;

/**
 * objetivo: calcular a barreira economica (custo medio para ser eleito).
 * logica: agrupa por situacao (eleito/nao eleito) usando codigos do tse.
 * usado em: secao 5 (tabela 7 do relatorio).
 */
WITH gastos_por_candidato AS (
    SELECT 
        c.nr_cpf_candidato,
        CASE 
            WHEN c.cd_sit_tot_turno IN ('1', '2', '3') THEN 'ELEITO'
            WHEN c.cd_sit_tot_turno = '5' THEN 'SUPLENTE'
            ELSE 'NÃO ELEITO' 
        END AS status_simplificado,
        SUM(d.vr_despesa_contratada) AS total_gasto
    FROM 
        candidatos_unicos c
    JOIN 
        despesas_campanha d ON c.nr_cpf_candidato = d.nr_cpf_candidato
    WHERE 
        c.ds_cargo LIKE '%DEPUTADO FEDERAL%'
    GROUP BY 
        c.nr_cpf_candidato, c.cd_sit_tot_turno
)
SELECT 
    status_simplificado,
    COUNT(*) AS qtd_candidatos,
    ROUND(AVG(total_gasto), 2) AS media_investimento,
    ROUND(MIN(total_gasto), 2) AS gasto_minimo,
    ROUND(MAX(total_gasto), 2) AS gasto_maximo
FROM 
    gastos_por_candidato
GROUP BY 
    status_simplificado
ORDER BY 
    media_investimento DESC;


/* ========================================================================== */
/* SECAO 6: ANALISE CRITICA DAS FONTES                                        */
/* identificacao de inconsistencias semanticas e problemas de qualidade       */
/* ========================================================================== */

/**
 * objetivo: detectar inconsistencias semanticas graves (anomalia).
 * logica: busca empresas de engenharia/construcao recebendo por marketing.
 * usado em: secao 6 (tabela 8 do relatorio).
 */
SELECT 
    txnomeparlamentar,
    txtfornecedor,
    txtcnpjcpf,
    txtdescricao AS tipo_servico,
    SUM(vlrliquido) AS total_recebido
FROM 
    gastos_parlamentares
WHERE 
    (txtfornecedor ILIKE '%ENGENHARIA%' OR txtfornecedor ILIKE '%CONSTRUTORA%')
    AND txtdescricao = 'DIVULGAÇÃO DA ATIVIDADE PARLAMENTAR.'
GROUP BY 
    txnomeparlamentar, txtfornecedor, txtcnpjcpf, txtdescricao
ORDER BY 
    total_recebido DESC;


/* ========================================================================== */
/* SECAO 7: ANALISE INTEGRADA DOS DADOS                                       */
/* cruzamento entre campanha e mandato (join entre tabelas)                   */
/* ========================================================================== */

/**
 * objetivo: identificar fornecedores que atuam nas duas pontas (visao de mercado).
 * logica: normaliza cnpj e une as tabelas para ver totais acumulados.
 * usado em: secao 7 (analise de recorrencia).
 */
WITH campanha AS (
    SELECT
        regexp_replace(nr_cpf_cnpj_fornecedor, '[^0-9]', '', 'g') AS cnpj_limpo,
        MAX(nm_fornecedor) AS nome_fornecedor_campanha,
        SUM(vr_despesa_contratada) AS total_gasto_campanha
    FROM
        despesas_campanha
    WHERE
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

/**
 * objetivo: identificar continuidade contratual (mesmo politico, mesma empresa).
 * logica: busca empresas contratadas pelo mesmo cpf na campanha e no mandato.
 * usado em: secao 7 (analise de fidelidade e figura 4).
 */
WITH despesas AS (
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
gastos AS (
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
    despesas d ON c.nr_cpf_candidato = d.cpf_candidato
JOIN
    gastos g ON c.nr_cpf_candidato = g.cpf_parlamentar 
                   AND d.cnpj_fornecedor = g.cnpj_fornecedor
ORDER BY
    g.total_gasto_cota DESC
LIMIT 50;

/**
 * objetivo: identificar escalada de valores (aumento expressivo no mandato).
 * logica: filtra casos onde o gasto publico (cota) superou o gasto de campanha.
 * usado em: secao 7 (analise de escalada de valores).
 */
WITH despesas AS (
    SELECT
        regexp_replace(nr_cpf_cnpj_fornecedor, '[^0-9]', '', 'g') AS cnpj_fornecedor,
        nr_cpf_candidato AS cpf_candidato,
        MAX(nm_fornecedor) AS nome_fornecedor,
        SUM(vr_despesa_contratada) AS total_gasto_campanha
    FROM
        despesas_campanha
    WHERE
        LENGTH(regexp_replace(nr_cpf_cnpj_fornecedor, '[^0-9]', '', 'g')) = 14
        AND vr_despesa_contratada > 0
    GROUP BY
        cnpj_fornecedor, cpf_candidato
),
gastos AS (
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
    TO_CHAR(d.total_gasto_campanha, 'L9G999G999D99') as gasto_campanha,
    TO_CHAR(g.total_gasto_cota, 'L9G999G999D99') as gasto_mandato,
    (g.total_gasto_cota - d.total_gasto_campanha) AS aumento_absoluto,
    ROUND(((g.total_gasto_cota - d.total_gasto_campanha) / d.total_gasto_campanha) * 100, 2) AS pct_aumento
FROM
    candidatos_unicos c
JOIN
    despesas d ON c.nr_cpf_candidato = d.cpf_candidato
JOIN
    gastos g ON c.nr_cpf_candidato = g.cpf_parlamentar 
                   AND d.cnpj_fornecedor = g.cnpj_fornecedor
WHERE 
    g.total_gasto_cota > d.total_gasto_campanha 
ORDER BY 
    aumento_absoluto DESC 
LIMIT 20;

/**
 * objetivo: analisar a capilaridade dos fornecedores (super-fornecedores).
 * logica: conta quantos politicos distintos cada empresa atende.
 * usado em: secao 7 (figura 5 do relatorio).
 */
WITH fornecedores_unificados AS (
    SELECT 
        regexp_replace(nr_cpf_cnpj_fornecedor, '[^0-9]', '', 'g') AS cnpj,
        nm_fornecedor AS nome,
        nr_cpf_candidato AS politico_id,
        'CAMPANHA' as origem
    FROM despesas_campanha
    WHERE LENGTH(regexp_replace(nr_cpf_cnpj_fornecedor, '[^0-9]', '', 'g')) = 14
    UNION ALL
    SELECT 
        regexp_replace(txtcnpjcpf, '[^0-9]', '', 'g') AS cnpj,
        txtfornecedor AS nome,
        cpf AS politico_id,
        'MANDATO' as origem
    FROM gastos_parlamentares
    WHERE LENGTH(regexp_replace(txtcnpjcpf, '[^0-9]', '', 'g')) = 14
)
SELECT 
    MAX(nome) as nome_fornecedor,
    cnpj,
    COUNT(DISTINCT politico_id) AS qtd_politicos_atendidos,
    COUNT(DISTINCT origem) AS atua_nas_duas_fases,
    TO_CHAR(SUM(1), '999G999') AS total_transacoes
FROM 
    fornecedores_unificados
GROUP BY 
    cnpj
HAVING 
    COUNT(DISTINCT politico_id) > 10
ORDER BY 
    qtd_politicos_atendidos DESC
LIMIT 20;