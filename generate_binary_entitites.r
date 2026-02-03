args <- commandArgs(trailingOnly = TRUE)
sc <- args[1]         # NaC / NfN / NfS
yr <- as.integer(args[2])

library(terra)
library(dplyr)
library(stringr)

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

# LUT
lut <- read.csv("/gpfs1/data/fragana/GLOBIO_categories.csv")
broad_ids <- sort(unique(lut$broad_id))

# Select raster
if (yr == 2020) {
  src <- list.files(tif_root, pattern="Historical_2020.*tif$", full.names=TRUE)
} else {
  src <- list.files(tif_root, pattern=paste0(sc, ".*", yr, ".*tif$"), full.names=TRUE)
}
stopifnot(length(src) == 1)

r <- rast(src)

for (i in seq_along(broad_ids)) {
  bin <- broad_ids[i]

  bin_r <- ifel(is.na(r), NA, ifel(r == bin, 1, 0))

  out <- file.path(out_root, sprintf("entity_%02d.tif", i))

  writeRaster(
    bin_r, out,
    overwrite = TRUE,
    datatype  = "INT1S",
    NAflag    = -1,
    wopt = list(gdal = c("COMPRESS=DEFLATE"))
  )

  rm(bin_r)
  gc()
}
