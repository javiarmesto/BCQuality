# BCQuality: la vara común de Microsoft para humanos y agentes en Business Central

El 16 de abril Microsoft creó un repositorio pequeño, MIT, todavía sin anuncio formal. Se llama BCQuality y la descripción del repo lo resume bien: *"Quality skills and knowledge for Business Central development. The shared bar for humans and agents alike."*

A primera vista parece otro repositorio de buenas prácticas. 99 knowledge files en la capa Microsoft, 14 más en la comunidad, 4 skills globales (1 entry-point y 3 meta-skill contracts), 7 review skills, una rama `main` y un único code owner declarado (Jesper Schulz, Microsoft). A medida que lo vas leyendo, sin embargo, lo que más me ha llamado la atención no es el inventario sino la lógica que han usado para decidir qué entra dentro del repo y qué se queda fuera. Vale la pena entenderla porque condiciona todo lo demás.

### La regla de admisión

BCQuality se presenta como una base de conocimiento **remedial**. Para que un fichero entre, los autores se hacen una pregunta:

> Si este fichero no existiera, ¿se equivocaría un LLM moderno generando o revisando código BC en algo que este fichero habría evitado?

Si la respuesta es no — porque la guía es genérica, o porque el modelo ya domina el mecanismo — el fichero no acaba en el repo, por correcto y relevante que sea su contenido. La regla suena dura escrita así, pero se entiende mejor con un par de ejemplos.

Imagina estas dos frases. La primera la encontrarás dentro de BCQuality. La segunda no.

> *"SetLoadFields debe llamarse antes de los filtros, no después."*
>
> *"No hardcodees secretos."*

Las dos son ciertas y las dos son buenas prácticas. La diferencia está en cómo se comporta un LLM cuando no se las recuerdas. La segunda la aplica de oficio cualquier modelo decente: si le pides un servicio que llama a una API, te devuelve código que lee la credencial de un secret store, no un literal en el `.al`. La primera, en cambio, se le escapa con facilidad. Si le pides reordenar el código y poner `SetLoadFields` después de los `SetRange` porque "queda más limpio leerlo así", lo hace sin objetar — y el plan de query no replega los campos como tú esperabas. El orden importa, pero es uno de esos detalles del runtime BC que el modelo no tiene fijado.

Esa es la idea del filtro remedial: incluir solo el conocimiento que un LLM no aplica por sí mismo. El README pone más ejemplos del mismo corte. Encajan: *"FindSet(true)"* (que tiene un `LockTable` implícito y la firma de dos parámetros está obsoleta) o *"CodeCop AA0233"* (regla específica con número que el modelo no conoce). En cambio, no encajan: *"usa HTTPS en lugar de HTTP"* o *"mantén las transacciones cortas"*. Son verdades importantes, pero los autores prefieren no añadirlas porque cualquier LLM moderno ya las cumple sin que se lo recuerdes.

Esta regla cambia cómo se mide el éxito de un repo así. La pregunta deja de ser *"¿cuántas reglas tenemos?"* y pasa a ser *"¿cuántas veces el agente se equivocó porque le faltaba un fichero?"*. Cuando un agente revisa un PR y deja pasar algo que debería haber cogido, la respuesta no está en retocar el prompt sino en escribir el knowledge file que faltaba. Es un cambio de marco interesante.

### Cinco palabras antes de seguir

Antes de meterse en cómo está organizado el repo conviene fijar el vocabulario, porque BCQuality reutiliza términos comunes con un sentido muy concreto:

- **Knowledge file**: archivo markdown atómico con frontmatter YAML. Una idea por fichero, menos de 100 líneas, sin bloques de código dentro. Los ejemplos de código viven en ficheros hermanos `<slug>.good.al` / `<slug>.bad.al`.
- **Action skill**: archivo markdown que un agente ejecuta (`kind: action-skill`). Aplica el patrón de cuatro pasos sobre los knowledge files y emite un JSON con findings.
- **Meta-skill**: contrato sobre *cómo* funcionan las cosas (`kind: meta-skill`). En BCQuality son tres — READ, DO y WRITE — y conviven en `/skills/` con un cuarto fichero, Entry, que es de tipo distinto (`kind: entry-point`).
- **Orchestrator**: la herramienta externa que dispara el trabajo. Vive *fuera* de BCQuality — puede ser AL-Go, una extensión de VS Code, un GitHub Action. Sabe *cuándo* hay que ejecutar algo, no *qué*.
- **Dispatch record**: el JSON que Entry devuelve cuando un orchestrator le pregunta qué hacer. Lista las action skills que tocan, las que se descartan y por qué.

Con esto en la cabeza, el resto se sigue mejor.

### Anatomía mínima

BCQuality se organiza en tres capas. La autoridad de cada fichero la marca dónde vive:

- `/microsoft/` — capa respaldada por Microsoft. Knowledge y action skills oficiales.
- `/community/` — capa de la comunidad BC. Hoy con 14 ficheros (8 performance, 6 security) y abierta a pull requests.
- `/custom/` — vacía por defecto. Se puebla en forks, normalmente en el repo del consumidor (no en BCQuality). Es el sitio para conocimiento interno de un partner o un cliente.

Las tres capas conviven cuando un agente consume el repo. Si dos ficheros entran en conflicto, gana el de mayor precedencia (`custom` sobre `microsoft` sobre `community` para knowledge files; misma ordenación para skills, según READ y Entry). El descartado se reporta en el campo `suppressed` (knowledge) o `skipped`/`skipped-sub-skills` (skills), así nada se pierde sin dejar rastro.

> Nota: la precedencia entre `microsoft` y `community` para knowledge files la define READ así — `/custom/` > `/microsoft/` > `/community/`. Para skills, Entry aplica `/custom/` > `/community/` > `/microsoft/` cuando dos skills comparten `id` entre capas. La diferencia es deliberada: las review skills oficiales pueden ser sustituidas por una versión community o custom con el mismo `id`.

Por encima de las capas hay cuatro skills globales en `/skills/`. La primera es Entry (`entry.md`), un *router* que recibe el goal del orchestrator y devuelve el dispatch record con la lista de action skills que tocan. Estructuralmente sigue el mismo patrón de cuatro pasos que las action skills, pero su salida es la dispatch, no findings.

Las otras tres son los **meta-skill contracts**:

- **READ** (`read.md`) — cómo leer un knowledge file: parsear el frontmatter, interpretar las secciones, aplicar la precedencia entre capas.
- **DO** (`do.md`) — la plantilla que sigue toda action skill. Define el patrón Source → Relevance → Worklist → Action y el contrato JSON de salida.
- **WRITE** (`write.md`) — cómo se escribe un knowledge file nuevo: reglas de atomicidad, secciones obligatorias, sin bloques de código dentro.

READ y DO se cargan bajo demanda, típicamente cuando el agente arranca la primera action skill que Entry le ha dispatchado, así que no hace falta leerlos antes de invocar Entry. WRITE solo entra en juego cuando alguien escribe contenido nuevo.

Una **action skill** sigue la plantilla DO y vive dentro de una capa. Tiene dos sabores: *leaf* (evalúa knowledge files directamente) y *super-skill* (compone otras action skills vía `sub-skills`). La referencia canónica es `al-code-review`, una super-skill que compone seis leaves: performance, security, privacy, upgrade, style y ui.

### Cómo se consume

El flow end-to-end es bastante elegante porque toda la convención cabe en una frase del propio repo: *"An agent that knows only 'invoke `/skills/entry.md` first' has enough to drive the rest of the repo."* El resto se descubre dinámicamente.

- El orchestrator (AL-Go, una extensión de VS Code, un GitHub Action) dispara con un `task-context`: goal, inputs disponibles (`pr-diff`, `file-path`...), versión BC, países, application area, capas habilitadas.
- El agente llama a Entry. Entry rutea: filtra por frontmatter, descarta candidatos por mismatch, las super-skills tapan a sus subs cuando el goal es más amplio (y las subs ganan cuando el goal nombra específicamente su dominio), aplica layer precedence — y devuelve la lista que aplica.
- Para cada skill en la dispatch, el agente la ejecuta. La skill aplica el patrón Source → Relevance → Worklist → Action sobre los knowledge files de su dominio y emite un JSON.
- El orchestrator consume ese JSON y mapea los findings a comentarios de PR, gates de build o diagnósticos del IDE.

El contrato JSON es uniforme: `outcome` (`completed`, `not-applicable`, `no-knowledge`, `partial`, `failed`), `findings` con severity (`blocker` / `major` / `minor` / `info`), `references` apuntando a los knowledge files que justifican cada finding, `confidence`, `suppressed`. Una super-skill añade además `sub-results` con el report verbatim de cada leaf y `skipped-sub-skills` para las que no se invocaron.

Como ejemplo, este es un fragmento real del repo: `al-code-review` sobre un PR detecta tres cosas y devuelve

```json
{
  "outcome": "completed",
  "summary": { "counts": { "blocker": 1, "major": 1, "minor": 1, "info": 0 } },
  "findings": [
    { "severity": "blocker",
      "message": "Bearer token declarado como Text y pasado en plano por el path de la HTTP request.",
      "references": [{ "path": "microsoft/knowledge/security/use-secrettext-for-credentials.md" }],
      "confidence": "high" },
    { "severity": "major",
      "message": "FindSet sin SetRange previo: escaneo full-table.",
      "references": [{ "path": "microsoft/knowledge/performance/filter-before-find.md" }],
      "confidence": "high" },
    { "severity": "minor",
      "message": "SetLoadFields llamado después de SetRange; el orden invertido no se replega en el plan.",
      "references": [{ "path": "community/knowledge/performance/call-setloadfields-before-filters.md" }],
      "confidence": "high" }
  ]
}
```

Cada finding apunta al fichero exacto que lo justifica, así que el developer humano puede abrirlo y leer la regla, y el agente puede citarla sin inventar.

### Lo que falta y lo que abre

Estado a 2 de mayo de 2026 (último commit en `main`: 24 de abril):

- **Capa Microsoft** — 99 knowledge files distribuidos así: performance 42, security 14, privacy 11, style 11, upgrade 11, ui 9, testing 1. Performance está bien cubierto; el resto de dominios quedan entre 9 y 14 ficheros, salvo testing que apenas arranca con uno.
- **Skills Microsoft** — 7 review skills: la super-skill `al-code-review` y sus seis leaves (`al-performance-review`, `al-security-review`, `al-privacy-review`, `al-upgrade-review`, `al-style-review`, `al-ui-review`).
- **Capa community** — 14 knowledge files (8 performance, 6 security). El resto de dominios sin sembrar y la carpeta `community/skills/` está vacía.
- **Capa custom** — vacía. Solo existe la estructura.

El propio repo lo dice claro: *"Large and potentially breaking changes are expected. Public preview will soon be announced."* Así que conviene tener en cuenta que lo que está hoy puede moverse. Aunque el contrato del frontmatter v1 ya está fijado — los cambios al schema requieren PR aprobado por los maintainers (el README habla en plural; el `CODEOWNERS` actual solo lista a `@jeschulz`, así que el segundo asiento está reservado pero todavía sin nombre público).

Las puertas que se abren me parecen las más interesantes:

- **Para partners**: `/custom/` ofrece un sitio limpio para meter conocimiento interno (reglas de un cliente, patrones propios) sin contaminar la capa upstream. Forkeas, llenas `/custom/`, apuntas el orchestrator al fork.
- **Para la comunidad**: `community/skills/` está vacía y abierta. Cualquier action skill probada en el campo (un linter de telemetría, un revisor de pipelines AL-Go, un auditor de AppSource) tiene sitio.
- **Para los frameworks comunitarios existentes**: ALDC, AL-Copilot-Skills-Collection, BC-Bench, CIRCE — todos los que estamos trabajando en este espacio tenemos ahora un punto de referencia común para alinearnos. La parte difícil del meta-design (cómo organizar knowledge para que un agente lo consuma, cómo formatear el output, cómo manejar precedencia entre capas) ya está resuelta y fijada.

Será interesante seguir cómo evoluciona la regla de admisión a medida que el repo crezca. La tentación de añadir *"guía importante"* aunque cualquier LLM ya la conozca está siempre ahí, y el filtro remedial pierde sentido en cuanto se relaja. Si Microsoft lo mantiene firme, BCQuality puede convertirse en una pieza muy útil del ecosistema.

📚 **Referencias**

- Repositorio: [github.com/microsoft/BCQuality](https://github.com/microsoft/BCQuality)
- `README.md` — test de admisión completo y layout de capas
- `agent-consumption.md` — flow end-to-end con diagrama Mermaid
- `skills/entry.md` y `skills/do.md` — los contratos de routing y action skill
- `skills/read.md` y `skills/write.md` — schema de knowledge files y reglas de autoría
- `microsoft/skills/review/al-code-review.md` — super-skill canónica
- AL-Go for GitHub: [github.com/microsoft/AL-Go](https://github.com/microsoft/AL-Go) (orchestrator por defecto)

🟦 **Cierre**

BCQuality no se plantea como un curso de buenas prácticas BC sino como la primera vez que Microsoft estructura el conocimiento BC explícitamente para que un agente lo consuma. La regla de admisión hace el trabajo pesado: si tu LLM ya lo sabe, no necesita estar en el repo, así que el contenido se mantiene útil y enfocado.

El siguiente paso natural — para los que llevamos un rato construyendo skills, frameworks y benchmarks alrededor de Copilot y Claude Code en AL — es preguntarse qué de lo que hemos hecho encaja bien en `/community/` y qué tiene más sentido mantener en sus repos propios. Esa conversación viene en una segunda pieza.
