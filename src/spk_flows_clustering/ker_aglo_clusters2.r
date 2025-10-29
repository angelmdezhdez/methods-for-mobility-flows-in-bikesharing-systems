##############################################################
# Libraries
##############################################################

options(warn = -1)
library(argparse)
library(RcppCNPy)
library(ggplot2)
library(dendextend)  

##############################################################
# Argument Parsing
##############################################################

parser <- ArgumentParser(description = "Clustering aglomerativo con matriz de kernel")
parser$add_argument('-km',"--kernel_matrix", type = "character", help = "Ruta al archivo .npy de la matriz de kernel", required = TRUE)
parser$add_argument('-dates', '--dates', type = "character", help = "Fechas a clusterizar (con columna opcional 'labels')", required = FALSE)
parser$add_argument('-odir', "--outdir", type = "character", default = "resultados", help = "Directorio de salida")
args <- parser$parse_args()

kernel_path <- args$kernel_matrix   
if (!file.exists(kernel_path)) {
  stop("Matrix file does not exist: ", kernel_path)
}

dates_path <- args$dates
if (!is.null(dates_path)) {
  dates <- read.csv(dates_path, header = TRUE, stringsAsFactors = FALSE)
} else {
  dates <- NULL
}

output_dir <- args$outdir        
if (!dir.exists(output_dir)) {
  dir.create(output_dir)
}

##############################################################
# Open a file to write results (append mode)
##############################################################

results_path <- file.path(output_dir, "results.txt")
results <- file(results_path, open = "w")

cat('Kernel matrix path:', kernel_path, '\n', file = results)
cat('Dates path:', dates_path, '\n', file = results)
cat('Output directory:', output_dir, '\n', file = results)

##############################################################
# Aglomerative Clustering
##############################################################

start_time <- Sys.time()

K <- npyLoad(kernel_path)
if (is.null(dates)) {
  dates <- data.frame(date = 1:nrow(K))
}

rownames(K) <- dates$dates

if (nrow(K) != ncol(K)) {
  stop("Kernel matrix must be square.")
}

# Computing the distance matrix from the kernel matrix
D <- sqrt(outer(diag(K), diag(K), "+") - 2 * K)

# dist object
D_dist <- as.dist(D)

hc <- hclust(D_dist, method = "complete")
dhc <- as.dendrogram(hc)

end_time <- Sys.time()
cat('Clustering completed in:', end_time - start_time, 'seconds.\n', file = results)

##########################################################
# Save clustering results
##########################################################

n_ <- nrow(K)
for (k in 2:(n_ - 1)) {
  etiquetas <- cutree(hc, k = k)
  ruta_etiquetas <- file.path(output_dir, paste0("labels_k", k, ".npy"))
  npySave(ruta_etiquetas, etiquetas)
}

write.csv(dates, file = file.path(output_dir, "dates.csv"), row.names = FALSE)

##########################################################
# Dendrograma coloreado por etiquetas (si existen)
##########################################################

pdf(file = file.path(output_dir, "dendrogram_colored.pdf"), width = 18, height = 12)

# Si existe la columna "labels", usamos colores
if ("labels" %in% colnames(dates)) {   # NUEVO
  # Convertimos labels a factor (para asegurar que haya un color por etiqueta)
  labels_factor <- as.factor(dates$labels)
  
  # Generamos una paleta de colores para las etiquetas únicas
  colores <- rainbow(length(levels(labels_factor)))
  names(colores) <- levels(labels_factor)
  
  # Asignamos colores a las hojas del dendrograma según su etiqueta
  dhc <- dhc %>%
    set("labels_colors", colores[as.character(labels_factor[order.dendrogram(dhc)])]) %>%
    set("labels_cex", 0.8)
  
  plot(dhc,
       main = "Aglomerative clustering dendrogram",
       xlab = "", sub = "")
  
  #legend("topright", legend = levels(labels_factor), col = colores, pch = 19, cex = 0.8)
  
} else {
  # Si no hay labels, graficamos como antes
  plot(dhc,
       main = "Aglomerative clustering dendrogram",
       xlab = "", sub = "",
       cex = 0.8)
}

ks <- 2:(n_-1)
n <- length(hc$order)
heights_k <- hc$height[(n - ks)]

for (h in heights_k) {
  abline(h = h, col = "blue", lty = 3)
}

axis(side = 4, at = heights_k, labels = ks, las = 1, col.axis = "blue", cex.axis = 0.8)
mtext("k", side = 4, line = 3, col = "blue", cex = 0.9)

invisible(dev.off())

cat('Finished!\n')
