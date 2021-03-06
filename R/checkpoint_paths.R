
checkpointPath <- function(snapshotDate, checkpointLocation,
                           type = c("lib", "src", "snapshot", "root", "base")){
  rootPath <- normalizePath(
    file.path(checkpointLocation, ".checkpoint"),
    mustWork = FALSE)
  type <- match.arg(type)
  if(type == "base") return(
    normalizePath(
      file.path(rootPath, paste0("R-", getRversion())),
      winslash = "/", mustWork = FALSE)
  )
  snapshotPath <- file.path(rootPath, snapshotDate)
  libPath <- file.path(snapshotPath, "lib", R.version$platform, base::getRversion())
  srcPath <- file.path(libPath, "src/contrib")
  normalizePath(
    switch(
      type,
      root  = rootPath,
      lib   = libPath,
      src   = srcPath,
      snapshot = snapshotPath
    ),
    winslash = "/",
    mustWork = FALSE)}

createFolders <- function(snapshotDate, checkpointLocation){
  paths <- sapply(c("root", "lib", "src"), checkpointPath,
                  snapshotDate = snapshotDate,
                  checkpointLocation = checkpointLocation)
  sapply(paths, function(x) if(!file.exists(x)) dir.create(x, recursive=TRUE, showWarnings = FALSE))
  all(file.exists(paths))
}

file.path =
  function(...)
    gsub(pattern = "/+", replacement = "/", x = base::file.path(...))

authorizeFileSystemUse =
  function(checkpointLocation) {
    checkpointRoot = file.path(checkpointLocation, ".checkpoint")
    if(file.exists(checkpointRoot)) {
      if(!file.info(checkpointRoot)$isdir)
        stop("Can't use a non-directory as checkpoint root")}
    else {
      if(interactive()) {
        answer = readline(paste("Can I create directory", checkpointRoot, "for internal checkpoint use?(y/n)\n"))
        if(tolower(answer) != "y")
          stop("Cannot proceed without access to checkpoint directory")}
      else {
        stop(paste(
          "The .checkpoint folder does not exist. Please try again after creating the folder at", 
          normalizePath(checkpointRoot)
        ))
      }
    }
    checkpointLocation
  }
