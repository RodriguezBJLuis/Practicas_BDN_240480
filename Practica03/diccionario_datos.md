# db_test · Diccionario de datos

![db_test: 16 tablas, 128 columnas, 45 triggers y 6 dominios](https://raw.githubusercontent.com/RodriguezBJLuis/Practicas_BDN_240480/Practica03/Practica03/assets/diccionario/portada.svg)

**BASE DE DATOS EN LA NUBE · PRÁCTICA 03**  
**Edición documental 3.1 · Esquema físico verificado**

Referencia técnica del modelo de comercio electrónico: desde las credenciales y el catálogo hasta los pedidos, las direcciones y la trazabilidad de cada operación.

| Tablas físicas | Columnas documentadas | Triggers de auditoría | Áreas funcionales |
| :---: | :---: | :---: | :---: |
| **16** | **128** | **45** | **6** |

| Control del documento | Detalle |
| --- | --- |
| Proyecto | `db_test` — Base de Datos en la Nube |
| Entrega | Práctica 03 |
| Motor | MySQL 8.0 |
| Verificación | 21 de octubre de 2026 |
| Edición | 3.1 — navegación visual y consultas por evento |
| Fuente técnica | Metadatos de `information_schema` y definiciones físicas verificadas |
| Formato | Markdown UTF-8 compatible con GitHub y GitHub Pages |

> **Lectura del modelo real.** El servidor contiene **45 triggers**, aunque la consigna menciona 42. Se incluyen los 45. Los nombres y restricciones se documentan tal como existen; no se presentan tablas inexistentes como si estuvieran implementadas.

<a id="inicio"></a>

### Explorar por área

[![Seguridad y personas](https://raw.githubusercontent.com/RodriguezBJLuis/Practicas_BDN_240480/Practica03/Practica03/assets/diccionario/nav-seguridad-personas.svg)](#seguridad-personas) [![Catálogo y proveedores](https://raw.githubusercontent.com/RodriguezBJLuis/Practicas_BDN_240480/Practica03/Practica03/assets/diccionario/nav-catalogo-proveedores.svg)](#catalogo-proveedores) [![Pedidos y ventas](https://raw.githubusercontent.com/RodriguezBJLuis/Practicas_BDN_240480/Practica03/Practica03/assets/diccionario/nav-pedidos.svg)](#pedidos)  
[![Carritos y deseos](https://raw.githubusercontent.com/RodriguezBJLuis/Practicas_BDN_240480/Practica03/Practica03/assets/diccionario/nav-carritos-deseos.svg)](#carritos-deseos) [![Direcciones](https://raw.githubusercontent.com/RodriguezBJLuis/Practicas_BDN_240480/Practica03/Practica03/assets/diccionario/nav-direcciones.svg)](#direcciones) [![Métodos de pago](https://raw.githubusercontent.com/RodriguezBJLuis/Practicas_BDN_240480/Practica03/Practica03/assets/diccionario/nav-pagos.svg)](#pagos)  

**Elige un área y expande una tabla.** Cada ficha conserva las ocho columnas del diccionario. Usa los enlaces de regreso para cambiar de sección.

## Acceso rápido

- [Guía de lectura y alcance](#guia-de-lectura)
- [Inventario de las 16 tablas](#inventario)
- [Diccionario completo por columna](#diccionario)
  - [01 · Seguridad, personas y trazabilidad](#seguridad-personas)
  - [02 · Catálogo y proveedores](#catalogo-proveedores)
  - [03 · Pedidos y líneas de venta](#pedidos)
  - [04 · Carritos y listas de deseos](#carritos-deseos)
  - [05 · Direcciones y componentes](#direcciones)
  - [06 · Tipos e instrumentos de pago](#pagos)
- [Observaciones de integridad](#integridad)
- [Documentación de los 42 Triggers — inventario real: 45](#triggers)
- [Consultas de verificación](#verificacion)

## Mapa del modelo · Archify

![ERD completo de db_test: 16 tablas, claves y relaciones](https://raw.githubusercontent.com/RodriguezBJLuis/Practicas_BDN_240480/Practica03/Practica03/diagrama_erd.png)

**Cómo leerlo:** los bloques de color agrupan dominios. **PK** identifica la clave primaria, **FK** una referencia y **UK** la pertenencia a un índice único, que puede ser compuesto. Las líneas muestran las relaciones físicas; las referencias hacia índices no únicos de ofertas requieren la interpretación explicada en las observaciones de integridad.

> La autorrelación de `tbd_address_components` se expresa con la FK compuesta `(address_ID, address_sup_ID) → (address_ID, ID)`. La imagen no dibuja ese bucle. El tipo `fulfillment_status` es `ENUM('Pending','Accepted','Preparing','Sent','Delivered','Canceled','Returned')`.

### Una consulta completa, en esta página

El contenido íntegro está disponible aquí. Expande la ficha de una tabla para ver todas sus columnas, índices, relaciones y restricciones. Al final encontrarás los 45 triggers y las consultas de comprobación. No necesitas descargar ningún adjunto.

---

<a id="guia-de-lectura"></a>

## Guía de lectura, alcance y criterios de interpretación

Este documento describe el esquema físico consultado directamente en `information_schema` de `db_test`: columnas, nulabilidad, valores predeterminados, índices, claves foráneas, restricciones CHECK y cuerpos de triggers. Las descripciones funcionales se interpretan a partir de esos objetos; no convierten una convención de aplicación en una restricción de MySQL. No incluye registros de personas, contraseñas, tokens de pago ni datos de conexión.

Los nombres solicitados como ejemplos se corresponden con los nombres físicos siguientes. Una entidad inexistente no se presenta como implementada.

| Nombre de referencia | Objeto físico actual | Observación |
| --- | --- | --- |
| tb_categories | tbc_categories | Catálogo de categorías. |
| tb_seller_orders | tb_buyer_orders | Cabecera actual; no incluye buyer_id ni total_amount. |
| tb_order_items | tbd_order_items | Líneas de pedido. |
| tbd_address_componentes | tbd_address_components | Componentes jerárquicos de dirección. |
| tb_payments | No existe | Existen tipos e instrumentos de pago; no una tabla de cobros. |
| tbd_users_offer_products | tbd_products_users_providers | Relación entre producto y usuario proveedor. |

**Llave:** PK identifica una fila; FK referencia otra clave; PK, FK indica ambos papeles. N/A significa que no participa en una clave primaria ni foránea; los índices UNIQUE se detallan en el dominio y no se confunden con PK.

**Obligatoriedad:** reproduce exclusivamente NOT NULL/NULL. Una columna obligatoria con AUTO_INCREMENT, DEFAULT o expresión generada puede ser completada por MySQL sin que el cliente envíe un valor. NOT NULL no prohíbe textos vacíos.

**Naturaleza:** los identificadores y códigos, aunque tengan tipo numérico, son cualitativos nominales. Importes, cantidades, plazos y coordenadas se clasifican como cuantitativos. Fechas y horas se presentan como atributos temporales cualitativos para esta clasificación binaria.

**Clasificación:** Almacenado [dato base] corresponde a un valor persistido sin expresión de generación; Derivado [calculado] se utiliza para la columna generada subtotal de tbd_order_items. Ninguna columna se define como Multivalor: las colecciones de categorías, proveedores, deseos y componentes se normalizan en filas separadas.

**Estados y baja lógica:** solo tb_users dispone de deleted_at. Un status inactivo no es un DELETE físico. Los 45 triggers inspeccionados son de trazabilidad AFTER; ninguno convierte DELETE en Soft Delete ni implementa cálculos de inventario o totales.

<a id="inventario"></a>

## Inventario de tablas

| Tabla | Columnas | Triggers | Propósito |
| --- | ---: | ---: | --- |
| [`tb_users`](#tabla-tb-users) | 9 | 3 | Almacena las cuentas funcionales del comercio: credenciales, correo, alias y estado de acceso. |
| [`tb_people`](#tabla-tb-people) | 12 | 3 | Separa los datos personales y de contacto de las credenciales de tb_users. |
| [`tb_logs`](#tabla-tb-logs) | 7 | 0 | Centraliza las evidencias de altas, cambios y bajas físicas generadas por los triggers. |
| [`tbc_categories`](#tabla-tbc-categories) | 6 | 3 | Define el catálogo de categorías para organizar los productos. |
| [`tb_products`](#tabla-tb-products) | 9 | 3 | Mantiene el catálogo maestro de productos, con SKU, nombre comercial, descripción, precio vigente y existencias. |
| [`tbd_products_categories`](#tabla-tbd-products-categories) | 6 | 3 | Implementa la relación muchos a muchos entre productos y categorías. |
| [`tbd_products_users_providers`](#tabla-tbd-products-users-providers) | 10 | 3 | Relaciona productos con usuarios proveedores e incorpora condiciones de suministro: código del proveedor, costo unitario, plazo de entrega y condición de proveedor principal. |
| [`tb_buyer_orders`](#tabla-tb-buyer-orders) | 8 | 3 | Representa la cabecera de pedidos con el usuario identificado como seller_ID, subtotal, costo de envío y estado de cumplimiento. |
| [`tbd_order_items`](#tabla-tbd-order-items) | 9 | 3 | Registra las líneas de un pedido: producto, proveedor, nombre histórico del producto, cantidad y precio aplicado. |
| [`tb_carts`](#tabla-tb-carts) | 5 | 3 | Mantiene la cabecera del carrito de cada usuario. |
| [`tbd_carts_items`](#tabla-tbd-carts-items) | 5 | 3 | Almacena los productos del carrito diferenciados por proveedor. |
| [`tbd_users_wishlist_products`](#tabla-tbd-users-wishlist-products) | 5 | 3 | Implementa la lista de deseos como asociación entre usuario y producto. |
| [`tb_user_addresses`](#tabla-tb-user-addresses) | 12 | 3 | Conserva las direcciones etiquetadas de cada usuario, los datos de quien recibe, las instrucciones y las coordenadas de entrega. |
| [`tbd_address_components`](#tabla-tbd-address-components) | 8 | 3 | Descompone una dirección en componentes tipificados, por ejemplo calle, colonia o municipio. |
| [`tbc_payment_methods_types`](#tabla-tbc-payment-methods-types) | 6 | 3 | Define los tipos de métodos de pago mediante un código único y una descripción. |
| [`tbd_user_payment_methods`](#tabla-tbd-user-payment-methods) | 11 | 3 | Guarda referencias a instrumentos de pago administrados por un proveedor externo, junto con etiqueta, últimos cuatro caracteres y preferencia del usuario. |

<a id="diccionario"></a>

## Diccionario completo por columna

<a id="seguridad-personas"></a>

### 01 · Seguridad, personas y trazabilidad

![Seguridad y personas — 3 tablas · 28 columnas · 6 triggers](https://raw.githubusercontent.com/RodriguezBJLuis/Practicas_BDN_240480/Practica03/Practica03/assets/diccionario/seguridad-personas.svg)

<a id="tabla-tb-users"></a>

<details open>
<summary><strong>1. tb_users</strong> · 9 columnas · 3 triggers</summary>

Almacena las cuentas funcionales del comercio: credenciales, correo, alias y estado de acceso. Es la entidad referenciada por personas, carritos, proveedores, pedidos y métodos de pago. Estas cuentas de aplicación son distintas de los usuarios del servidor MySQL.

**Triggers asociados: 3.** `trg_users_after_insert` (AFTER INSERT); `trg_users_after_update` (AFTER UPDATE); `trg_users_after_delete` (AFTER DELETE). Todos son de trazabilidad; no son triggers de Soft Delete ni de lógica de negocio.

| **Nombre de la Columna** | **Tipo de Dato / Composición** | **Llave** | **Obligatoriedad** | **Naturaleza** | **Clasificación** | **Dominio** | **Descripción Detallada** |
| --- | --- | --- | --- | --- | --- | --- | --- |
| `id` | `INT` | PK | Obligatorio | Cualitativa | Almacenado [dato base] | Entero entre -2,147,483,648 y 2,147,483,647; AUTO_INCREMENT; normalmente asignado por MySQL. | Identificador técnico del registro. Permite localizarlo de forma inequívoca y, cuando existen referencias, enlazarlo desde otras entidades. |
| `email` | `VARCHAR(100)` | N/A | Opcional | Cualitativa | Almacenado [dato base] | Hasta 100 caracteres; Admite NULL y cadena vacía; Sin valor predeterminado explícito; puede omitirse como NULL. | Correo asociado a la cuenta. Se utiliza como dato de contacto y como candidato para identificar al usuario durante el registro; su formato y su unicidad no están impuestos por la definición física de esta columna. |
| `nickname` | `VARCHAR(50)` | N/A | Opcional | Cualitativa | Almacenado [dato base] | Hasta 50 caracteres; Admite NULL y cadena vacía; Sin valor predeterminado explícito; puede omitirse como NULL. | Alias de la cuenta usado por la aplicación. No tiene índice único en el esquema actual. |
| `password` | `VARCHAR(255)` | N/A | Opcional | Cualitativa | Almacenado [dato base] | Hasta 255 caracteres; Admite NULL y cadena vacía; Sin valor predeterminado explícito; puede omitirse como NULL. | Credencial persistida de la cuenta. El procedimiento sp_register_user recibe un hash generado por la aplicación; el tipo VARCHAR por sí mismo no exige un algoritmo de hash ni impide texto plano. |
| `status` | `VARCHAR(20)` | N/A | Opcional | Cualitativa | Almacenado [dato base] | Hasta 20 caracteres; Admite NULL y cadena vacía; DEFAULT `active`; Convención funcional de estado/indicador; sin CHECK ni ENUM que limite sus valores a 0/1 o a etiquetas específicas. | Estado funcional de la cuenta, con valor inicial active. La columna no está limitada a una lista cerrada de estados. |
| `creation_date` | `DATETIME` | N/A | Opcional | Cualitativa | Almacenado [dato base] | Fecha y hora DATETIME, sin zona horaria almacenada; validez sujeta al sql_mode; DEFAULT `CURRENT_TIMESTAMP`. | Fecha y hora de creación del registro. Cuando existe DEFAULT CURRENT_TIMESTAMP, MySQL la completa si se omite en la inserción. |
| `last_date` | `DATETIME` | N/A | Opcional | Cualitativa | Almacenado [dato base] | Fecha y hora DATETIME, sin zona horaria almacenada; validez sujeta al sql_mode; DEFAULT `CURRENT_TIMESTAMP`; ON UPDATE CURRENT_TIMESTAMP. | Fecha de modificación de la cuenta, inicializada y actualizada automáticamente por MySQL. |
| `last_log` | `DATETIME` | N/A | Opcional | Cualitativa | Almacenado [dato base] | Fecha y hora DATETIME, sin zona horaria almacenada; validez sujeta al sql_mode; Sin valor predeterminado explícito; puede omitirse como NULL. | Fecha y hora del último acceso registrado por la aplicación. No tiene DEFAULT ni un trigger que la actualice al iniciar sesión. |
| `deleted_at` | `DATETIME` | N/A | Opcional | Cualitativa | Almacenado [dato base] | Fecha y hora DATETIME, sin zona horaria almacenada; validez sujeta al sql_mode; Sin valor predeterminado explícito; puede omitirse como NULL. | Marca temporal de baja lógica de la cuenta. NULL representa ausencia de una marca de eliminación; establecerla no elimina físicamente la fila. |

**Índices y unicidad**

| Índice | Columnas, en orden | Tipo |
| --- | --- | --- |
| `PRIMARY` | `id` | PRIMARY KEY |

**Relaciones e integridad referencial**

No tiene claves foráneas salientes. Esto no excluye que otras tablas la referencien.


[↑ Explorar áreas](#inicio) · [Inventario](#inventario) · [Consultar triggers](#triggers)

</details>

<a id="tabla-tb-people"></a>

<details>
<summary><strong>2. tb_people</strong> · 12 columnas · 3 triggers</summary>

Separa los datos personales y de contacto de las credenciales de tb_users. Tiene exactamente 12 columnas; status, creation_date y last_update constituyen los tres campos de auditoría. Cada persona pertenece a un usuario y cada usuario admite como máximo un perfil de persona.

**Triggers asociados: 3.** `trg_tb_people_after_insert` (AFTER INSERT); `trg_tb_people_after_update` (AFTER UPDATE); `trg_tb_people_after_delete` (AFTER DELETE). Todos son de trazabilidad; no son triggers de Soft Delete ni de lógica de negocio.

| **Nombre de la Columna** | **Tipo de Dato / Composición** | **Llave** | **Obligatoriedad** | **Naturaleza** | **Clasificación** | **Dominio** | **Descripción Detallada** |
| --- | --- | --- | --- | --- | --- | --- | --- |
| `id` | `INT` | PK | Obligatorio | Cualitativa | Almacenado [dato base] | Entero entre -2,147,483,648 y 2,147,483,647; AUTO_INCREMENT; normalmente asignado por MySQL. | Identificador técnico del registro. Permite localizarlo de forma inequívoca y, cuando existen referencias, enlazarlo desde otras entidades. |
| `user_id` | `INT` | FK | Obligatorio | Cualitativa | Almacenado [dato base] | Entero entre -2,147,483,648 y 2,147,483,647; Sin valor predeterminado explícito; debe suministrarse; FK a `tb_users.id` mediante `fk_people_user`; UNIQUE `uk_people_user` sobre (`user_id`). | Identificador de la cuenta de usuario a la que pertenece el registro o la asociación. |
| `first_name` | `VARCHAR(100)` | N/A | Obligatorio | Cualitativa | Almacenado [dato base] | Hasta 100 caracteres; NOT NULL no impide cadena vacía; Sin valor predeterminado explícito; debe suministrarse. | Nombre o nombres de la persona vinculada a la cuenta; se separan del alias de acceso. |
| `last_name` | `VARCHAR(100)` | N/A | Obligatorio | Cualitativa | Almacenado [dato base] | Hasta 100 caracteres; NOT NULL no impide cadena vacía; Sin valor predeterminado explícito; debe suministrarse. | Primer apellido de la persona para identificación y presentación del perfil. |
| `second_last_name` | `VARCHAR(100)` | N/A | Opcional | Cualitativa | Almacenado [dato base] | Hasta 100 caracteres; Admite NULL y cadena vacía; Sin valor predeterminado explícito; puede omitirse como NULL. | Segundo apellido de la persona; puede omitirse cuando no aplique. |
| `birth_date` | `DATE` | N/A | Opcional | Cualitativa | Almacenado [dato base] | Fecha DATE; validez y fechas cero sujetas al sql_mode de la sesión; Sin valor predeterminado explícito; puede omitirse como NULL. | Fecha de nacimiento del titular del perfil. sp_register_user rechaza fechas futuras, pero la tabla no impone esa regla mediante CHECK. |
| `gender` | `VARCHAR(30)` | N/A | Opcional | Cualitativa | Almacenado [dato base] | Hasta 30 caracteres; Admite NULL y cadena vacía; Sin valor predeterminado explícito; puede omitirse como NULL. | Atributo de género informado en el perfil. Se almacena como texto libre; no hay catálogo ni ENUM que limite sus valores. |
| `phone` | `VARCHAR(25)` | N/A | Opcional | Cualitativa | Almacenado [dato base] | Hasta 25 caracteres; Admite NULL y cadena vacía; Sin valor predeterminado explícito; puede omitirse como NULL. | Teléfono de contacto de la persona, conservado como texto para admitir prefijos y separadores. |
| `nationality` | `VARCHAR(80)` | N/A | Opcional | Cualitativa | Almacenado [dato base] | Hasta 80 caracteres; Admite NULL y cadena vacía; Sin valor predeterminado explícito; puede omitirse como NULL. | Nacionalidad declarada de la persona. No referencia un catálogo de países ni utiliza un código normalizado obligatorio. |
| `status` | `BIT(1)` | N/A | Obligatorio | Cualitativa | Almacenado [dato base] | Bit: 0 o 1; DEFAULT `b'1'`. | Indicador funcional de activación o vigencia del registro. Cambiarlo no elimina físicamente la fila ni establece una fecha de baja. |
| `creation_date` | `DATETIME` | N/A | Obligatorio | Cualitativa | Almacenado [dato base] | Fecha y hora DATETIME, sin zona horaria almacenada; validez sujeta al sql_mode; DEFAULT `CURRENT_TIMESTAMP`. | Fecha y hora de creación del registro. Cuando existe DEFAULT CURRENT_TIMESTAMP, MySQL la completa si se omite en la inserción. |
| `last_update` | `DATETIME` | N/A | Opcional | Cualitativa | Almacenado [dato base] | Fecha y hora DATETIME, sin zona horaria almacenada; validez sujeta al sql_mode; Sin valor predeterminado explícito; puede omitirse como NULL; ON UPDATE CURRENT_TIMESTAMP. | Fecha y hora de la última modificación. Su obligatoriedad y su actualización automática dependen de la definición física indicada en el dominio. |

**Índices y unicidad**

| Índice | Columnas, en orden | Tipo |
| --- | --- | --- |
| `PRIMARY` | `id` | PRIMARY KEY |
| `uk_people_user` | `user_id` | UNIQUE |

**Relaciones e integridad referencial**

- `fk_people_user`: (`user_id`) → `tb_users` (`id`); ON DELETE `RESTRICT`; ON UPDATE `CASCADE`.


[↑ Explorar áreas](#inicio) · [Inventario](#inventario) · [Consultar triggers](#triggers)

</details>

<a id="tabla-tb-logs"></a>

<details>
<summary><strong>3. tb_logs</strong> · 7 columnas · 0 triggers</summary>

Centraliza las evidencias de altas, cambios y bajas físicas generadas por los triggers. Conserva el nombre de la tabla, la operación, el usuario de conexión y una descripción del evento. No tiene claves foráneas hacia las entidades auditadas, de modo que la evidencia no depende de que el registro original permanezca.

**Triggers asociados: 0.** No tiene triggers propios; funciona como destino de la auditoría.

| **Nombre de la Columna** | **Tipo de Dato / Composición** | **Llave** | **Obligatoriedad** | **Naturaleza** | **Clasificación** | **Dominio** | **Descripción Detallada** |
| --- | --- | --- | --- | --- | --- | --- | --- |
| `id` | `INT` | PK | Obligatorio | Cualitativa | Almacenado [dato base] | Entero entre -2,147,483,648 y 2,147,483,647; AUTO_INCREMENT; normalmente asignado por MySQL. | Identificador técnico del registro. Permite localizarlo de forma inequívoca y, cuando existen referencias, enlazarlo desde otras entidades. |
| `table_affected` | `VARCHAR(50)` | N/A | Opcional | Cualitativa | Almacenado [dato base] | Hasta 50 caracteres; Admite NULL y cadena vacía; Sin valor predeterminado explícito; puede omitirse como NULL. | Nombre de la tabla cuya operación originó el evento. Es una referencia descriptiva y no una clave foránea. |
| `operation` | `VARCHAR(20)` | N/A | Opcional | Cualitativa | Almacenado [dato base] | Hasta 20 caracteres; Admite NULL y cadena vacía; Sin valor predeterminado explícito; puede omitirse como NULL. | Etiqueta de la operación auditada. Los triggers actuales escriben INSERT, UPDATE o DELETE; la columna VARCHAR permite otras cadenas. |
| `db_user` | `VARCHAR(100)` | N/A | Opcional | Cualitativa | Almacenado [dato base] | Hasta 100 caracteres; Admite NULL y cadena vacía; Sin valor predeterminado explícito; puede omitirse como NULL. | Cuenta y host de la conexión que originó el evento, obtenidos mediante USER() por los triggers. No equivale necesariamente al usuario funcional de tb_users. |
| `description` | `TEXT` | N/A | Opcional | Cualitativa | Almacenado [dato base] | TEXT: máximo 65 535 bytes; cantidad de caracteres dependiente de la codificación; Sin valor predeterminado explícito; puede omitirse como NULL. | Texto explicativo de la operación auditada, construido por el trigger que la origina. Su detalle varía según la tabla y el evento. |
| `operation_date` | `DATETIME` | N/A | Opcional | Cualitativa | Almacenado [dato base] | Fecha y hora DATETIME, sin zona horaria almacenada; validez sujeta al sql_mode; DEFAULT `CURRENT_TIMESTAMP`. | Fecha y hora de persistencia del evento de auditoría. Se obtiene automáticamente mediante CURRENT_TIMESTAMP si no se suministra otro valor. |
| `status` | `TINYINT` | N/A | Opcional | Cualitativa | Almacenado [dato base] | Entero entre -128 y 127; DEFAULT `1`; Convención funcional de estado/indicador; sin CHECK ni ENUM que limite sus valores a 0/1 o a etiquetas específicas. | Indicador de estado del registro. Los triggers de auditoría lo inicializan en 1. |

**Índices y unicidad**

| Índice | Columnas, en orden | Tipo |
| --- | --- | --- |
| `PRIMARY` | `id` | PRIMARY KEY |

**Relaciones e integridad referencial**

No tiene claves foráneas salientes. Esto no excluye que otras tablas la referencien.


[↑ Explorar áreas](#inicio) · [Inventario](#inventario) · [Consultar triggers](#triggers)

</details>

<a id="catalogo-proveedores"></a>

### 02 · Catálogo y proveedores

![Catálogo y proveedores — 4 tablas · 31 columnas · 12 triggers](https://raw.githubusercontent.com/RodriguezBJLuis/Practicas_BDN_240480/Practica03/Practica03/assets/diccionario/catalogo-proveedores.svg)

<a id="tabla-tbc-categories"></a>

<details>
<summary><strong>4. tbc_categories</strong> · 6 columnas · 3 triggers</summary>

Define el catálogo de categorías para organizar los productos. Su relación con productos se implementa mediante tbd_products_categories; no existe una columna category_id en tb_products ni una jerarquía de categorías en esta versión.

**Triggers asociados: 3.** `trg_categories_after_insert` (AFTER INSERT); `trg_categories_after_update` (AFTER UPDATE); `trg_categories_after_delete` (AFTER DELETE). Todos son de trazabilidad; no son triggers de Soft Delete ni de lógica de negocio.

| **Nombre de la Columna** | **Tipo de Dato / Composición** | **Llave** | **Obligatoriedad** | **Naturaleza** | **Clasificación** | **Dominio** | **Descripción Detallada** |
| --- | --- | --- | --- | --- | --- | --- | --- |
| `id` | `INT` | PK | Obligatorio | Cualitativa | Almacenado [dato base] | Entero entre -2,147,483,648 y 2,147,483,647; AUTO_INCREMENT; normalmente asignado por MySQL. | Identificador técnico del registro. Permite localizarlo de forma inequívoca y, cuando existen referencias, enlazarlo desde otras entidades. |
| `name` | `VARCHAR(100)` | N/A | Obligatorio | Cualitativa | Almacenado [dato base] | Hasta 100 caracteres; NOT NULL no impide cadena vacía; Sin valor predeterminado explícito; debe suministrarse; UNIQUE `uq_tbc_categories_name` sobre (`name`). | Nombre legible de la categoría. Su índice único evita duplicados conforme a la intercalación de la tabla. |
| `description` | `TEXT` | N/A | Opcional | Cualitativa | Almacenado [dato base] | TEXT: máximo 65 535 bytes; cantidad de caracteres dependiente de la codificación; Sin valor predeterminado explícito; puede omitirse como NULL. | Descripción ampliada de la categoría para explicar su alcance comercial. |
| `status` | `TINYINT` | N/A | Obligatorio | Cualitativa | Almacenado [dato base] | Entero entre -128 y 127; DEFAULT `1`; Convención funcional de estado/indicador; sin CHECK ni ENUM que limite sus valores a 0/1 o a etiquetas específicas. | Indicador funcional de activación o vigencia del registro. Cambiarlo no elimina físicamente la fila ni establece una fecha de baja. |
| `created_at` | `DATETIME` | N/A | Obligatorio | Cualitativa | Almacenado [dato base] | Fecha y hora DATETIME, sin zona horaria almacenada; validez sujeta al sql_mode; DEFAULT `CURRENT_TIMESTAMP`. | Fecha y hora de creación de la asociación o entidad; se asigna automáticamente mediante CURRENT_TIMESTAMP. |
| `updated_at` | `DATETIME` | N/A | Obligatorio | Cualitativa | Almacenado [dato base] | Fecha y hora DATETIME, sin zona horaria almacenada; validez sujeta al sql_mode; DEFAULT `CURRENT_TIMESTAMP`; ON UPDATE CURRENT_TIMESTAMP. | Fecha y hora de última modificación, inicializada y actualizada automáticamente por MySQL. |

**Índices y unicidad**

| Índice | Columnas, en orden | Tipo |
| --- | --- | --- |
| `PRIMARY` | `id` | PRIMARY KEY |
| `uq_tbc_categories_name` | `name` | UNIQUE |

**Relaciones e integridad referencial**

No tiene claves foráneas salientes. Esto no excluye que otras tablas la referencien.


[↑ Explorar áreas](#inicio) · [Inventario](#inventario) · [Consultar triggers](#triggers)

</details>

<a id="tabla-tb-products"></a>

<details>
<summary><strong>5. tb_products</strong> · 9 columnas · 3 triggers</summary>

Mantiene el catálogo maestro de productos, con SKU, nombre comercial, descripción, precio vigente y existencias. Los nombres físicos son nombre_producto y descripcion. Las categorías y los proveedores se vinculan mediante tablas de asociación independientes.

**Triggers asociados: 3.** `trg_products_after_insert` (AFTER INSERT); `trg_products_after_update` (AFTER UPDATE); `trg_products_after_delete` (AFTER DELETE). Todos son de trazabilidad; no son triggers de Soft Delete ni de lógica de negocio.

| **Nombre de la Columna** | **Tipo de Dato / Composición** | **Llave** | **Obligatoriedad** | **Naturaleza** | **Clasificación** | **Dominio** | **Descripción Detallada** |
| --- | --- | --- | --- | --- | --- | --- | --- |
| `id` | `INT` | PK | Obligatorio | Cualitativa | Almacenado [dato base] | Entero entre -2,147,483,648 y 2,147,483,647; AUTO_INCREMENT; normalmente asignado por MySQL. | Identificador técnico del registro. Permite localizarlo de forma inequívoca y, cuando existen referencias, enlazarlo desde otras entidades. |
| `SKU` | `VARCHAR(20)` | N/A | Obligatorio | Cualitativa | Almacenado [dato base] | Hasta 20 caracteres; NOT NULL no impide cadena vacía; Sin valor predeterminado explícito; debe suministrarse. | Código comercial del producto. Aunque sirve como identificador de negocio, actualmente no existe una restricción UNIQUE que evite su repetición. |
| `nombre_producto` | `VARCHAR(150)` | N/A | Obligatorio | Cualitativa | Almacenado [dato base] | Hasta 150 caracteres; NOT NULL no impide cadena vacía; Sin valor predeterminado explícito; debe suministrarse. | Nombre comercial vigente con el que se identifica el producto en consultas y en la interfaz de catálogo. |
| `descripcion` | `TEXT` | N/A | Opcional | Cualitativa | Almacenado [dato base] | TEXT: máximo 65 535 bytes; cantidad de caracteres dependiente de la codificación; Sin valor predeterminado explícito; puede omitirse como NULL. | Descripción ampliada del producto, con características útiles para su consulta comercial. |
| `current_price` | `DECIMAL(10,2)` | N/A | Obligatorio | Cuantitativa | Almacenado [dato base] | Decimal exacto: 10 dígitos totales, 2 decimales y 8 enteros; admite signo; Sin valor predeterminado explícito; debe suministrarse. | Precio unitario vigente del catálogo. Se almacena como decimal exacto; la moneda y la política de impuestos no están definidas en esta columna. |
| `current_stock` | `INT` | N/A | Obligatorio | Cuantitativa | Almacenado [dato base] | Entero entre -2,147,483,648 y 2,147,483,647; Sin valor predeterminado explícito; debe suministrarse. | Cantidad de existencias vigentes del producto. Su tipo INT es firmado y no tiene CHECK de no negatividad en el esquema actual. |
| `status` | `TINYINT` | N/A | Obligatorio | Cualitativa | Almacenado [dato base] | Entero entre -128 y 127; Sin valor predeterminado explícito; debe suministrarse; Convención funcional de estado/indicador; sin CHECK ni ENUM que limite sus valores a 0/1 o a etiquetas específicas. | Indicador funcional de activación o vigencia del registro. Cambiarlo no elimina físicamente la fila ni establece una fecha de baja. |
| `creation_date` | `DATETIME` | N/A | Obligatorio | Cualitativa | Almacenado [dato base] | Fecha y hora DATETIME, sin zona horaria almacenada; validez sujeta al sql_mode; Sin valor predeterminado explícito; debe suministrarse. | Fecha y hora de creación del registro. Cuando existe DEFAULT CURRENT_TIMESTAMP, MySQL la completa si se omite en la inserción. |
| `last_update` | `DATETIME` | N/A | Obligatorio | Cualitativa | Almacenado [dato base] | Fecha y hora DATETIME, sin zona horaria almacenada; validez sujeta al sql_mode; Sin valor predeterminado explícito; debe suministrarse. | Fecha y hora de la última modificación. Su obligatoriedad y su actualización automática dependen de la definición física indicada en el dominio. |

**Índices y unicidad**

| Índice | Columnas, en orden | Tipo |
| --- | --- | --- |
| `PRIMARY` | `id` | PRIMARY KEY |

**Relaciones e integridad referencial**

No tiene claves foráneas salientes. Esto no excluye que otras tablas la referencien.


[↑ Explorar áreas](#inicio) · [Inventario](#inventario) · [Consultar triggers](#triggers)

</details>

<a id="tabla-tbd-products-categories"></a>

<details>
<summary><strong>6. tbd_products_categories</strong> · 6 columnas · 3 triggers</summary>

Implementa la relación muchos a muchos entre productos y categorías. Cuenta con identificador propio y una restricción única sobre el par producto/categoría para impedir asociaciones duplicadas.

**Triggers asociados: 3.** `trg_product_categories_after_insert` (AFTER INSERT); `trg_product_categories_after_update` (AFTER UPDATE); `trg_product_categories_after_delete` (AFTER DELETE). Todos son de trazabilidad; no son triggers de Soft Delete ni de lógica de negocio.

| **Nombre de la Columna** | **Tipo de Dato / Composición** | **Llave** | **Obligatoriedad** | **Naturaleza** | **Clasificación** | **Dominio** | **Descripción Detallada** |
| --- | --- | --- | --- | --- | --- | --- | --- |
| `id` | `INT` | PK | Obligatorio | Cualitativa | Almacenado [dato base] | Entero entre -2,147,483,648 y 2,147,483,647; AUTO_INCREMENT; normalmente asignado por MySQL. | Identificador técnico del registro. Permite localizarlo de forma inequívoca y, cuando existen referencias, enlazarlo desde otras entidades. |
| `product_id` | `INT` | FK | Obligatorio | Cualitativa | Almacenado [dato base] | Entero entre -2,147,483,648 y 2,147,483,647; Sin valor predeterminado explícito; debe suministrarse; FK a `tb_products.id` mediante `fk_product_categories_product`; UNIQUE `uq_product_category` sobre (`product_id`, `category_id`). | Identificador del producto relacionado con el registro. La referencia física concreta se indica en el dominio y en el apartado de relaciones. |
| `category_id` | `INT` | FK | Obligatorio | Cualitativa | Almacenado [dato base] | Entero entre -2,147,483,648 y 2,147,483,647; Sin valor predeterminado explícito; debe suministrarse; FK a `tbc_categories.id` mediante `fk_product_categories_category`; UNIQUE `uq_product_category` sobre (`product_id`, `category_id`). | Identificador de la categoría utilizada para clasificar el producto asociado. |
| `status` | `TINYINT` | N/A | Obligatorio | Cualitativa | Almacenado [dato base] | Entero entre -128 y 127; DEFAULT `1`; Convención funcional de estado/indicador; sin CHECK ni ENUM que limite sus valores a 0/1 o a etiquetas específicas. | Indicador funcional de activación o vigencia del registro. Cambiarlo no elimina físicamente la fila ni establece una fecha de baja. |
| `created_at` | `DATETIME` | N/A | Obligatorio | Cualitativa | Almacenado [dato base] | Fecha y hora DATETIME, sin zona horaria almacenada; validez sujeta al sql_mode; DEFAULT `CURRENT_TIMESTAMP`. | Fecha y hora de creación de la asociación o entidad; se asigna automáticamente mediante CURRENT_TIMESTAMP. |
| `updated_at` | `DATETIME` | N/A | Obligatorio | Cualitativa | Almacenado [dato base] | Fecha y hora DATETIME, sin zona horaria almacenada; validez sujeta al sql_mode; DEFAULT `CURRENT_TIMESTAMP`; ON UPDATE CURRENT_TIMESTAMP. | Fecha y hora de última modificación, inicializada y actualizada automáticamente por MySQL. |

**Índices y unicidad**

| Índice | Columnas, en orden | Tipo |
| --- | --- | --- |
| `idx_product_categories_category` | `category_id` | Índice no único |
| `PRIMARY` | `id` | PRIMARY KEY |
| `uq_product_category` | `product_id`, `category_id` | UNIQUE |

**Relaciones e integridad referencial**

- `fk_product_categories_category`: (`category_id`) → `tbc_categories` (`id`); ON DELETE `RESTRICT`; ON UPDATE `CASCADE`.
- `fk_product_categories_product`: (`product_id`) → `tb_products` (`id`); ON DELETE `RESTRICT`; ON UPDATE `CASCADE`.


[↑ Explorar áreas](#inicio) · [Inventario](#inventario) · [Consultar triggers](#triggers)

</details>

<a id="tabla-tbd-products-users-providers"></a>

<details>
<summary><strong>7. tbd_products_users_providers</strong> · 10 columnas · 3 triggers</summary>

Relaciona productos con usuarios proveedores e incorpora condiciones de suministro: código del proveedor, costo unitario, plazo de entrega y condición de proveedor principal. La pareja producto/proveedor es única. No contiene una columna available_stock.

**Triggers asociados: 3.** `trg_product_providers_after_insert` (AFTER INSERT); `trg_product_providers_after_update` (AFTER UPDATE); `trg_product_providers_after_delete` (AFTER DELETE). Todos son de trazabilidad; no son triggers de Soft Delete ni de lógica de negocio.

| **Nombre de la Columna** | **Tipo de Dato / Composición** | **Llave** | **Obligatoriedad** | **Naturaleza** | **Clasificación** | **Dominio** | **Descripción Detallada** |
| --- | --- | --- | --- | --- | --- | --- | --- |
| `id` | `INT` | PK | Obligatorio | Cualitativa | Almacenado [dato base] | Entero entre -2,147,483,648 y 2,147,483,647; AUTO_INCREMENT; normalmente asignado por MySQL. | Identificador técnico del registro. Permite localizarlo de forma inequívoca y, cuando existen referencias, enlazarlo desde otras entidades. |
| `product_id` | `INT` | FK | Obligatorio | Cualitativa | Almacenado [dato base] | Entero entre -2,147,483,648 y 2,147,483,647; Sin valor predeterminado explícito; debe suministrarse; FK a `tb_products.id` mediante `fk_product_providers_product`; UNIQUE `uq_product_provider` sobre (`product_id`, `provider_user_id`). | Identificador del producto relacionado con el registro. La referencia física concreta se indica en el dominio y en el apartado de relaciones. |
| `provider_user_id` | `INT` | FK | Obligatorio | Cualitativa | Almacenado [dato base] | Entero entre -2,147,483,648 y 2,147,483,647; Sin valor predeterminado explícito; debe suministrarse; FK a `tb_users.id` mediante `fk_product_providers_user`; UNIQUE `uq_product_provider` sobre (`product_id`, `provider_user_id`). | Identificador del usuario que suministra el producto asociado. Referencia la cuenta del proveedor en tb_users. |
| `provider_sku` | `VARCHAR(100)` | N/A | Opcional | Cualitativa | Almacenado [dato base] | Hasta 100 caracteres; Admite NULL y cadena vacía; Sin valor predeterminado explícito; puede omitirse como NULL. | Código que utiliza el proveedor para identificar este producto en su propio catálogo. |
| `unit_cost` | `DECIMAL(10,2)` | N/A | Opcional | Cuantitativa | Almacenado [dato base] | Decimal exacto: 10 dígitos totales, 2 decimales y 8 enteros; admite signo; Sin valor predeterminado explícito; puede omitirse como NULL. | Costo unitario de suministro del producto para este proveedor. No existe CHECK de no negatividad ni moneda explícita en esta columna. |
| `lead_time_days` | `SMALLINT UNSIGNED` | N/A | Opcional | Cuantitativa | Almacenado [dato base] | Entero entre 0 y 65,535; Sin valor predeterminado explícito; puede omitirse como NULL. | Plazo de suministro expresado en días. El tipo sin signo permite cero; NULL representa que no se ha especificado el plazo. |
| `is_primary` | `TINYINT` | N/A | Obligatorio | Cualitativa | Almacenado [dato base] | Entero entre -128 y 127; DEFAULT `0`; Convención funcional de estado/indicador; sin CHECK ni ENUM que limite sus valores a 0/1 o a etiquetas específicas. | Indicador de proveedor principal para el producto. La tabla no impone que exista como máximo un proveedor principal por producto. |
| `status` | `TINYINT` | N/A | Obligatorio | Cualitativa | Almacenado [dato base] | Entero entre -128 y 127; DEFAULT `1`; Convención funcional de estado/indicador; sin CHECK ni ENUM que limite sus valores a 0/1 o a etiquetas específicas. | Indicador funcional de activación o vigencia del registro. Cambiarlo no elimina físicamente la fila ni establece una fecha de baja. |
| `created_at` | `DATETIME` | N/A | Obligatorio | Cualitativa | Almacenado [dato base] | Fecha y hora DATETIME, sin zona horaria almacenada; validez sujeta al sql_mode; DEFAULT `CURRENT_TIMESTAMP`. | Fecha y hora de creación de la asociación o entidad; se asigna automáticamente mediante CURRENT_TIMESTAMP. |
| `updated_at` | `DATETIME` | N/A | Obligatorio | Cualitativa | Almacenado [dato base] | Fecha y hora DATETIME, sin zona horaria almacenada; validez sujeta al sql_mode; DEFAULT `CURRENT_TIMESTAMP`; ON UPDATE CURRENT_TIMESTAMP. | Fecha y hora de última modificación, inicializada y actualizada automáticamente por MySQL. |

**Índices y unicidad**

| Índice | Columnas, en orden | Tipo |
| --- | --- | --- |
| `idx_product_providers_user` | `provider_user_id` | Índice no único |
| `PRIMARY` | `id` | PRIMARY KEY |
| `uq_product_provider` | `product_id`, `provider_user_id` | UNIQUE |

**Relaciones e integridad referencial**

- `fk_product_providers_product`: (`product_id`) → `tb_products` (`id`); ON DELETE `RESTRICT`; ON UPDATE `CASCADE`.
- `fk_product_providers_user`: (`provider_user_id`) → `tb_users` (`id`); ON DELETE `RESTRICT`; ON UPDATE `CASCADE`.


[↑ Explorar áreas](#inicio) · [Inventario](#inventario) · [Consultar triggers](#triggers)

</details>

<a id="pedidos"></a>

### 03 · Pedidos y líneas de venta

![Pedidos y ventas — 2 tablas · 17 columnas · 6 triggers](https://raw.githubusercontent.com/RodriguezBJLuis/Practicas_BDN_240480/Practica03/Practica03/assets/diccionario/pedidos.svg)

<a id="tabla-tb-buyer-orders"></a>

<details>
<summary><strong>8. tb_buyer_orders</strong> · 8 columnas · 3 triggers</summary>

Representa la cabecera de pedidos con el usuario identificado como seller_ID, subtotal, costo de envío y estado de cumplimiento. A pesar del nombre, el esquema actual no incluye buyer_id ni una clave comercial del pedido. Sus renglones se almacenan en tbd_order_items.

**Triggers asociados: 3.** `trg_tb_buyer_orders_after_insert` (AFTER INSERT); `trg_tb_buyer_orders_after_update` (AFTER UPDATE); `trg_tb_buyer_orders_after_delete` (AFTER DELETE). Todos son de trazabilidad; no son triggers de Soft Delete ni de lógica de negocio.

| **Nombre de la Columna** | **Tipo de Dato / Composición** | **Llave** | **Obligatoriedad** | **Naturaleza** | **Clasificación** | **Dominio** | **Descripción Detallada** |
| --- | --- | --- | --- | --- | --- | --- | --- |
| `ID` | `INT UNSIGNED` | PK | Obligatorio | Cualitativa | Almacenado [dato base] | Entero entre 0 y 4,294,967,295; AUTO_INCREMENT; normalmente asignado por MySQL. | Identificador técnico del registro. Permite localizarlo de forma inequívoca y, cuando existen referencias, enlazarlo desde otras entidades. |
| `seller_ID` | `INT` | FK | Obligatorio | Cualitativa | Almacenado [dato base] | Entero entre -2,147,483,648 y 2,147,483,647; Sin valor predeterminado explícito; debe suministrarse; FK a `tb_users.id` mediante `tb_buyer_orders_ibfk_1`. | Identificador del usuario vinculado al pedido como vendedor. No debe interpretarse como comprador sin una regla externa que lo establezca. |
| `subtotal` | `DECIMAL(12,2)` | N/A | Obligatorio | Cuantitativa | Almacenado [dato base] | Decimal exacto: 12 dígitos totales, 2 decimales y 10 enteros; admite signo; DEFAULT `0.00`; CHECK `(`subtotal` >= 0)`. | Subtotal persistido de la cabecera del pedido. No es una columna generada y los triggers actuales no lo sincronizan con la suma de las líneas. |
| `shipping_cost` | `DECIMAL(12,2)` | N/A | Obligatorio | Cuantitativa | Almacenado [dato base] | Decimal exacto: 12 dígitos totales, 2 decimales y 10 enteros; admite signo; DEFAULT `0.00`; CHECK `(`shipping_cost` >= 0)`. | Importe de envío persistido en la cabecera del pedido, independiente del subtotal de productos. |
| `fulfillment_status` | `ENUM('PENDING','ACCEPTED','PREPARING','SENT','DELIVERED','CANCELED','RETURNED')` | N/A | Obligatorio | Cualitativa | Almacenado [dato base] | Valores admitidos: `Pending`, `Accepted`, `Preparing`, `Sent`, `Delivered`, `Canceled`, `Returned`; DEFAULT `Pending`. | Etapa operativa del cumplimiento del pedido. El ENUM restringe las etiquetas permitidas, pero no define una secuencia obligatoria de transiciones. |
| `status` | `BIT(1)` | N/A | Obligatorio | Cualitativa | Almacenado [dato base] | Bit: 0 o 1; DEFAULT `b'1'`. | Indicador funcional de activación o vigencia del registro. Cambiarlo no elimina físicamente la fila ni establece una fecha de baja. |
| `creation_date` | `DATETIME` | N/A | Obligatorio | Cualitativa | Almacenado [dato base] | Fecha y hora DATETIME, sin zona horaria almacenada; validez sujeta al sql_mode; DEFAULT `CURRENT_TIMESTAMP`. | Fecha y hora de creación del registro. Cuando existe DEFAULT CURRENT_TIMESTAMP, MySQL la completa si se omite en la inserción. |
| `last_update` | `DATETIME` | N/A | Opcional | Cualitativa | Almacenado [dato base] | Fecha y hora DATETIME, sin zona horaria almacenada; validez sujeta al sql_mode; Sin valor predeterminado explícito; puede omitirse como NULL; ON UPDATE CURRENT_TIMESTAMP. | Fecha y hora de la última modificación. Su obligatoriedad y su actualización automática dependen de la definición física indicada en el dominio. |

**Índices y unicidad**

| Índice | Columnas, en orden | Tipo |
| --- | --- | --- |
| `PRIMARY` | `ID` | PRIMARY KEY |
| `seller_ID` | `seller_ID` | Índice no único |

**Relaciones e integridad referencial**

- `tb_buyer_orders_ibfk_1`: (`seller_ID`) → `tb_users` (`id`); ON DELETE `NO ACTION`; ON UPDATE `NO ACTION`.

**Restricciones CHECK**

- `tb_buyer_orders_chk_1`: `(`subtotal` >= 0)`.
- `tb_buyer_orders_chk_2`: `(`shipping_cost` >= 0)`.


[↑ Explorar áreas](#inicio) · [Inventario](#inventario) · [Consultar triggers](#triggers)

</details>

<a id="tabla-tbd-order-items"></a>

<details>
<summary><strong>9. tbd_order_items</strong> · 9 columnas · 3 triggers</summary>

Registra las líneas de un pedido: producto, proveedor, nombre histórico del producto, cantidad y precio aplicado. El subtotal es una columna generada almacenada, calculada por MySQL como cantidad por precio unitario.

**Triggers asociados: 3.** `trg_tbd_order_items_after_insert` (AFTER INSERT); `trg_tbd_order_items_after_update` (AFTER UPDATE); `trg_tbd_order_items_after_delete` (AFTER DELETE). Todos son de trazabilidad; no son triggers de Soft Delete ni de lógica de negocio.

| **Nombre de la Columna** | **Tipo de Dato / Composición** | **Llave** | **Obligatoriedad** | **Naturaleza** | **Clasificación** | **Dominio** | **Descripción Detallada** |
| --- | --- | --- | --- | --- | --- | --- | --- |
| `ID` | `INT UNSIGNED` | PK | Obligatorio | Cualitativa | Almacenado [dato base] | Entero entre 0 y 4,294,967,295; AUTO_INCREMENT; normalmente asignado por MySQL. | Identificador técnico del registro. Permite localizarlo de forma inequívoca y, cuando existen referencias, enlazarlo desde otras entidades. |
| `seller_order_ID` | `INT UNSIGNED` | FK | Obligatorio | Cualitativa | Almacenado [dato base] | Entero entre 0 y 4,294,967,295; Sin valor predeterminado explícito; debe suministrarse; FK a `tb_buyer_orders.ID` mediante `tbd_order_items_ibfk_1`. | Identificador de la cabecera del pedido al que pertenece el renglón. El nombre físico de la cabecera es tb_buyer_orders. |
| `product_ID` | `INT` | FK | Obligatorio | Cualitativa | Almacenado [dato base] | Entero entre -2,147,483,648 y 2,147,483,647; Sin valor predeterminado explícito; debe suministrarse; FK a `tbd_products_users_providers.product_id` mediante `tbd_order_items_ibfk_2`. | Identificador del producto relacionado con el registro. La referencia física concreta se indica en el dominio y en el apartado de relaciones. |
| `provider_ID` | `INT` | FK | Obligatorio | Cualitativa | Almacenado [dato base] | Entero entre -2,147,483,648 y 2,147,483,647; Sin valor predeterminado explícito; debe suministrarse; FK a `tbd_products_users_providers.provider_user_id` mediante `tbd_order_items_ibfk_3`. | Identificador del usuario proveedor. Se relaciona con provider_user_id de la tabla de ofertas de productos y proveedores. |
| `product_name` | `VARCHAR(255)` | N/A | Obligatorio | Cualitativa | Almacenado [dato base] | Hasta 255 caracteres; NOT NULL no impide cadena vacía; Sin valor predeterminado explícito; debe suministrarse. | Copia del nombre del producto al registrar la línea del pedido, útil para conservar el contexto comercial aunque cambie el catálogo. |
| `quantity` | `INT UNSIGNED` | N/A | Obligatorio | Cuantitativa | Almacenado [dato base] | Entero entre 0 y 4,294,967,295; Sin valor predeterminado explícito; debe suministrarse; CHECK `(`quantity` > 0)`. | Número de unidades del producto en el renglón. La restricción CHECK exige una cantidad mayor que cero. |
| `unit_price` | `DECIMAL(12,2)` | N/A | Obligatorio | Cuantitativa | Almacenado [dato base] | Decimal exacto: 12 dígitos totales, 2 decimales y 10 enteros; admite signo; Sin valor predeterminado explícito; debe suministrarse; CHECK `(`unit_price` >= 0)`. | Precio unitario aplicado al producto en este pedido. Es independiente del precio vigente del catálogo y no puede ser negativo. |
| `subtotal` | `DECIMAL(12,2)` | N/A | Opcional | Cuantitativa | Derivado [calculado; persistido STORED] | Decimal exacto: 12 dígitos totales, 2 decimales y 10 enteros; admite signo; GENERATED ALWAYS AS `(`quantity` * `unit_price`)` STORED; no se introduce manualmente. | Importe de la línea calculado automáticamente como quantity × unit_price y persistido físicamente por MySQL; se recalcula al modificar sus operandos. |
| `creation_date` | `DATETIME` | N/A | Obligatorio | Cualitativa | Almacenado [dato base] | Fecha y hora DATETIME, sin zona horaria almacenada; validez sujeta al sql_mode; DEFAULT `CURRENT_TIMESTAMP`. | Fecha y hora de creación del registro. Cuando existe DEFAULT CURRENT_TIMESTAMP, MySQL la completa si se omite en la inserción. |

**Índices y unicidad**

| Índice | Columnas, en orden | Tipo |
| --- | --- | --- |
| `PRIMARY` | `ID` | PRIMARY KEY |
| `product_ID` | `product_ID` | Índice no único |
| `provider_ID` | `provider_ID` | Índice no único |
| `seller_order_ID` | `seller_order_ID` | Índice no único |

**Relaciones e integridad referencial**

- `tbd_order_items_ibfk_1`: (`seller_order_ID`) → `tb_buyer_orders` (`ID`); ON DELETE `NO ACTION`; ON UPDATE `NO ACTION`.
- `tbd_order_items_ibfk_2`: (`product_ID`) → `tbd_products_users_providers` (`product_id`); ON DELETE `NO ACTION`; ON UPDATE `NO ACTION`.
- `tbd_order_items_ibfk_3`: (`provider_ID`) → `tbd_products_users_providers` (`provider_user_id`); ON DELETE `NO ACTION`; ON UPDATE `NO ACTION`.

**Restricciones CHECK**

- `tbd_order_items_chk_1`: `(`quantity` > 0)`.
- `tbd_order_items_chk_2`: `(`unit_price` >= 0)`.


[↑ Explorar áreas](#inicio) · [Inventario](#inventario) · [Consultar triggers](#triggers)

</details>

<a id="carritos-deseos"></a>

### 04 · Carritos y listas de deseos

![Carritos y deseos — 3 tablas · 15 columnas · 9 triggers](https://raw.githubusercontent.com/RodriguezBJLuis/Practicas_BDN_240480/Practica03/Practica03/assets/diccionario/carritos-deseos.svg)

<a id="tabla-tb-carts"></a>

<details>
<summary><strong>10. tb_carts</strong> · 5 columnas · 3 triggers</summary>

Mantiene la cabecera del carrito de cada usuario. El índice único sobre user_ID limita a un carrito por usuario, incluso si un carrito previo está inactivo. El contenido se almacena en tbd_carts_items.

**Triggers asociados: 3.** `trg_tb_carts_after_insert` (AFTER INSERT); `trg_tb_carts_after_update` (AFTER UPDATE); `trg_tb_carts_after_delete` (AFTER DELETE). Todos son de trazabilidad; no son triggers de Soft Delete ni de lógica de negocio.

| **Nombre de la Columna** | **Tipo de Dato / Composición** | **Llave** | **Obligatoriedad** | **Naturaleza** | **Clasificación** | **Dominio** | **Descripción Detallada** |
| --- | --- | --- | --- | --- | --- | --- | --- |
| `ID` | `INT UNSIGNED` | PK | Obligatorio | Cualitativa | Almacenado [dato base] | Entero entre 0 y 4,294,967,295; AUTO_INCREMENT; normalmente asignado por MySQL. | Identificador técnico del registro. Permite localizarlo de forma inequívoca y, cuando existen referencias, enlazarlo desde otras entidades. |
| `user_ID` | `INT` | FK | Obligatorio | Cualitativa | Almacenado [dato base] | Entero entre -2,147,483,648 y 2,147,483,647; Sin valor predeterminado explícito; debe suministrarse; FK a `tb_users.id` mediante `tb_carts_ibfk_1`; UNIQUE `uk_cart_user` sobre (`user_ID`). | Identificador de la cuenta de usuario a la que pertenece el registro o la asociación. |
| `status` | `BIT(1)` | N/A | Opcional | Cualitativa | Almacenado [dato base] | Bit: 0 o 1; DEFAULT `b'1'`. | Indicador funcional de activación o vigencia del registro. Cambiarlo no elimina físicamente la fila ni establece una fecha de baja. |
| `creation_date` | `DATETIME` | N/A | Obligatorio | Cualitativa | Almacenado [dato base] | Fecha y hora DATETIME, sin zona horaria almacenada; validez sujeta al sql_mode; DEFAULT `CURRENT_TIMESTAMP`. | Fecha y hora de creación del registro. Cuando existe DEFAULT CURRENT_TIMESTAMP, MySQL la completa si se omite en la inserción. |
| `last_update` | `DATETIME` | N/A | Opcional | Cualitativa | Almacenado [dato base] | Fecha y hora DATETIME, sin zona horaria almacenada; validez sujeta al sql_mode; Sin valor predeterminado explícito; puede omitirse como NULL; ON UPDATE CURRENT_TIMESTAMP. | Fecha y hora de la última modificación. Su obligatoriedad y su actualización automática dependen de la definición física indicada en el dominio. |

**Índices y unicidad**

| Índice | Columnas, en orden | Tipo |
| --- | --- | --- |
| `PRIMARY` | `ID` | PRIMARY KEY |
| `uk_cart_user` | `user_ID` | UNIQUE |

**Relaciones e integridad referencial**

- `tb_carts_ibfk_1`: (`user_ID`) → `tb_users` (`id`); ON DELETE `NO ACTION`; ON UPDATE `NO ACTION`.


[↑ Explorar áreas](#inicio) · [Inventario](#inventario) · [Consultar triggers](#triggers)

</details>

<a id="tabla-tbd-carts-items"></a>

<details>
<summary><strong>11. tbd_carts_items</strong> · 5 columnas · 3 triggers</summary>

Almacena los productos del carrito diferenciados por proveedor. La clave primaria compuesta permite un solo renglón para cada combinación carrito/proveedor/producto, con cantidad estrictamente positiva.

**Triggers asociados: 3.** `trg_tbd_carts_items_after_insert` (AFTER INSERT); `trg_tbd_carts_items_after_update` (AFTER UPDATE); `trg_tbd_carts_items_after_delete` (AFTER DELETE). Todos son de trazabilidad; no son triggers de Soft Delete ni de lógica de negocio.

| **Nombre de la Columna** | **Tipo de Dato / Composición** | **Llave** | **Obligatoriedad** | **Naturaleza** | **Clasificación** | **Dominio** | **Descripción Detallada** |
| --- | --- | --- | --- | --- | --- | --- | --- |
| `cart_ID` | `INT UNSIGNED` | PK, FK | Obligatorio | Cualitativa | Almacenado [dato base] | Entero entre 0 y 4,294,967,295; Sin valor predeterminado explícito; debe suministrarse; FK a `tb_carts.ID` mediante `tbd_carts_items_ibfk_1`. | Identificador de la cabecera del carrito al que pertenece este renglón. |
| `provider_ID` | `INT` | PK, FK | Obligatorio | Cualitativa | Almacenado [dato base] | Entero entre -2,147,483,648 y 2,147,483,647; Sin valor predeterminado explícito; debe suministrarse; FK a `tbd_products_users_providers.provider_user_id` mediante `tbd_carts_items_ibfk_2`. | Identificador del usuario proveedor. Se relaciona con provider_user_id de la tabla de ofertas de productos y proveedores. |
| `product_ID` | `INT` | PK, FK | Obligatorio | Cualitativa | Almacenado [dato base] | Entero entre -2,147,483,648 y 2,147,483,647; Sin valor predeterminado explícito; debe suministrarse; FK a `tbd_products_users_providers.product_id` mediante `tbd_carts_items_ibfk_3`. | Identificador del producto relacionado con el registro. La referencia física concreta se indica en el dominio y en el apartado de relaciones. |
| `quantity` | `INT UNSIGNED` | N/A | Obligatorio | Cuantitativa | Almacenado [dato base] | Entero entre 0 y 4,294,967,295; DEFAULT `1`; CHECK `(`quantity` > 0)`. | Número de unidades del producto en el renglón. La restricción CHECK exige una cantidad mayor que cero. |
| `creation_date` | `DATETIME` | N/A | Obligatorio | Cualitativa | Almacenado [dato base] | Fecha y hora DATETIME, sin zona horaria almacenada; validez sujeta al sql_mode; DEFAULT `CURRENT_TIMESTAMP`. | Fecha y hora de creación del registro. Cuando existe DEFAULT CURRENT_TIMESTAMP, MySQL la completa si se omite en la inserción. |

**Índices y unicidad**

| Índice | Columnas, en orden | Tipo |
| --- | --- | --- |
| `PRIMARY` | `cart_ID`, `provider_ID`, `product_ID` | PRIMARY KEY |
| `product_ID` | `product_ID` | Índice no único |
| `provider_ID` | `provider_ID` | Índice no único |

**Relaciones e integridad referencial**

- `tbd_carts_items_ibfk_1`: (`cart_ID`) → `tb_carts` (`ID`); ON DELETE `NO ACTION`; ON UPDATE `NO ACTION`.
- `tbd_carts_items_ibfk_2`: (`provider_ID`) → `tbd_products_users_providers` (`provider_user_id`); ON DELETE `NO ACTION`; ON UPDATE `NO ACTION`.
- `tbd_carts_items_ibfk_3`: (`product_ID`) → `tbd_products_users_providers` (`product_id`); ON DELETE `NO ACTION`; ON UPDATE `NO ACTION`.

**Restricciones CHECK**

- `chk_cart_quantity`: `(`quantity` > 0)`.


[↑ Explorar áreas](#inicio) · [Inventario](#inventario) · [Consultar triggers](#triggers)

</details>

<a id="tabla-tbd-users-wishlist-products"></a>

<details>
<summary><strong>12. tbd_users_wishlist_products</strong> · 5 columnas · 3 triggers</summary>

Implementa la lista de deseos como asociación entre usuario y producto. La clave primaria compuesta impide repetir el mismo producto para un mismo usuario. El estado permite marcar la asociación como activa o inactiva.

**Triggers asociados: 3.** `trg_tbd_users_wishlist_products_after_insert` (AFTER INSERT); `trg_tbd_users_wishlist_products_after_update` (AFTER UPDATE); `trg_tbd_users_wishlist_products_after_delete` (AFTER DELETE). Todos son de trazabilidad; no son triggers de Soft Delete ni de lógica de negocio.

| **Nombre de la Columna** | **Tipo de Dato / Composición** | **Llave** | **Obligatoriedad** | **Naturaleza** | **Clasificación** | **Dominio** | **Descripción Detallada** |
| --- | --- | --- | --- | --- | --- | --- | --- |
| `user_ID` | `INT` | PK, FK | Obligatorio | Cualitativa | Almacenado [dato base] | Entero entre -2,147,483,648 y 2,147,483,647; Sin valor predeterminado explícito; debe suministrarse; FK a `tb_users.id` mediante `fk_user2`. | Identificador de la cuenta de usuario a la que pertenece el registro o la asociación. |
| `product_ID` | `INT` | PK, FK | Obligatorio | Cualitativa | Almacenado [dato base] | Entero entre -2,147,483,648 y 2,147,483,647; Sin valor predeterminado explícito; debe suministrarse; FK a `tb_products.id` mediante `fk_products3`. | Identificador del producto relacionado con el registro. La referencia física concreta se indica en el dominio y en el apartado de relaciones. |
| `status` | `BIT(1)` | N/A | Obligatorio | Cualitativa | Almacenado [dato base] | Bit: 0 o 1; DEFAULT `b'1'`. | Indicador funcional de activación o vigencia del registro. Cambiarlo no elimina físicamente la fila ni establece una fecha de baja. |
| `creation_date` | `DATETIME` | N/A | Obligatorio | Cualitativa | Almacenado [dato base] | Fecha y hora DATETIME, sin zona horaria almacenada; validez sujeta al sql_mode; DEFAULT `CURRENT_TIMESTAMP`. | Fecha y hora de creación del registro. Cuando existe DEFAULT CURRENT_TIMESTAMP, MySQL la completa si se omite en la inserción. |
| `last_update` | `DATETIME` | N/A | Obligatorio | Cualitativa | Almacenado [dato base] | Fecha y hora DATETIME, sin zona horaria almacenada; validez sujeta al sql_mode; Sin valor predeterminado explícito; debe suministrarse; ON UPDATE CURRENT_TIMESTAMP. | Fecha y hora de la última modificación. Su obligatoriedad y su actualización automática dependen de la definición física indicada en el dominio. |

**Índices y unicidad**

| Índice | Columnas, en orden | Tipo |
| --- | --- | --- |
| `fk_products3` | `product_ID` | Índice no único |
| `PRIMARY` | `user_ID`, `product_ID` | PRIMARY KEY |

**Relaciones e integridad referencial**

- `fk_products3`: (`product_ID`) → `tb_products` (`id`); ON DELETE `NO ACTION`; ON UPDATE `NO ACTION`.
- `fk_user2`: (`user_ID`) → `tb_users` (`id`); ON DELETE `NO ACTION`; ON UPDATE `NO ACTION`.


[↑ Explorar áreas](#inicio) · [Inventario](#inventario) · [Consultar triggers](#triggers)

</details>

<a id="direcciones"></a>

### 05 · Direcciones y componentes

![Direcciones — 2 tablas · 20 columnas · 6 triggers](https://raw.githubusercontent.com/RodriguezBJLuis/Practicas_BDN_240480/Practica03/Practica03/assets/diccionario/direcciones.svg)

<a id="tabla-tb-user-addresses"></a>

<details>
<summary><strong>13. tb_user_addresses</strong> · 12 columnas · 3 triggers</summary>

Conserva las direcciones etiquetadas de cada usuario, los datos de quien recibe, las instrucciones y las coordenadas de entrega. Los componentes postales se descomponen en tbd_address_components.

**Triggers asociados: 3.** `trg_tb_user_addresses_after_insert` (AFTER INSERT); `trg_tb_user_addresses_after_update` (AFTER UPDATE); `trg_tb_user_addresses_after_delete` (AFTER DELETE). Todos son de trazabilidad; no son triggers de Soft Delete ni de lógica de negocio.

| **Nombre de la Columna** | **Tipo de Dato / Composición** | **Llave** | **Obligatoriedad** | **Naturaleza** | **Clasificación** | **Dominio** | **Descripción Detallada** |
| --- | --- | --- | --- | --- | --- | --- | --- |
| `ID` | `BIGINT UNSIGNED` | PK | Obligatorio | Cualitativa | Almacenado [dato base] | Entero entre 0 y 18,446,744,073,709,551,615; AUTO_INCREMENT; normalmente asignado por MySQL. | Identificador técnico del registro. Permite localizarlo de forma inequívoca y, cuando existen referencias, enlazarlo desde otras entidades. |
| `user_ID` | `INT` | FK | Obligatorio | Cualitativa | Almacenado [dato base] | Entero entre -2,147,483,648 y 2,147,483,647; Sin valor predeterminado explícito; debe suministrarse; FK a `tb_users.id` mediante `fk_addresses_users`. | Identificador de la cuenta de usuario a la que pertenece el registro o la asociación. |
| `address_label` | `VARCHAR(100)` | N/A | Obligatorio | Cualitativa | Almacenado [dato base] | Hasta 100 caracteres; NOT NULL no impide cadena vacía; Sin valor predeterminado explícito; debe suministrarse. | Etiqueta elegida para distinguir una dirección del usuario, por ejemplo casa u oficina. |
| `recipient_name` | `VARCHAR(150)` | N/A | Opcional | Cualitativa | Almacenado [dato base] | Hasta 150 caracteres; Admite NULL y cadena vacía; Sin valor predeterminado explícito; puede omitirse como NULL. | Nombre de la persona autorizada o prevista para recibir la entrega en esta dirección. |
| `recipient_phone` | `VARCHAR(25)` | N/A | Opcional | Cualitativa | Almacenado [dato base] | Hasta 25 caracteres; Admite NULL y cadena vacía; Sin valor predeterminado explícito; puede omitirse como NULL. | Teléfono de contacto del destinatario para coordinar la entrega. |
| `delivery_instructions` | `VARCHAR(500)` | N/A | Opcional | Cualitativa | Almacenado [dato base] | Hasta 500 caracteres; Admite NULL y cadena vacía; Sin valor predeterminado explícito; puede omitirse como NULL. | Indicaciones adicionales para localizar el domicilio o realizar la entrega. |
| `latitude` | `DECIMAL(10,7)` | N/A | Opcional | Cuantitativa | Almacenado [dato base] | Decimal exacto: 10 dígitos totales, 7 decimales y 3 enteros; admite signo; Sin valor predeterminado explícito; puede omitirse como NULL; CHECK `(((`latitude` is null) and (`longitude` is null)) or ((`latitude` is not null) and (`longitude` is not null)))`; CHECK `(`latitude` between -(90) and 90)`. | Coordenada de latitud decimal de la ubicación. Debe informarse junto con longitude o quedar ambas en NULL. |
| `longitude` | `DECIMAL(10,7)` | N/A | Opcional | Cuantitativa | Almacenado [dato base] | Decimal exacto: 10 dígitos totales, 7 decimales y 3 enteros; admite signo; Sin valor predeterminado explícito; puede omitirse como NULL; CHECK `(((`latitude` is null) and (`longitude` is null)) or ((`latitude` is not null) and (`longitude` is not null)))`; CHECK `(`longitude` between -(180) and 180)`. | Coordenada de longitud decimal de la ubicación. Debe informarse junto con latitude o quedar ambas en NULL. |
| `is_default` | `TINYINT(1)` | N/A | Obligatorio | Cualitativa | Almacenado [dato base] | Entero entre -128 y 127; El ancho (1) no restringe a valores booleanos; DEFAULT `0`; Convención funcional de estado/indicador; sin CHECK ni ENUM que limite sus valores a 0/1 o a etiquetas específicas. | Marca el registro preferido del usuario. No existe una restricción que garantice un único registro predeterminado por usuario. |
| `status` | `BIT(1)` | N/A | Obligatorio | Cualitativa | Almacenado [dato base] | Bit: 0 o 1; DEFAULT `b'1'`. | Indicador funcional de activación o vigencia del registro. Cambiarlo no elimina físicamente la fila ni establece una fecha de baja. |
| `creation_date` | `DATETIME` | N/A | Obligatorio | Cualitativa | Almacenado [dato base] | Fecha y hora DATETIME, sin zona horaria almacenada; validez sujeta al sql_mode; DEFAULT `CURRENT_TIMESTAMP`. | Fecha y hora de creación del registro. Cuando existe DEFAULT CURRENT_TIMESTAMP, MySQL la completa si se omite en la inserción. |
| `last_update` | `DATETIME` | N/A | Opcional | Cualitativa | Almacenado [dato base] | Fecha y hora DATETIME, sin zona horaria almacenada; validez sujeta al sql_mode; Sin valor predeterminado explícito; puede omitirse como NULL; ON UPDATE CURRENT_TIMESTAMP. | Fecha y hora de la última modificación. Su obligatoriedad y su actualización automática dependen de la definición física indicada en el dominio. |

**Índices y unicidad**

| Índice | Columnas, en orden | Tipo |
| --- | --- | --- |
| `idx_user_addresses` | `user_ID` | Índice no único |
| `PRIMARY` | `ID` | PRIMARY KEY |

**Relaciones e integridad referencial**

- `fk_addresses_users`: (`user_ID`) → `tb_users` (`id`); ON DELETE `NO ACTION`; ON UPDATE `NO ACTION`.

**Restricciones CHECK**

- `chk_coordinates`: `(((`latitude` is null) and (`longitude` is null)) or ((`latitude` is not null) and (`longitude` is not null)))`.
- `chk_latitude`: `(`latitude` between -(90) and 90)`.
- `chk_longitude`: `(`longitude` between -(180) and 180)`.


[↑ Explorar áreas](#inicio) · [Inventario](#inventario) · [Consultar triggers](#triggers)

</details>

<a id="tabla-tbd-address-components"></a>

<details>
<summary><strong>14. tbd_address_components</strong> · 8 columnas · 3 triggers</summary>

Descompone una dirección en componentes tipificados, por ejemplo calle, colonia o municipio. La referencia compuesta al componente superior establece una jerarquía cuyos padres deben pertenecer a la misma dirección. Los tipos concretos se almacenan como texto libre.

**Triggers asociados: 3.** `trg_tbd_address_components_after_insert` (AFTER INSERT); `trg_tbd_address_components_after_update` (AFTER UPDATE); `trg_tbd_address_components_after_delete` (AFTER DELETE). Todos son de trazabilidad; no son triggers de Soft Delete ni de lógica de negocio.

| **Nombre de la Columna** | **Tipo de Dato / Composición** | **Llave** | **Obligatoriedad** | **Naturaleza** | **Clasificación** | **Dominio** | **Descripción Detallada** |
| --- | --- | --- | --- | --- | --- | --- | --- |
| `ID` | `BIGINT UNSIGNED` | PK | Obligatorio | Cualitativa | Almacenado [dato base] | Entero entre 0 y 18,446,744,073,709,551,615; AUTO_INCREMENT; normalmente asignado por MySQL; UNIQUE `uk_address_component` sobre (`address_ID`, `ID`). | Identificador técnico del registro. Permite localizarlo de forma inequívoca y, cuando existen referencias, enlazarlo desde otras entidades. |
| `address_ID` | `BIGINT UNSIGNED` | FK | Obligatorio | Cualitativa | Almacenado [dato base] | Entero entre 0 y 18,446,744,073,709,551,615; Sin valor predeterminado explícito; debe suministrarse; FK a `tb_user_addresses.ID` mediante `fk_component_address`; FK a `tbd_address_components.address_ID` mediante `fk_component_parent`; UNIQUE `uk_address_component` sobre (`address_ID`, `ID`). | Identificador de la dirección a la que pertenece el componente postal. |
| `value` | `VARCHAR(255)` | N/A | Obligatorio | Cualitativa | Almacenado [dato base] | Hasta 255 caracteres; NOT NULL no impide cadena vacía; Sin valor predeterminado explícito; debe suministrarse. | Contenido del componente de dirección, como nombre de calle, número exterior o código postal, según component_type. |
| `component_type` | `VARCHAR(50)` | N/A | Obligatorio | Cualitativa | Almacenado [dato base] | Hasta 50 caracteres; NOT NULL no impide cadena vacía; Sin valor predeterminado explícito; debe suministrarse. | Tipo semántico del componente de dirección. Los valores se guardan como texto libre y no están limitados por un catálogo físico. |
| `status` | `BIT(1)` | N/A | Obligatorio | Cualitativa | Almacenado [dato base] | Bit: 0 o 1; DEFAULT `b'1'`. | Indicador funcional de activación o vigencia del registro. Cambiarlo no elimina físicamente la fila ni establece una fecha de baja. |
| `address_sup_ID` | `BIGINT UNSIGNED` | FK | Opcional | Cualitativa | Almacenado [dato base] | Entero entre 0 y 18,446,744,073,709,551,615; Sin valor predeterminado explícito; puede omitirse como NULL; FK a `tbd_address_components.ID` mediante `fk_component_parent`. | Identificador del componente padre dentro de la misma dirección. NULL representa un componente sin padre; la referencia no impide por sí sola ciclos jerárquicos. |
| `creation_date` | `DATETIME` | N/A | Obligatorio | Cualitativa | Almacenado [dato base] | Fecha y hora DATETIME, sin zona horaria almacenada; validez sujeta al sql_mode; DEFAULT `CURRENT_TIMESTAMP`. | Fecha y hora de creación del registro. Cuando existe DEFAULT CURRENT_TIMESTAMP, MySQL la completa si se omite en la inserción. |
| `last_update` | `DATETIME` | N/A | Opcional | Cualitativa | Almacenado [dato base] | Fecha y hora DATETIME, sin zona horaria almacenada; validez sujeta al sql_mode; Sin valor predeterminado explícito; puede omitirse como NULL; ON UPDATE CURRENT_TIMESTAMP. | Fecha y hora de la última modificación. Su obligatoriedad y su actualización automática dependen de la definición física indicada en el dominio. |

**Índices y unicidad**

| Índice | Columnas, en orden | Tipo |
| --- | --- | --- |
| `idx_address_parent` | `address_ID`, `address_sup_ID` | Índice no único |
| `PRIMARY` | `ID` | PRIMARY KEY |
| `uk_address_component` | `address_ID`, `ID` | UNIQUE |

**Relaciones e integridad referencial**

- `fk_component_address`: (`address_ID`) → `tb_user_addresses` (`ID`); ON DELETE `RESTRICT`; ON UPDATE `NO ACTION`.
- `fk_component_parent`: (`address_ID`, `address_sup_ID`) → `tbd_address_components` (`address_ID`, `ID`); ON DELETE `RESTRICT`; ON UPDATE `NO ACTION`.


[↑ Explorar áreas](#inicio) · [Inventario](#inventario) · [Consultar triggers](#triggers)

</details>

<a id="pagos"></a>

### 06 · Tipos e instrumentos de pago

![Métodos de pago — 2 tablas · 17 columnas · 6 triggers](https://raw.githubusercontent.com/RodriguezBJLuis/Practicas_BDN_240480/Practica03/Practica03/assets/diccionario/pagos.svg)

<a id="tabla-tbc-payment-methods-types"></a>

<details>
<summary><strong>15. tbc_payment_methods_types</strong> · 6 columnas · 3 triggers</summary>

Define los tipos de métodos de pago mediante un código único y una descripción. Se utiliza para clasificar los instrumentos registrados por los usuarios; no registra cobros ni transacciones monetarias.

**Triggers asociados: 3.** `trg_tbc_payment_methods_types_after_insert` (AFTER INSERT); `trg_tbc_payment_methods_types_after_update` (AFTER UPDATE); `trg_tbc_payment_methods_types_after_delete` (AFTER DELETE). Todos son de trazabilidad; no son triggers de Soft Delete ni de lógica de negocio.

| **Nombre de la Columna** | **Tipo de Dato / Composición** | **Llave** | **Obligatoriedad** | **Naturaleza** | **Clasificación** | **Dominio** | **Descripción Detallada** |
| --- | --- | --- | --- | --- | --- | --- | --- |
| `ID` | `INT UNSIGNED` | PK | Obligatorio | Cualitativa | Almacenado [dato base] | Entero entre 0 y 4,294,967,295; AUTO_INCREMENT; normalmente asignado por MySQL. | Identificador técnico del registro. Permite localizarlo de forma inequívoca y, cuando existen referencias, enlazarlo desde otras entidades. |
| `code` | `VARCHAR(30)` | N/A | Obligatorio | Cualitativa | Almacenado [dato base] | Hasta 30 caracteres; NOT NULL no impide cadena vacía; Sin valor predeterminado explícito; debe suministrarse; UNIQUE `code_UNIQUE` sobre (`code`). | Código funcional único del tipo de método de pago, utilizado por la aplicación para clasificar los instrumentos. |
| `description` | `TEXT` | N/A | Obligatorio | Cualitativa | Almacenado [dato base] | TEXT: máximo 65 535 bytes; cantidad de caracteres dependiente de la codificación; Sin valor predeterminado explícito; debe suministrarse. | Descripción funcional del tipo de método de pago. |
| `status` | `BIT(1)` | N/A | Obligatorio | Cualitativa | Almacenado [dato base] | Bit: 0 o 1; DEFAULT `b'1'`. | Indicador funcional de activación o vigencia del registro. Cambiarlo no elimina físicamente la fila ni establece una fecha de baja. |
| `creation_date` | `DATETIME` | N/A | Obligatorio | Cualitativa | Almacenado [dato base] | Fecha y hora DATETIME, sin zona horaria almacenada; validez sujeta al sql_mode; DEFAULT `CURRENT_TIMESTAMP`. | Fecha y hora de creación del registro. Cuando existe DEFAULT CURRENT_TIMESTAMP, MySQL la completa si se omite en la inserción. |
| `last_update` | `DATETIME` | N/A | Opcional | Cualitativa | Almacenado [dato base] | Fecha y hora DATETIME, sin zona horaria almacenada; validez sujeta al sql_mode; Sin valor predeterminado explícito; puede omitirse como NULL; ON UPDATE CURRENT_TIMESTAMP. | Fecha y hora de la última modificación. Su obligatoriedad y su actualización automática dependen de la definición física indicada en el dominio. |

**Índices y unicidad**

| Índice | Columnas, en orden | Tipo |
| --- | --- | --- |
| `code_UNIQUE` | `code` | UNIQUE |
| `PRIMARY` | `ID` | PRIMARY KEY |

**Relaciones e integridad referencial**

No tiene claves foráneas salientes. Esto no excluye que otras tablas la referencien.


[↑ Explorar áreas](#inicio) · [Inventario](#inventario) · [Consultar triggers](#triggers)

</details>

<a id="tabla-tbd-user-payment-methods"></a>

<details>
<summary><strong>16. tbd_user_payment_methods</strong> · 11 columnas · 3 triggers</summary>

Guarda referencias a instrumentos de pago administrados por un proveedor externo, junto con etiqueta, últimos cuatro caracteres y preferencia del usuario. Su diseño utiliza una referencia del proveedor; no incluye campos específicos para PAN completo ni CVV.

**Triggers asociados: 3.** `trg_tbd_user_payment_methods_after_insert` (AFTER INSERT); `trg_tbd_user_payment_methods_after_update` (AFTER UPDATE); `trg_tbd_user_payment_methods_after_delete` (AFTER DELETE). Todos son de trazabilidad; no son triggers de Soft Delete ni de lógica de negocio.

| **Nombre de la Columna** | **Tipo de Dato / Composición** | **Llave** | **Obligatoriedad** | **Naturaleza** | **Clasificación** | **Dominio** | **Descripción Detallada** |
| --- | --- | --- | --- | --- | --- | --- | --- |
| `ID` | `BIGINT UNSIGNED` | PK | Obligatorio | Cualitativa | Almacenado [dato base] | Entero entre 0 y 18,446,744,073,709,551,615; AUTO_INCREMENT; normalmente asignado por MySQL. | Identificador técnico del registro. Permite localizarlo de forma inequívoca y, cuando existen referencias, enlazarlo desde otras entidades. |
| `user_ID` | `INT` | FK | Obligatorio | Cualitativa | Almacenado [dato base] | Entero entre -2,147,483,648 y 2,147,483,647; Sin valor predeterminado explícito; debe suministrarse; FK a `tb_users.id` mediante `tbd_user_payment_methods_ibfk_1`. | Identificador de la cuenta de usuario a la que pertenece el registro o la asociación. |
| `payment_method_type_ID` | `INT UNSIGNED` | FK | Obligatorio | Cualitativa | Almacenado [dato base] | Entero entre 0 y 4,294,967,295; Sin valor predeterminado explícito; debe suministrarse; FK a `tbc_payment_methods_types.ID` mediante `tbd_user_payment_methods_ibfk_2`. | Tipo de instrumento de pago, vinculado al catálogo tbc_payment_methods_types. |
| `provider` | `VARCHAR(60)` | N/A | Obligatorio | Cualitativa | Almacenado [dato base] | Hasta 60 caracteres; NOT NULL no impide cadena vacía; Sin valor predeterminado explícito; debe suministrarse; UNIQUE `uk_provider_method` sobre (`provider`, `provider_method_ref`). | Nombre o código del proveedor que administra el instrumento de pago, utilizado junto con su referencia para identificarlo. |
| `provider_method_ref` | `VARCHAR(255)` | N/A | Obligatorio | Cualitativa | Almacenado [dato base] | Hasta 255 caracteres; NOT NULL no impide cadena vacía; Sin valor predeterminado explícito; debe suministrarse; UNIQUE `uk_provider_method` sobre (`provider`, `provider_method_ref`). | Referencia del instrumento emitida por el proveedor externo. La combinación provider/provider_method_ref es única. |
| `label` | `VARCHAR(100)` | N/A | Opcional | Cualitativa | Almacenado [dato base] | Hasta 100 caracteres; Admite NULL y cadena vacía; Sin valor predeterminado explícito; puede omitirse como NULL. | Etiqueta legible que permite al usuario distinguir sus instrumentos de pago. |
| `last_four` | `CHAR(4)` | N/A | Opcional | Cualitativa | Almacenado [dato base] | Longitud de almacenamiento de 4 caracteres; Admite NULL y cadena vacía; Sin valor predeterminado explícito; puede omitirse como NULL. | Hasta cuatro caracteres finales de identificación del instrumento. El tipo CHAR(4) no exige por sí solo que sean dígitos. |
| `is_default` | `TINYINT(1)` | N/A | Obligatorio | Cualitativa | Almacenado [dato base] | Entero entre -128 y 127; El ancho (1) no restringe a valores booleanos; DEFAULT `0`; Convención funcional de estado/indicador; sin CHECK ni ENUM que limite sus valores a 0/1 o a etiquetas específicas. | Marca el registro preferido del usuario. No existe una restricción que garantice un único registro predeterminado por usuario. |
| `status` | `BIT(1)` | N/A | Obligatorio | Cualitativa | Almacenado [dato base] | Bit: 0 o 1; DEFAULT `b'1'`. | Indicador funcional de activación o vigencia del registro. Cambiarlo no elimina físicamente la fila ni establece una fecha de baja. |
| `creation_date` | `DATETIME` | N/A | Obligatorio | Cualitativa | Almacenado [dato base] | Fecha y hora DATETIME, sin zona horaria almacenada; validez sujeta al sql_mode; DEFAULT `CURRENT_TIMESTAMP`. | Fecha y hora de creación del registro. Cuando existe DEFAULT CURRENT_TIMESTAMP, MySQL la completa si se omite en la inserción. |
| `last_update` | `DATETIME` | N/A | Opcional | Cualitativa | Almacenado [dato base] | Fecha y hora DATETIME, sin zona horaria almacenada; validez sujeta al sql_mode; Sin valor predeterminado explícito; puede omitirse como NULL; ON UPDATE CURRENT_TIMESTAMP. | Fecha y hora de la última modificación. Su obligatoriedad y su actualización automática dependen de la definición física indicada en el dominio. |

**Índices y unicidad**

| Índice | Columnas, en orden | Tipo |
| --- | --- | --- |
| `payment_method_type_ID` | `payment_method_type_ID` | Índice no único |
| `PRIMARY` | `ID` | PRIMARY KEY |
| `uk_provider_method` | `provider`, `provider_method_ref` | UNIQUE |
| `user_ID` | `user_ID` | Índice no único |

**Relaciones e integridad referencial**

- `tbd_user_payment_methods_ibfk_1`: (`user_ID`) → `tb_users` (`id`); ON DELETE `NO ACTION`; ON UPDATE `NO ACTION`.
- `tbd_user_payment_methods_ibfk_2`: (`payment_method_type_ID`) → `tbc_payment_methods_types` (`ID`); ON DELETE `NO ACTION`; ON UPDATE `NO ACTION`.


[↑ Explorar áreas](#inicio) · [Inventario](#inventario) · [Consultar triggers](#triggers)

</details>

<a id="integridad"></a>

## Observaciones de integridad y alcance funcional

1. **Correo y SKU sin unicidad física.** tb_users.email, tb_users.nickname y tb_products.SKU no tienen índices UNIQUE. El formato de email tampoco está impuesto por una restricción de columna. La validación del procedimiento de registro no sustituye una restricción única frente a escrituras concurrentes o inserciones directas.

2. **Proveedor y producto en líneas.** tbd_carts_items y tbd_order_items tienen claves foráneas independientes hacia product_id y provider_user_id de tbd_products_users_providers. Esas referencias apuntan a índices no únicos; no equivalen a una clave foránea compuesta que garantice que el producto y el proveedor de una línea formen una misma oferta. Se documenta la estructura actual sin afirmar una integridad de pareja que no está implementada.

3. **Totales e inventario.** Solo tbd_order_items.subtotal se calcula por el motor. tb_buyer_orders.subtotal es un dato base y los triggers no lo recalculan; tampoco descuentan existencias, registran cobros ni validan transiciones del pedido.

4. **Baja lógica y eliminación física.** deleted_at existe únicamente en tb_users. Los triggers AFTER DELETE registran una baja física; la operación puede ser rechazada antes por referencias de otras tablas. Una baja lógica ejecutada mediante UPDATE dispara el trigger de actualización, que registra el ID del usuario pero no el valor de deleted_at.

5. **Indicadores de preferencia.** is_primary e is_default no cuentan con restricciones que impongan un único registro verdadero por producto o por usuario. Los TINYINT sin CHECK admiten más valores que cero y uno.

6. **Jerarquía de direcciones.** La referencia compuesta asegura pertenencia del padre a la misma dirección; no detecta ciclos por sí misma. Los tipos de componente son texto libre.

7. **Auditoría parcial.** Los triggers nuevos guardan claves primarias y, en UPDATE, sus versiones antigua y nueva. No capturan una copia completa de los datos modificados. Los triggers previos incluyen detalles concretos de producto, categoría o asociación. USER() identifica una conexión MySQL, no necesariamente una persona de tb_users.

8. **Objetos de consulta.** Las vistas existentes no se cuentan como tablas físicas de este diccionario. No se inventan columnas de entidades ausentes ni se documentan usuarios o roles de MySQL como filas de tb_users.

9. **Fechas y moneda.** DATETIME no conserva zona horaria. Los importes no llevan una columna de moneda, por lo que su unidad y reglas de impuestos deben establecerse en la aplicación. DEFAULT CURRENT_TIMESTAMP no implica ON UPDATE salvo que esté indicado expresamente.

<a id="triggers"></a>

## Documentación de los 42 Triggers

### Inventario completo de trazabilidad · 45 objetos

**Aclaración del título solicitado:** el inventario real contiene **45 triggers**, no 42: 15 tablas auditadas × 3 eventos. Se conserva el encabezado solicitado y se documentan los 45 objetos verificados, sin omitir los tres de tb_people. tb_logs no tiene triggers.

Todos los triggers son **FOR EACH ROW** y se ejecutan **AFTER**. Cada uno inserta en tb_logs el nombre de tabla, el evento, USER() y una descripción. operation_date se completa mediante su DEFAULT CURRENT_TIMESTAMP. El estado del log queda en 1, por valor explícito o predeterminado. En tablas InnoDB el registro de auditoría forma parte de la misma transacción: no constituye evidencia autónoma de una operación posteriormente revertida.

### Consultar por operación

[![INSERT](https://raw.githubusercontent.com/RodriguezBJLuis/Practicas_BDN_240480/Practica03/Practica03/assets/diccionario/evento-insert.svg)](#evento-insert) [![UPDATE](https://raw.githubusercontent.com/RodriguezBJLuis/Practicas_BDN_240480/Practica03/Practica03/assets/diccionario/evento-update.svg)](#evento-update) [![DELETE](https://raw.githubusercontent.com/RodriguezBJLuis/Practicas_BDN_240480/Practica03/Practica03/assets/diccionario/evento-delete.svg)](#evento-delete) 

<a id="evento-insert"></a>

<details>
<summary><strong>INSERT · 15 triggers</strong> — consultar tablas y lógica</summary>

| Nombre del Trigger | Tabla Afectada | Evento (INSERT/UPDATE/DELETE) | Momento (BEFORE/AFTER) | Lógica/Propósito |
| --- | --- | --- | --- | --- |
| `trg_tb_buyer_orders_after_insert` | `tb_buyer_orders` | INSERT | AFTER | Traza el alta en tb_logs, con USER() y descripción construida a partir de `NEW.ID`. |
| `trg_tb_carts_after_insert` | `tb_carts` | INSERT | AFTER | Traza el alta en tb_logs, con USER() y descripción construida a partir de `NEW.ID`. |
| `trg_tb_people_after_insert` | `tb_people` | INSERT | AFTER | Traza el alta en tb_logs, con USER() y descripción construida a partir de `NEW.id`. |
| `trg_products_after_insert` | `tb_products` | INSERT | AFTER | Traza el alta en tb_logs, con USER() y descripción construida a partir de `NEW.SKU`. |
| `trg_tb_user_addresses_after_insert` | `tb_user_addresses` | INSERT | AFTER | Traza el alta en tb_logs, con USER() y descripción construida a partir de `NEW.ID`. |
| `trg_users_after_insert` | `tb_users` | INSERT | AFTER | Traza el alta en tb_logs, con USER() y descripción construida a partir de `NEW.email`. |
| `trg_categories_after_insert` | `tbc_categories` | INSERT | AFTER | Traza el alta en tb_logs, con USER() y descripción construida a partir de `NEW.id`, `NEW.name`, `NEW.status`. |
| `trg_tbc_payment_methods_types_after_insert` | `tbc_payment_methods_types` | INSERT | AFTER | Traza el alta en tb_logs, con USER() y descripción construida a partir de `NEW.ID`. |
| `trg_tbd_address_components_after_insert` | `tbd_address_components` | INSERT | AFTER | Traza el alta en tb_logs, con USER() y descripción construida a partir de `NEW.ID`. |
| `trg_tbd_carts_items_after_insert` | `tbd_carts_items` | INSERT | AFTER | Traza el alta en tb_logs, con USER() y descripción construida a partir de `NEW.cart_ID`, `NEW.provider_ID`, `NEW.product_ID`. |
| `trg_tbd_order_items_after_insert` | `tbd_order_items` | INSERT | AFTER | Traza el alta en tb_logs, con USER() y descripción construida a partir de `NEW.ID`. |
| `trg_product_categories_after_insert` | `tbd_products_categories` | INSERT | AFTER | Traza el alta en tb_logs, con USER() y descripción construida a partir de `NEW.id`, `NEW.product_id`, `NEW.category_id`, `NEW.status`. |
| `trg_product_providers_after_insert` | `tbd_products_users_providers` | INSERT | AFTER | Traza el alta en tb_logs, con USER() y descripción construida a partir de `NEW.id`, `NEW.product_id`, `NEW.provider_user_id`, `NEW.status`. |
| `trg_tbd_user_payment_methods_after_insert` | `tbd_user_payment_methods` | INSERT | AFTER | Traza el alta en tb_logs, con USER() y descripción construida a partir de `NEW.ID`. |
| `trg_tbd_users_wishlist_products_after_insert` | `tbd_users_wishlist_products` | INSERT | AFTER | Traza el alta en tb_logs, con USER() y descripción construida a partir de `NEW.user_ID`, `NEW.product_ID`. |

[↑ Cambiar operación](#triggers)

</details>

<a id="evento-update"></a>

<details>
<summary><strong>UPDATE · 15 triggers</strong> — consultar tablas y lógica</summary>

| Nombre del Trigger | Tabla Afectada | Evento (INSERT/UPDATE/DELETE) | Momento (BEFORE/AFTER) | Lógica/Propósito |
| --- | --- | --- | --- | --- |
| `trg_tb_buyer_orders_after_update` | `tb_buyer_orders` | UPDATE | AFTER | Traza la modificación en tb_logs, con USER() y descripción construida a partir de `NEW.ID`, `OLD.ID`. |
| `trg_tb_carts_after_update` | `tb_carts` | UPDATE | AFTER | Traza la modificación en tb_logs, con USER() y descripción construida a partir de `NEW.ID`, `OLD.ID`. |
| `trg_tb_people_after_update` | `tb_people` | UPDATE | AFTER | Traza la modificación en tb_logs, con USER() y descripción construida a partir de `NEW.id`, `OLD.id`. |
| `trg_products_after_update` | `tb_products` | UPDATE | AFTER | Traza la modificación en tb_logs, con USER() y descripción construida a partir de `NEW.SKU`, `NEW.current_price`. |
| `trg_tb_user_addresses_after_update` | `tb_user_addresses` | UPDATE | AFTER | Traza la modificación en tb_logs, con USER() y descripción construida a partir de `NEW.ID`, `OLD.ID`. |
| `trg_users_after_update` | `tb_users` | UPDATE | AFTER | Traza la modificación en tb_logs, con USER() y descripción construida a partir de `NEW.id`. |
| `trg_categories_after_update` | `tbc_categories` | UPDATE | AFTER | Traza la modificación en tb_logs, con USER() y descripción construida a partir de `NEW.id`, `NEW.name`, `OLD.status`, `NEW.status`. |
| `trg_tbc_payment_methods_types_after_update` | `tbc_payment_methods_types` | UPDATE | AFTER | Traza la modificación en tb_logs, con USER() y descripción construida a partir de `NEW.ID`, `OLD.ID`. |
| `trg_tbd_address_components_after_update` | `tbd_address_components` | UPDATE | AFTER | Traza la modificación en tb_logs, con USER() y descripción construida a partir de `NEW.ID`, `OLD.ID`. |
| `trg_tbd_carts_items_after_update` | `tbd_carts_items` | UPDATE | AFTER | Traza la modificación en tb_logs, con USER() y descripción construida a partir de `NEW.cart_ID`, `NEW.provider_ID`, `NEW.product_ID`, `OLD.cart_ID`, `OLD.provider_ID`, `OLD.product_ID`. |
| `trg_tbd_order_items_after_update` | `tbd_order_items` | UPDATE | AFTER | Traza la modificación en tb_logs, con USER() y descripción construida a partir de `NEW.ID`, `OLD.ID`. |
| `trg_product_categories_after_update` | `tbd_products_categories` | UPDATE | AFTER | Traza la modificación en tb_logs, con USER() y descripción construida a partir de `NEW.id`, `NEW.product_id`, `NEW.category_id`, `OLD.status`, `NEW.status`. |
| `trg_product_providers_after_update` | `tbd_products_users_providers` | UPDATE | AFTER | Traza la modificación en tb_logs, con USER() y descripción construida a partir de `NEW.id`, `NEW.product_id`, `NEW.provider_user_id`, `OLD.status`, `NEW.status`. |
| `trg_tbd_user_payment_methods_after_update` | `tbd_user_payment_methods` | UPDATE | AFTER | Traza la modificación en tb_logs, con USER() y descripción construida a partir de `NEW.ID`, `OLD.ID`. |
| `trg_tbd_users_wishlist_products_after_update` | `tbd_users_wishlist_products` | UPDATE | AFTER | Traza la modificación en tb_logs, con USER() y descripción construida a partir de `NEW.user_ID`, `NEW.product_ID`, `OLD.user_ID`, `OLD.product_ID`. |

[↑ Cambiar operación](#triggers)

</details>

<a id="evento-delete"></a>

<details>
<summary><strong>DELETE · 15 triggers</strong> — consultar tablas y lógica</summary>

| Nombre del Trigger | Tabla Afectada | Evento (INSERT/UPDATE/DELETE) | Momento (BEFORE/AFTER) | Lógica/Propósito |
| --- | --- | --- | --- | --- |
| `trg_tb_buyer_orders_after_delete` | `tb_buyer_orders` | DELETE | AFTER | Traza la eliminación física en tb_logs, con USER() y descripción construida a partir de `OLD.ID`. No realiza baja lógica. |
| `trg_tb_carts_after_delete` | `tb_carts` | DELETE | AFTER | Traza la eliminación física en tb_logs, con USER() y descripción construida a partir de `OLD.ID`. No realiza baja lógica. |
| `trg_tb_people_after_delete` | `tb_people` | DELETE | AFTER | Traza la eliminación física en tb_logs, con USER() y descripción construida a partir de `OLD.id`. No realiza baja lógica. |
| `trg_products_after_delete` | `tb_products` | DELETE | AFTER | Traza la eliminación física en tb_logs, con USER() y descripción construida a partir de `OLD.SKU`. No realiza baja lógica. |
| `trg_tb_user_addresses_after_delete` | `tb_user_addresses` | DELETE | AFTER | Traza la eliminación física en tb_logs, con USER() y descripción construida a partir de `OLD.ID`. No realiza baja lógica. |
| `trg_users_after_delete` | `tb_users` | DELETE | AFTER | Traza la eliminación física en tb_logs, con USER() y descripción construida a partir de `OLD.id`. No realiza baja lógica. |
| `trg_categories_after_delete` | `tbc_categories` | DELETE | AFTER | Traza la eliminación física en tb_logs, con USER() y descripción construida a partir de `OLD.id`, `OLD.name`, `OLD.status`. No realiza baja lógica. |
| `trg_tbc_payment_methods_types_after_delete` | `tbc_payment_methods_types` | DELETE | AFTER | Traza la eliminación física en tb_logs, con USER() y descripción construida a partir de `OLD.ID`. No realiza baja lógica. |
| `trg_tbd_address_components_after_delete` | `tbd_address_components` | DELETE | AFTER | Traza la eliminación física en tb_logs, con USER() y descripción construida a partir de `OLD.ID`. No realiza baja lógica. |
| `trg_tbd_carts_items_after_delete` | `tbd_carts_items` | DELETE | AFTER | Traza la eliminación física en tb_logs, con USER() y descripción construida a partir de `OLD.cart_ID`, `OLD.provider_ID`, `OLD.product_ID`. No realiza baja lógica. |
| `trg_tbd_order_items_after_delete` | `tbd_order_items` | DELETE | AFTER | Traza la eliminación física en tb_logs, con USER() y descripción construida a partir de `OLD.ID`. No realiza baja lógica. |
| `trg_product_categories_after_delete` | `tbd_products_categories` | DELETE | AFTER | Traza la eliminación física en tb_logs, con USER() y descripción construida a partir de `OLD.id`, `OLD.product_id`, `OLD.category_id`, `OLD.status`. No realiza baja lógica. |
| `trg_product_providers_after_delete` | `tbd_products_users_providers` | DELETE | AFTER | Traza la eliminación física en tb_logs, con USER() y descripción construida a partir de `OLD.id`, `OLD.product_id`, `OLD.provider_user_id`, `OLD.status`. No realiza baja lógica. |
| `trg_tbd_user_payment_methods_after_delete` | `tbd_user_payment_methods` | DELETE | AFTER | Traza la eliminación física en tb_logs, con USER() y descripción construida a partir de `OLD.ID`. No realiza baja lógica. |
| `trg_tbd_users_wishlist_products_after_delete` | `tbd_users_wishlist_products` | DELETE | AFTER | Traza la eliminación física en tb_logs, con USER() y descripción construida a partir de `OLD.user_ID`, `OLD.product_ID`. No realiza baja lógica. |

[↑ Cambiar operación](#triggers)

</details>

<details>
<summary><strong>Inventario conjunto · 45 triggers</strong> — abrir la tabla resumen completa</summary>

| Nombre del Trigger | Tabla Afectada | Evento (INSERT/UPDATE/DELETE) | Momento (BEFORE/AFTER) | Lógica/Propósito |
| --- | --- | --- | --- | --- |
| `trg_tb_buyer_orders_after_insert` | `tb_buyer_orders` | INSERT | AFTER | Traza el alta en tb_logs, con USER() y descripción construida a partir de `NEW.ID`. |
| `trg_tb_buyer_orders_after_update` | `tb_buyer_orders` | UPDATE | AFTER | Traza la modificación en tb_logs, con USER() y descripción construida a partir de `NEW.ID`, `OLD.ID`. |
| `trg_tb_buyer_orders_after_delete` | `tb_buyer_orders` | DELETE | AFTER | Traza la eliminación física en tb_logs, con USER() y descripción construida a partir de `OLD.ID`. No realiza baja lógica. |
| `trg_tb_carts_after_insert` | `tb_carts` | INSERT | AFTER | Traza el alta en tb_logs, con USER() y descripción construida a partir de `NEW.ID`. |
| `trg_tb_carts_after_update` | `tb_carts` | UPDATE | AFTER | Traza la modificación en tb_logs, con USER() y descripción construida a partir de `NEW.ID`, `OLD.ID`. |
| `trg_tb_carts_after_delete` | `tb_carts` | DELETE | AFTER | Traza la eliminación física en tb_logs, con USER() y descripción construida a partir de `OLD.ID`. No realiza baja lógica. |
| `trg_tb_people_after_insert` | `tb_people` | INSERT | AFTER | Traza el alta en tb_logs, con USER() y descripción construida a partir de `NEW.id`. |
| `trg_tb_people_after_update` | `tb_people` | UPDATE | AFTER | Traza la modificación en tb_logs, con USER() y descripción construida a partir de `NEW.id`, `OLD.id`. |
| `trg_tb_people_after_delete` | `tb_people` | DELETE | AFTER | Traza la eliminación física en tb_logs, con USER() y descripción construida a partir de `OLD.id`. No realiza baja lógica. |
| `trg_products_after_insert` | `tb_products` | INSERT | AFTER | Traza el alta en tb_logs, con USER() y descripción construida a partir de `NEW.SKU`. |
| `trg_products_after_update` | `tb_products` | UPDATE | AFTER | Traza la modificación en tb_logs, con USER() y descripción construida a partir de `NEW.SKU`, `NEW.current_price`. |
| `trg_products_after_delete` | `tb_products` | DELETE | AFTER | Traza la eliminación física en tb_logs, con USER() y descripción construida a partir de `OLD.SKU`. No realiza baja lógica. |
| `trg_tb_user_addresses_after_insert` | `tb_user_addresses` | INSERT | AFTER | Traza el alta en tb_logs, con USER() y descripción construida a partir de `NEW.ID`. |
| `trg_tb_user_addresses_after_update` | `tb_user_addresses` | UPDATE | AFTER | Traza la modificación en tb_logs, con USER() y descripción construida a partir de `NEW.ID`, `OLD.ID`. |
| `trg_tb_user_addresses_after_delete` | `tb_user_addresses` | DELETE | AFTER | Traza la eliminación física en tb_logs, con USER() y descripción construida a partir de `OLD.ID`. No realiza baja lógica. |
| `trg_users_after_insert` | `tb_users` | INSERT | AFTER | Traza el alta en tb_logs, con USER() y descripción construida a partir de `NEW.email`. |
| `trg_users_after_update` | `tb_users` | UPDATE | AFTER | Traza la modificación en tb_logs, con USER() y descripción construida a partir de `NEW.id`. |
| `trg_users_after_delete` | `tb_users` | DELETE | AFTER | Traza la eliminación física en tb_logs, con USER() y descripción construida a partir de `OLD.id`. No realiza baja lógica. |
| `trg_categories_after_insert` | `tbc_categories` | INSERT | AFTER | Traza el alta en tb_logs, con USER() y descripción construida a partir de `NEW.id`, `NEW.name`, `NEW.status`. |
| `trg_categories_after_update` | `tbc_categories` | UPDATE | AFTER | Traza la modificación en tb_logs, con USER() y descripción construida a partir de `NEW.id`, `NEW.name`, `OLD.status`, `NEW.status`. |
| `trg_categories_after_delete` | `tbc_categories` | DELETE | AFTER | Traza la eliminación física en tb_logs, con USER() y descripción construida a partir de `OLD.id`, `OLD.name`, `OLD.status`. No realiza baja lógica. |
| `trg_tbc_payment_methods_types_after_insert` | `tbc_payment_methods_types` | INSERT | AFTER | Traza el alta en tb_logs, con USER() y descripción construida a partir de `NEW.ID`. |
| `trg_tbc_payment_methods_types_after_update` | `tbc_payment_methods_types` | UPDATE | AFTER | Traza la modificación en tb_logs, con USER() y descripción construida a partir de `NEW.ID`, `OLD.ID`. |
| `trg_tbc_payment_methods_types_after_delete` | `tbc_payment_methods_types` | DELETE | AFTER | Traza la eliminación física en tb_logs, con USER() y descripción construida a partir de `OLD.ID`. No realiza baja lógica. |
| `trg_tbd_address_components_after_insert` | `tbd_address_components` | INSERT | AFTER | Traza el alta en tb_logs, con USER() y descripción construida a partir de `NEW.ID`. |
| `trg_tbd_address_components_after_update` | `tbd_address_components` | UPDATE | AFTER | Traza la modificación en tb_logs, con USER() y descripción construida a partir de `NEW.ID`, `OLD.ID`. |
| `trg_tbd_address_components_after_delete` | `tbd_address_components` | DELETE | AFTER | Traza la eliminación física en tb_logs, con USER() y descripción construida a partir de `OLD.ID`. No realiza baja lógica. |
| `trg_tbd_carts_items_after_insert` | `tbd_carts_items` | INSERT | AFTER | Traza el alta en tb_logs, con USER() y descripción construida a partir de `NEW.cart_ID`, `NEW.provider_ID`, `NEW.product_ID`. |
| `trg_tbd_carts_items_after_update` | `tbd_carts_items` | UPDATE | AFTER | Traza la modificación en tb_logs, con USER() y descripción construida a partir de `NEW.cart_ID`, `NEW.provider_ID`, `NEW.product_ID`, `OLD.cart_ID`, `OLD.provider_ID`, `OLD.product_ID`. |
| `trg_tbd_carts_items_after_delete` | `tbd_carts_items` | DELETE | AFTER | Traza la eliminación física en tb_logs, con USER() y descripción construida a partir de `OLD.cart_ID`, `OLD.provider_ID`, `OLD.product_ID`. No realiza baja lógica. |
| `trg_tbd_order_items_after_insert` | `tbd_order_items` | INSERT | AFTER | Traza el alta en tb_logs, con USER() y descripción construida a partir de `NEW.ID`. |
| `trg_tbd_order_items_after_update` | `tbd_order_items` | UPDATE | AFTER | Traza la modificación en tb_logs, con USER() y descripción construida a partir de `NEW.ID`, `OLD.ID`. |
| `trg_tbd_order_items_after_delete` | `tbd_order_items` | DELETE | AFTER | Traza la eliminación física en tb_logs, con USER() y descripción construida a partir de `OLD.ID`. No realiza baja lógica. |
| `trg_product_categories_after_insert` | `tbd_products_categories` | INSERT | AFTER | Traza el alta en tb_logs, con USER() y descripción construida a partir de `NEW.id`, `NEW.product_id`, `NEW.category_id`, `NEW.status`. |
| `trg_product_categories_after_update` | `tbd_products_categories` | UPDATE | AFTER | Traza la modificación en tb_logs, con USER() y descripción construida a partir de `NEW.id`, `NEW.product_id`, `NEW.category_id`, `OLD.status`, `NEW.status`. |
| `trg_product_categories_after_delete` | `tbd_products_categories` | DELETE | AFTER | Traza la eliminación física en tb_logs, con USER() y descripción construida a partir de `OLD.id`, `OLD.product_id`, `OLD.category_id`, `OLD.status`. No realiza baja lógica. |
| `trg_product_providers_after_insert` | `tbd_products_users_providers` | INSERT | AFTER | Traza el alta en tb_logs, con USER() y descripción construida a partir de `NEW.id`, `NEW.product_id`, `NEW.provider_user_id`, `NEW.status`. |
| `trg_product_providers_after_update` | `tbd_products_users_providers` | UPDATE | AFTER | Traza la modificación en tb_logs, con USER() y descripción construida a partir de `NEW.id`, `NEW.product_id`, `NEW.provider_user_id`, `OLD.status`, `NEW.status`. |
| `trg_product_providers_after_delete` | `tbd_products_users_providers` | DELETE | AFTER | Traza la eliminación física en tb_logs, con USER() y descripción construida a partir de `OLD.id`, `OLD.product_id`, `OLD.provider_user_id`, `OLD.status`. No realiza baja lógica. |
| `trg_tbd_user_payment_methods_after_insert` | `tbd_user_payment_methods` | INSERT | AFTER | Traza el alta en tb_logs, con USER() y descripción construida a partir de `NEW.ID`. |
| `trg_tbd_user_payment_methods_after_update` | `tbd_user_payment_methods` | UPDATE | AFTER | Traza la modificación en tb_logs, con USER() y descripción construida a partir de `NEW.ID`, `OLD.ID`. |
| `trg_tbd_user_payment_methods_after_delete` | `tbd_user_payment_methods` | DELETE | AFTER | Traza la eliminación física en tb_logs, con USER() y descripción construida a partir de `OLD.ID`. No realiza baja lógica. |
| `trg_tbd_users_wishlist_products_after_insert` | `tbd_users_wishlist_products` | INSERT | AFTER | Traza el alta en tb_logs, con USER() y descripción construida a partir de `NEW.user_ID`, `NEW.product_ID`. |
| `trg_tbd_users_wishlist_products_after_update` | `tbd_users_wishlist_products` | UPDATE | AFTER | Traza la modificación en tb_logs, con USER() y descripción construida a partir de `NEW.user_ID`, `NEW.product_ID`, `OLD.user_ID`, `OLD.product_ID`. |
| `trg_tbd_users_wishlist_products_after_delete` | `tbd_users_wishlist_products` | DELETE | AFTER | Traza la eliminación física en tb_logs, con USER() y descripción construida a partir de `OLD.user_ID`, `OLD.product_ID`. No realiza baja lógica. |

</details>

<a id="verificacion"></a>

### Verificación reproducible

Estas consultas permiten contrastar el documento con el servidor sin modificar datos.

```sql
SELECT COUNT(*) AS tablas_fisicas FROM information_schema.TABLES
WHERE TABLE_SCHEMA = 'db_test' AND TABLE_TYPE = 'BASE TABLE';

SELECT COUNT(*) AS columnas_fisicas
FROM information_schema.COLUMNS c
JOIN information_schema.TABLES t
  ON t.TABLE_SCHEMA = c.TABLE_SCHEMA AND t.TABLE_NAME = c.TABLE_NAME
WHERE c.TABLE_SCHEMA = 'db_test' AND t.TABLE_TYPE = 'BASE TABLE';

SELECT EVENT_OBJECT_TABLE AS tabla, COUNT(*) AS triggers_por_tabla
FROM information_schema.TRIGGERS
WHERE TRIGGER_SCHEMA = 'db_test'
GROUP BY EVENT_OBJECT_TABLE ORDER BY EVENT_OBJECT_TABLE;

SELECT TRIGGER_NAME, EVENT_OBJECT_TABLE, EVENT_MANIPULATION, ACTION_TIMING, ACTION_STATEMENT
FROM information_schema.TRIGGERS
WHERE TRIGGER_SCHEMA = 'db_test'
ORDER BY EVENT_OBJECT_TABLE, EVENT_MANIPULATION;
```

Resultado esperado al corte: **16 tablas**, **128 columnas** y **45 triggers** (15 INSERT, 15 UPDATE y 15 DELETE).

---

## Anexo · Modelo físico DBML

<details>
<summary><strong>Consultar el código completo del modelo</strong> · 16 tablas y relaciones</summary>

```dbml
Project db_test {
  database_type: 'MySQL'
  Note: 'Modelo fisico consultado el 2026-10-21: 16 tablas y 45 triggers. Solo tb_users tiene deleted_at. Se conservan nombres, tipos e indices reales; no se agregan tablas de pagos inexistentes.'
}

Enum fulfillment_status {
  Pending
  Accepted
  Preparing
  Sent
  Delivered
  Canceled
  Returned
}

// SEGURIDAD Y PERSONAS

Table tb_users {
  id int [pk, increment, not null]
  email varchar(100) [null]
  nickname varchar(50) [null]
  password varchar(255) [null]
  status varchar(20) [null, default: 'active']
  creation_date datetime [null, default: `CURRENT_TIMESTAMP`]
  last_date datetime [null, default: `CURRENT_TIMESTAMP`, note: 'ON UPDATE CURRENT_TIMESTAMP']
  last_log datetime [null]
  deleted_at datetime [null]

  Note: 'Tiene 3 triggers de auditoria'
}

Table tb_people {
  id int [pk, increment, not null]
  user_id int [not null]
  first_name varchar(100) [not null]
  last_name varchar(100) [not null]
  second_last_name varchar(100) [null]
  birth_date date [null]
  gender varchar(30) [null]
  phone varchar(25) [null]
  nationality varchar(80) [null]
  status bit(1) [not null, default: `b'1'`]
  creation_date datetime [not null, default: `CURRENT_TIMESTAMP`]
  last_update datetime [null, note: 'ON UPDATE CURRENT_TIMESTAMP']

  indexes {
    user_id [unique, name: 'uk_people_user']
  }

  Note: 'Tiene 3 triggers de auditoria'
}

Table tb_logs {
  id int [pk, increment, not null]
  table_affected varchar(50) [null]
  operation varchar(20) [null]
  db_user varchar(100) [null]
  description text [null]
  operation_date datetime [null, default: `CURRENT_TIMESTAMP`]
  status tinyint [null, default: 1]

  Note: 'Sin triggers; recibe los registros de auditoria'
}

// CATALOGO Y PROVEEDORES

Table tbc_categories {
  id int [pk, increment, not null]
  name varchar(100) [not null]
  description text [null]
  status tinyint [not null, default: 1]
  created_at datetime [not null, default: `CURRENT_TIMESTAMP`]
  updated_at datetime [not null, default: `CURRENT_TIMESTAMP`, note: 'ON UPDATE CURRENT_TIMESTAMP']

  indexes {
    name [unique, name: 'uq_tbc_categories_name']
  }

  Note: 'Tiene 3 triggers de auditoria'
}

Table tb_products {
  id int [pk, increment, not null]
  SKU varchar(20) [not null]
  nombre_producto varchar(150) [not null]
  descripcion text [null]
  current_price decimal(10,2) [not null]
  current_stock int [not null]
  status tinyint [not null]
  creation_date datetime [not null]
  last_update datetime [not null]

  Note: 'Tiene 3 triggers de auditoria'
}

Table tbd_products_categories {
  id int [pk, increment, not null]
  product_id int [not null]
  category_id int [not null]
  status tinyint [not null, default: 1]
  created_at datetime [not null, default: `CURRENT_TIMESTAMP`]
  updated_at datetime [not null, default: `CURRENT_TIMESTAMP`, note: 'ON UPDATE CURRENT_TIMESTAMP']

  indexes {
    category_id [name: 'idx_product_categories_category']
    (product_id, category_id) [unique, name: 'uq_product_category']
  }

  Note: 'Tiene 3 triggers de auditoria'
}

Table tbd_products_users_providers {
  id int [pk, increment, not null]
  product_id int [not null]
  provider_user_id int [not null]
  provider_sku varchar(100) [null]
  unit_cost decimal(10,2) [null]
  lead_time_days "smallint unsigned" [null]
  is_primary tinyint [not null, default: 0]
  status tinyint [not null, default: 1]
  created_at datetime [not null, default: `CURRENT_TIMESTAMP`]
  updated_at datetime [not null, default: `CURRENT_TIMESTAMP`, note: 'ON UPDATE CURRENT_TIMESTAMP']

  indexes {
    provider_user_id [name: 'idx_product_providers_user']
    (product_id, provider_user_id) [unique, name: 'uq_product_provider']
  }

  Note: 'Tiene 3 triggers de auditoria'
}

// PEDIDOS

Table tb_buyer_orders {
  ID "int unsigned" [pk, increment, not null]
  seller_ID int [not null]
  subtotal decimal(12,2) [not null, default: 0.00]
  shipping_cost decimal(12,2) [not null, default: 0.00]
  fulfillment_status fulfillment_status [not null, default: 'Pending']
  status bit(1) [not null, default: `b'1'`]
  creation_date datetime [not null, default: `CURRENT_TIMESTAMP`]
  last_update datetime [null, note: 'ON UPDATE CURRENT_TIMESTAMP']

  indexes {
    seller_ID [name: 'seller_ID']
  }

  Note: 'Tiene 3 triggers de auditoria; CHECK: tb_buyer_orders_chk_1: (`subtotal` >= 0); tb_buyer_orders_chk_2: (`shipping_cost` >= 0)'
}

Table tbd_order_items {
  ID "int unsigned" [pk, increment, not null]
  seller_order_ID "int unsigned" [not null]
  product_ID int [not null]
  provider_ID int [not null]
  product_name varchar(255) [not null]
  quantity "int unsigned" [not null]
  unit_price decimal(12,2) [not null]
  subtotal decimal(12,2) [null, note: 'GENERATED ALWAYS AS ((`quantity` * `unit_price`)) STORED']
  creation_date datetime [not null, default: `CURRENT_TIMESTAMP`]

  indexes {
    product_ID [name: 'product_ID']
    provider_ID [name: 'provider_ID']
    seller_order_ID [name: 'seller_order_ID']
  }

  Note: 'Tiene 3 triggers de auditoria; CHECK: tbd_order_items_chk_1: (`quantity` > 0); tbd_order_items_chk_2: (`unit_price` >= 0)'
}

// CARRITOS Y DESEOS

Table tb_carts {
  ID "int unsigned" [pk, increment, not null]
  user_ID int [not null]
  status bit(1) [null, default: `b'1'`]
  creation_date datetime [not null, default: `CURRENT_TIMESTAMP`]
  last_update datetime [null, note: 'ON UPDATE CURRENT_TIMESTAMP']

  indexes {
    user_ID [unique, name: 'uk_cart_user']
  }

  Note: 'Tiene 3 triggers de auditoria'
}

Table tbd_carts_items {
  cart_ID "int unsigned" [not null]
  provider_ID int [not null]
  product_ID int [not null]
  quantity "int unsigned" [not null, default: 1]
  creation_date datetime [not null, default: `CURRENT_TIMESTAMP`]

  indexes {
    (cart_ID, provider_ID, product_ID) [pk]
    product_ID [name: 'product_ID']
    provider_ID [name: 'provider_ID']
  }

  Note: 'Tiene 3 triggers de auditoria; CHECK: chk_cart_quantity: (`quantity` > 0)'
}

Table tbd_users_wishlist_products {
  user_ID int [not null]
  product_ID int [not null]
  status bit(1) [not null, default: `b'1'`]
  creation_date datetime [not null, default: `CURRENT_TIMESTAMP`]
  last_update datetime [not null, note: 'ON UPDATE CURRENT_TIMESTAMP']

  indexes {
    product_ID [name: 'fk_products3']
    (user_ID, product_ID) [pk]
  }

  Note: 'Tiene 3 triggers de auditoria'
}

// DIRECCIONES

Table tb_user_addresses {
  ID "bigint unsigned" [pk, increment, not null]
  user_ID int [not null]
  address_label varchar(100) [not null]
  recipient_name varchar(150) [null]
  recipient_phone varchar(25) [null]
  delivery_instructions varchar(500) [null]
  latitude decimal(10,7) [null]
  longitude decimal(10,7) [null]
  is_default tinyint(1) [not null, default: 0]
  status bit(1) [not null, default: `b'1'`]
  creation_date datetime [not null, default: `CURRENT_TIMESTAMP`]
  last_update datetime [null, note: 'ON UPDATE CURRENT_TIMESTAMP']

  indexes {
    user_ID [name: 'idx_user_addresses']
  }

  Note: 'Tiene 3 triggers de auditoria; CHECK: chk_coordinates: (((`latitude` is null) and (`longitude` is null)) or ((`latitude` is not null) and (`longitude` is not null))); chk_latitude: (`latitude` between -(90) and 90); chk_longitude: (`longitude` between -(180) and 180)'
}

Table tbd_address_components {
  ID "bigint unsigned" [pk, increment, not null]
  address_ID "bigint unsigned" [not null]
  value varchar(255) [not null]
  component_type varchar(50) [not null]
  status bit(1) [not null, default: `b'1'`]
  address_sup_ID "bigint unsigned" [null]
  creation_date datetime [not null, default: `CURRENT_TIMESTAMP`]
  last_update datetime [null, note: 'ON UPDATE CURRENT_TIMESTAMP']

  indexes {
    (address_ID, address_sup_ID) [name: 'idx_address_parent']
    (address_ID, ID) [unique, name: 'uk_address_component']
  }

  Note: 'Tiene 3 triggers de auditoria'
}

// METODOS DE PAGO

Table tbc_payment_methods_types {
  ID "int unsigned" [pk, increment, not null]
  code varchar(30) [not null]
  description text [not null]
  status bit(1) [not null, default: `b'1'`]
  creation_date datetime [not null, default: `CURRENT_TIMESTAMP`]
  last_update datetime [null, note: 'ON UPDATE CURRENT_TIMESTAMP']

  indexes {
    code [unique, name: 'code_UNIQUE']
  }

  Note: 'Tiene 3 triggers de auditoria'
}

Table tbd_user_payment_methods {
  ID "bigint unsigned" [pk, increment, not null]
  user_ID int [not null]
  payment_method_type_ID "int unsigned" [not null]
  provider varchar(60) [not null]
  provider_method_ref varchar(255) [not null]
  label varchar(100) [null]
  last_four char(4) [null]
  is_default tinyint(1) [not null, default: 0]
  status bit(1) [not null, default: `b'1'`]
  creation_date datetime [not null, default: `CURRENT_TIMESTAMP`]
  last_update datetime [null, note: 'ON UPDATE CURRENT_TIMESTAMP']

  indexes {
    payment_method_type_ID [name: 'payment_method_type_ID']
    (provider, provider_method_ref) [unique, name: 'uk_provider_method']
    user_ID [name: 'user_ID']
  }

  Note: 'Tiene 3 triggers de auditoria'
}

// RELACIONES FISICAS (incluida la referencia compuesta de direcciones)

Ref tb_buyer_orders_ibfk_1: tb_buyer_orders.seller_ID > tb_users.id [delete: no action, update: no action]
Ref tb_carts_ibfk_1: tb_carts.user_ID - tb_users.id [delete: no action, update: no action]
Ref fk_people_user: tb_people.user_id - tb_users.id [delete: restrict, update: cascade]
Ref fk_addresses_users: tb_user_addresses.user_ID > tb_users.id [delete: no action, update: no action]
Ref fk_component_address: tbd_address_components.address_ID > tb_user_addresses.ID [delete: restrict, update: no action]
Ref fk_component_parent: tbd_address_components.(address_ID, address_sup_ID) > tbd_address_components.(address_ID, ID) [delete: restrict, update: no action]
Ref tbd_carts_items_ibfk_1: tbd_carts_items.cart_ID > tb_carts.ID [delete: no action, update: no action]
Ref tbd_carts_items_ibfk_2: tbd_carts_items.provider_ID > tbd_products_users_providers.provider_user_id [delete: no action, update: no action]
Ref tbd_carts_items_ibfk_3: tbd_carts_items.product_ID > tbd_products_users_providers.product_id [delete: no action, update: no action]
Ref tbd_order_items_ibfk_1: tbd_order_items.seller_order_ID > tb_buyer_orders.ID [delete: no action, update: no action]
Ref tbd_order_items_ibfk_2: tbd_order_items.product_ID > tbd_products_users_providers.product_id [delete: no action, update: no action]
Ref tbd_order_items_ibfk_3: tbd_order_items.provider_ID > tbd_products_users_providers.provider_user_id [delete: no action, update: no action]
Ref fk_product_categories_category: tbd_products_categories.category_id > tbc_categories.id [delete: restrict, update: cascade]
Ref fk_product_categories_product: tbd_products_categories.product_id > tb_products.id [delete: restrict, update: cascade]
Ref fk_product_providers_product: tbd_products_users_providers.product_id > tb_products.id [delete: restrict, update: cascade]
Ref fk_product_providers_user: tbd_products_users_providers.provider_user_id > tb_users.id [delete: restrict, update: cascade]
Ref tbd_user_payment_methods_ibfk_1: tbd_user_payment_methods.user_ID > tb_users.id [delete: no action, update: no action]
Ref tbd_user_payment_methods_ibfk_2: tbd_user_payment_methods.payment_method_type_ID > tbc_payment_methods_types.ID [delete: no action, update: no action]
Ref fk_products3: tbd_users_wishlist_products.product_ID > tb_products.id [delete: no action, update: no action]
Ref fk_user2: tbd_users_wishlist_products.user_ID > tb_users.id [delete: no action, update: no action]
```

</details>
