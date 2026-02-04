args <- commandArgs(trailingOnly = TRUE)
sc <- args[1]
yr <- as.integer(args[2])

library(terra)

terraOptions(
  todisk  = TRUE,
  memfrac = 0.3,
  tempdir = Sys.getenv("TMPDIR", unset = "/tmp")
)

id <- 98
tif_root <- "/gpfs1/data/fragana/aggregated_broadclasses"

HIST_DIR <- file.path(tif_root, "Historical_2020")
SC_DIR   <- file.path(tif_root, paste0(sc, "_19"))

# outputs
out_root <- file.path("/gpfs1/data/fragana", as.character(id), "binary", sc, as.character(yr))
dir.create(out_root, recursive = TRUE, showWarnings = FALSE)

# LUT
lut <- read.csv("/gpfs1/data/fragana/GLOBIO_categories.csv")
broad_ids <- sort(unique(lut$broad_id))

# ---- Select source raster ----
if (yr == 2020 || sc == "HIST") {

  if (!dir.exists(HIST_DIR)) stop("Historical dir does not exist: ", HIST_DIR)

  cand <- list.files(HIST_DIR, pattern="\\.tif$", full.names=TRUE)
  # si hay más de uno, filtra por año
  src <- cand[grepl(paste0("_", yr, "_"), basename(cand))]

} else {

  if (!dir.exists(SC_DIR)) stop("Scenario dir does not exist: ", SC_DIR)

  cand <- list.files(SC_DIR, pattern="\\.tif$", full.names=TRUE)
  src <- cand[grepl(paste0("_", yr, "_"), basename(cand))]
}

if (length(src) != 1) {
  cat("DEBUG:\n")
  cat(" sc=", sc, " yr=", yr, "\n")
  cat(" dir_used=", if (yr == 2020 || sc == "HIST") HIST_DIR else SC_DIR, "\n")
  cat(" candidates:\n", paste(basename(cand), collapse="\n"), "\n")
  cat(" matches:\n", paste(basename(src), collapse="\n"), "\n")
  stop("Expected exactly 1 raster for scenario/year; found ", length(src))
}

src <- src[1]
cat("Using raster:\n", src, "\n")

r <- rast(src)

# ---- Create entities ----
for (i in seq_along(broad_ids)) {

  bin <- broad_ids[i]

  # presencia/ausencia 0/1 (más ligero que NA)
  bin_r <- as.int(r == bin)

  out <- file.path(out_root, sprintf("entity_%02d.tif", i))

  writeRaster(
    bin_r, out,
    overwrite = TRUE,
    datatype  = "INT1U",
    wopt = list(gdal = c("COMPRESS=DEFLATE"))
  )

  rm(bin_r)
  gc()
}
