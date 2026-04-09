# Guía de Arquitectura — ms-template-clean-architecture

Este documento resume cómo está pensado el proyecto, cómo usar la arquitectura por módulos (clean architecture), reglas prácticas sobre dependencias, cómo subir versión, comandos frecuentes y buenas prácticas.

---

Breve plan de lo que cubre este documento:
- Explicar responsabilidades de cada módulo
- Normas de dependencias y límites entre capas
- Cómo compilar/ejecutar y configuraciones importantes (Lombok, BOM)
- Cómo subir versión (manual y con Maven)
- Publicación

Checklist rápido (lo que verás más abajo):
- [x] Estructura de módulos y responsabilidades
- [x] Reglas de dependencias (quién puede depender de quién)
- [x] Cómo agregar dependencias correctamente
- [x] Bump de versión en multi-módulo
- [x] Comandos útiles
- [x] Buenas prácticas y recomendaciones

---

## 1. Estructura del proyecto

Módulos (raíz `pom.xml`):
- `domain` (jar)
  - Contiene modelos, excepciones y _interfaces_ (gateways) que representan contratos de infraestructura.
  - Nunca depende de frameworks (Spring, JPA, etc.). Solo utilidades de bajo nivel (p. ej. Lombok `provided`).
- `application` (pom)
  - `usecase` (jar): casos de uso, lógica de negocio. Depende solo de `domain`.
  - `app-service` (jar): arranque de la aplicación (Spring Boot). Orquesta los módulos, contiene `main`.
- `infrastructure` (pom)
  - `entry-points` (jar): adaptadores de entrada (REST controllers, validación, DTOs). Depende de `usecase`.
  - `driven-adapters` (jar): adaptadores de salida (repositorios, clientes REST, adaptadores JPA). Implementan las interfaces del `domain`.

Diagrama simplificado:

```
domain <-- usecase <-- entry-points
                    ^
                    |
              driven-adapters

app-service arranca y junta todo
```

---

## 2. Reglas de dependencias (principios)

- Domain (centrado) no debe conocer frameworks ni adaptadores.
- Usecases dependen de domain únicamente (interpretación de reglas de negocio).
- Adapters (entry-points y driven-adapters) dependen de usecases y domain (si necesitan los modelos) pero no al revés.
- `app-service` es el punto de ensamblado y arranque, puede depender de adaptadores y usecases.

Práctica: todas las interfaces (gateways) van en `domain`. Las implementaciones en `driven-adapters`.

---

## 3. Dependencias y gestionarlas (BOM y dependencyManagement)

- El `pom.xml` raíz define las versiones vía `dependencyManagement` (BOM de Spring Boot y versión de Lombok). Esto **no** añade dependencias a los módulos hijos por sí mismo; solo fija versiones para que los módulos hijos definan la dependencia sin declarar versión.

Qué significa esto en la práctica:
- Define las versiones en el padre (por ejemplo `spring-boot-dependencies` en `dependencyManagement` y la propiedad `lombok.version`).
- En un módulo hijo solo declaras la dependencia sin versión. Maven usará la versión fijada por el padre.
- Si un módulo hijo especifica su propia versión, esa versión **sobrescribe** la del padre para ese módulo.

Ejemplo (en `pom` raíz):
```xml
<dependencyManagement>
  <dependencies>
    <!-- BOM de Spring Boot importado -->
    <dependency>
      <groupId>org.springframework.boot</groupId>
      <artifactId>spring-boot-dependencies</artifactId>
      <version>${spring-boot.version}</version>
      <type>pom</type>
      <scope>import</scope>
    </dependency>
    <!-- Version de Lombok en properties y referenciada en dependencyManagement -->
  </dependencies>
</dependencyManagement>
```

Ejemplo (en un módulo hijo):
```xml
<dependency>
  <groupId>org.springframework.boot</groupId>
  <artifactId>spring-boot-starter-web</artifactId>
  <!-- sin <version> aquí: la versión viene del BOM del padre -->
</dependency>
```

Consejo: Mantén las dependencias de framework fuera de `domain`.

---

## 4. Lombok

- Lombok se declara como `provided` (o en `dependencyManagement`/padre) para que el código use las anotaciones pero los artefactos generados no incluyan la dependencia en tiempo de ejecución.
- Evita declarar versiones de Lombok en varios módulos: centralízala en el `pom` raíz (por ejemplo en `<properties>`).

---

## 5. Versionado del proyecto (política obligatoria)

Esta sección es crítica: **cada PR que introduce cambios en el código debe incluir el bump de versión adecuado** y la nueva versión debe estar claramente indicada en la descripción del PR.

### 5.1 Política de versionado (semántico obligatorio)
Usamos versionado semántico (SemVer): MAJOR.MINOR.PATCH.
- PATCH: cambios que no rompen la API pública ni el comportamiento esperado (bug fixes, cambios internos). Ej: `0.0.1` -> `0.0.2`.
- MINOR: nuevas funcionalidades compatibles (features que no rompen compatibilidad). Ej: `0.0.2` -> `0.1.0`.
- MAJOR: cambios que rompen compatibilidad (contratos, cambios en modelos públicos, cambios que requieren migraciones). Ej: `0.1.0` -> `1.0.0`.

**Regla del equipo**: TODO PR que modifique código fuente (no solo documentación) debe aumentar la versión en el `pom` raíz y en los hijos (esto lo hace `mvn versions:set`).

### 5.2 Cómo decidir qué nivel aplicar
- Si el PR corrige un bug o hace un ajuste interno: aplicar un PATCH.
- Si el PR añade una nueva funcionalidad que es retrocompatible: aplicar un MINOR.
- Si el PR introduce cambios incompatibles (cambio de contrato, eliminación de endpoints, rename público de paquetes/paquetes-modelos): aplicar un MAJOR.

Si hay dudas, preferir un PATCH y discutir en la PR; el revisor puede solicitar cambiar a MINOR/MAJOR.

### 5.3 Comandos que el autor del PR debe ejecutar
1. Desde la raíz del repo ejecuta (ejemplo para pasar a 0.0.2):

```bash
mvn versions:set -DnewVersion=0.0.2 -DgenerateBackupPoms=false
mvn versions:commit
```

2. Verifica los cambios en los pom hijos (el plugin actualiza los `<parent>` donde aplica).
3. Ejecuta tests y build mínimo:

```bash
mvn -T 1C clean install -DskipTests=false
```

4. Realiza los commits y push del cambio (el bump debe estar incluido en el mismo PR que introduce el cambio):

```bash
git add pom.xml **/pom.xml
git commit -m "chore: bump version to 0.0.2 — <breve motivo>"
git push origin <branch>
```

> Nota: No dejes el cambio de versión para otro PR distinto — el objetivo es que el PR que introduce el cambio también publique el nuevo número de versión.

---

## 6. Comandos útiles

- Compilar todo y ejecutar tests:
```bash
mvn clean install
```

- Solo construir app-service (desde la raíz):
```bash
mvn -pl application/app-service -am clean package
```

- Ejecutar la app en modo local (dev):
```bash
cd application/app-service
mvn spring-boot:run
```

- Actualizar versión (bump):
```bash
mvn versions:set -DnewVersion=0.0.2 -DgenerateBackupPoms=false
mvn versions:commit
```

- Ejecutar solo tests de un módulo:
```bash
mvn -pl domain test
```

---

## 7. Publicación (cuando aplica)

- Si vas a publicar módulos (por ejemplo `domain` o `driven-adapters`) en un repositorio Nexus/Artifactory, asegúrate de:
  - Aumentar la versión con `mvn versions:set` antes del `deploy`.
  - Firmar (GPG) si publicas en Maven Central.

---

## 8. Buenas prácticas y recomendaciones

- Mantén `domain` lo más puro posible: sin frameworks. Solo POJOs, excepciones y contratos (interfaces). Esto facilita pruebas unitarias y mantenimiento.
- Implementa beans de usecase de forma explícita (preferible) o validada la estrategia de `@ComponentScan` que uses (si usas el regex asegúrate que todos los UseCase respeten el patrón de nombre).
- Centraliza versiones en el `pom` raíz (BOM) y no repitas versiones en módulos hijos: define la versión en el padre y en los hijos declara las dependencias sin `<version>` para que hereden.
- Usa `spring-boot-starter-*` solo en módulos que van a necesitar Spring; evita en `domain`.
- Documenta en `README.md` o en este archivo el flujo para tu equipo (bump de versión, deploy, pruebas).

---