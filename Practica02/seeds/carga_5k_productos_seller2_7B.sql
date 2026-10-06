-- Desde la raíz del repositorio, conectado como adrian.gonzalez.
USE db_test;
SELECT USER() AS conexion, CURRENT_ROLE() AS rol_activo;
-- No usar REPLACE/IGNORE: una segunda carga debe fallar por ID/SKU duplicado.
-- LOCAL requiere local_infile=ON en servidor y --local-infile=1 en cliente.
LOAD DATA LOCAL INFILE 'Practica02/seeds/5000_productos.csv'
INTO TABLE tb_products
CHARACTER SET utf8mb4
FIELDS TERMINATED BY ',' OPTIONALLY ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 LINES
(id, sku, name, description, current_price, current_stock, @status, creation_date, last_update)
SET status = IF(@status = '1', b'1', b'0');
SHOW WARNINGS;
SELECT COUNT(*) AS total_productos FROM tb_products;
