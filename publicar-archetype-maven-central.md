# Publicar un Maven Archetype en Maven Central (Sonatype Central)

## Contexto

Este proceso aplica para archetypes generados usando:

```bash
mvn archetype:create-from-project
```

El archetype REAL que se publica queda generado en:

```text
target/generated-sources/archetype
```

NO se publica el proyecto base original.

---

# Estructura importante

## Proyecto base

```text
mi-proyecto/
```

Solo sirve como plantilla.

---

## Archetype generado

```text
target/generated-sources/archetype
```

Este es el proyecto Maven que:
- se compila,
- se firma,
- y se publica a Maven Central.

---

# Configuración necesaria en el pom.xml raíz del archetype

Archivo:

```text
target/generated-sources/archetype/pom.xml
```

Agregar:

```xml
<name>Clean Architecture Archetype</name>

<description>
  Archetype for generating clean architecture microservices with Maven and Spring Boot
</description>

<url>
  https://github.com/juancamilogj/clean-architecture-archetype-with-maven-for-microservices
</url>

<licenses>
  <license>
    <name>Apache License 2.0</name>
    <url>https://www.apache.org/licenses/LICENSE-2.0.txt</url>
  </license>
</licenses>

<developers>
  <developer>
    <id>juancamilogj</id>
    <name>Juan Camilo Garcia</name>
  </developer>
</developers>

<scm>
  <connection>
    scm:git:git://github.com/juancamilogj/clean-architecture-archetype-with-maven-for-microservices.git
  </connection>

  <developerConnection>
    scm:git:ssh://github.com/juancamilogj/clean-architecture-archetype-with-maven-for-microservices.git
  </developerConnection>

  <url>
    https://github.com/juancamilogj/clean-architecture-archetype-with-maven-for-microservices
  </url>
</scm>

<build>
  <plugins>

    <!-- Firma GPG -->
    <plugin>
      <groupId>org.apache.maven.plugins</groupId>
      <artifactId>maven-gpg-plugin</artifactId>
      <version>3.2.4</version>

      <executions>
        <execution>
          <id>sign-artifacts</id>
          <phase>verify</phase>

          <goals>
            <goal>sign</goal>
          </goals>
        </execution>
      </executions>
    </plugin>

    <!-- Publicación Sonatype Central -->
    <plugin>
      <groupId>org.sonatype.central</groupId>
      <artifactId>central-publishing-maven-plugin</artifactId>
      <version>0.6.0</version>
      <extensions>true</extensions>

      <configuration>
        <publishingServerId>central</publishingServerId>
        <autoPublish>true</autoPublish>
      </configuration>
    </plugin>

  </plugins>

  <extensions>
    <extension>
      <groupId>org.apache.maven.archetype</groupId>
      <artifactId>archetype-packaging</artifactId>
      <version>3.4.1</version>
    </extension>
  </extensions>
</build>
```

---

# settings.xml necesario

Ubicación:

## Windows

```text
C:\Users\TU_USUARIO\.m2\settings.xml
```

---

## Ejemplo

```xml
<?xml version="1.0" encoding="UTF-8"?>

<settings xmlns="http://maven.apache.org/SETTINGS/1.2.0"
          xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
          xsi:schemaLocation="http://maven.apache.org/SETTINGS/1.2.0 https://maven.apache.org/xsd/settings-1.2.0.xsd">

  <servers>
    <server>
      <id>central</id>

      <!-- Token Name -->
      <username>TOKEN_NAME</username>

      <!-- Token Password -->
      <password>TOKEN_PASSWORD</password>
    </server>
  </servers>

  <profiles>
    <profile>
      <id>gpg</id>

      <properties>
        <gpg.keyname>TU_KEY_ID</gpg.keyname>
        <gpg.passphrase>TU_PASSPHRASE</gpg.passphrase>
      </properties>
    </profile>
  </profiles>

  <activeProfiles>
    <activeProfile>gpg</activeProfile>
  </activeProfiles>

</settings>
```

---

# Obtener token de Sonatype

Ir a:

https://central.sonatype.com/account

Generar:
- User Token Name
- User Token Password

NO usar:
- email
- password normal de la cuenta.

---

# Crear llave GPG

## Verificar si existe

```bash
gpg --list-secret-keys
```

---

## Crear nueva

```bash
gpg --full-generate-key
```

---

## Obtener key id

```bash
gpg --list-secret-keys --keyid-format LONG
```

---

# Verificar GPG

```bash
echo hola | gpg --clearsign
```

Debe:
- pedir passphrase,
- o generar firma correctamente.

---

# Comando para publicar

Entrar al archetype generado:

```bash
cd target/generated-sources/archetype
```

Luego:

```bash
mvn clean deploy
```

---

# Problemas comunes

## 401 Unauthorized

Token inválido o expirado.

Generar nuevo token en Sonatype.

---

## Missing signature

Falta plugin GPG.

---

## Missing metadata

Faltan:
- description
- url
- scm
- developers
- licenses

---

## Could not determine gpg version

GPG no está instalado o no está en PATH.

Instalar:

https://www.gpg4win.org/

---

## Bad passphrase

La passphrase de la llave GPG es incorrecta.

---

## Git Bash no encuentra settings.xml

Usar:

```bash
mvn clean deploy -s /c/Users/TU_USUARIO/.m2/settings.xml
```

NO:

```bash
-s C:\Users\...
```

en Git Bash.

---

# Publicar desde otra máquina

## Caso 1: Tengo acceso a la llave GPG original

### Exportar llave privada desde la máquina original

```bash
gpg --export-secret-keys TU_KEY_ID > private.key
```

### Copiar archivo a la nueva máquina

```text
private.key
```

### Importar en nueva máquina

```bash
gpg --import private.key
```

### Verificar

```bash
gpg --list-secret-keys
```

### Publicar normalmente

```bash
mvn clean deploy
```

---

## Caso 2: NO tengo acceso a la llave GPG original

IMPORTANTE:

Maven Central requiere firmar con la misma identidad GPG asociada a tus publicaciones.

Si perdiste:
- la llave privada,
- la máquina original,
- o la passphrase,

NO podrás seguir firmando con esa key.

### Opciones

#### Opción A (Recomendada)

Crear una nueva llave GPG:

```bash
gpg --full-generate-key
```

Luego actualizar:

```xml
<gpg.keyname>NUEVA_KEY_ID</gpg.keyname>
```

en `settings.xml`.

Sonatype normalmente acepta nuevas firmas mientras controles:
- el namespace,
- y el groupId.

---

#### Opción B

Revocar la llave anterior si todavía tienes certificado de revocación.

---

#### Opción C

Generar un nuevo namespace/groupId si el anterior quedó completamente inaccesible.

---

# Validar publicación

## Sonatype Central

https://central.sonatype.com/publishing/deployments

---

## Maven Central

https://repo1.maven.org/maven2/io/github/juancamilogj/archetype-clean-architecture-archetype/
