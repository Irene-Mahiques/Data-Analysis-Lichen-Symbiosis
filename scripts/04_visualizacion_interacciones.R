library(bipartite)
library(ggplot2)
library(svglite)

# 1. RED BIPARTITA ESTÉTICA (Ejemplo Comunidad Valenciana)
# Cargamos datos para el gráfico
try({
  df <- read.csv2("Comunidad Valenciana.csv")
  matriz <- table(df$Micobionte, df$Fotobionte)
  M_limpia <- matriz[rownames(matriz) != "", colnames(matriz) != ""]

  # Generamos el SVG para Inkscape
  svglite("output/Red_Bipartita_Final.svg", width = 16, height = 10)
  plotweb(M_limpia, text.rot = 45, labsize = 1.2,
          col.high = "#3B5C11", col.low = "#542D0F", 
          y.width.low = 0.05, y.width.high = 0.05)
  dev.off()
