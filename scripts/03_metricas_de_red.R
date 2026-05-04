# ==========================================================
# SCRIPT 3: ANÁLISIS TOPOLÓGICO DE REDES BIPARTITAS
# ==========================================================
library(bipartite)
library(dplyr)

# Definimos las zonas y los tipos de red que queremos analizar
zonas <- c("Comunidad Valenciana", "Espadán", "Font Roja", "Penyagolosa", "Vall d'Albaida")
tipos_red <- c("Micobionte", "Biotipo", "Hábitat", "Reproducción")

# Función para limpiar matrices y calcular métricas
analizar_red <- function(datos, col_inferior, col_superior) {
  matriz <- table(datos[[col_inferior]], datos[[col_superior]])
  # Limpieza de registros vacíos
  matriz <- matriz[rownames(matriz) != "", colnames(matriz) != ""]
  
  # 1. Anidamiento (NODF)
  nodf <- networklevel(matriz, index="NODF")
  
  # 2. Selectividad (H2')
  h2 <- networklevel(matriz, index="H2")
  
  # 3. Modularidad (Q)
  mod <- computeModules(as.matrix(matriz))
  
  return(list(NODF = nodf, H2 = h2, Q = mod@likelihood, Modulos = mod))
}

# Ejemplo de bucle para procesar Micobiontes en todas las zonas
resultados_finales <- list()

for (z in zonas) {
  ruta <- paste0("data/", z, ".csv")
  df <- read.csv2(ruta)
  
  print(paste("Analizando red de micobiontes en:", z))
  resultados_finales[[z]] <- analizar_red(df, "Micobionte", "Fotobionte")
}

# Guardar los roles de especie (c y z) de la Comunidad Valenciana
roles_cv <- czvalues(resultados_finales[["Comunidad Valenciana"]]$Modulos)
write.csv(roles_cv, "output/Roles_Especies_CV.csv")
