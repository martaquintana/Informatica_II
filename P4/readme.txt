--- Marta Quintana Portales Práctica 4  de Informática 2   ISAM

En la entrega de esta práctica he introducido en cada carpeta de las tablas hash sus ejemplos de prueba.
Adicionalmente en hash_maps_g_open he añadido el ejercicio 1 de Debug de los Ejercicios
de Hash Tables (los últimos ejercicios que subiste).

En ordered_maps_g he añadido dos ejemplos_test uno con Números y otro con Unbounded Strings.

El cliente se compila:
gnatmake -I/usr/local/ll/lib chat_client_3.adb

Para probar la tabla de símbolos de clientes activos como Tabla Hash
con encadenamiento compilar el server de la siguiente manera:

gnatmake -I/usr/local/ll/lib -I./hash_maps_g_chaining -I./ordered_maps_g  chat_server_3.adb


Para probar la tabla de símbolos de clientes activos como Tabla Hash
con direccionamiento abierto compilar el server de la siguiente manera:

gnatmake -I/usr/local/ll/lib -I./hash_maps_g_open -I./ordered_maps_g  chat_server_3.adb
