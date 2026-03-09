## Criação do Banco de Dados

CREATE DATABASE olist;
USE olist;

-- ===== Consultas ====

-- Pergunta: 1
-- Qual a quantidade de registros?
-- ======


SELECT 
	COUNT(*) AS total_registros
FROM analytics;

-- Pergunta: 2
-- Quantos pedidos completos foram feitos?
-- ======

SELECT
	order_complete,
	COUNT(*) AS quantidade,
	ROUND(COUNT(*) * 100 / SUM(COUNT(*)) OVER(), 2) AS percentual
FROM analytics
GROUP BY order_complete;

-- Pergunta: 3
-- Qual o período dos dados?
-- ======

SELECT
	MIN(order_purchase_timestamp) AS primeiro_pedido,
	MAX(order_purchase_timestamp) AS ultimo_pedido
FROM analytics;

-- ===================

-- BLOCO 1 >

-- ===================

-- ANÁLISE 1.1 - Faturamento Total

-- CONTEXTO: Qual foi o faturamento total no período?
-- PROBLEMA: Identificar se o volume financeiro justifica falhas operacionais na logística.

-- ===================


SELECT
	ROUND(SUM(price + freight_value),2) AS faturamento_total
FROM analytics
WHERE order_complete = 1

-- ===================

-- ANÁLISE 1.2 — EVOLUÇÃO MENSAL DO FATURAMENTO

-- CONTEXTO: Como o faturamento se comportou mês a mês?
-- PROBLEMA: Identificar sazonalidade e tendência de crescimento.

-- ===================

SELECT 
	ROUND(SUM(price + freight_value), 2) AS faturamento,
	DATE_FORMAT(order_purchase_timestamp, '%Y-%m') AS ano_mes,
	COUNT(DISTINCT order_id) AS total_pedidos
FROM analytics
WHERE order_complete = 1
GROUP BY DATE_FORMAT(order_purchase_timestamp, '%Y-%m')
ORDER BY ano_mes ASC;

-- ====================

-- ANÁLISE 1.3 — TOP 10 CATEGORIAS POR FATURAMENTO

-- CONTEXTO: Quais categorias sustentam a receita da Olist?
-- PROBLEMA: Identificar concentração de receita em poucas categorias.

-- ====================

SELECT
	product_category_name AS categoria,
	ROUND(SUM(price+freight_value), 2) AS faturamento,
	COUNT(DISTINCT order_id) AS total_pedidos,
	ROUND(AVG(price), 2) AS ticket_medio,
	DATE_FORMAT(order_purchase_timestamp, '%Y') AS ano
FROM analytics
WHERE order_complete = 1
GROUP BY product_category_name, DATE_FORMAT(order_purchase_timestamp, '%Y')
ORDER BY faturamento DESC;

-- ====================

-- ANÁLISE 1.4 — CONCENTRAÇÃO DE RECEITA (REGRA 80/20)

-- CONTEXTO: Quantas categorias representam 80% do faturamento?
-- PROBLEMA: Identificar dependência da Olist em poucas categorias.

-- ====================

SELECT
	categoria,
	faturamento,
	ROUND(faturamento / SUM(faturamento) OVER() * 100, 2) AS pct_total,
	ROUND(SUM(faturamento) OVER (ORDER BY faturamento DESC) / SUM(faturamento) OVER () * 100, 2) AS pct_acumulado
FROM (
	SELECT
		product_category_name AS categoria,
		ROUND(SUM(price + freight_value), 2) AS faturamento
	FROM analytics
	WHERE order_complete = 1
	GROUP BY product_category_name
) t 
ORDER BY faturamento DESC
LIMIT 20; 	

-- ===================

-- BLOCO 2 >

-- ===================

-- ANÁLISE 2.1 — KPIs GERAIS DE LOGÍSTICA

-- CONTEXTO: Como foi a performance de entrega da Olist no geral?
-- PROBLEMA: Identificar o volume e proporção de atrasos.

-- ===================
SELECT
	total_pedidos,
	tempo_medio_entrega_dias,
	prazo_prometido_dias,
	pedidos_atrasados,
	ROUND(pedidos_atrasados / total_pedidos * 100, 2) AS pct_atraso
	FROM( 
		SELECT
			COUNT(DISTINCT order_id) AS total_pedidos,
			ROUND(AVG(DATEDIFF(order_delivered_customer_date, order_purchase_timestamp)), 1) AS tempo_medio_entrega_dias,
			ROUND(AVG(DATEDIFF(order_estimated_delivery_date, order_purchase_timestamp)), 1) AS prazo_prometido_dias,
			SUM(CASE 
					WHEN order_delivered_customer_date > order_estimated_delivery_date THEN 1 ELSE 0
			END) AS pedidos_atrasados
		FROM analytics
		WHERE order_complete = 1
) t;

-- ===================

-- ANÁLISE 2.2 — PERFORMANCE DE ENTREGA POR ESTADO

-- CONTEXTO: Quais estados concentram os maiores atrasos?
-- PROBLEMA: Identificar gargalos regionais na logística.

-- ===================

SELECT
	customer_state AS estado,
	COUNT(DISTINCT order_id) AS total_pedidos,
	ROUND(AVG(DATEDIFF(order_delivered_customer_date, order_purchase_timestamp)), 1) AS tempo_medio_dias,
	SUM(CASE
		WHEN order_delivered_customer_date > order_estimated_delivery_date THEN 1 ELSE 0
	END) AS atrasados,
	ROUND(SUM(CASE
		WHEN order_delivered_customer_date > order_estimated_delivery_date THEN 1 ELSE 0
	END) / COUNT(DISTINCT order_id) * 100, 2) AS pct_atraso
FROM analytics
WHERE order_complete = 1
GROUP BY customer_state
ORDER BY pct_atraso DESC;

-- ===================

-- ANÁLISE 2.3 — EVOLUÇÃO MENSAL DA TAXA DE ATRASO

-- CONTEXTO: Os atrasos pioraram conforme a empresa cresceu?
-- PROBLEMA: Confirmar se o crescimento acelerado degradou a logística.

-- ===================


SELECT
	DATE_FORMAT(order_purchase_timestamp, '%Y-%m') AS ano_mes,
	COUNT(DISTINCT order_id) AS total_pedidos,
	SUM(CASE
		WHEN order_delivered_customer_date > order_estimated_delivery_date THEN 1 ELSE 0
	END) AS atrasados,
	ROUND(SUM(CASE
		WHEN order_delivered_customer_date > order_estimated_delivery_date THEN 1 ELSE 0
	END) / COUNT(DISTINCT order_id) * 100, 2) AS pct_atraso
FROM analytics
WHERE order_complete = 1
GROUP BY ano_mes
ORDER BY ano_mes ASC;

-- ===================

-- ANÁLISE 2.4 — TAXA DE ATRASO POR CATEGORIA

-- CONTEXTO: Quais categorias têm mais problemas de entrega?
-- PROBLEMA: Identificar se produtos maiores/pesados atrasam mais.

-- ===================

SELECT
	product_category_name AS categoria,
	COUNT(DISTINCT order_id) AS total_pedidos,
	SUM(CASE
		WHEN order_delivered_customer_date > order_estimated_delivery_date THEN 1 ELSE 0
	END) AS atrasados,
	ROUND(SUM(CASE
		WHEN order_delivered_customer_date > order_estimated_delivery_date THEN 1 ELSE 0
	END) / COUNT(DISTINCT order_id) * 100, 2) AS pct_atraso,
	ROUND(AVG(freight_value), 2) AS frete_medio
FROM analytics
WHERE order_complete = 1
GROUP BY product_category_name
HAVING total_pedidos >= 100
ORDER BY pct_atraso DESC
LIMIT 15;

-- ===================

-- ANÁLISE 2.5A — ENTREGA INTRAESTADUAL vs INTERESTADUAL

-- CONTEXTO: Entregas dentro do mesmo estado são mais rápidas?
-- PROBLEMA: Validar se distância geográfica impacta atrasos.

-- ===================

SELECT
	CASE
		WHEN seller_state = customer_state THEN 'Mesmo Estado' ELSE 'Estados Diferentes'
	END AS tipo_entrega,
	COUNT(DISTINCT order_id) AS total_pedidos,
	ROUND(AVG(DATEDIFF(order_delivered_customer_date, order_purchase_timestamp)), 1) AS tempo_medio_dias,
	ROUND(AVG(freight_value), 2) AS frete_medio,
	ROUND(SUM(CASE
		WHEN order_delivered_customer_date > order_estimated_delivery_date THEN 1 ELSE 0
	END) / COUNT(DISTINCT order_id) * 100, 2) AS pct_atraso
FROM analytics
WHERE order_complete = 1
GROUP BY tipo_entrega;

-- ===================

-- ANÁLISE 2.5B — TOP 10 ROTAS (CIDADE VENDEDOR → CIDADE CLIENTE)

-- CONTEXTO: Quais rotas específicas concentram mais atrasos?
-- PROBLEMA: Identificar gargalos logísticos por origem-destino.

-- ===================

SELECT
	CONCAT(seller_city, ' (', seller_state, ')', ' > ', customer_city, ' (', customer_state, ')') AS rota,
	COUNT(DISTINCT order_id) AS total_pedidos,
	ROUND(AVG(DATEDIFF(order_delivered_customer_date, order_purchase_timestamp)), 1) AS tempo_medio_dias,
	ROUND(SUM(CASE
		WHEN order_delivered_customer_date > order_estimated_delivery_date THEN 1 ELSE 0
	END) / COUNT(DISTINCT order_id) * 100, 2) AS pct_atraso
FROM analytics
WHERE order_complete = 1
GROUP BY rota
HAVING total_pedidos >= 30
ORDER BY pct_atraso DESC
LIMIT 10;

Verdade! Segue o padrão do seu notebook:


-- ===================

-- BLOCO 3 | QUERY 3.1 — Nota Média vs. Status de Entrega

-- Objetivo: Provar que atrasos causam queda na satisfação
--           e quantificar o impacto na nota de avaliação

-- ===================

SELECT
    CASE
        WHEN DATEDIFF(order_delivered_customer_date,
                      order_estimated_delivery_date) > 0
        THEN 'Atrasado'
        ELSE 'No Prazo'
    END AS status_entrega,
    COUNT(*)                       AS total_pedidos,
    ROUND(AVG(review_score), 2)  AS nota_media,
    ROUND(MIN(review_score), 2)  AS nota_minima,
    ROUND(MAX(review_score), 2)  AS nota_maxima
FROM analytics 
WHERE order_complete = 1
GROUP BY status_entrega
ORDER BY nota_media ASC;

-- ===================

-- BLOCO 3 | QUERY 3.2 — Distribuição de Notas por Status
-- Objetivo: Identificar se pedidos atrasados concentram
--           avaliações nota 1 e confirmar padrão de churn

-- ===================

SELECT
	CASE 
		WHEN DATEDIFF(order_delivered_customer_date,
					  order_estimated_delivery_date) > 0
		THEN 'Atrasado'
		ELSE 'No Prazo'
	END AS status_entrega,
	review_score AS nota,
	COUNT(DISTINCT order_id) AS total_pedidos,
	ROUND(COUNT(DISTINCT order_id) * 100 / SUM(COUNT(DISTINCT order_id)) OVER (
	PARTITION BY CASE
		WHEN DATEDIFF(order_delivered_customer_date, order_estimated_delivery_date) > 0
		THEN 'Atrasado'
		ELSE 'No Prazo'
	END), 2) AS percentual
FROM analytics
WHERE order_complete = 1 AND review_score IS NOT null
GROUP BY status_entrega, review_score
ORDER BY status_entrega, nota;
	
-- ===================

-- BLOCO 3 | QUERY 3.3 — Nota Média por Região do Cliente
-- Objetivo: Identificar regiões com maior insatisfação
--           e cruzar com os dados de atraso do Bloco 2

-- ===================

SELECT
	CASE
		WHEN customer_state IN ('RR', 'AP', 'AM', 'PA', 'AC', 'RO', 'TO') THEN 'Norte'
		WHEN customer_state IN ('CE', 'BA', 'MA', 'RN', 'PB', 'PE', 'AL', 'SE', 'PI') THEN 'Nordeste'
		WHEN customer_state IN ('GO', 'MT', 'MS', 'DF') THEN 'Centro-Oeste'
		WHEN customer_state IN ('SP', 'RJ', 'ES', 'MG') THEN 'Sudeste'
		WHEN customer_state IN ('PR', 'SC', 'RS') THEN 'Sul'
 	END AS regiao,
 	COUNT(DISTINCT order_id) AS total_pedidos,
 	ROUND(AVG(review_score), 2) AS nota_media,
 	ROUND(SUM(CASE WHEN review_score <= 2 THEN 1 ELSE 0 
 	END) * 100.0 / COUNT(*), 2) AS pct_notas_ruins
FROM analytics
WHERE order_complete = 1 AND review_score IS NOT NULL
GROUP BY regiao 
ORDER BY nota_media ASC;


SELECT
	CASE
		WHEN customer_state IN ('CE', 'PE', 'PB', 'MA', 'SE', 'AL', 'BA', 'PI', 'RN') THEN 'Nordeste'
	END AS regiao,
	COUNT(DISTINCT order_id) AS total_pedidos,
	ROUND(SUM(payment_value), 2) AS receita_total,
	SUM(CASE
		WHEN DATEDIFF(order_delivered_customer_date, order_estimated_delivery_date) > 0 THEN 1 ELSE 0
	END) AS pedidos_atrasados,
	ROUND(SUM(CASE
		WHEN DATEDIFF(order_delivered_customer_date, order_estimated_delivery_date) > 0 THEN payment_value ELSE 0
	END) * 100 / SUM(payment_value), 2) AS pct_receita_em_risco
FROM analytics
WHERE order_complete = 1 AND customer_state IN ('CE', 'PE', 'PB', 'MA', 'SE', 'AL', 'BA', 'PI', 'RN')
GROUP BY regiao;

-- Criação das tabelas com os resultados

CREATE OR REPLACE VIEW vw_lead_time_breakdown AS
SELECT
    'Aprovação do Pagamento' AS etapa,
    ROUND(AVG(DATEDIFF(order_approved_at, order_purchase_timestamp)), 2) AS media_dias
FROM analytics
WHERE order_complete = 1
UNION ALL
SELECT
    'Preparação (Seller)',
    ROUND(AVG(DATEDIFF(order_delivered_carrier_date, order_approved_at)), 2)
FROM analytics
WHERE order_complete = 1
UNION ALL
SELECT
    'Transporte',
    ROUND(AVG(DATEDIFF(order_delivered_customer_date, order_delivered_carrier_date)), 2)
FROM analytics
WHERE order_complete = 1;

-- 2. 

CREATE OR REPLACE VIEW vw_otif_revenue AS
SELECT
    CASE
        WHEN DATEDIFF(order_delivered_customer_date,
                      order_estimated_delivery_date) > 0
        THEN 'Atrasado'
        ELSE 'No Prazo'
    END AS status_entrega,
    COUNT(*) AS total_pedidos,
    ROUND(SUM(payment_value), 2) AS receita_total,
    ROUND(AVG(review_score), 2) AS nota_media
FROM analytics
WHERE order_complete = 1
  AND review_score IS NOT NULL
GROUP BY status_entrega;

-- 3. 

CREATE OR REPLACE VIEW vw_performance_regional AS
SELECT
    CASE
        WHEN customer_state IN ('RR','AP','AM','PA','AC','RO','TO') THEN 'Norte'
        WHEN customer_state IN ('AL','BA','CE','MA','PB','PE','PI','RN','SE') THEN 'Nordeste'
        WHEN customer_state IN ('GO','MT','MS','DF') THEN 'Centro-Oeste'
        WHEN customer_state IN ('SP','RJ','ES','MG') THEN 'Sudeste'
        WHEN customer_state IN ('PR','SC','RS') THEN 'Sul'
    END AS regiao,
    COUNT(*) AS total_pedidos,
    ROUND(AVG(DATEDIFF(order_delivered_customer_date,
                       order_delivered_carrier_date)), 2) AS media_transporte_dias,
    ROUND(AVG(review_score), 2) AS nota_media,
    ROUND(SUM(CASE WHEN review_score <= 2 THEN 1 ELSE 0 END)
          * 100.0 / COUNT(*), 2) AS pct_notas_ruins
FROM analytics
WHERE order_complete = 1
  AND review_score IS NOT NULL
GROUP BY regiao;

-- 4. 

CREATE OR REPLACE VIEW vw_distribuicao_notas AS
SELECT
    CASE
        WHEN DATEDIFF(order_delivered_customer_date,
                      order_estimated_delivery_date) > 0
        THEN 'Atrasado'
        ELSE 'No Prazo'
    END AS status_entrega,
    review_score AS nota,
    COUNT(*) AS total_pedidos
FROM analytics
WHERE order_complete = 1
  AND review_score IS NOT NULL
GROUP BY status_entrega, review_score
ORDER BY status_entrega, nota;



















	






















