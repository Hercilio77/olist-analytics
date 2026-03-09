# Análise de Vendas e Performance Logística - Olist E-commerce

## 1. O Problema

A Olist é uma plataforma de e-commerce brasileira que conecta pequenas
empresas a grandes marketplaces. Entre 2016 e 2018, a empresa cresceu
rapidamente, mas a diretoria não tinha clareza sobre o que estava
impulsionando o faturamento nem onde a operação logística estava falhando.

Sem visibilidade clara sobre regiões, categorias e prazos de entrega,
decisões estratégicas eram tomadas com base em achismo. O resultado:
oportunidades de receita perdidas e clientes insatisfeitos com atrasos.

## 2. Perguntas de Negócio

Para direcionar a análise, foram levantadas as seguintes perguntas:

- Quais regiões e estados geram mais receita para a empresa?
- Quais categorias de produtos mais contribuem para o faturamento?
- Como as vendas se comportam ao longo do tempo? Existe sazonalidade?
- Como os clientes preferem pagar?
- Os pedidos estão sendo entregues no prazo (OTIF)?
- Existe relação entre o tempo de entrega e a satisfação do cliente?
- Quais regiões concentram os maiores atrasos logísticos?

## 3. O Processo

O projeto foi desenvolvido em quatro etapas:

**Etapa 1: Limpeza e Preparação dos Dados (Python)**

Os dados brutos foram coletados do dataset público da Olist no Kaggle
em formato CSV. Utilizando Python e a biblioteca Pandas, foram feitos
o tratamento de valores nulos, a remoção de duplicatas e a padronização
dos campos para garantir consistência na análise.

**Etapa 2: Modelagem e Análise SQL (MySQL)**

Os dados tratados foram carregados em um banco de dados relacional no
MySQL. Foram criadas Views analíticas para consolidar as informações
mais importantes:

- vw_otif_revenue: faturamento, status de entrega e nota media por pedido.
- vw_performance_regional: desempenho de vendas e entrega por estado.
- vw_lead_time_breakdown: tempo de ciclo do pedido, do pagamento
  à entrega ao cliente.

**Etapa 3: ETL e Modelagem no Power BI (Power Query e DAX)**

O Power BI foi conectado ao banco MySQL. No Power Query, os campos em
inglês foram traduzidos para o portugues (ex: credit_card passou a ser
Cartao de Credito). No DAX, foram criadas colunas e medidas para agrupar
estados em regioes geograficas e calcular indicadores de negocio.

**Etapa 4: Construção do Dashboard**

O layout do dashboard foi prototipado no PowerPoint para garantir um
visual limpo e profissional. O resultado foi um painel interativo com
duas paginas e filtros globais de Regiao, Estado e Periodo.

- Pagina 1 - Visao Geral de Vendas: faturamento total, ticket medio,
  frete medio, total de pedidos, distribuicao por categoria, por estado
  e por tipo de pagamento.
- Pagina 2 - Performance Operacional: taxa de entrega no prazo (OTIF),
  evolucao da satisfacao do cliente, lead time por regiao e analise
  de atrasos.

## 4. A Solucao

O dashboard entregou respostas diretas para todas as perguntas de negocio
e revelou tres pontos de acao imediata:

**Concentracao de receita no Sudeste**
Sao Paulo representa quase 40% do faturamento. Existe espaco para crescer
no Nordeste e no Sul com campanhas de marketing e melhoria no frete para
essas regioes.

**Sazonalidade forte no Q4**
O pico de novembro (Black Friday) foi o maior do periodo e sobrecarregou
a logistica. O planejamento de estoque e capacidade de entrega para o
quarto trimestre deve ser uma prioridade anual da empresa.

**Atraso logistico derruba a satisfacao**
Regioes com maior tempo de entrega apresentam as menores notas medias.
A solucao e investir em centros de distribuicao regionais ou parcerias
com transportadoras locais para reduzir o prazo e recuperar a satisfacao
do cliente nessas areas.

---

## Ferramentas Utilizadas

- Python e Pandas: limpeza e preparacao dos dados.
- MySQL: banco de dados relacional e Views analiticas.
- Power Query: transformacoes e padronizacao (ETL).
- DAX: medidas e colunas calculadas no modelo semantico.
- Power BI e PowerPoint: visualizacao e dashboard interativo.

---

LinkedIn: linkedin.com/in/herciliofalcaoo
GitHub: github.com/herciliofalcaoo

