# 1. LIBRERÍAS
library(bipartite)
library(ggplot2)

# 2. REDES BIPARTITAS (plotweb)
# Esto genera el SVG que luego usas en Inkscape
svg("output/Red_Bipartita_Final.pdf", width = 16, height = 10)
plotweb(M_limpia, text.rot = 45, col.high = "#3B5C11", col.low = "#542D0F")
dev.off()
