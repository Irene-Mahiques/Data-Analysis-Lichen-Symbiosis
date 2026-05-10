# ==============================================================================
# SCRIPT 03: CURVAS DE RAREFACCIÓN
# Proyecto: Lichen-Net (TFG)
# Autora: Irene Mahiques Andrés
# Descripción: Evaluación del esfuerzo de muestreo y riqueza esperada.
#              Generación de gráficos vectoriales (SVG) para publicación.
# ==============================================================================

# 1. CARGA DE LIBRERÍAS Y ENTORNO ----------------------------------------------
if (!require("pacman")) install.packages("pacman")
pacman::p_load(dplyr, tidyr, vegan, svglite, readxl)

# Asegurar que existe el directorio de resultados
if (!dir.exists("output")) dir.create("output")

# 2. CARGA DE DATOS LIMPIOS (EXCEL) --------------------------------------------
# Usamos el archivo procesado por el Script 01
datos_limpios <- read_excel("data/processed/DATOS_R.xlsx")

# 3. CONSTRUCCIÓN DE LA MATRIZ DE COMUNIDAD ------------------------------------
matriz_comunidad <- datos_limpios %>%
  group_by(Zona, Micobionte_clean) %>%
  summarise(Abundancia = n(), .groups = "drop") %>%
  pivot_wider(names_from = Micobionte_clean, values_from = Abundancia, values_fill = 0)

# Formateo para la librería 'vegan'
comu_df <- as.data.frame(matriz_comunidad)
rownames(comu_df) <- comu_df$Zona
comu_df <- comu_df[, -1]

# 4. CONFIGURACIÓN ESTÉTICA Y COLORES ------------------------------------------
colores_zonas <- c(
  "Zona completa" = "#0B536E", 
  "Zona 1"        = "#D4AC0D", 
  "Zona 2"        = "#3B5C11", 
  "Zona 3"        = "#5C0C0C", 
  "Zona 4"        = "#542D0F"
)

# 5. GENERACIÓN DE LA FIGURA (SVG) ---------------------------------------------
svglite("output/03_Curvas_Rarefaccion_Final.svg", width = 8.5, height = 6, bg = "transparent")

# Ajuste de parámetros gráficos (Base R)
par(mar = c(5, 5, 4, 2) + 0.1, family = "sans")

# Cálculo y dibujo de las curvas
# 'sample' indica el tamaño de muestra mínimo para la comparación estandarizada
rarecurve(
  comu_df, 
  step = 1, 
  sample = min(rowSums(comu_df)), 
  col = colores_zonas[rownames(comu_df)], 
  lwd = 3, 
  ylab = "Riqueza Esperada de Taxones (S)", 
  xlab = "Esfuerzo de Muestreo (Nº de registros)", 
  main = "Curvas de Rarefacción por Enclave",
  font.main = 2, 
  cex.main = 1.4, 
  cex.lab = 1.1,
  label = FALSE # Quitamos etiquetas automáticas para usar una leyenda limpia
)

# Añadimos una leyenda profesional sin marco
legend(
  "bottomright", 
  legend = rownames(comu_df), 
  col = colores_zonas[rownames(comu_df)], 
  lty = 1, 
  lwd = 4, 
  bty = "n", 
  cex = 1.1,
  inset = c(0.02, 0.05)
)

dev.off()

message("✅ SCRIPT 03 (Rarefacción): Figura guardada correctamente como SVG.")
