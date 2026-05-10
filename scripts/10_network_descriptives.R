# ==============================================================================
# SCRIPT 10: ESTADÍSTICAS DESCRIPTIVAS DE LA RED
# Proyecto: Lichen-Net (TFG)
# Autora: Irene Mahiques Andrés
# Descripción: Extracción de magnitudes básicas de la meta-red (nodos, 
#              observaciones, enlaces únicos).
# ==============================================================================

# 1. CARGA DE LIBRERÍAS Y ENTORNO ----------------------------------------------
if (!require("pacman")) install.packages("pacman")
pacman::p_load(readxl, dplyr, writexl)

# Asegurar que existe el directorio de resultados
if (!dir.exists("output")) dir.create("output")

# 2. CARGA DE DATOS LIMPIOS ----------------------------------------------------
# Leemos el archivo central y filtramos valores nulos en los simbiontes
df <- read_excel("data/processed/DATOS_R.xlsx") %>%
  filter(!is.na(Micobionte_clean), !is.na(Fotobionte_clean))

# 3. CÁLCULOS DE MAGNITUD (KPIs Topológicos) -----------------------------------
n_observaciones <- nrow(df)                           # Total de muestras procesadas
n_micobiontes   <- n_distinct(df$Micobionte_clean)    # Nodos de nivel superior
n_fotobiontes   <- n_distinct(df$Fotobionte_clean)    # Nodos de nivel inferior

# Cálculo de enlaces (links): combinaciones únicas entre hongo y alga
enlaces_unicos <- df %>% 
  select(Micobionte_clean, Fotobionte_clean) %>% 
  distinct() %>% 
  nrow()

# 4. CONSOLIDACIÓN Y EXPORTACIÓN -----------------------------------------------
df_descriptivos <- data.frame(
  Metrica = c("Total Observaciones (Muestras válidas)", 
              "Riqueza de Micobiontes (Nodos Top)", 
              "Riqueza de Fotobiontes (Nodos Bottom)", 
              "Interacciones Únicas (Enlaces/Edges)"),
  Valor = c(n_observaciones, n_micobiontes, n_fotobiontes, enlaces_unicos)
)

# Exportamos a Excel
write_xlsx(df_descriptivos, "output/10_Tabla_Estadisticas_Red.xlsx")

# 5. REPORTE POR CONSOLA -------------------------------------------------------
message("✅ SCRIPT 10 (Descriptivos): Ejecución completada. Resultados extraídos:")
print(df_descriptivos)
