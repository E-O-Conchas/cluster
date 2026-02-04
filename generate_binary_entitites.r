args <- commandArgs(trailingOnly = TRUE)
sc <- args[1]         # NaC / NfN / NfS
yr <- as.integer(args[2])

library(terra)

terraOptions(
  todisk  = TRUE,
  memfrac = 0.3,
  tempdir = Sys.getenv("TMPDIR", unset = "/scratch/tmp")
)

# ---- paths (adapt to EVE mounts) ----

# /gpfs1/work/oceguera
id <- 98
tif_root <- file.path("/gpfs1/data/fragana/aggregated_broadclasses")
out_root <- file.path("/gpfs1/data/fragana/", id, "binary", sc, yr)
dir.create(out_root, recursive = TRUE, showWarnings = FALSE)


HIST_DIR <- file.path(tif_root, "Historical_2020")
SC_DIR   <- file.path(tif_root, paste0(sc, "_19"))


# LUT
lut <- read.csv("/gpfs1/data/fragana/GLOBIO_categories.csv")
broad_ids <- sort(unique(lut$broad_id))

# Select raster


if (yr == 2020) {
  cand <- list.files(HIST_DIR, "\\.tif$", full.names = TRUE)
} else {
  cand <- list.files(SC_DIR, "\\.tif$", full.names = TRUE)
}


if (!dir.exists(SC_DIR)) stop("Scenario dir does not exist: ", SC_DIR)

# listar solo tif en esa carpeta
cand <- list.files(SC_DIR, pattern="\\.tif$", full.names=TRUE)

# quedarnos con el que tenga el año en el nombre
pat_year <- paste0("_", yr, "_")
src <- cand[grepl(pat_year, basename(cand))]

# debug útil si falla
if (length(src) != 1) {
  cat("DEBUG:\n")
  cat(" sc=", sc, " yr=", yr, "\n")
  cat(" sc_dir=", SC_DIR, "\n")
  cat(" candidates:\n", paste(basename(cand), collapse="\n"), "\n")
  cat(" matches:\n", paste(basename(src), collapse="\n"), "\n")
  stop("Expected exactly 1 raster for scenario/year; found ", length(src))
}

src <- src[1]
cat("Using raster:\n", src, "\n")

r <- rast(src)

for (i in seq_along(broad_ids)) {
  bin <- broad_ids[i]

  # bin_r <- ifel(is.na(r), NA, ifel(r == bin, 1, 0))
  bin_r <- (r == bin)

  out <- file.path(out_root, sprintf("entity_%02d.tif", i))

  writeRaster(
    bin_r, out,
    overwrite = TRUE,
    datatype="INT1U", 
    NAflag=255,
    #datatype  = "INT1S",
    #NAflag    = -1,
    wopt = list(gdal = c("COMPRESS=DEFLATE"))
  )

  rm(bin_r)
  gc()
}
