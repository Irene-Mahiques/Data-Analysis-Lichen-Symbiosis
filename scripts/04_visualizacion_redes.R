if (!dir.exists("output")) dir.create("output")

# ==========================================================
# 04: REDES BIPARTITAS
# ==========================================================

# 1. LIBRERÍAS
library(bipartite)
library(ggplot2)

# 2. REDES BIPARTITAS (plotweb)
# Esto genera el SVG que luego usas en Inkscape
svg("output/Red_Bipartita_Final.svg", width = 16, height = 10)
plotweb(M_limpia, text.rot = 45, labsize = 2,
        col.high = "#3B5C11", col.low = "#542D0F", 
        y.width.low = 0.05, y.width.high = 0.05)
dev.off()
