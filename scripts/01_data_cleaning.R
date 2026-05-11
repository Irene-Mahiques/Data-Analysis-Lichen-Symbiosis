# ==============================================================================
# Script: 01_data_cleaning.R
# Proyecto: Lichen-Net (TFG)
# Autora: Irene Mahiques Andrés
# Descripción: Depuración, estandarización taxonómica y exportación a Excel.
# ==============================================================================

# 1. CARGA DE LIBRERÍAS --------------------------------------------------------
if (!require("pacman")) install.packages("pacman")
# Añadimos readxl (para leer) y writexl (para exportar a Excel)
pacman::p_load(dplyr, stringr, tidyr, readxl, writexl)

# 2. CARGA DE DATOS (MOCK DATA) -----------------------------------------------
# Archivo con datos inventados para demostración del pipeline
raw_data <- read_excel("data/raw/DATOS_R.xlsx")

# 3. DEPURACIÓN INICIAL --------------------------------------------------------
clean_data <- raw_data %>%
  # Suponiendo que las columnas se llaman 'Zona', 'Micobionte', 'Fotobionte'
  filter(!is.na(Micobionte) & Micobionte != "") %>%
  mutate(
    # Estandarización de partículas de incertidumbre
    Micobionte_clean = str_replace_all(Micobionte, " cf\\.| aff\\.| gr\\.", ""),
    Fotobionte_clean = str_replace_all(Fotobionte, " cf\\.| aff\\.| gr\\.", ""),
    across(where(is.character), str_trim) # Limpia espacios extra en textos
  )

# 4. EXPORTACIÓN DE MATRIZ PROCESADA (EXCEL) -----------------------------------
# Exportamos el resultado limpio como DATOS_R.xlsx
write_xlsx(clean_data, "data/processed/DATOS_R.xlsx")

message("✅ SCRIPT 01: Depuración completada. Matriz guardada como DATOS_R.xlsx")
