--Exercício 1: Gênero dos Leads
--Objetivo: Criar um relatório que mostre a quantidade de leads por gênero.
--Dica: Você precisará cruzar a tabela de clientes com a tabela do IBGE. Use um LEFT JOIN e trate os nomes das colunas com lower(). 
--Use CASE WHEN para traduzir 'male' e 'female' para o português.

select 
	case 
		when ibge.gender = 'female'  then 'mulher'
		when ibge.gender = 'male'  then 'homem'
		end as "genero",
		count(*) as leads
from sales.customers cus
left join temp_tables.ibge_genders as ibge
on lower(ibge.first_name) = lower(cus.first_name)
group by 
ibge.gender

--Exercício 2: Status Profissional dos Leads
--Objetivo: Calcular a distribuição percentual dos leads de acordo com sua profissão.
--Dica: Use CASE WHEN para renomear os termos em inglês para português. Para calcular a porcentagem, 
--você precisará dividir o count(*) pelo total de registros da tabela (use uma subquery para isso). 
--Não esqueça de converter para float para evitar arredondamentos indesejados.

select * from sales.customers

select
case
	when professional_status = 'freelancer' then 'freelancer'
	when professional_status = 'retired' then 'aposentado(a)'
	when professional_status = 'clt' then 'clt'
	when professional_status = 'self_employed' then 'autônomo(a)'
	when professional_status = 'other' then 'outro' 
	when professional_status = 'businessman' then 'empresário(a)'
	when professional_status = 'civil_servant' then 'funcionário(a) público(a)'
	when professional_status = 'student' then 'estudante'
end as  "status profissional",
	count(*)::float / (select count(*) from sales.customers) as procentagem
from sales.customers
group by professional_status
order by professional_status desc

--Exercício 3: Faixa Etária dos Leads
--Objetivo: Agrupar os leads em faixas de idade (0-20, 20-40, 40-60, 60-80 e 80+) 
--e mostrar a representatividade (em %) de cada grupo.
--Dica: Use a função datediff para calcular a idade com base na birth_date. 
--Utilize CASE WHEN para criar as categorias de faixas e ordene de forma decrescente.
select
case
when datediff('year', birth_date, current_date) <=20  then '0-20'
when datediff('year', birth_date, current_date) between 20 and 40 then '20-40' 
when datediff('year', birth_date, current_date) between 40 and 60 then '40-60'
when datediff('year', birth_date, current_date) between 60 and 80 then '60-80'
else '80+'
end as "faixa etaria",
count(*)::float / (select count(*) from sales.customers) as procentagem
from sales.customers
group  by "faixa etaria"
order by "faixa etaria"


--Exercício 4: Faixa Salarial dos Leads
--Objetivo: Agrupar os leads por faixas de renda   
--(de 5.000 em 5.000) e mostrar o percentual de cada faixa.
--Dica: Além do CASE WHEN para as faixas, crie uma coluna extra chamada "ordem" 
--(também usando CASE) para garantir que o gráfico ou tabela siga a sequência lógica de valores, e não a ordem alfabética.	
select
case 
	when income < 5000 then '1'
	when income < 10000 then '2'
	when income <15000 then  '3'
	when income <20000 then  '4'
else '5' 
end as "ordem", 
case 
	when income < 5000 then '0-5000'
	when income < 10000 then '5000-10000'
	when income <15000 then  '10000-15000'
	when income <20000 then  '15000-20000'
else '20000+' 
end as "faixa salarial",
count(*)::float / (select count(*) from sales.customers) as procentagem
from sales.customers
group by 
"faixa salarial",
"ordem"
order by
"ordem"

--Exercício 5: Classificação dos Veículos Visitados
--Objetivo: Classificar as visitas no funil entre veículos "novos" 
--(até 2 anos de uso) e "seminovos" (mais de 2 anos).
--Dica: Utilize uma CTE para calcular a idade do veículo primeiro (ano da visita menos o ano do modelo). 
--Use extract('year' from ...)
--para pegar o ano da data de visita. No SELECT final, agrupe pela classificação criada.
with
	classificacao_veiculos as (
	
		select
			fun.visit_page_date,
			pro.model_year,
			extract('year' from visit_page_date) - pro.model_year::int as idade_veiculo,
			case
				when (extract('year' from visit_page_date) - pro.model_year::int)<=2 then 'novo'
				else 'seminovo'
				end as "classificação do veículo"
		
		from sales.funnel as fun
		left join sales.products as pro
			on fun.product_id = pro.product_id	
	)

select
	"classificação do veículo",
	count(*) as "veículos visitados (#)"
from classificacao_veiculos
group by "classificação do veículo"

select from sales.cus
select * from sales.funnel
select * from sales.products

-- (Query 6) Idade dos veículos visitados
-- Colunas: Idade do veículo, veículos visitados (%), ordem

with
	faixa_de_idade_dos_veiculos as (
	
		select
			fun.visit_page_date,
			pro.model_year,
			extract('year' from visit_page_date) - pro.model_year::int as idade_veiculo,
			case
				when (extract('year' from visit_page_date) - pro.model_year::int)<=2 then 'até 2 anos'
				when (extract('year' from visit_page_date) - pro.model_year::int)<=4 then 'de 2 à 4 anos'
				when (extract('year' from visit_page_date) - pro.model_year::int)<=6 then 'de 4 à 6 anos'
				when (extract('year' from visit_page_date) - pro.model_year::int)<=8 then 'de 6 à 8 anos'
				when (extract('year' from visit_page_date) - pro.model_year::int)<=10 then 'de 8 à 10 anos'
				else 'acima de 10 anos'
				end as "idade do veículo",
			case
				when (extract('year' from visit_page_date) - pro.model_year::int)<=2 then 1
				when (extract('year' from visit_page_date) - pro.model_year::int)<=4 then 2
				when (extract('year' from visit_page_date) - pro.model_year::int)<=6 then 3
				when (extract('year' from visit_page_date) - pro.model_year::int)<=8 then 4
				when (extract('year' from visit_page_date) - pro.model_year::int)<=10 then 5
				else 6
				end as "ordem"

		from sales.funnel as fun
		left join sales.products as pro
			on fun.product_id = pro.product_id	
	)

select
	"idade do veículo",
	count(*)::float/(select count(*) from sales.funnel) as "veículos visitados (%)",
	ordem
from faixa_de_idade_dos_veiculos
group by "idade do veículo", ordem
order by ordem



-- (Query 7) Veículos mais visitados por marca
-- Colunas: brand, model, visitas (#)

select
	pro.brand,
	pro.model,
	count(*) as "visitas (#)"

from sales.funnel as fun
left join sales.products as pro
	on fun.product_id = pro.product_id
group by pro.brand, pro.model
order by pro.brand, pro.model, "visitas (#)"

