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
datos_limpios <- read_excel("data/processed/DATOS_R.xlsx") %>%
  filter(!is.na(Zona), !is.na(Micobionte_clean))

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
  "Zona 1"        = "#D4AC0D", 
  "Zona 2"        = "#3B5C11", 
  "Zona 3"        = "#0B536E", 
  "Zona 4"        = "#542D0F"
)

# 5. GENERACIÓN DE LA FIGURA (SVG) ---------------------------------------------
svglite("output/03_Curvas_Rarefaccion_Final.svg", width = 8.5, height = 6, bg = "transparent")

# Ajuste de parámetros gráficos (Base R)
par(mar = c(6, 6, 5, 3) + 0.1, family = "sans")

# Cálculo y dibujo de las curvas
rarecurve(
  comu_df, 
  step = 1, 
  col = colores_zonas[rownames(comu_df)], 
  lwd = 3, 
  ylab = "Riqueza Esperada de Taxones (S)", 
  xlab = "Esfuerzo de Muestreo (Nº de registros)", 
  main = "Curvas de Rarefacción por Enclave",
  font.main = 2, 
  cex.main = 2.0,  # Tamaño del TÍTULO principal
  cex.lab = 1.6,   # Tamaño del texto de los EJES (X e Y)
  cex.axis = 1.3,  # Tamaño de los NÚMEROS de los ejes
  cex = 1.4        # Tamaño de las etiquetas al final de cada curva
)

# Añadimos una leyenda
legend(
  "bottomright", 
  legend = rownames(comu_df), 
  col = colores_zonas[rownames(comu_df)], 
  lty = 1, 
  lwd = 3, 
  bty = "n", 
  cex = 1.4        # Tamaño del texto de la LEYENDA
)

dev.off()

message("✅ SCRIPT 03 (Rarefacción): Figura guardada correctamente como SVG.")
