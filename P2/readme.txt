--Marta Quintana Portales ISAM  Práctica 2 INFORMÁTICA 2

Esta práctica es un chat del modelo cliente/cliente servidor.
El cliente puede ser lector (nickname: reader) o escritor (cualquier nickname).
El server se encarga de recibir los mensajes de los escritores y mandárselos a los lectores.


Para la resolución de esta práctica he tendido en cuenta que:

* Si ya esta conectado un writer que se llama por ejemplo "marta" y otro writer quiere entrar con el nombre de MARTA, este último se ignorá.
Siempre guardo todos los escritores en minúscula y se compararán en minúscula también. Por lo tanto marta = MARTA = Marta ...

* He tenido en cuenta los errores de introducir los argumentos por el terminal, con Usage_Error.

* El cliente que es reader si espera 60 segundos y no tiene respuesta del servidor se apaga.

* Si hay cualquier error distinto a Usage_Error o a Client Colection Error salta un error de "Excepción imprevista ..."


Además de la parte básica, he hecho la extensión de la práctica que consiste en hacer un administrador que muestra un menú con las diferentes
opciones:
(para poder hacer implementar las opciones del menú la contraseña debe ser la misma que la introducida en el chat Server,
sino dará error )
Las opciones son:
(1) Ver la colección de escritores del servidor.
(2) Borrar un escritor, para ello debe indicar cual es el nick del escritor que quiere borrar.
(3) Apagar el servidor
(4) Salir

Cuando la contraseña es incorrecta mis errores son los siguentes:
(1) acaba el programa admin e imprime "Incorrect password".
(2) vuelve a mostrar el menú solo que el sevidor le ignora.
(3) "          "            "                     "       sigue con el menú.

Para lanzar los programas:

./chat_client <host sever>  <port sever> <nickname>
./chat_server  <port sever> <password>
./chat_admin <host sever>  <port sever> <password>
