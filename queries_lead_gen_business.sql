select * from billing;
select * from clients;
select * from sites;
select * from leads;

-- Consultas
-- 1. ¿Qué consulta ejecutaría para obtener los ingresos totales para marzo de 2012?
SELECT
  MONTHNAME(charged_datetime) as month,
  SUM(amount) as revenue
FROM
  billing
WHERE
  charged_datetime >= '2012/03/01'
  AND charged_datetime < '2012/04/01';

-- 2. ¿Qué consulta ejecutaría para obtener los ingresos totales recaudados del cliente con una identificación de 2?
SELECT
  client_id,
  SUM(amount) as total_revenue
FROM
  billing
WHERE
  client_id = 2;
-- 3. ¿Qué consulta ejecutaría para obtener todos los sitios que posee client = 10?
SELECT
  domain_name as website,
  client_id
FROM
  sites
WHERE
  client_id = 10;
-- 4. ¿Qué consulta ejecutaría para obtener el número total de sitios creados por mes por año para el cliente con una identificación de 1? 
-- ¿Qué pasa con el cliente = 20?
SELECT
  client_id,
  COUNT(domain_name) as number_of_websites,
  MONTHNAME(created_datetime) as month_created,
  YEAR(created_datetime)
FROM
  sites
WHERE
  client_id = 1
GROUP BY
  MONTHNAME(created_datetime),
  YEAR(created_datetime);
  
-- cliente 20  
SELECT
  client_id,
  COUNT(domain_name) as number_of_websites,
  MONTHNAME(created_datetime) as month_created,
  YEAR(created_datetime) as year_created
FROM
  sites
WHERE
  client_id = 20
GROUP BY
  MONTHNAME(created_datetime),
  YEAR(created_datetime);
-- 5. ¿Qué consulta ejecutaría para obtener el número total de clientes potenciales generados para cada uno de los sitios entre el 1 de enero de 2011 y el 15 de febrero de 2011?
SELECT
  sites.domain_name as website,
  COUNT(leads.first_name) as number_of_leads,
  leads.registered_datetime as date_generated
FROM
  leads
  JOIN sites ON leads.site_id = sites.site_id
WHERE
  leads.registered_datetime BETWEEN '2011-1-1'
  AND '2011-2-15'
GROUP BY sites.domain_name, leads.registered_datetime;

-- 6. ¿Qué consulta ejecutaría para obtener una lista de nombres de clientes y el número total de clientes potenciales que hemos generado para cada 
-- uno de nuestros clientes entre el 1 de enero de 2011 y el 31 de diciembre de 2011?
select concat(clients.first_name, ' ', clients.last_name) as client_name, count(leads.leads_id) as number_of_leads from clients
left join sites on clients.client_id = sites.client_id
left join leads on sites.site_id = leads.site_id
where leads.registered_datetime between '2011-1-1' AND '2011-12-31'
group by concat(clients.first_name, ' ', clients.last_name), clients.client_id
order by clients.client_id;

-- 7. ¿Qué consulta ejecutaría para obtener una lista de nombres de clientes y el número total de clientes potenciales que hemos generado para cada 
-- cliente cada mes entre los meses 1 y 6 del año 2011?
select concat(clients.first_name, ' ', clients.last_name) as client_name, count(leads.leads_id) as number_of_leads,
date_format(leads.registered_datetime, '%M') as month_generated  
from clients
join sites on clients.client_id = sites.client_id
join leads on sites.site_id = leads.site_id
where extract(month from leads.registered_datetime)>= 1
and  extract(month from leads.registered_datetime)<= 6
and date_format(leads.registered_datetime, '%Y') = '2011'
group by concat(clients.first_name, ' ', clients.last_name), leads.registered_datetime
order by leads.registered_datetime;

-- 8. ¿Qué consulta ejecutaría para obtener una lista de nombres de clientes y el número total de clientes potenciales que hemos generado para cada 
-- uno de los sitios de nuestros clientes entre el 1 de enero de 2011 y el 31 de diciembre de 2011? 
select concat(clients.first_name, ' ' , clients.last_name) as client_name, 
sites.domain_name as website,
count(leads.leads_id) as number_of_leads, 
DATE_FORMAT(max(leads.registered_datetime), "%M %e, %Y") as date_generated
from sites
join clients on sites.client_id = clients.client_id
join leads on sites.site_id = leads.site_id
where leads.registered_datetime between '2011-1-1' and '2011-12-31'
group by clients.client_id, sites.site_id
order by clients.client_id, sites.site_id;
-- 8b. Solicite esta consulta por ID de cliente. Presente una segunda consulta que muestre todos los clientes, los nombres del sitio y el número 
-- total de clientes potenciales generados en cada sitio en todo momento. 
select concat(clients.first_name, ' ' , clients.last_name) as client_name, 
coalesce(sites.domain_name, 'Sin sitios registrados') as website,
count(leads.leads_id) as number_of_leads
from clients
left join sites on clients.client_id = sites.client_id
left join leads on sites.site_id = leads.site_id
group by clients.client_id, sites.domain_name, sites.site_id
order by clients.client_id, sites.site_id;

-- 9. Escriba una sola consulta que recupere los ingresos totales recaudados de cada cliente para cada mes del año. Pídalo por ID de cliente.
select concat(clients.first_name, ' ' , clients.last_name) as client_name, 
sum(billing.amount) as Total_Revenue,
date_format(billing.charged_datetime, '%M') as month_charge,
date_format(billing.charged_datetime, '%Y') as year_charge
from billing
left join clients on billing.client_id = clients.client_id
group by clients.client_id, date_format(billing.charged_datetime, '%M'), date_format(billing.charged_datetime,'%Y') 
order by clients.client_id, date_format(billing.charged_datetime,'%Y') asc, date_format(billing.charged_datetime, '%M') asc;

-- 10. Escriba una sola consulta que recupere todos los sitios que posee cada cliente. Agrupe los resultados para que cada fila muestre un nuevo 
-- cliente. Se volverá más claro cuando agregue un nuevo campo llamado 'sitios' que tiene todos los sitios que posee el cliente. (SUGERENCIA: use GROUP_CONCAT)
select concat(clients.first_name, ' ' , clients.last_name) as client_name, 
COALESCE(group_concat(sites.domain_name separator' / '), 'Sin Sitios Registrados') as sites
from clients
left join sites on clients.client_id = sites.client_id
group by clients.client_id;