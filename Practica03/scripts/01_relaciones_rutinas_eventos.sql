USE db_test;
CREATE TABLE IF NOT EXISTS tbc_categories (
 id INT AUTO_INCREMENT PRIMARY KEY, name VARCHAR(100) NOT NULL UNIQUE,
 description TEXT, status TINYINT DEFAULT 1
);
CREATE TABLE IF NOT EXISTS tbd_products_categories (
 id INT AUTO_INCREMENT PRIMARY KEY, product_id INT NOT NULL, category_id INT NOT NULL,
 UNIQUE KEY uk_product_category (product_id, category_id),
 FOREIGN KEY (product_id) REFERENCES tb_products(id),
 FOREIGN KEY (category_id) REFERENCES tbc_categories(id)
);
GRANT SELECT ON db_test.tbc_categories TO 'seller';
GRANT SELECT, INSERT, UPDATE ON db_test.tbd_products_categories TO 'seller';
DELIMITER $$
DROP TRIGGER IF EXISTS trg_tbc_categories_insert$$
CREATE TRIGGER trg_tbc_categories_insert AFTER INSERT ON tbc_categories
FOR EACH ROW BEGIN
 INSERT INTO tb_logs (table_affected,operation,db_user,description)
 VALUES ('tbc_categories','Create',USER(),CONCAT('id=',NEW.id));
END$$
DROP TRIGGER IF EXISTS trg_tbc_categories_update$$
CREATE TRIGGER trg_tbc_categories_update AFTER UPDATE ON tbc_categories
FOR EACH ROW BEGIN
 INSERT INTO tb_logs (table_affected,operation,db_user,description)
 VALUES ('tbc_categories','Update',USER(),CONCAT('id=',NEW.id));
END$$
DROP TRIGGER IF EXISTS trg_tbc_categories_delete$$
CREATE TRIGGER trg_tbc_categories_delete AFTER DELETE ON tbc_categories
FOR EACH ROW BEGIN
 INSERT INTO tb_logs (table_affected,operation,db_user,description)
 VALUES ('tbc_categories','Delete',USER(),CONCAT('id=',OLD.id));
END$$
DROP TRIGGER IF EXISTS trg_tbd_products_categories_insert$$
CREATE TRIGGER trg_tbd_products_categories_insert AFTER INSERT ON tbd_products_categories
FOR EACH ROW BEGIN
 INSERT INTO tb_logs (table_affected,operation,db_user,description)
 VALUES ('tbd_products_categories','Create',USER(),CONCAT('id=',NEW.id));
END$$
DROP TRIGGER IF EXISTS trg_tbd_products_categories_update$$
CREATE TRIGGER trg_tbd_products_categories_update AFTER UPDATE ON tbd_products_categories
FOR EACH ROW BEGIN
 INSERT INTO tb_logs (table_affected,operation,db_user,description)
 VALUES ('tbd_products_categories','Update',USER(),CONCAT('id=',NEW.id));
END$$
DROP TRIGGER IF EXISTS trg_tbd_products_categories_delete$$
CREATE TRIGGER trg_tbd_products_categories_delete AFTER DELETE ON tbd_products_categories
FOR EACH ROW BEGIN
 INSERT INTO tb_logs (table_affected,operation,db_user,description)
 VALUES ('tbd_products_categories','Delete',USER(),CONCAT('id=',OLD.id));
END$$
DROP PROCEDURE IF EXISTS sp_categorizar_producto$$
CREATE PROCEDURE sp_categorizar_producto(IN p_product_id INT, IN p_category_id INT)
SQL SECURITY INVOKER
BEGIN
 INSERT INTO tbd_products_categories (product_id,category_id) VALUES (p_product_id,p_category_id);
END$$
DROP FUNCTION IF EXISTS fn_valor_inventario$$
CREATE FUNCTION fn_valor_inventario(p_product_id INT) RETURNS DECIMAL(18,2)
READS SQL DATA SQL SECURITY INVOKER
BEGIN
 RETURN (SELECT current_price * current_stock FROM tb_products WHERE id=p_product_id);
END$$
DROP EVENT IF EXISTS ev_resumen_inventario$$
CREATE EVENT ev_resumen_inventario ON SCHEDULE EVERY 1 DAY DISABLE
DO INSERT INTO tb_logs (table_affected,operation,db_user,description)
 SELECT 'tb_products','Summary',CURRENT_USER(),CONCAT('Productos activos: ',COUNT(*))
 FROM tb_products WHERE status=b'1'$$
DELIMITER ;
GRANT EXECUTE ON PROCEDURE db_test.sp_categorizar_producto TO 'seller';
GRANT EXECUTE ON FUNCTION db_test.fn_valor_inventario TO 'seller';
