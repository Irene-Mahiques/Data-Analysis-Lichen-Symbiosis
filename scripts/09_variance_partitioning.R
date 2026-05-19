# ==================================================================================
# SCRIPT 09: PARTICIÓN DE LA VARIANZA (VARPART)
# Proyecto: Lichen-Net (TFG)
# Autora: Irene Mahiques Andrés
# Descripción: Modelado de los determinantes de la simbiosis liquénica mediante 
#              partición de varianza (2, 3 y 4 vías). Diagramas de Venn vectoriales.
# ==================================================================================

# 1. CARGA DE LIBRERÍAS Y ENTORNO ----------------------------------------------
if (!require("pacman")) install.packages("pacman")
pacman::p_load(readxl, dplyr, tidyr, vegan, writexl, svglite)

if (!dir.exists("output")) dir.create("output")

# 2. CARGA CENTRAL DE DATOS ----------------------------------------------------
# Lectura y estandarización del nombre de la variable conflictiva
df_base <- read_excel("data/processed/DATOS_R.xlsx") %>%
  rename(Reproduccion = matches("Reproducci"))


# ==============================================================================
# MODELO 1: PARTICIÓN DE 2 VÍAS (Geografía vs. Biología)
# ==============================================================================
message("Ejecutando Modelo 1 (2 Vías)...")

df_2v <- df_base %>%
  select(Fotobionte_clean, Zona, Biotipo, Sustrato, Reproduccion) %>%
  drop_na()

# Matrices de diseño
Y_2v  <- as.data.frame(model.matrix(~ Fotobionte_clean - 1, data = df_2v))
X1_2v <- as.data.frame(model.matrix(~ Zona - 1, data = df_2v))    
X2_2v <- as.data.frame(model.matrix(~ Biotipo + Sustrato + Reproduccion - 1, data = df_2v)) 

mod_2v <- varpart(Y_2v, X1_2v, X2_2v)

# Exportar Tabla
df_res_2v <- as.data.frame(mod_2v$part$indfract) %>%
  mutate(Fraccion = c("Geografía Pura [a]", "Biología Pura [b]", "Compartida [c]", "Residual [d]")) %>%
  select(Fraccion, Adj.R.squared)
write_xlsx(df_res_2v, "output/09_Tabla_Varianza_2Vias.xlsx")

# Exportar Figura (SVG)
svglite("output/09_Figura_Venn_2Vias.svg", width = 8, height = 8, bg = "transparent")
plot(mod_2v, 
     Xnames = c("Geografía", "Biología"), 
     bg = c("#4E7E1A", "#7B4B2A"), 
     alpha = 150, cex = 1.5, digits = 3)
title(main = "Determinantes de la Simbiosis",
      sub = paste("N =", nrow(df_2v), "muestras"),
      font.main = 2, cex.main = 1.6)
dev.off()


# ==================================================================================================
# MODELO 2: PARTICIÓN DE 4 VÍAS (Filogenia, Geografía, Reproducción y Hábitat (Biotipo + Sustrato))
# ==================================================================================================
message("Ejecutando Modelo 2 (4 Vías Complejo)...")

df_4v <- df_base %>%
  select(Fotobionte_clean, Zona, Reproduccion, Biotipo, Sustrato, Familia) %>% 
  drop_na()

Y_4v  <- as.data.frame(model.matrix(~ Fotobionte_clean - 1, data = df_4v))
X1_4v <- as.data.frame(model.matrix(~ Familia - 1, data = df_4v))      # Filogenia
X2_4v <- as.data.frame(model.matrix(~ Zona - 1, data = df_4v))         # Geografía
X3_4v <- as.data.frame(model.matrix(~ Reproduccion - 1, data = df_4v)) # Reproducción
X4_4v <- as.data.frame(model.matrix(~ Biotipo + Sustrato - 1, data = df_4v)) # Hábitat

mod_4v <- varpart(Y_4v, X1_4v, X2_4v, X3_4v, X4_4v)

df_res_4v <- as.data.frame(mod_4v$part$indfract) %>%
  mutate(Fraccion = rownames(.)) %>%
  select(Fraccion, everything())
write_xlsx(df_res_4v, "output/09_Tabla_Varianza_4Vias.xlsx")

svglite("output/09_Figura_Venn_4Vias.svg", width = 10.5, height = 10.5, bg = "transparent")
plot(mod_4v, 
     Xnames = c("Familia", "Geografía", "Reproducción", "Hábitat"), 
     bg = c("#4E7E1A", "#7B4B2A", "#D4AC0D", "#5D6D7E"), 
     alpha = 140, cex = 1.1)
title(main = "Determinantes Complejos de la Simbiosis", 
      sub = paste("Partición en 4 bloques | N =", nrow(df_4v)), 
      font.main = 2, cex.main = 1.4)
dev.off()


# ================================================================================
# MODELO 3: PARTICIÓN DE 4 VÍAS (Separando Biotipo y Sustrato, y sin reproducción)
# ================================================================================
message("Ejecutando Modelo 3 (4 Vías - Biotipo vs Sustrato)...")

df_biosus <- df_base %>%
  select(Fotobionte_clean, Familia, Zona, Biotipo, Sustrato) %>% 
  drop_na()

Y_bs  <- as.data.frame(model.matrix(~ Fotobionte_clean - 1, data = df_biosus))
X1_bs <- as.data.frame(model.matrix(~ Familia - 1, data = df_biosus))  
X2_bs <- as.data.frame(model.matrix(~ Zona - 1, data = df_biosus))     
X3_bs <- as.data.frame(model.matrix(~ Biotipo - 1, data = df_biosus))  
X4_bs <- as.data.frame(model.matrix(~ Sustrato - 1, data = df_biosus)) 

mod_biosus <- varpart(Y_bs, X1_bs, X2_bs, X3_bs, X4_bs)

df_res_biosus <- as.data.frame(mod_biosus$part$indfract) %>%
  mutate(Fraccion = rownames(.)) %>%
  select(Fraccion, everything())
write_xlsx(df_res_biosus, "output/09_Tabla_Varianza_4Vias_BiotipoSustrato.xlsx")

svglite("output/09_Figura_Venn_4Vias_BiotipoSustrato.svg", width = 10.5, height = 10.5, bg = "transparent")
plot(mod_biosus, 
     Xnames = c("Familia", "Geografía", "Biotipo", "Sustrato"), 
     bg = c("#4E7E1A", "#7B4B2A", "#D4AC0D", "#0B536E"), 
     alpha = 140, cex = 1.1)
title(main = "Determinantes de la Simbiosis (Desglose Estructural)", 
      sub = paste("Familia vs Geografía vs Biotipo vs Sustrato | N =", nrow(df_biosus)), 
      font.main = 2, cex.main = 1.4)
dev.off()


# ==============================================================================
# MODELO 4: PARTICIÓN DE 3 VÍAS (Familia vs Biotipo vs Sustrato)
# ==============================================================================
message("Ejecutando Modelo 4 (3 Vías - Genética vs Ambiente)...")

df_3v <- df_base %>%
  select(Fotobionte_clean, Familia, Biotipo, Sustrato) %>% 
  drop_na()

Y_3v  <- as.data.frame(model.matrix(~ Fotobionte_clean - 1, data = df_3v))
X1_3v <- as.data.frame(model.matrix(~ Familia - 1, data = df_3v))  # FILOGENIA
X2_3v <- as.data.frame(model.matrix(~ Biotipo - 1, data = df_3v))  # MORFOLOGÍA
X3_3v <- as.data.frame(model.matrix(~ Sustrato - 1, data = df_3v)) # ECOLOGÍA

mod_3v <- varpart(Y_3v, X1_3v, X2_3v, X3_3v)

df_res_3v <- as.data.frame(mod_3v$part$indfract) %>%
  mutate(Fraccion = rownames(.)) %>%
  select(Fraccion, everything())
write_xlsx(df_res_3v, "output/09_Tabla_Varianza_3Vias.xlsx")

svglite("output/09_Figura_Venn_3Vias.svg", width = 10.5, height = 10.5, bg = "transparent")

plot(mod_3v, 
     Xnames = c("Familia", "Biotipo", "Sustrato"), 
     bg = c("#4E7E1A", "#D4AC0D", "#0B536E"), # Verde oliva, Mostaza, Azul oscuro
     alpha = 140, cex = 1.3)

title(main = "Determinantes de la Simbiosis (Genética vs Ambiente)", 
      sub = paste("Filogenia vs Morfología vs Ecología | N =", nrow(df_3v)), 
      font.main = 2, cex.main = 1.4)

dev.off()

message("✅ SCRIPT 09 (Varpart): Todos los modelos ejecutados y guardados correctamente.")
