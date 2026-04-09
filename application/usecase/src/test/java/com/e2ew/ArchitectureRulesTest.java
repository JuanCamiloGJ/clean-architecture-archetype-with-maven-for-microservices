package com.e2ew;

import static com.tngtech.archunit.lang.syntax.ArchRuleDefinition.noClasses;

import com.tngtech.archunit.core.domain.JavaClasses;
import com.tngtech.archunit.core.importer.ClassFileImporter;
import org.junit.jupiter.api.Test;

/**
 * Reglas mínimas para que el template se mantenga fiel a Clean Architecture.
 *
 * <p>Nota: estas reglas se ejecutan en el módulo `usecase`, así que el classpath disponible para
 * ArchUnit incluye principalmente `domain` y `usecase`.
 */
class ArchitectureRulesTest {

    private static final String BASE_PACKAGE = "com.e2ew";

    private static final String ENTRY_PACKAGE = "com.e2ew.infrastructure.entry..";
    private static final String DRIVEN_PACKAGE = "com.e2ew.infrastructure.driven..";

    @Test
    void domain_must_not_depend_on_frameworks_or_infrastructure() {
        JavaClasses classes = new ClassFileImporter().importPackages(BASE_PACKAGE);

        // Ninguna clase del dominio (com.e2ew.domain..) debe depender de frameworks o de
        // infraestructura.
        noClasses()
                .that()
                .resideInAPackage("com.e2ew.domain..")
                .should()
                .dependOnClassesThat()
                .resideInAnyPackage(
                        "org.springframework..",
                        "jakarta.persistence..",
                        "jakarta.servlet..",
                        ENTRY_PACKAGE,
                        DRIVEN_PACKAGE)
                .allowEmptyShould(true)
                .check(classes);
    }

    @Test
    void usecase_must_not_depend_on_entrypoints_or_driven_adapters() {
        JavaClasses classes = new ClassFileImporter().importPackages(BASE_PACKAGE);

        // Los casos de uso no deben depender de adaptadores: solo de domain.
        noClasses()
                .that()
                .resideInAPackage("..usecase..")
                .should()
                .dependOnClassesThat()
                .resideInAnyPackage(ENTRY_PACKAGE, DRIVEN_PACKAGE)
                .allowEmptyShould(true)
                .check(classes);
    }

    @Test
    void entrypoints_must_not_depend_on_driven_adapters() {
        JavaClasses classes = new ClassFileImporter().importPackages(BASE_PACKAGE);

        // Entry-points solo habla con usecase (y DTOs propios), no con driven-adapters.
        noClasses()
                .that()
                .resideInAPackage(ENTRY_PACKAGE)
                .should()
                .dependOnClassesThat()
                .resideInAPackage(DRIVEN_PACKAGE)
                .allowEmptyShould(true)
                .check(classes);
    }

    @Test
    void driven_adapters_must_not_depend_on_entrypoints() {
        JavaClasses classes = new ClassFileImporter().importPackages(BASE_PACKAGE);

        // Driven-adapters implementa gateways del domain; no debe conocer entry-points.
        noClasses()
                .that()
                .resideInAPackage(DRIVEN_PACKAGE)
                .should()
                .dependOnClassesThat()
                .resideInAPackage(ENTRY_PACKAGE)
                .allowEmptyShould(true)
                .check(classes);
    }
}
