library("stringr")
library("whisker")

.DATA_URL <- "http://content.bfwpub.com/webroot_pubcontent/Content/BCS_5/BPS6e/Student/DataSets/PC_Text/PC_Text.zip"

.LARGE_DATA_URL <- "http://content.bfwpub.com/webroot_pubcontent/Content/BCS_5/BPS6e/Student/DataSets/LargeDataSets/Large_Data_Sets.zip"

download_unzip <- function(url) {
  # create a temporary directory
  td = tempdir()
  # create the placeholder file
  tf = tempfile(tmpdir=td, fileext=".zip")
  # download into the placeholder file
  download.file(url, tf)
  unzip(tf, exdir = td)
}

read_data <- function(x) {
  read.delim(x, stringsAsFactors = FALSE, fileEncoding = "latin1",
             encoding = "UTF-8")
}

save_data <- function(.data, name) {
  assign(name, .data)
  save(list = name, file = file.path("data", str_c(name, ".rda")))
}

dir.create("data", showWarnings = FALSE)
dir.create("R", showWarnings = FALSE)

files <- download_unzip(.DATA_URL)

datasets <- list()
for (fname in files) {
  objname <- make.names(tools::file_path_sans_ext(basename(fname)))
  chapter <- str_match(fname, "Chapter (\\d+)")[1, 2]

  if (objname %in% names(datasets)) {
    datasets[[objname]] <- c(datasets[[objname]], chapter)
  } else {
    datasets[[objname]] <- chapter
    save_data(read_data(fname), objname)
  }
}
datasets <- sapply(datasets, function(x) paste(sort(x), collapse = ", "))

render_template <- function(src, dst, data = list()) {
  template <- paste(readLines(src), collapse = "\n")
  cat(whisker.render(template, data), file = dst)
}
tpl_data <- list(url = .DATA_URL,
                 datasets = iteratelist(datasets))
render_template("r.template", "R/data.R", data = tpl_data)
