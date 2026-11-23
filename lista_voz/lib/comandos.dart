/// Enumero aquí los comandos admitidos por la aplicación.
/// Este enum representa las acciones naturales que el usuario puede solicitar mediante voz o botones.
enum Comando {
  anadir,
  borrar,
  leer,
  ayuda,
  desconocido,
}

/// En esta función auxiliar normalizo el texto de entrada:
/// Paso todo a minúsculas, elimino tildes/diéresis y convierto la 'ñ' en 'n'
/// para que no haya discrepancias fonéticas o de teclado entre «Añade», «anade» y «AÑADIR».
String normalizarTexto(String entrada) {
  // Convierto a minúsculas y quito espacios en los extremos
  var texto = entrada.toLowerCase().trim();

  // Mapeo de caracteres con tilde o especiales a sus equivalentes planos
  const origen = 'áéíóúüñÁÉÍÓÚÜÑ';
  const destino = 'aeiouunaeiouun';

  for (int i = 0; i < origen.length; i++) {
    texto = texto.replaceAll(origen[i], destino[i]);
  }

  // Elimino signos de puntuación comunes para aislar palabras limpias
  texto = texto.replaceAll(RegExp(r'[^\w\s]'), ' ');

  return texto;
}

/// Aquí implemento la lógica de interpretación de órdenes en Dart puro.
/// Recibo la frase capturada por el micrófono y determino qué acción desea ejecutar el usuario.
Comando interpretarComando(String texto) {
  // Primero normalizo el texto recibido para asegurar una comparación sin fallos
  final normalizado = normalizarTexto(texto);

  // Si el texto resultante está vacío, devuelvo directamente desconocido
  if (normalizado.isEmpty) {
    return Comando.desconocido;
  }

  // Desgloso el texto en palabras individuales para evaluar la presencia de términos clave
  final palabras = normalizado.split(RegExp(r'\s+')).where((p) => p.isNotEmpty).toList();

  // Defino los conjuntos de sinónimos para cada comando según la especificación
  const sinonimosAnadir = {'anadir', 'anade', 'nuevo', 'crear', 'agregar', 'agrega'};
  const sinonimosBorrar = {'borrar', 'borra', 'eliminar', 'elimina', 'quitar', 'quita'};
  const sinonimosLeer = {'leer', 'lee', 'cuantos', 'cuantas', 'lista'};
  const sinonimosAyuda = {'ayuda', 'comandos', 'comando'};

  // Compruebo si alguna palabra de la frase coincide con los sinónimos de añadir
  if (palabras.any((p) => sinonimosAnadir.contains(p))) {
    return Comando.anadir;
  }

  // Compruebo si alguna palabra coincide con los sinónimos de borrar
  if (palabras.any((p) => sinonimosBorrar.contains(p))) {
    return Comando.borrar;
  }

  // Compruebo si alguna palabra coincide con los sinónimos de leer
  if (palabras.any((p) => sinonimosLeer.contains(p))) {
    return Comando.leer;
  }

  // Compruebo si alguna palabra coincide con los sinónimos de ayuda
  if (palabras.any((p) => sinonimosAyuda.contains(p))) {
    return Comando.ayuda;
  }

  // Si ninguna orden coincide, devuelvo comando desconocido
  return Comando.desconocido;
}
