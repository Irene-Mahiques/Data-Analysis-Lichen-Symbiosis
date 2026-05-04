# ==========================================================
# 04: REDES BIPARTITAS (PLOTWEB)
# ==========================================================

# 1. LIBRERÍAS
library(bipartite)
library(ggplot2)

# 2. CARGA DE DATOS
df <- read.csv2("data/Comunidad Valenciana.csv")
matriz <- table(df$Micobionte, df$Fotobionte)
M_limpia <- matriz[rownames(matriz) != "", colnames(matriz) != ""]

# 3. GENERACIÓN DEL SVG
if (!dir.exists("output")) dir.create("output")

svglite::svglite("output/Red_Bipartita_Final.svg", width = 16, height = 10)
plotweb(M_limpia, text.rot = 45, labsize = 1.2,
        col.high = "#3B5C11", col.low = "#542D0F", 
        y.width.low = 0.05, y.width.high = 0.05)
dev.off()
