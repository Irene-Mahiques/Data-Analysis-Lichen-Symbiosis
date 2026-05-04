# 1. LIBRERÍAS
library(bipartite)

# 2. CÁLCULO DE ÍNDICES (Ejemplo Comunidad Valenciana)
# M es tu matriz de interacciones hongo-alga
M <- table(datos$Micobionte, datos$Fotobionte)
M_limpia <- M[rownames(M) != "", colnames(M) != ""]

# Selectividad H2'
h2 <- networklevel(M_limpia, index="H2")
print(paste("Selectividad H2':", h2))

# Modularidad Q
modulos <- computeModules(as.matrix(M_limpia))
print(paste("Modularidad Q:", modulos@likelihood))

# Especies clave (c y z)
roles <- czvalues(modulos)
write.csv(roles, "output/Especies_Clave_CZ.csv")
