# ==============================================================================
# SCRIPT 11: CATÁLOGO FLORÍSTICO AGREGADO
# Proyecto: Lichen-Net (TFG)
# Autora: Irene Mahiques Andrés
# Descripción: Consolidación de información taxonómica, funcional y de 
#              distribución por especie. Generación de inventario final (Excel).
# ==============================================================================

# 1. CARGA DE LIBRERÍAS Y ENTORNO ----------------------------------------------
if (!require("pacman")) install.packages("pacman")
pacman::p_load(readxl, dplyr, tidyr, writexl)

# Asegurar que existe el directorio de resultados
if (!dir.exists("output")) dir.create("output")

# 2. CARGA DE DATOS ------------------------------------------------------------
# Se utiliza el archivo específico para el catálogo (mantiene nomenclatura original)
df <- read_excel("data/raw/DATOS_CATÁLOGO.xlsx") %>%
  rename(Reproduccion = matches("Reproducción")) %>%
  filter(!is.na(Micobionte))

# 3. FUNCIÓN DE AGREGACIÓN TAXONÓMICA ------------------------------------------
# Concatena valores únicos, los ordena alfabéticamente y los separa por comas
agrupar_unicos <- function(x) {
  valores <- sort(unique(na.omit(x)))
  if(length(valores) == 0) return(NA)
  
  paste(valores, collapse = ", ")
}

# 4. GENERACIÓN DEL CATÁLOGO ---------------------------------------------------
message("Generando catálogo florístico... (N=", nrow(df), " registros)")

catalogo_final <- df %>%
  group_by(Micobionte) %>%
  summarise(
    Fotobionte = agrupar_unicos(Fotobionte),
    Biotipo = agrupar_unicos(Biotipo),
    Sustrato = agrupar_unicos(Sustrato),
    Reproducción = agrupar_unicos(Reproduccion),
    `Zonas de Distribución` = agrupar_unicos(Zona)
  ) %>%
  # Ordenación alfabética por género/especie
  arrange(Micobionte)

# 5. EXPORTACIÓN ---------------------------------------------------------------
write_xlsx(catalogo_final, "output/11_Catalogo_Floristico_LichenNet.xlsx")

message("✅ SCRIPT 11 (Catálogo): Archivo generado con éxito en la carpeta output.")
