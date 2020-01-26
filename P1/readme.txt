--Marta Quintana Portales ISAM  Práctica 1 INFORMÁTICA 2

--Este programa lee un fichero y cuenta el número de veces que sale cada palabra
--e imprime la palabra más frecuente:  ./words <fichero>
--También hay una opción de menú:  ./words -i <fichero>
--y puedes elegir que Añada(1), Elimine(2), Busque(3) una palabra o
--que las Imprima(4) todas, al Salir(5) te dice la más frecuente.


En esta práctica está implementado todo lo que pone en el guión y adicionalmente,
he hecho las 3 extensiones.

He tenido en cuenta las siguientes consideraciones que no estaban especificadas:

* Cuando salta la excepción Word_List_Error escribe por pantalla "No words." ya sea
en la búsqueda de una palabra que no está o que la lista esté vacía.

*En la extensión 1, solo he tenido en cuenta que los signos de puntuación: espacio, coma, punto y guión.

*Las palabras siempre se van a  guardar en minuscula.

* He añadido el Constraint_Error, cuando está el menú, si lee una opción que no está o pones letras salta el mensaje "Sorry, options are only 1, 2, 3, 4 or 5"
y vuelve a aparecer el menú.
