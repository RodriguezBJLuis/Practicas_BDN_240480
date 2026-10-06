# Práctica 02: Conexiones Remotas a Bases de Datos Relacionales

Autor: RodriguezBJLuis — 240480@utxicotepec.edu.mx.
MySQL 8.0+. Se conservan el respaldo original y el CSV original.

| Usuario | Rol |
|---|---|
| Jose.Luis | superadmin |
| Marco.Ramirez | admin |
| Sharely.Lilian | seller |
| Alex.Soporte | support |
| adrian.gonzalez | seller |
| ivan.ojeda | user_not_registered, sin privilegios |

## Orden de ejecución

Desde la raíz del repositorio, sustituir HOST y PUERTO por el servidor real.
Las contraseñas se introducen en el prompt de MySQL.

```bash
mysql -h HOST -P PUERTO -u root -p < Practica02/scripts/01_schema.sql
mysql -h HOST -P PUERTO -u root -p < Practica02/scripts/02_auditoria.sql
mysql -h HOST -P PUERTO -u root -p < Practica02/scripts/remote_users_privileges_creation_7A.sql
mysql -h HOST -P PUERTO -u adrian.gonzalez -p < Practica02/seeds/carga_5000_adrian.sql
mysql -h HOST -P PUERTO -u Jose.Luis -p < Practica02/queries/consultas_verificacion.sql
```

Elegir solo un archivo de usuarios: 7A y 7B son equivalentes adaptados a db_test.
La carga contiene exactamente 5,000 INSERT y debe ejecutarse sobre tb_products vacía,
sin --force. Si ocurre un error, el cliente se cierra y revierte la transacción.
La alternativa CSV es carga_5k_productos_seller2_7B.sql; no ejecutar ambas cargas.
LOAD DATA LOCAL puede transformar algunos errores en advertencias: revisar SHOW WARNINGS.

La bitácora registra USER() en cada operación real, no un nombre fijo ni CURRENT_USER()
(que dentro del trigger identifica al definidor). Para repartir los productos entre sellers,
dividir la carga sin repetir IDs y conectar cada parte como el usuario que la ejecuta.
Aquí los 5,000 se preparan para adrian.gonzalez; Sharely.Lilian conserva su rol seller.

El respaldo original solo contiene tb_users y tb_logs, sin datos. Los scripts nuevos
completan las tablas que faltan. CREATE TABLE IF NOT EXISTS no migra tablas preexistentes:
comparar SHOW CREATE TABLE antes de ejecutarlos sobre otro esquema.
Los usuarios ya existentes conservan su contraseña con CREATE USER IF NOT EXISTS.

## Evidencia pendiente de ejecución

Los datos están preparados; no se afirma que hayan sido cargados en el VPS.
Comprobar total_productos=5000 y 5000 operaciones Create atribuidas a adrian.gonzalez.
Probar con ivan.ojeda que SELECT/INSERT en db_test son rechazados.
Generar un respaldo real después de la carga:

```bash
mysqldump -h HOST -P PUERTO -u Jose.Luis -p --single-transaction --routines --events --triggers db_test > Practica02/backups/respaldo_despues_carga.sql
```
