USE db_test;
DELIMITER $$
DROP TRIGGER IF EXISTS trg_tb_users_insert$$
CREATE TRIGGER trg_tb_users_insert AFTER INSERT ON tb_users
FOR EACH ROW BEGIN
 INSERT INTO tb_logs (table_affected, operation, db_user, description)
 VALUES ('tb_users', 'Create', USER(), CONCAT('id=', NEW.id));
END$$
DROP TRIGGER IF EXISTS trg_tb_users_update$$
CREATE TRIGGER trg_tb_users_update AFTER UPDATE ON tb_users
FOR EACH ROW BEGIN
 INSERT INTO tb_logs (table_affected, operation, db_user, description)
 VALUES ('tb_users', 'Update', USER(), CONCAT('id=', NEW.id));
END$$
DROP TRIGGER IF EXISTS trg_tb_users_delete$$
CREATE TRIGGER trg_tb_users_delete AFTER DELETE ON tb_users
FOR EACH ROW BEGIN
 INSERT INTO tb_logs (table_affected, operation, db_user, description)
 VALUES ('tb_users', 'Delete', USER(), CONCAT('id=', OLD.id));
END$$
DROP TRIGGER IF EXISTS trg_tb_products_insert$$
CREATE TRIGGER trg_tb_products_insert AFTER INSERT ON tb_products
FOR EACH ROW BEGIN
 INSERT INTO tb_logs (table_affected, operation, db_user, description)
 VALUES ('tb_products', 'Create', USER(), CONCAT('id=', NEW.id));
END$$
DROP TRIGGER IF EXISTS trg_tb_products_update$$
CREATE TRIGGER trg_tb_products_update AFTER UPDATE ON tb_products
FOR EACH ROW BEGIN
 INSERT INTO tb_logs (table_affected, operation, db_user, description)
 VALUES ('tb_products', 'Update', USER(), CONCAT('id=', NEW.id));
END$$
DROP TRIGGER IF EXISTS trg_tb_products_delete$$
CREATE TRIGGER trg_tb_products_delete AFTER DELETE ON tb_products
FOR EACH ROW BEGIN
 INSERT INTO tb_logs (table_affected, operation, db_user, description)
 VALUES ('tb_products', 'Delete', USER(), CONCAT('id=', OLD.id));
END$$
DELIMITER ;
