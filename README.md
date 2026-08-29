 Projekt z SQL

## Autor

Karolína Šťastná

## Zadání projektu

Cílem projektu bylo vytvořit dvě výsledné tabulky:

- t_karolina_stastna_project_sql_primary_final
- t_karolina_stastna_project_sql_secondary_final

a pomocí SQL odpovědět na pět výzkumných otázek týkajících se vývoje mezd, cen potravin a ekonomických ukazatelů.

## Použité tabulky

### Primární tabulky

- czechia_payroll
- czechia_payroll_industry_branch
- czechia_payroll_calculation
- czechia_payroll_unit
- czechia_payroll_value_type
- czechia_price
- czechia_price_category

### Dodatečné tabulky

- countries
- economies

## Vytvořené tabulky

### Primární tabulka

t_karolina_stastna_project_sql_primary_final

Obsahuje:

- rok
- odvětví
- kategorii potraviny
- jednotku potraviny
- průměrnou mzdu
- průměrnou cenu potraviny

### Sekundární tabulka

t_karolina_stastna_project_sql_secondary_final

Obsahuje ekonomické ukazatele evropských států:

- stát
- rok
- HDP
- GINI
- počet obyvatel

# # Výzkumné otázky

### 1. Rostou v průběhu let mzdy ve všech odvětvích, nebo v některých klesají?

Mzdy ve sledovaném období nerostly ve všech odvětvích nepřetržitě. Bylo nalezeno 23 meziročních poklesů mezd.

### 2. Kolik je možné si koupit litrů mléka a kilogramů chleba za první a poslední srovnatelné období v dostupných datech cen a mezd?

V roce 2006 bylo možné za průměrnou mzdu koupit přibližně:
- 1 262 kg chleba
- 1 409 litrů mléka

V roce 2018:
- 1 319 kg chleba
- 1 614 litrů mléka

Kupní síla se u obou sledovaných potravin zvýšila.

### 3. Která kategorie potravin zdražuje nejpomaleji (je u ní nejnižší procentuální meziroční nárůst)?

Nejpomalejší průměrný meziroční růst měl cukr krystalový. Ve sledovaném období jeho cena v průměru klesala.

### 4. Existuje rok, ve kterém byl meziroční nárůst cen potravin výrazně vyšší než růst mezd (větší než 10 %)?

Nebyl nalezen žádný rok, ve kterém by meziroční růst cen potravin převýšil růst mezd o více než 10 %.

### 5. Má výška HDP vliv na změny ve mzdách a cenách potravin? Neboli, pokud HDP vzroste výrazněji v jednom roce, projeví se to na cenách potravin či mzdách ve stejném nebo následujícím roce výraznějším růstem?

Z porovnání stejného i následujícího roku nelze jednoznačně potvrdit, že vyšší růst HDP automaticky vede k vyššímu růstu mezd nebo cen potravin.

## Použité SQL techniky

- SELECT
- WHERE
- JOIN
- GROUP BY
- ORDER BY
- AVG()
- ROUND()
- LAG()
- CASE
- CREATE TABLE
- DROP TABLE
