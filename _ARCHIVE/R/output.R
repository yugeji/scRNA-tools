#' Make table JSON
#'
#' Create table JSON
#'
#' @param swsheet Tibble containing software table
make_table_json <- function(swsheet) {

    futile.logger::flog.info("Converting tools table...")

    table <- jsonlite::toJSON(swsheet, pretty = TRUE)

    futile.logger::flog.info("Writing 'tools-table.json'...")
    readr::write_lines(table, "docs/data/tools-table.json")
}


#' Make tools JSON
#'
#' Create tools JSON
#'
#' @param tidysw Tibble containing tidy software table
make_tools_json <- function(tidysw) {

    `%>%` <- magrittr::`%>%`

    futile.logger::flog.info("Converting tools...")

    catlist <- split(tidysw$Category, f = tidysw$Name)

    tools <- tidysw %>%
        dplyr::select(-Category) %>%
        unique() %>%
        dplyr::mutate(Categories = catlist[Name]) %>%
        jsonlite::toJSON(pretty = TRUE)

    futile.logger::flog.info("Writing 'tools.json'...")
    readr::write_lines(tools, "docs/data/tools.json")
}


#' Make categories JSON
#'
#' Create categories JSON
#'
#' @param tidysw Tibble containing tidy software table
#' @param swsheet Tibble containing software table
#' @param descs data.frame containing category descriptions
make_cats_json <- function(tidysw, swsheet, descs) {

    `%>%` <- magrittr::`%>%`

    futile.logger::flog.info("Converting categories...")

    namelist <- split(tidysw$Name, f = tidysw$Category)
    namelist <- lapply(namelist, function(x) {
        swsheet %>%
            dplyr::filter(Name %in% x) %>%
            dplyr::select(Name, Citations, Publications, Preprints, BioC, CRAN,
                          PyPI, Conda, Added, Updated)
    })

    cats <- tidysw %>%
        dplyr::select(Category) %>%
        dplyr::arrange(Category) %>%
        unique() %>%
        dplyr::mutate(Tools = namelist[Category]) %>%
        dplyr::left_join(descs, by = "Category") %>%
        jsonlite::toJSON(pretty = TRUE)

    futile.logger::flog.info("Writing 'categories.json'...")
    readr::write_lines(cats, "docs/data/categories.json")
}


#' Write footer
#'
#' Write a HTML footer to use on website pages
write_footer <- function() {
    datetime <- Sys.time()
    attr(datetime, "tzone") <- "UTC"

    writeLines(paste0('<p class="text-muted">Last updated: ', datetime,
                      ' UTC</p>'),
               "docs/footer_content.html")
}
