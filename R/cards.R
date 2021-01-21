rstudio_hex <- function(pkg) {
  list(
    src = glue("https://github.com/rstudio/hex-stickers/raw/master/PNG/{pkg}.png"),
    alt = glue("{pkg} R package hex sticker")
  )
}
