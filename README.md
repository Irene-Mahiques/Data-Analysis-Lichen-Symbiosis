# 🍄 Lichen-Symbiont Interaction Networks

[![R-v4.2.0](https://img.shields.io/badge/R-v4.2.0-blue.svg)](https://www.r-project.org/)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)

**Investigadora:** Irene Mahiques Andrés  
**Especialidad:** Biología de Sistemas | Ecología Molecular  
**Contacto:** [LinkedIn](https://www.linkedin.com/in/irene-mahiques)

## 🎯 Resumen del Proyecto
Este repositorio documenta el pipeline bioinformático y estadístico desarrollado para mi **Trabajo de Fin de Grado (TFG)**. El proyecto modela las interacciones biológicas entre micobiontes y fotobiontes en ecosistemas de montaña de la Comunidad Valenciana.

**💡 Valor Tecnológico e Industrial:**  
Las metodologías de **modelado matemático de redes** y el tratamiento de datos biológicos complejos aquí presentados son directamente extrapolables a:
*   **Análisis de Microbiomas:** Caracterización de perfiles complejos.
*   **NAMs (Métodos Alternativos):** Biología de sistemas aplicada a validación toxicológica.
*   **Biomarcadores:** Detección de "nodos clave" en ecosistemas.

---

## 📂 Estructura del Repositorio
*   [`/scripts`](./scripts): 
    *   `01_data_cleaning.R`: Normalización taxonómica y curación de registros.
    *   `02_taxonomy_viz.R`: Generación de perfiles de diversidad (Clase/Orden/Familia).
    *   `03_network_analysis.R`: Cálculo de índices de red ($H_2'$, $Q$, NODF).
    *   `04_heatmaps_and_graphs.R`: Visualización de interacciones complejas.
*   [`/data`](./data): Estructura de matrices de interacción (muestras).
*   [`/output`](./output): Resultados visuales (SVG/PDF) listos para publicación.

---

## 🧬 Pipeline Bioinformático

### 1. Curación y Normalización
Implementación de scripts para la corrección masiva de registros y unificación taxonómica. El análisis se basa en el **Nº de registros (abundancia)** para garantizar rigor en grupos complejos como líquenes leprosos y crustáceos.

### 2. Modelado de Redes Bipartitas (`bipartite`)
Análisis topológico avanzado para determinar la estabilidad del ecosistema:
*   **Selectividad ($H_2'$):** Especialización absoluta de las simbiosis.
*   **Modularidad ($Q$):** Detección de compartimentación mediante algoritmos de verosimilitud.
*   **Roles de Especie:** Identificación de conectores y hubs mediante valores $c$ y $z$.

---

## 📈 Visualización y Resultados Clave

### A. Estructura de la Comunidad (Taxonomía)
<img width="875" alt="Familia_CV" src="https://github.com/user-attachments/assets/ee774441-96db-41a3-b0bf-107809cc40c9" />

### B. Evolución de la Selectividad ($H_2'$)
Análisis comparativo de la especialización hongo-alga a través de diferentes niveles de organización y zonas geográficas.
<img width="1000" alt="Grafica_Selectividad_Definitiva" src="https://github.com/user-attachments/assets/94c86a6e-ba3e-486b-9e9e-8e55e6a7a759" />

---

## ⚙️ Metodología
1. **Lab:** Extracción ADN (Chelex®), PCR (ITS) y purificación enzimática.
2. **Bioinfo:** Ensamblaje (Geneious), alineamiento (MAFFT) y filogenia (RAxML).
3. **Estadística:** Modelado matemático de redes bipartitas en R.
