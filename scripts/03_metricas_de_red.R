# ==========================================================
# SCRIPT 3: ANÁLISIS BIOESTADÍSTICO DE REDES
# ==========================================================
library(bipartite)

# Preparar Matriz
datos <- read.csv2("data/Comunidad_Valenciana.csv")
matriz <- table(datos$Micobionte, datos$Fotobionte)
matriz_pura <- as.matrix(as.data.frame.matrix(matriz))

# 1. Selectividad (H2')
h2_val <- networklevel(matriz_pura, index="H2")

# 2. Modularidad y Roles (c y z)
modulos <- computeModules(matriz_pura)
roles <- czvalues(modulos, level = "lower") # lower = hongos

# Imprimir Resultados
print(paste("Índice H2':", h2_val))
print(roles)
