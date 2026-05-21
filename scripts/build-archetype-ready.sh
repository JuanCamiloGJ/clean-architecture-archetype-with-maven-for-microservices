#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
ARCH_DIR="$ROOT_DIR/target/generated-sources/archetype"
RES_DIR="$ARCH_DIR/src/main/resources/archetype-resources"
META_FILE="$ARCH_DIR/src/main/resources/META-INF/maven/archetype-metadata.xml"

cd "$ROOT_DIR"
mvn -q -Denforcer.skip=true -DskipTests archetype:create-from-project

if [ ! -f "$META_FILE" ]; then
  echo "No se encontró archetype-metadata.xml en: $META_FILE" >&2
  exit 1
fi

# El proyecto generado por el archetype no debe incluir utilidades internas ni metadatos del IDE.
rm -rf "$RES_DIR/scripts" "$RES_DIR/.idea"

# Mantiene el descriptor generado por Maven y solo añade rootArtifactId.
if ! grep -q 'key="rootArtifactId"' "$META_FILE"; then
  TMP_FILE="$(mktemp)"
  awk '
    /<fileSets>/ && !added {
      print "  <requiredProperties>"
      print "    <requiredProperty key=\"rootArtifactId\">"
      print "      <defaultValue>${artifactId}</defaultValue>"
      print "    </requiredProperty>"
      print "  </requiredProperties>"
      added=1
    }
    { print }
  ' "$META_FILE" > "$TMP_FILE"
  mv "$TMP_FILE" "$META_FILE"
fi

# Elimina fileSets de scripts/.idea para que no se creen carpetas vacias al generar proyectos.
TMP_FILE="$(mktemp)"
awk '
  BEGIN { inFileSet=0; drop=0; block="" }
  /<fileSet[ >]/ {
    inFileSet=1
    drop=0
    block=$0 ORS
    next
  }
  inFileSet {
    block=block $0 ORS
    if ($0 ~ /<directory>(scripts|\.idea)<\/directory>/) {
      drop=1
    }
    if ($0 ~ /<\/fileSet>/) {
      if (!drop) {
        printf "%s", block
      }
      inFileSet=0
      drop=0
      block=""
    }
    next
  }
  { print }
' "$META_FILE" > "$TMP_FILE"
mv "$TMP_FILE" "$META_FILE"

# Root dependencyManagement: internal modules should follow the generated root prefix.
sed -i 's#<artifactId>domain</artifactId>#<artifactId>${rootArtifactId}-domain</artifactId>#g' "$RES_DIR/pom.xml"
sed -i 's#<artifactId>usecase</artifactId>#<artifactId>${rootArtifactId}-usecase</artifactId>#g' "$RES_DIR/pom.xml"
sed -i 's#<artifactId>app-service</artifactId>#<artifactId>${rootArtifactId}-app-service</artifactId>#g' "$RES_DIR/pom.xml"
sed -i 's#<artifactId>driven-adapters</artifactId>#<artifactId>${rootArtifactId}-driven-adapters</artifactId>#g' "$RES_DIR/pom.xml"
sed -i 's#<artifactId>entry-points</artifactId>#<artifactId>${rootArtifactId}-entry-points</artifactId>#g' "$RES_DIR/pom.xml"


# application module and children.
sed -i 's#<artifactId>${artifactId}</artifactId>#<artifactId>${rootArtifactId}-application</artifactId>#' "$RES_DIR/application/pom.xml"
sed -i '/<parent>/,/<\/parent>/ s#<artifactId>${rootArtifactId}-application</artifactId>#<artifactId>${artifactId}</artifactId>#' "$RES_DIR/application/pom.xml"

sed -i 's#<artifactId>application</artifactId>#<artifactId>${rootArtifactId}-application</artifactId>#' "$RES_DIR/application/usecase/pom.xml"
sed -i 's#<artifactId>${artifactId}</artifactId>#<artifactId>${rootArtifactId}-usecase</artifactId>#' "$RES_DIR/application/usecase/pom.xml"
sed -i 's#<artifactId>domain</artifactId>#<artifactId>${rootArtifactId}-domain</artifactId>#' "$RES_DIR/application/usecase/pom.xml"

sed -i 's#<artifactId>application</artifactId>#<artifactId>${rootArtifactId}-application</artifactId>#' "$RES_DIR/application/app-service/pom.xml"
sed -i 's#<artifactId>${artifactId}</artifactId>#<artifactId>${rootArtifactId}-app-service</artifactId>#' "$RES_DIR/application/app-service/pom.xml"
sed -i 's#<artifactId>usecase</artifactId>#<artifactId>${rootArtifactId}-usecase</artifactId>#' "$RES_DIR/application/app-service/pom.xml"
sed -i 's#<artifactId>driven-adapters</artifactId>#<artifactId>${rootArtifactId}-driven-adapters</artifactId>#' "$RES_DIR/application/app-service/pom.xml"
sed -i 's#<artifactId>entry-points</artifactId>#<artifactId>${rootArtifactId}-entry-points</artifactId>#' "$RES_DIR/application/app-service/pom.xml"

# domain module.
sed -i 's#<artifactId>${artifactId}</artifactId>#<artifactId>${rootArtifactId}-domain</artifactId>#' "$RES_DIR/domain/pom.xml"
sed -i '/<parent>/,/<\/parent>/ s#<artifactId>${rootArtifactId}-domain</artifactId>#<artifactId>${artifactId}</artifactId>#' "$RES_DIR/domain/pom.xml"

# infrastructure module and children.
sed -i 's#<artifactId>${artifactId}</artifactId>#<artifactId>${rootArtifactId}-infrastructure</artifactId>#' "$RES_DIR/infrastructure/pom.xml"
sed -i '/<parent>/,/<\/parent>/ s#<artifactId>${rootArtifactId}-infrastructure</artifactId>#<artifactId>${artifactId}</artifactId>#' "$RES_DIR/infrastructure/pom.xml"

sed -i 's#<artifactId>infrastructure</artifactId>#<artifactId>${rootArtifactId}-infrastructure</artifactId>#' "$RES_DIR/infrastructure/entry-points/pom.xml"
sed -i 's#<artifactId>${artifactId}</artifactId>#<artifactId>${rootArtifactId}-entry-points</artifactId>#' "$RES_DIR/infrastructure/entry-points/pom.xml"
sed -i 's#<artifactId>usecase</artifactId>#<artifactId>${rootArtifactId}-usecase</artifactId>#' "$RES_DIR/infrastructure/entry-points/pom.xml"

sed -i 's#<artifactId>infrastructure</artifactId>#<artifactId>${rootArtifactId}-infrastructure</artifactId>#' "$RES_DIR/infrastructure/driven-adapters/pom.xml"
sed -i 's#<artifactId>${artifactId}</artifactId>#<artifactId>${rootArtifactId}-driven-adapters</artifactId>#' "$RES_DIR/infrastructure/driven-adapters/pom.xml"
sed -i 's#<artifactId>usecase</artifactId>#<artifactId>${rootArtifactId}-usecase</artifactId>#' "$RES_DIR/infrastructure/driven-adapters/pom.xml"

# Obtener coordenadas del artefacto desde el pom.xml del archetype generado
ARCH_GROUP=$(mvn -q -f "$ARCH_DIR/pom.xml" help:evaluate -Dexpression=project.groupId -DforceStdout)
ARCH_ARTIFACT=$(mvn -q -f "$ARCH_DIR/pom.xml" help:evaluate -Dexpression=project.artifactId -DforceStdout)
ARCH_VERSION=$(mvn -q -f "$ARCH_DIR/pom.xml" help:evaluate -Dexpression=project.version -DforceStdout)
JAR_FILE="$ARCH_DIR/target/${ARCH_ARTIFACT}-${ARCH_VERSION}.jar"

# Reempaquetar el archetype usando solo archetype:jar (NO dispara create-from-project).
# Esto evita que el lifecycle maven-archetype regenere com/e2ew duplicados.
cd "$ARCH_DIR"
mvn -q clean resources:resources archetype:jar

# Instalar el JAR en el repositorio local directamente (sin lifecycle).
mvn -q install:install-file \
  -Dfile="$JAR_FILE" \
  -DpomFile="$ARCH_DIR/pom.xml" \
  -Dpackaging=jar

echo "Archetype listo en: $ARCH_DIR"
