# Proyecto Estructuras - Sistema de Navegación e IA en Godot 4

Un proyecto educativo de juego 3D desarrollado en **Godot 4** que implementa algoritmos de búsqueda de caminos (**A\*, Dijkstra, DFS**) para navegación de personajes y enemigos en una grilla discreta.

## 📋 Descripción

Este proyecto demostra cómo crear un sistema completo de:

- **Navegación basada en grilla**: Conversión de mundo 3D a cuadrícula discreta
- **Algoritmos de búsqueda de caminos**:
  - **A\***: Búsqueda óptima y rápida con heurística
  - **Dijkstra**: Búsqueda sin heurística, garantiza camino más corto
  - **DFS**: Búsqueda en profundidad para comparación
- **Sistema de IA**: Estados (IDLE, CHASE, ATTACK, DEAD) para enemigos
- **Movimiento del jugador**: Control basado en clics con cámara seguidor
- **Interfaz de usuario**: HUD con barras de salud y estados

## 🎮 Características

- ✅ Personaje jugador controlable por ratón
- ✅ Enemigos inteligentes que persiguen y atacan
- ✅ Navegación automática sorteando obstáculos
- ✅ Sistema de combate y vida
- ✅ Menú principal y transiciones de escenas
- ✅ Cámara cinemática que sigue al personaje

## 📁 Estructura del Proyecto

```
proyecto-estructuras/
├── GestorCuadricula.gd          # Motor de búsqueda de caminos
├── Nodo.gd                      # Celda individual de la grilla
├── MovimientoJugador.gd         # Control del jugador
├── InteligenciaEnemigo.gd       # IA de enemigos
├── ManejadorEntrada.gd          # Input del ratón
├── CamaraSeguimiento.gd         # Cámara dinámica
├── InterfazUsuario.gd           # HUD y UI
├── MenuPrincipal.gd             # Menú inicial
├── main_player.tscn             # Escena del jugador
├── EnemyUnit.tscn               # Escena del enemigo
├── mundo.tscn                   # Escena principal
├── main_menu.tscn               # Escena de menú
├── suelo/                       # Terreno y texturas
├── heroe/                       # Modelos y animaciones del jugador
├── enemigo/                     # Modelos y animaciones de enemigos
├── KayKit_Forest_Nature_Pack/   # Assets de naturaleza
├── modular_terrain_collections/ # Terrenos modulares
└── project.godot                # Configuración del proyecto
```

## 📚 Algoritmos Implementados

### A\* (A-Star)
Combina el costo desde el inicio (**g**) con una heurística al destino (**h**):
- Fórmula: `f = g + h`
- **Ventaja**: Óptimo y rápido
- **Uso**: Navegación en tiempo real de enemigos

### Dijkstra
Búsqueda sin heurística (h = 0):
- Explora por distancia creciente
- **Ventaja**: Garantiza camino más corto sin heurística
- **Uso**: Casos donde se necesita garantía absoluta

### DFS (Depth-First Search)
Exploración en profundidad:
- **Ventaja**: Bajo costo de memoria
- **Desventaja**: No garantiza camino óptimo
- **Uso**: Demostrativo o exploraciones especiales

## 🚀 Cómo Usar

### Requisitos
- Godot 4.x
- Extensión opcional: Godot Asset Library

### Instalación

1. Clona el repositorio:
```bash
git clone https://github.com/tu-usuario/proyecto-estructuras.git
cd proyecto-estructuras
```

2. Abre el proyecto en Godot 4:
```bash
godot --path .
```

3. En el editor, presiona **F5** o **Play** para ejecutar

### Controles en Juego

- **Clic izquierdo**: Mover personaje al destino
- **ESC**: Volver al menú principal
- Los enemigos persiguen automáticamente al jugador

## 📖 Documentación Detallada

Para más detalles técnicos sobre cada script, algoritmo y mecanismos de búsqueda, consulta:
- [`documentacion.txt`](documentacion.txt) - Descripción completa de todos los scripts

## 🎓 Conceptos Educativos

Este proyecto es ideal para aprender:
- Estructuras de datos (grillas, colas de prioridad)
- Algoritmos de búsqueda (A\*, Dijkstra, DFS)
- Máquinas de estados para IA
- Diseño de sistemas en Godot
- Raycasting para detección de obstáculos

## 🛠 Tecnologías

- **Engine**: Godot 4
- **Lenguaje**: GDScript
- **3D**: Modelos FBX/GLB importados
- **Assets**: KayKit Forest Nature Pack, Modular Terrain Collections

## 📝 Notas de Desarrollo

- **Optimización**: Para mapas grandes, ajusta el tamaño de celda en `GestorCuadricula.gd`
- **Frecuencia de recálculo**: La IA recalcula rutas cada 0.5-1s para optimizar
- **Heurística**: Se usa distancia Manhattan/Euclidiana según necesidad

## 🤝 Contribuciones

Las contribuciones son bienvenidas. Para cambios mayores:
1. Fork el proyecto
2. Crea una rama (`git checkout -b feature/mejora`)
3. Commit tus cambios (`git commit -m "Agrega mejora"`)
4. Push a la rama (`git push origin feature/mejora`)
5. Abre un Pull Request

## 📄 Licencia

Este proyecto está bajo la licencia MIT. Consulta `LICENSE` para más detalles.

## 👤 Autor

Desarrollado como proyecto educativo de estructuras de datos y algoritmos.

---

**¿Preguntas?** Abre un issue o revisa la documentación técnica en `documentacion.txt`.
