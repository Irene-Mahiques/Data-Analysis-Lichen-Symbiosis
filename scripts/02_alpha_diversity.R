# ==============================================================================
# SCRIPT 02: ÍNDICES DE DIVERSIDAD ALFA
# Proyecto: Lichen-Net (TFG)
# Autora: Irene Mahiques Andrés
# Descripción: Inferencia de diversidad Alfa.
# ==============================================================================

# 1. CARGA DE LIBRERÍAS Y ENTORNO ----------------------------------------------
if (!require("pacman")) install.packages("pacman")
pacman::p_load(dplyr, tidyr, vegan, ggplot2, svglite, readxl, writexl)

# Asegurar que existe el directorio de resultados
if (!dir.exists("output")) dir.create("output")

# 2. CARGA DE DATOS LIMPIOS (EXCEL) --------------------------------------------
# Se asume que DATOS_R.xlsx ya contiene los nombres de zona anonimizados
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

# 4. CÁLCULO DE ÍNDICES ECOLÓGICOS ---------------------------------------------
tabla_diversidad <- data.frame(
  Zona = rownames(comu_df),
  Riqueza_S = specnumber(comu_df),
  Shannon_H = round(diversity(comu_df, index = "shannon"), 3),
  Simpson_1_D = round(diversity(comu_df, index = "simpson"), 3)
) %>%
  # Cálculo de la Equidad de Pielou (J')
  mutate(Equidad_Pielou = round(Shannon_H / log(Riqueza_S), 3)) %>%
  arrange(desc(Shannon_H))

# Exportación de resultados
write_xlsx(tabla_diversidad, "output/02_Tabla_Diversidad_Resultados.xlsx")

message("✅ SCRIPT 02 (Diversidad Alfa): Ejecución completada con éxito.")
