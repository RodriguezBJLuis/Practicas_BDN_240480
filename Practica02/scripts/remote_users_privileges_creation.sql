-- MySQL 8.0+. Ejecutar como administrador después de crear las tablas.
USE db_test;   

/* ==============================================================================
   CREACIÓN DE USUARIOS REMOTOS
   ============================================================================== */
CREATE USER IF NOT EXISTS 'Jose.Luis'@'%' IDENTIFIED BY 'password123';
CREATE USER IF NOT EXISTS 'Marco.Ramirez'@'%' IDENTIFIED BY 'qwerty123';
CREATE USER IF NOT EXISTS 'Sharely.Lilian'@'%' IDENTIFIED BY 'password123';
CREATE USER IF NOT EXISTS 'Alex.Soporte'@'%' IDENTIFIED BY 'Soporte123!'; -- Usuario ficticio

/* ==============================================================================
   CREACIÓN DE ROLES
   ============================================================================== */
CREATE USER IF NOT EXISTS 'adrian.gonzalez'@'%' IDENTIFIED BY '240784';
CREATE USER IF NOT EXISTS 'ivan.ojeda'@'%' IDENTIFIED BY '240793';

CREATE ROLE IF NOT EXISTS 'superadmin', 'admin', 'support', 'seller', 'buyer', 'common', 'user_not_registered';

/* ==============================================================================
   ASIGNACIÓN DE PRIVILEGIOS A LOS ROLES
   ============================================================================== */
/* SUPERADMIN: Control total del servidor */
GRANT ALL PRIVILEGES ON *.* TO 'superadmin';

/* ADMIN: Control total de la base de datos de pruebas */
GRANT ALL PRIVILEGES ON db_test.* TO 'admin';

/* SUPPORT: Mesa de ayuda (lee todas las tablas para investigar, pero solo actualiza usuarios) */
GRANT SELECT ON db_test.* TO 'support';
GRANT UPDATE ON db_test.tb_users TO 'support';

/* SELLER: Gestiona inventario (Necesario para insertar los 5000 registros en productos) */
GRANT SELECT, INSERT, UPDATE ON db_test.tb_products TO 'seller';

/* ==============================================================================
   ASIGNACIÓN DE ROLES A USUARIOS
   ============================================================================== */
/* Jose.Luis (Tú) */
GRANT 'superadmin' TO 'Jose.Luis'@'%';

/* Marco.Ramirez (Profesor) */
GRANT 'admin' TO 'Marco.Ramirez'@'%';

/* Sharely.Lilian (Compañera) */
GRANT 'seller' TO 'Sharely.Lilian'@'%';

/* Alex.Soporte (Pruebas de soporte) */
GRANT 'support' TO 'Alex.Soporte'@'%';

/* ==============================================================================
   ACTIVACIÓN DE ROLES POR DEFECTO
   ============================================================================== */
SET DEFAULT ROLE 'superadmin' TO 'Jose.Luis'@'%';
SET DEFAULT ROLE 'admin' TO 'Marco.Ramirez'@'%';
SET DEFAULT ROLE 'seller' TO 'Sharely.Lilian'@'%';
SET DEFAULT ROLE 'support' TO 'Alex.Soporte'@'%';
GRANT 'seller' TO 'adrian.gonzalez'@'%';
SET DEFAULT ROLE 'seller' TO 'adrian.gonzalez'@'%';
-- Rol sin privilegios para probar el rechazo de operaciones.
GRANT 'user_not_registered' TO 'ivan.ojeda'@'%';
SET DEFAULT ROLE 'user_not_registered' TO 'ivan.ojeda'@'%';
