library(bipartite)
library(dplyr)

# 1. CONFIGURACIÓN
# Definimos las zonas. El código buscará archivos con estos nombres en tu ordenador.
zonas <- c("Comunidad Valenciana", "Espadán", "Font Roja", "Penyagolosa", "Vall d'Albaida")

if (!dir.exists("output/tablas")) dir.create("output/tablas", recursive = TRUE)

# 2. BUCLE DE PROCESAMIENTO
# Este bucle recorre cada zona y calcula todo automáticamente
for (z in zonas) {
  archivo <- paste0(z, ".csv")
  
  if (file.exists(archivo)) {
    datos <- read.csv2(archivo)
    
    # Crear matriz limpia
    matriz <- table(datos$Micobionte, datos$Fotobionte)
    matriz_pura <- as.matrix(as.data.frame.matrix(matriz))
    matriz_pura <- matriz_pura[rownames(matriz_pura) != "", colnames(matriz_pura) != ""]

    # --- Cálculo de Índices ---
    # NODF (Anidamiento)
    nodf <- networklevel(matriz_pura, index="NODF")
    
    # H2 (Selectividad)
    h2 <- networklevel(matriz_pura, index="H2")
    
    # Modularidad y Roles (c y z)
    mod <- computeModules(matriz_pura)
    roles <- czvalues(mod, level="lower") # lower indica que calculamos para hongos
    
    # --- Guardar Resultados ---
    write.csv(roles, paste0("output/tablas/Roles_", z, ".csv"))
    
    print(paste("Análisis completado para:", z))
    print(paste("NODF:", nodf, "| H2':", h2))
  }
}
