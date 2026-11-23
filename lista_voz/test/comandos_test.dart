import 'package:flutter_test/flutter_test.dart';
import 'package:lista_voz/comandos.dart';

void main() {
  group('Pruebas unitarias de interpretación de comandos por voz', () {
    // En este test verifico que no importan mayúsculas, minúsculas ni tildes para añadir
    test('1. Normalización de mayúsculas y tildes para añadir', () {
      expect(interpretarComando('Añade'), equals(Comando.anadir));
      expect(interpretarComando('anade'), equals(Comando.anadir));
      expect(interpretarComando('AÑADIR'), equals(Comando.anadir));
      expect(interpretarComando('añadir'), equals(Comando.anadir));
    });

    // En este test compruebo que se aceptan todos los sinónimos requeridos para añadir
    test('2. Sinónimos del comando añadir (nuevo, crear)', () {
      expect(interpretarComando('nuevo'), equals(Comando.anadir));
      expect(interpretarComando('crear'), equals(Comando.anadir));
      expect(interpretarComando('agregar'), equals(Comando.anadir));
    });

    // En este test verifico los sinónimos para la acción de borrar
    test('3. Sinónimos del comando borrar (borrar, borra, eliminar, quitar)', () {
      expect(interpretarComando('borrar'), equals(Comando.borrar));
      expect(interpretarComando('borra'), equals(Comando.borrar));
      expect(interpretarComando('eliminar'), equals(Comando.borrar));
      expect(interpretarComando('quitar'), equals(Comando.borrar));
    });

    // En este test valido los sinónimos para el comando leer
    test('4. Sinónimos del comando leer (leer, lee, cuántos, lista)', () {
      expect(interpretarComando('leer'), equals(Comando.leer));
      expect(interpretarComando('lee'), equals(Comando.leer));
      expect(interpretarComando('cuántos'), equals(Comando.leer));
      expect(interpretarComando('cuantos'), equals(Comando.leer));
      expect(interpretarComando('lista'), equals(Comando.leer));
    });

    // En este test compruebo los sinónimos para solicitar ayuda
    test('5. Sinónimos del comando ayuda (ayuda, comandos)', () {
      expect(interpretarComando('ayuda'), equals(Comando.ayuda));
      expect(interpretarComando('comandos'), equals(Comando.ayuda));
    });

    // En este test demuestro que la orden se reconoce insertada en una frase compleja
    test('6. Reconocimiento de orden dentro de una frase natural', () {
      expect(interpretarComando('por favor añade uno'), equals(Comando.anadir));
      expect(interpretarComando('quiero borrar un elemento'), equals(Comando.borrar));
      expect(interpretarComando('dime cuántos elementos hay'), equals(Comando.leer));
      expect(interpretarComando('necesito ayuda por favor'), equals(Comando.ayuda));
    });

    // En este test compruebo que cadenas vacías o con solo espacios devuelven desconocido
    test('7. Manejo seguro de texto vacío o con espacios en blanco', () {
      expect(interpretarComando(''), equals(Comando.desconocido));
      expect(interpretarComando('   '), equals(Comando.desconocido));
    });

    // En este test aseguro que frases no relacionadas se catalogan como desconocidas
    test('8. Clasificación de órdenes desconocidas o sin palabras clave', () {
      expect(interpretarComando('hola qué tal hace buen tiempo'), equals(Comando.desconocido));
      expect(interpretarComando('abrir navegador'), equals(Comando.desconocido));
    });
  });
}
