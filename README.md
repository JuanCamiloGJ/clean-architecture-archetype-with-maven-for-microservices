# ms-template-clean-architecture

## 🚀 ¿Qué problema resuelve esto?

Este arquetipo reduce el tiempo de configuración de microservicios de horas a minutos gracias a:
- Estructura de arquitectura limpia
- Controles de calidad preconfigurados
- Configuración de Docker lista para usar

Template base multi-módulo inspirado en Clean Architecture para proyectos Java 17 + Spring Boot + Maven.

## Estructura (módulos)
- `domain` (jar): modelos, excepciones y **gateways/puertos**. No depende de Spring ni infraestructura.
- `application` (pom)
  - `usecase` (jar): casos de uso/orquestación de negocio. Depende de `domain`.
  - `app-service` (jar): arranque Spring Boot y ensamblaje (inyección de dependencias).
- `infrastructure` (pom)
  - `entry-points` (jar): adaptadores de entrada (REST, consumers, etc.). Depende de `usecase`.
  - `driven-adapters` (jar): adaptadores de salida (repos, clientes http, mensajes). Implementan interfaces de `domain`.

## Comandos

### Generar proyecto

Generar un nuevo proyecto usando el arquetipo publicado en Maven Central (versión 1.0.1 al momento de escribir esto):

```bash
  mvn archetype:generate \
    -DarchetypeCatalog=remote \
    -DarchetypeGroupId=io.github.juancamilogj \
    -DarchetypeArtifactId=archetype-clean-architecture-archetype \
    -DarchetypeVersion=1.0.1 \
    -DgroupId=com.tuempresa \
    -DartifactId=mi-microservicio \
    -Dversion=1.0.0-SNAPSHOT \
    -Dpackage=com.tuempresa.mimicroservicio \
    -DinteractiveMode=false
```
Generar en modo interactivo (te irá preguntando por cada valor):

```bash
mvn archetype:generate \
  -DarchetypeCatalog=remote \
  -DarchetypeGroupId=io.github.juancamilogj \
  -DarchetypeArtifactId=archetype-clean-architecture-archetype \
  -DarchetypeVersion=1.0.1
```

### Generar proyecto localmente (si clonaste este repo)
```bash
  mvn archetype:create-from-project
```  
Esto generará un arquetipo local en `target/generated-sources/archetype/` que puedes instalar con:
```bash
  mvn install
```
Luego podrás usarlo con `-DarchetypeCatalog=local` en el comando de generación.

```bash
  mvn archetype:generate \
    -DarchetypeCatalog=local \
    -DarchetypeGroupId=io.github.juancamilogj \
    -DarchetypeArtifactId=archetype-clean-architecture-archetype \
    -DarchetypeVersion=1.0.1 \
    -DgroupId=com.tuempresa \
    -DartifactId=mi-microservicio \
    -Dversion=1.0.0-SNAPSHOT \
    -Dpackage=com.tuempresa.mimicroservicio \
    -DinteractiveMode=false
```

### Publicar a Maven Central (flujo local, sin CI)

Este flujo lo ejecuta el mantenedor del arquetipo en su máquina.

```bash
cd "D:/PYT/Development/API Homebanking/API Homebanking Gen/clean-architecture-archetype-with-maven-for-microservices"
bash scripts/build-archetype-ready.sh

cd "target/generated-sources/archetype"
mvn -s "C:/Users/PYT09/.m2/settings-central.xml" -DskipTests clean deploy
```

Si usas passphrase en GPG para deploy batch:

```bash
export MAVEN_GPG_PASSPHRASE="TU_PASS_REAL"
mvn -s "C:/Users/PYT09/.m2/settings-central.xml" -DskipTests clean deploy
```


### Build + tests
```bash
mvn clean verify
```

### Formato (si el build falla por formato)
```bash
mvn spotless:apply
mvn clean verify
```

### Ejecutar local
```bash
cd application/app-service
mvn spring-boot:run
```

### Docker
**Pre-requisito:** generar el jar.
```bash
mvn -pl application/app-service -am clean package
```

Construir imagen:
```bash
docker build -t ms-template:local .
```

Correr:
```bash
docker run --rm -p 8793:8793 ms-template:local
```

## Quality gates incluidos (arquetipo)
- Enforcer: valida versión mínima de Maven/Java y convergencia de dependencias.
- Spotless: formato Java y orden de POMs.




