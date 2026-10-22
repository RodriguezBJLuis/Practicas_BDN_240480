# Documentación de la Práctica 03: Manipulación de Datos, Relaciones, Procedimientos , Funciones y Eventos en Conexiones Remotas
## Diccionario de datos interactivo

[Abrir el diccionario web](https://rodriguezbjluis.github.io/Practicas_BDN_240480/diccionario/)

Explorador de 128 campos, 16 tablas y 45 triggers de MySQL. Incluye buscador, filtros, referencia completa por tabla, codigo de triggers, conceptos y ERD con zoom.

- [Documentacion en Releases](https://github.com/RodriguezBJLuis/Practicas_BDN_240480/releases/tag/practica03-diccionario-v1.0)
- [Diccionario Markdown](diccionario_datos.md)
- [Codigo del sitio](diccionario/)

## Registros por tabla

[Consultar los registros anonimizados](https://rodriguezbjluis.github.io/Practicas_BDN_240480/diccionario/#registros). La copia del 22 de octubre de 2026 contiene 30,071 registros: 14 usuarios, 15,012 productos y 15,045 eventos de auditoria. Las otras 13 tablas estan vacias.

La vista permite buscar y recorrer todos los registros con paginacion. No es una conexion en vivo. Los datos personales y las referencias de pago estan sustituidos, y las contrasenas se ocultan antes de exportar. El script [exportar_registros_anonimos.py](scripts/exportar_registros_anonimos.py) actualiza esta copia con consultas de solo lectura; requiere MYSQL_PWD en el entorno y el cliente MySQL.
