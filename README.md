# ms-template-clean-architecture

Template base multi-módulo inspirado en Clean Architecture (estilo Bancolombia) para proyectos Java 17 + Spring Boot + Maven.

## Estructura (módulos)
- `domain` (jar): modelos, excepciones y **gateways/puertos**. No depende de Spring ni infraestructura.
- `application` (pom)
  - `usecase` (jar): casos de uso/orquestación de negocio. Depende de `domain`.
  - `app-service` (jar): arranque Spring Boot y ensamblaje (inyección de dependencias).
- `infrastructure` (pom)
  - `entry-points` (jar): adaptadores de entrada (REST, consumers, etc.). Depende de `usecase`.
  - `driven-adapters` (jar): adaptadores de salida (repos, clientes http, mensajes). Implementan interfaces de `domain`.

## Comandos
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
- Surefire/Failsafe: separa unit tests e integration tests (`*IT.java`).
- JaCoCo: reportes y gating (valores por defecto en 0.00, súbelos en tu CI).
- Spotless: formato Java y orden de POMs.

## Próximos pasos recomendados
- Agregar tests de arquitectura (ArchUnit) para hacer cumplir reglas de dependencias entre capas.
- Incluir Maven Wrapper (`mvnw`) para builds reproducibles.
- Completar `application-dev.yaml`/`application-prod.yaml` con actuator/observabilidad.
