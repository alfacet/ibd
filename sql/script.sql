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