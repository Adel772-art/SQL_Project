-- Projekt z SQL 2026


-- Prohlédnutí tabulky mezd
SELECT *
FROM czechia_payroll
LIMIT 10;


-- Prohlédnutí tabulky cen potravin
SELECT *
FROM czechia_price
LIMIT 10;


-- Zjištění prvního a posledního roku v tabulce cen
SELECT
    MIN(EXTRACT(YEAR FROM date_from)) AS prvni_rok_cen,
    MAX(EXTRACT(YEAR FROM date_from)) AS posledni_rok_cen
FROM czechia_price
WHERE value IS NOT NULL;


-- Zjištění prvního a posledního roku v tabulce mezd
SELECT
    MIN(payroll_year) AS prvni_rok_mezd,
    MAX(payroll_year) AS posledni_rok_mezd
FROM czechia_payroll
WHERE value IS NOT NULL;


-- Kontrola číselníku typu mezd
SELECT *
FROM czechia_payroll_value_type;


-- Kontrola číselníku způsobu výpočtu mezd
SELECT *
FROM czechia_payroll_calculation;


-- Kontrola číselníku odvětví
SELECT *
FROM czechia_payroll_industry_branch;


-- Kontrola číselníku kategorií potravin
SELECT *
FROM czechia_price_category;


-- Výběr průměrných mezd za roky 2006–2018
SELECT
    payroll_year,
    industry_branch_code,
    value
FROM czechia_payroll
WHERE value_type_code = 5958
    AND calculation_code = 100
    AND payroll_year BETWEEN 2006 AND 2018
    AND industry_branch_code IS NOT NULL
LIMIT 20;


-- Připojení názvu odvětví
SELECT
    cp.payroll_year,
    cp.value,
    cpib.name
FROM czechia_payroll cp
JOIN czechia_payroll_industry_branch cpib
    ON cp.industry_branch_code = cpib.code
WHERE cp.value_type_code = 5958
    AND cp.calculation_code = 100
    AND cp.payroll_year BETWEEN 2006 AND 2018
    AND cp.industry_branch_code IS NOT NULL
LIMIT 20;


-- Připojení cen potravin podle roku
SELECT
    cp.payroll_year,
    cp.value,
    cpib.name,
    cpr.value
FROM czechia_payroll cp
JOIN czechia_payroll_industry_branch cpib
    ON cp.industry_branch_code = cpib.code
JOIN czechia_price cpr
    ON cp.payroll_year = EXTRACT(YEAR FROM cpr.date_from)
WHERE cp.value_type_code = 5958
    AND cp.calculation_code = 100
    AND cp.payroll_year BETWEEN 2006 AND 2018
    AND cp.industry_branch_code IS NOT NULL
LIMIT 20;


-- Připojení názvu potraviny
SELECT
    cp.payroll_year,
    cp.value,
    cpib.name,
    cpc.name,
    cpr.value
FROM czechia_payroll cp
JOIN czechia_payroll_industry_branch cpib
    ON cp.industry_branch_code = cpib.code
JOIN czechia_price cpr
    ON cp.payroll_year = EXTRACT(YEAR FROM cpr.date_from)
JOIN czechia_price_category cpc
    ON cpr.category_code = cpc.code
WHERE cp.value_type_code = 5958
    AND cp.calculation_code = 100
    AND cp.payroll_year BETWEEN 2006 AND 2018
    AND cp.industry_branch_code IS NOT NULL
LIMIT 20;


-- Výpočet průměrné mzdy podle roku
SELECT
    cp.payroll_year,
    AVG(cp.value) AS average_wage
FROM czechia_payroll cp
WHERE cp.value_type_code = 5958
    AND cp.calculation_code = 100
    AND cp.payroll_year BETWEEN 2006 AND 2018
    AND cp.industry_branch_code IS NOT NULL
GROUP BY cp.payroll_year
ORDER BY cp.payroll_year;


-- Výpočet průměrné mzdy a průměrné ceny podle roku, odvětví a potraviny
SELECT
    cp.payroll_year,
    cpib.name,
    cpc.name,
    AVG(cp.value) AS average_wage,
    AVG(cpr.value) AS average_price
FROM czechia_payroll cp
JOIN czechia_payroll_industry_branch cpib
    ON cp.industry_branch_code = cpib.code
JOIN czechia_price cpr
    ON cp.payroll_year = EXTRACT(YEAR FROM cpr.date_from)
JOIN czechia_price_category cpc
    ON cpr.category_code = cpc.code
WHERE cp.value_type_code = 5958
    AND cp.calculation_code = 100
    AND cp.payroll_year BETWEEN 2006 AND 2018
    AND cp.industry_branch_code IS NOT NULL
GROUP BY
    cp.payroll_year,
    cpib.name,
    cpc.name
ORDER BY
    cp.payroll_year,
    cpib.name,
    cpc.name;


-- Kontrola jednotek mezd
SELECT *
FROM czechia_payroll_unit;


-- Smazání tabulky pro její nové vytvoření
DROP TABLE IF EXISTS t_karolina_stastna_project_sql_primary_final;


-- Vytvoření finální primární tabulky s filtrem na mzdy v Kč
CREATE TABLE t_karolina_stastna_project_sql_primary_final AS
SELECT
    cp.payroll_year,
    cpib.name AS industry_branch,
    cpc.name AS food_category,
    cpc.price_value,
    cpc.price_unit,
    AVG(cp.value) AS average_wage,
    AVG(cpr.value) AS average_price
FROM czechia_payroll cp
JOIN czechia_payroll_industry_branch cpib
    ON cp.industry_branch_code = cpib.code
JOIN czechia_price cpr
    ON cp.payroll_year = EXTRACT(YEAR FROM cpr.date_from)
JOIN czechia_price_category cpc
    ON cpr.category_code = cpc.code
WHERE cp.value_type_code = 5958
    AND cp.unit_code = 200
    AND cp.calculation_code = 100
    AND cp.payroll_year BETWEEN 2006 AND 2018
    AND cp.industry_branch_code IS NOT NULL
GROUP BY
    cp.payroll_year,
    cpib.name,
    cpc.name,
    cpc.price_value,
    cpc.price_unit;


-- Kontrola finální primární tabulky
SELECT *
FROM t_karolina_stastna_project_sql_primary_final
LIMIT 10;


-- 1. OTÁZKA:
-- Rostou v průběhu let mzdy ve všech odvětvích,
-- nebo v některých letech a odvětvích klesají?


-- Kontrola dat z primární tabulky.
-- Mzda se zde opakuje, protože je v tabulce uvedena u každé potraviny.
SELECT
    payroll_year,
    industry_branch,
    average_wage
FROM t_karolina_stastna_project_sql_primary_final
ORDER BY
    industry_branch,
    payroll_year;


-- Výpočet jedné průměrné mzdy pro každý rok a každé odvětví.
-- GROUP BY spojí opakující se řádky, které vznikly kvůli různým potravinám.
SELECT
    payroll_year,
    industry_branch,
    AVG(average_wage) AS average_wage
FROM t_karolina_stastna_project_sql_primary_final
GROUP BY
    payroll_year,
    industry_branch
ORDER BY
    industry_branch,
    payroll_year;


-- Porovnání průměrné mzdy s předchozím rokem.
-- Funkce LAG() vrátí mzdu z předchozího roku ve stejném odvětví.
-- PARTITION BY rozdělí data podle jednotlivých odvětví.
-- ORDER BY uvnitř okna seřadí data podle roku.
SELECT
    payroll_year,
    industry_branch,
    average_wage,
    LAG(average_wage) OVER (
        PARTITION BY industry_branch
        ORDER BY payroll_year
    ) AS previous_year_wage
FROM (
    SELECT
        payroll_year,
        industry_branch,
        AVG(average_wage) AS average_wage
    FROM t_karolina_stastna_project_sql_primary_final
    GROUP BY
        payroll_year,
        industry_branch
) wages
ORDER BY
    industry_branch,
    payroll_year;


-- Určení meziročního vývoje mzdy.
-- CASE označí, zda mzda proti předchozímu roku rostla,
-- klesla, zůstala stejná, nebo jde o první dostupný rok.
SELECT
    payroll_year,
    industry_branch,
    average_wage,
    previous_year_wage,
    CASE
        WHEN previous_year_wage IS NULL THEN 'prvni rok'
        WHEN average_wage > previous_year_wage THEN 'rust'
        WHEN average_wage < previous_year_wage THEN 'pokles'
        ELSE 'beze zmeny'
    END AS wage_trend
FROM (
    SELECT
        payroll_year,
        industry_branch,
        AVG(average_wage) AS average_wage,
        LAG(AVG(average_wage)) OVER (
            PARTITION BY industry_branch
            ORDER BY payroll_year
        ) AS previous_year_wage
    FROM t_karolina_stastna_project_sql_primary_final
    GROUP BY
        payroll_year,
        industry_branch
) wages
ORDER BY
    industry_branch,
    payroll_year;


-- Výběr pouze těch roků a odvětví, ve kterých mzda
-- proti předchozímu roku klesla.
SELECT *
FROM (
    SELECT
        payroll_year,
        industry_branch,
        average_wage,
        previous_year_wage,
        CASE
            WHEN previous_year_wage IS NULL THEN 'prvni rok'
            WHEN average_wage > previous_year_wage THEN 'rust'
            WHEN average_wage < previous_year_wage THEN 'pokles'
            ELSE 'beze zmeny'
        END AS wage_trend
    FROM (
        SELECT
            payroll_year,
            industry_branch,
            AVG(average_wage) AS average_wage,
            LAG(AVG(average_wage)) OVER (
                PARTITION BY industry_branch
                ORDER BY payroll_year
            ) AS previous_year_wage
        FROM t_karolina_stastna_project_sql_primary_final
        GROUP BY
            payroll_year,
            industry_branch
    ) wages
) result
WHERE wage_trend = 'pokles'
ORDER BY
    industry_branch,
    payroll_year;


-- VÝSLEDEK:
-- Mzdy ve sledovaném období nerostly ve všech odvětvích nepřetržitě. 
-- V některých odvětvích a letech došlo oproti předchozímu roku k 
-- poklesu průměrné mzdy. 
-- Výsledný SQL dotaz zobrazil celkem 23 meziročních poklesů.


-- 2. OTÁZKA:
-- Kolik je možné si koupit litrů mléka a kilogramů chleba 
-- za první a poslední srovnatelné období v dostupných datech cen a mezd?


-- Kontrola názvů chleba a mléka
SELECT DISTINCT
    food_category
FROM t_karolina_stastna_project_sql_primary_final
ORDER BY food_category;

SELECT DISTINCT
    food_category
FROM t_karolina_stastna_project_sql_primary_final
WHERE food_category LIKE '%Mléko%'
   OR food_category LIKE '%Chléb%'
ORDER BY food_category;


-- Výpočet množství chleba a mléka, 
-- které bylo možné koupit za průměrnou mzdu
SELECT
    payroll_year,
    food_category,
    price_value,
    price_unit,
    AVG(average_wage) AS average_wage,
    AVG(average_price) AS average_price,
    AVG(average_wage) / AVG(average_price) AS quantity
FROM t_karolina_stastna_project_sql_primary_final
WHERE payroll_year IN (2006, 2018)
    AND food_category IN (
        'Chléb konzumní kmínový',
        'Mléko polotučné pasterované'
    )
GROUP BY
    payroll_year,
    food_category,
    price_value,
    price_unit
ORDER BY
    food_category,
    payroll_year;


-- VÝSLEDEK:
-- V roce 2006 bylo možné za průměrnou mzdu koupit přibližně
-- 1262 kg chleba a 1409 litrů mléka.
-- V roce 2018 bylo možné za průměrnou mzdu koupit přibližně
-- 1319 kg chleba a 1614 litrů mléka.
-- Kupní síla se mezi lety 2006 a 2018 zvýšila u obou sledovaných potravin,
-- výrazněji u mléka než u chleba.



-- 3. OTÁZKA:
-- Která kategorie potravin zdražuje nejpomaleji 
-- (je u ní nejnižší procentuální meziroční nárůst)


-- Výpočet průměrné ceny jednotlivých potravin podle roku
SELECT
    payroll_year,
    food_category,
    AVG(average_price) AS average_price
FROM t_karolina_stastna_project_sql_primary_final
GROUP BY
    payroll_year,
    food_category
ORDER BY
    food_category,
    payroll_year;


-- Získání ceny z předchozího roku pomocí funkce LAG()
SELECT
    payroll_year,
    food_category,
    average_price,
    LAG(average_price) OVER (
        PARTITION BY food_category
        ORDER BY payroll_year
    ) AS previous_price
FROM (
    SELECT
        payroll_year,
        food_category,
        AVG(average_price) AS average_price
    FROM t_karolina_stastna_project_sql_primary_final
    GROUP BY
        payroll_year,
        food_category
) prices
ORDER BY
    food_category,
    payroll_year;


-- Meziroční procentuální změna ceny potravin
SELECT
    payroll_year,
    food_category,
    average_price,
    previous_price,
    ROUND(
        (((average_price - previous_price) / previous_price) * 100)::numeric,
        2
    ) AS price_growth
FROM (
    SELECT
        payroll_year,
        food_category,
        AVG(average_price) AS average_price,
        LAG(AVG(average_price)) OVER (
            PARTITION BY food_category
            ORDER BY payroll_year
        ) AS previous_price
    FROM t_karolina_stastna_project_sql_primary_final
    GROUP BY
        payroll_year,
        food_category
) prices
WHERE previous_price IS NOT NULL
ORDER BY
    food_category,
    payroll_year;

-- Průměrný meziroční růst cen jednotlivých potravin
SELECT
    food_category,
    ROUND(AVG(price_growth)::numeric, 2) AS average_growth
FROM (
    SELECT
        payroll_year,
        food_category,
        ROUND(
            (((average_price - previous_price) / previous_price) * 100)::numeric,
            2
        ) AS price_growth
    FROM (
        SELECT
            payroll_year,
            food_category,
            AVG(average_price) AS average_price,
            LAG(AVG(average_price)) OVER (
                PARTITION BY food_category
                ORDER BY payroll_year
            ) AS previous_price
        FROM t_karolina_stastna_project_sql_primary_final
        GROUP BY
            payroll_year,
            food_category
    ) prices
    WHERE previous_price IS NOT NULL
) growth
GROUP BY
    food_category
ORDER BY
    average_growth;


-- VÝSLEDEK:
-- Nejnižší průměrný meziroční růst ceny měl cukr krystalový.
-- Jeho průměrná meziroční změna činila přibližně -1,92 %.
-- To znamená, že se jeho cena ve sledovaném období v průměru snižovala.


-- 4. OTÁZKA:
-- Existuje rok, ve kterém byl meziroční nárůst cen potravin 
-- výrazně vyšší než růst mezd (větší než 10 %)?


-- Průměrná mzda podle roku
SELECT
    payroll_year,
    AVG(average_wage) AS average_wage
FROM t_karolina_stastna_project_sql_primary_final
GROUP BY payroll_year
ORDER BY payroll_year;


-- Průměrná cena potravin podle roku
SELECT
    payroll_year,
    AVG(average_price) AS average_price
FROM t_karolina_stastna_project_sql_primary_final
GROUP BY payroll_year
ORDER BY payroll_year;



-- Přehled průměrných mezd a cen podle roku
SELECT
    payroll_year,
    AVG(average_wage) AS average_wage,
    AVG(average_price) AS average_price
FROM t_karolina_stastna_project_sql_primary_final
GROUP BY payroll_year
ORDER BY payroll_year;


-- Přidání hodnot z předchozího roku
SELECT
    payroll_year,
    average_wage,
    average_price,
    LAG(average_wage) OVER (
        ORDER BY payroll_year
    ) AS previous_wage,
    LAG(average_price) OVER (
        ORDER BY payroll_year
    ) AS previous_price
FROM (
    SELECT
        payroll_year,
        AVG(average_wage) AS average_wage,
        AVG(average_price) AS average_price
    FROM t_karolina_stastna_project_sql_primary_final
    GROUP BY payroll_year
) data
ORDER BY payroll_year;


-- Meziroční růst mezd a cen v procentech
SELECT
    payroll_year,
    average_wage,
    average_price,
    previous_wage,
    previous_price,
    ROUND(
        (((average_wage - previous_wage) / previous_wage) * 100)::numeric,
        2
    ) AS wage_growth,
    ROUND(
        (((average_price - previous_price) / previous_price) * 100)::numeric,
        2
    ) AS price_growth
FROM (
    SELECT
        payroll_year,
        AVG(average_wage) AS average_wage,
        AVG(average_price) AS average_price,
        LAG(AVG(average_wage)) OVER (
            ORDER BY payroll_year
        ) AS previous_wage,
        LAG(AVG(average_price)) OVER (
            ORDER BY payroll_year
        ) AS previous_price
    FROM t_karolina_stastna_project_sql_primary_final
    GROUP BY payroll_year
) data
WHERE previous_wage IS NOT NULL
ORDER BY payroll_year;


-- Porovnání růstu cen a mezd
SELECT
    payroll_year,
    wage_growth,
    price_growth,
    ROUND((price_growth - wage_growth)::numeric, 2) AS difference
FROM (
    SELECT
        payroll_year,
        ROUND((((average_wage - previous_wage) / previous_wage) * 100)::numeric, 2) AS wage_growth,
        ROUND((((average_price - previous_price) / previous_price) * 100)::numeric, 2) AS price_growth
    FROM (
        SELECT
            payroll_year,
            AVG(average_wage) AS average_wage,
            AVG(average_price) AS average_price,
            LAG(AVG(average_wage)) OVER (
                ORDER BY payroll_year
            ) AS previous_wage,
            LAG(AVG(average_price)) OVER (
                ORDER BY payroll_year
            ) AS previous_price
        FROM t_karolina_stastna_project_sql_primary_final
        GROUP BY payroll_year
    ) data
    WHERE previous_wage IS NOT NULL
) growth
ORDER BY payroll_year;



-- VÝSLEDEK:
-- Ve sledovaném období 2006–2018 nenastal žádný rok,
-- ve kterém by meziroční růst cen potravin převýšil růst mezd
-- o více než 10 %.
-- Nejvyšší rozdíl nastal v roce 2013,
-- kdy ceny rostly přibližně o 6,66 % rychleji než mzdy.



-- 5. OTÁZKA:
-- Má výška HDP vliv na změny ve mzdách a cenách potravin? 
-- Neboli, pokud HDP vzroste výrazněji v jednom roce, 
-- projeví se to na cenách potravin či mzdách 
-- ve stejném nebo následujícím roce výraznějším růstem?


-- Smazání sekundární tabulky, pokud již existuje
DROP TABLE IF EXISTS t_karolina_stastna_project_sql_secondary_final;


-- Vytvoření sekundární tabulky s ekonomickými údaji evropských států
-- ve stejném období jako primární tabulka
CREATE TABLE t_karolina_stastna_project_sql_secondary_final AS
SELECT
    e.country,
    e.year,
    e.gdp,
    e.gini,
    e.population
FROM economies e
JOIN countries c
    ON e.country = c.country
WHERE c.continent = 'Europe'
    AND e.year BETWEEN 2006 AND 2018
ORDER BY
    e.country,
    e.year;


-- Kontrola sekundární tabulky
SELECT *
FROM t_karolina_stastna_project_sql_secondary_final
LIMIT 20;


-- HDP České republiky podle roku
SELECT
    country,
    year,
    gdp
FROM t_karolina_stastna_project_sql_secondary_final
WHERE country = 'Czech Republic'
ORDER BY year;


-- Meziroční růst HDP České republiky
SELECT
    year,
    gdp,
    previous_gdp,
    ROUND(
        (((gdp - previous_gdp) / previous_gdp) * 100)::numeric,
        2
    ) AS gdp_growth
FROM (
    SELECT
        year,
        gdp,
        LAG(gdp) OVER (
            ORDER BY year
        ) AS previous_gdp
    FROM t_karolina_stastna_project_sql_secondary_final
    WHERE country = 'Czech Republic'
) hdp
WHERE previous_gdp IS NOT NULL
ORDER BY year;


-- Spojení meziročního růstu HDP, mezd a cen potravin
SELECT
    hdp.year,
    hdp.gdp_growth,
    growth.wage_growth,
    growth.price_growth
FROM (
    SELECT
        year,
        ROUND(
            (((gdp - previous_gdp) / previous_gdp) * 100)::numeric,
            2
        ) AS gdp_growth
    FROM (
        SELECT
            year,
            gdp,
            LAG(gdp) OVER (
                ORDER BY year
            ) AS previous_gdp
        FROM t_karolina_stastna_project_sql_secondary_final
        WHERE country = 'Czech Republic'
    ) hdp_data
    WHERE previous_gdp IS NOT NULL
) hdp
JOIN (
    SELECT
        payroll_year,
        ROUND(
            (((average_wage - previous_wage) / previous_wage) * 100)::numeric,
            2
        ) AS wage_growth,
        ROUND(
            (((average_price - previous_price) / previous_price) * 100)::numeric,
            2
        ) AS price_growth
    FROM (
        SELECT
            payroll_year,
            AVG(average_wage) AS average_wage,
            AVG(average_price) AS average_price,
            LAG(AVG(average_wage)) OVER (
                ORDER BY payroll_year
            ) AS previous_wage,
            LAG(AVG(average_price)) OVER (
                ORDER BY payroll_year
            ) AS previous_price
        FROM t_karolina_stastna_project_sql_primary_final
        GROUP BY payroll_year
    ) growth_data
    WHERE previous_wage IS NOT NULL
) growth
    ON hdp.year = growth.payroll_year
ORDER BY hdp.year;


-- Porovnání růstu HDP s růstem mezd a cen v následujícím roce
 SELECT
    hdp.year AS gdp_year,
    hdp.gdp_growth,
    growth.payroll_year AS following_year,
    growth.wage_growth AS following_year_wage_growth,
    growth.price_growth AS following_year_price_growth
FROM (
    SELECT
        year,
        ROUND(
            (((gdp - previous_gdp) / previous_gdp) * 100)::numeric,
            2
        ) AS gdp_growth
    FROM (
        SELECT
            year,
            gdp,
            LAG(gdp) OVER (
                ORDER BY year
            ) AS previous_gdp
        FROM t_karolina_stastna_project_sql_secondary_final
        WHERE country = 'Czech Republic'
    ) hdp_data
    WHERE previous_gdp IS NOT NULL
) hdp
JOIN (
    SELECT
        payroll_year,
        ROUND(
            (((average_wage - previous_wage) / previous_wage) * 100)::numeric,
            2
        ) AS wage_growth,
        ROUND(
            (((average_price - previous_price) / previous_price) * 100)::numeric,
            2
        ) AS price_growth
    FROM (
        SELECT
            payroll_year,
            AVG(average_wage) AS average_wage,
            AVG(average_price) AS average_price,
            LAG(AVG(average_wage)) OVER (
                ORDER BY payroll_year
            ) AS previous_wage,
            LAG(AVG(average_price)) OVER (
                ORDER BY payroll_year
            ) AS previous_price
        FROM t_karolina_stastna_project_sql_primary_final
        GROUP BY payroll_year
    ) growth_data
    WHERE previous_wage IS NOT NULL
) growth
    ON hdp.year + 1 = growth.payroll_year
ORDER BY hdp.year;



-- VÝSLEDEK:
-- Při porovnání stejného i následujícího roku nelze jednoznačně potvrdit,
-- že by výraznější růst HDP automaticky vedl k výraznějšímu růstu mezd
-- nebo cen potravin.
-- V některých letech se ukazatele vyvíjely podobně.
-- Například po růstu HDP o 5,57 % v roce 2007 vzrostly
-- v roce 2008 mzdy o 8,06 % a ceny potravin o 6,19 %.
-- V jiných obdobích se však stejný vztah nepotvrdil.
-- Například po růstu HDP o 5,39 % v roce 2015 vzrostly
-- v roce 2016 mzdy o 3,66 %, ale ceny potravin klesly o 1,19 %.
-- Z výsledků tedy nevyplývá jednoznačná závislost mezi růstem HDP
-- a vývojem mezd nebo cen potravin ve stejném ani v následujícím roce.
