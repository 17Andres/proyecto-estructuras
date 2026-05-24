# Proyecto Estructuras

Proyecto educativo desarrollado en **Godot 4** para practicar estructuras de datos, algoritmos de búsqueda de caminos e inteligencia artificial en un entorno 3D.

El proyecto actualmente es un juego 3D donde un jugador puede moverse por un escenario, atacar enemigos y ser perseguido por IA enemiga usando una grilla de navegación. La escena principal combina terreno, personajes animados, detección de obstáculos, combate, vida, HUD y menú principal.

## Estado actual del proyecto

- Proyecto de Godot 4 configurado con la escena principal `mundo.tscn`.
- Menú principal en `main_menu.tscn`, con botones para jugar, abrir un editor si existe y salir.
- Jugador 3D con animaciones, movimiento por clic y movimiento directo con teclado.
- Enemigos 3D con IA de persecución, ataque, muerte y celebración.
- Sistema de grilla para convertir posiciones del mundo 3D a celdas navegables.
- Algoritmos de búsqueda implementados: A*, Dijkstra y DFS.
- Sistema de combate con vida del jugador, vida de enemigos, ataque y pantalla de derrota.
- Cámara de seguimiento para acompañar al jugador.
- Terreno y assets visuales en carpetas como `suelo/`, `heroe/`, `enemigo/`, `KayKit_Forest_Nature_Pack_1.0_FREE/` y `modular_terrain_collections/`.

## Controles

- `W`, `A`, `S`, `D`: mover el jugador manualmente.
- Flechas del teclado: también permiten mover el jugador.
- Clic izquierdo sobre el suelo: calcular una ruta y mover al jugador hacia ese punto.
- Clic derecho: atacar enemigos cercanos.
- Botones del menú: iniciar partida, intentar abrir editor de niveles o salir.

Cuando se usa movimiento manual, se cancela la ruta calculada por clic para que el jugador responda directamente al teclado.

## Sistemas principales

### Grilla y búsqueda de caminos

El script `GestorCuadricula.gd` crea una grilla de navegación sobre el mundo 3D. Cada celda se representa con `Nodo.gd`, que guarda:

- coordenada de grilla;
- posición en el mundo;
- si es obstáculo o no;
- costos `g`, `h` y `f`;
- referencia al nodo padre para reconstruir caminos.

La grilla usa raycasts para detectar obstáculos y marcar celdas no transitables. Los vecinos incluyen movimientos horizontales, verticales y diagonales.

Algoritmos disponibles:

- **A\***: algoritmo principal para rutas rápidas hacia un destino usando heurística.
- **Dijkstra**: busca camino por costo acumulado sin heurística.
- **DFS**: búsqueda en profundidad, incluida como comparación educativa.

El algoritmo que usa el clic del mouse se puede seleccionar desde `ManejadorEntrada.gd` mediante la propiedad exportada `algoritmo`.

### Jugador

El script `MovimientoJugador.gd` controla al personaje principal. Actualmente incluye:

- estados `IDLE`, `MOVIENDOSE`, `FRENANDO`, `MUERTO` y `ATACANDO`;
- movimiento por rutas calculadas con la grilla;
- movimiento manual con WASD o flechas;
- rotación suavizada usando `atan2`;
- vida máxima configurable;
- ataque con rango, daño e intervalo;
- animaciones de caminar, reposo, muerte y ataque;
- notificación al HUD cuando cambia la vida;
- pantalla de derrota cuando el jugador muere.

### Entrada del jugador

`ManejadorEntrada.gd` procesa el mouse:

- lanza un raycast desde la cámara hacia el suelo;
- valida que el destino esté dentro del mapa;
- ignora destinos marcados como obstáculos;
- calcula el camino usando A*, Dijkstra o DFS;
- envía el camino al jugador con `establecer_camino`.

### Enemigos

`InteligenciaEnemigo.gd` controla los enemigos. Cada enemigo:

- se registra en el grupo `enemigos`;
- detecta al jugador dentro de una distancia configurable;
- recalcula ruta cada cierto intervalo usando A*;
- persigue al jugador si lo detecta;
- ataca si entra en rango;
- recibe daño del jugador;
- muestra una barra de vida sobre el modelo;
- reproduce animación de muerte y se elimina;
- celebra la victoria si el jugador muere.

Estados principales del enemigo:

- `PATRULLANDO`
- `PERSIGUIENDO`
- `ATACANDO`
- `MUERTO`
- `CELEBRANDO`

### Interfaz de usuario

`InterfazUsuario.gd` maneja el HUD:

- actualiza la barra de vida del jugador;
- muestra una pantalla de derrota;
- permite volver al menú principal después de perder.

### Menú principal

`MenuPrincipal.gd` controla `main_menu.tscn`:

- botón de jugar: carga `mundo.tscn`;
- botón de editor: intenta abrir `editor.tscn` si existe;
- botón de salir: cierra el juego.

## Estructura del proyecto

```text
proyecto-estructuras/
|-- project.godot                    # Configuración del proyecto Godot
|-- mundo.tscn                       # Escena principal del juego
|-- main_menu.tscn                   # Menú principal
|-- main_player.tscn                 # Escena del jugador
|-- EnemyUnit.tscn                   # Escena base del enemigo
|-- GestorCuadricula.gd              # Grilla y algoritmos A*, Dijkstra y DFS
|-- Nodo.gd                          # Nodo/celda usado por la grilla
|-- MovimientoJugador.gd             # Movimiento, vida y combate del jugador
|-- ManejadorEntrada.gd              # Clics, raycast y selección de algoritmo
|-- InteligenciaEnemigo.gd           # IA, persecución, ataque y vida del enemigo
|-- InterfazUsuario.gd               # HUD y pantalla de derrota
|-- MenuPrincipal.gd                 # Lógica del menú principal
|-- CamaraSeguimiento.gd             # Seguimiento de cámara
|-- documentacion.txt                # Documentación técnica adicional
|-- suelo/                           # Escenas y texturas del suelo
|   |-- suelo.tscn
|   |-- pasto.tscn
|   `-- tierra.tscn
|-- heroe/                           # Modelo y animaciones del jugador
|-- enemigo/                         # Modelo y animaciones de enemigos
|-- KayKit_Forest_Nature_Pack_1.0_FREE/
`-- modular_terrain_collections/
```

## Capas de física

El proyecto define capas 3D en `project.godot`:

- capa 1: `suelo`;
- capa 2: `jugador`;
- capa 3: `obstaculos`.

Estas capas se usan para raycasts, detección de suelo, obstáculos y movimiento.

## Cómo ejecutar

### Requisitos

- Godot 4.x.
- Se recomienda abrir el proyecto directamente desde el editor de Godot.

### Pasos

1. Clonar el repositorio:

```bash
git clone https://github.com/17Andres/proyecto-estructuras.git
cd proyecto-estructuras
```

2. Abrir la carpeta del proyecto en Godot 4.

3. Ejecutar con **F5** o el botón **Play**.

La escena principal configurada en `project.godot` es `mundo.tscn`.

## Objetivo educativo

Este proyecto sirve para estudiar:

- representación de mapas con grillas;
- nodos y relaciones entre celdas;
- costos de movimiento y reconstrucción de caminos;
- algoritmos A*, Dijkstra y DFS;
- raycasting en Godot;
- máquinas de estado para jugador y enemigos;
- integración entre entrada, IA, combate, animaciones y UI.

## Documentación adicional

Para una explicación más técnica de los scripts, revisar:

- `documentacion.txt`

## Licencia

Este proyecto usa licencia MIT. Ver `LICENSE` para más detalles.

## Autor

Proyecto educativo de estructuras de datos y algoritmos desarrollado en Godot 4.
