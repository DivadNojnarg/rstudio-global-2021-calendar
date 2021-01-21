library(shiny)
library(shinyMobile)
library(lubridate)
library(calendar)
library(reactable)
library(glue)
source("R/stack.R")
source("R/tz.R")
source("R/cards.R")

options(reactable.theme = reactableTheme(
  color = "hsl(233, 9%, 87%)",
  backgroundColor = "#202020",
  borderColor = "hsl(233, 9%, 22%)",
  stripedColor = "hsl(233, 12%, 22%)",
  highlightColor = "hsl(233, 12%, 24%)",
  inputStyle = list(backgroundColor = "hsl(233, 9%, 25%)"),
  selectStyle = list(backgroundColor = "hsl(233, 9%, 25%)"),
  pageButtonHoverStyle = list(backgroundColor = "hsl(233, 9%, 25%)"),
  pageButtonActiveStyle = list(backgroundColor = "hsl(233, 9%, 28%)")
))

Sys.setenv(TZ = "UTC")

schedule <- readr::read_csv("data/schedule.csv")
schedule$id <- seq_len(nrow(schedule))
year(schedule$time_gmt) <- 2021
schedule$name <- gsub("\n", ", ", schedule$name)

ui <- f7Page(
  title = 'rstudio global',
  options = list(
    theme = "auto",
    version = "1.0.0",
    taphold = TRUE,
    #color = "#42f5a1",
    filled = FALSE,
    dark = TRUE
  ),
  f7TabLayout(
    navbar = f7Navbar(
      title = f7Link(
        href = "https://global.rstudio.com",
        code("rstudio::global")
      ),
      hairline = TRUE,
      shadow = TRUE,
      bigger = TRUE,
      transparent = TRUE
    ),
    f7Tabs(
      id = "tabs",
      f7Tab(
        tabName = "Schedule",
        icon = f7Icon("calendar"),
        # skip link
        a(
          "If you're using a screen reader, you may find the official ",
          "RStudio Global conference website is better suited. Do you want to go there now?",
          class = "screenreader-text external",
          `tab-index` = 1,
          href = "https://global.rstudio.com/student/all_events"
        ),
        uiOutput("your_talks"),

        br(),
        f7Flex(f7Button("options", "Options", fill = FALSE, size = "large")),
        br(),
        tagList(
          reactable::reactableOutput("schedule"),
          htmltools::htmlDependency(
            name = "rstudio-global-calendar",
            version = "0.0.1",
            src = "www",
            script = "extra.js",
            stylesheet = "extra.css"
          )
        ),
        f7Sheet(
          id = "sheet1",
          orientation = "bottom",
          swipeToClose = TRUE,
          swipeToStep = TRUE,
          backdrop = TRUE,
          closeByOutsideClick = FALSE,
          hiddenItems = tagList(
            f7SmartSelect("sch_type", "Talk Type", choices = sort(unique(schedule$type)), multiple = TRUE, openIn = "sheet"),
            f7SmartSelect("sch_topic", "Talk Topic", choices = sort(unique(schedule$topic)), multiple = TRUE, openIn = "sheet"),
            f7SmartSelect("sch_presenter", "Presenter", choices = sort(unique(schedule$name)), multiple = TRUE, openIn = "sheet")
          ),
          f7Select("tz", "Your Timezone", choices = unlist(available_timezones()), selected = "UTC", width = "100%"),
          f7Text("sch_search", "Search"),
          f7Radio("sch_day", "Day", c("First" = "one", "Second" = "two", "All" = "all"), selected = c("all")),
          f7Slider("sch_hours", "Hours in Your Time Zone", value = c(0, 24), min = 0, max = 24, step = 1)
        ),
        f7Popup(
          id = "more_info_popup",
          uiOutput("more_popup")
        )
      ),
      f7Tab(
        tabName = "About",
        icon = f7Icon("info_round"),
        f7Block(
          inset = TRUE,
          strong = TRUE,
          f7BlockTitle(
            title = "community %>% tidyr::gather()"
          ),
          p("January 21, 2021 at 8am PT / 16:00 GMT / 01:00 JST"),
          p(
            "Our goal is to make rstudio::global(2021) our most inclusive and",
            "global event, making the most of the freedom from geographical and",
            "economic constraints that comes with an online event. That means that",
            "the conference will be free, designed around participation from every",
            "time zone, and have speakers from around the world."
          ),
          p(
            a(
              "Register Now",
              href = "https://global.rstudio.com/student/authentication/register",
              class = "btn btn-primary"
            ),
            a(
              tags$a(
                href = "https://global.rstudio.com/student/all_events",
                class = "btn btn-success",
                "Official Schedule"
              )
            )
          ),
          tags$hr(class = "my-4"),
          h2("About this app", class = "text-monospace"),
          p(
            HTML("This app was built with &#x2665;&#xFE0F; and &#x2615; by"),
            tags$a(href = "https://www.garrickadenbuie.com", "Garrick Aden-Buie", .noWS = "after"),
            ", using the packages listed below. Check out",
            tags$a(href = "https://github.com/gadenbuie/rstudio-global-2021-calendar", "the full source code"),
            "on Github."
          ),
          div(
            class = "d-flex flex-wrap align-items-stretch justify-content-between",
            f7ExpandableCard(
              title = "shiny",
              fullBackground = TRUE,
              image = rstudio_hex("shiny")$src,
              subtitle = "https://shiny.rstudio.com",
              "Shiny is an R package that makes it easy to build interactive web apps straight from R."
            ),
            f7ExpandableCard(
              title = "renv",
              fullBackground = TRUE,
              image = rstudio_hex("renv")$src,
              subtitle = "https://rstudio.github.io/renv",
              "The renv package helps you create reproducible environments for your R projects. Use renv to make your R projects more: isolated, portable, and reproducible."
            ),
            f7ExpandableCard(
              title = "shinyMobile",
              fullBackground = TRUE,
              image = "https://rinterface.github.io/shinyMobile/reference/figures/logo.png",
              subtitle = "https://rinterface.github.io/shinyMobile/",
              "Develop outstanding {shiny} apps for iOS, Android, desktop as well as beautiful {shiny} gadgets. {shinyMobile} is built on top of the latest Framework7 template."
            ),
            f7ExpandableCard(
              title = "R6",
              fullBackground = TRUE,
              image = rstudio_hex("R6")$src,
              subtitle = "https://r6.r-lib.org/",
              "Encapsulated object-oriented programming for R."
            ),
            f7ExpandableCard(
              title = "glue",
              fullBackground = TRUE,
              image = rstudio_hex("glue")$src,
              subtitle = "https://glue.tidyverse.org",
              "Glue strings to data in R. Small, fast, dependency free interpreted string literals."
            ),
            f7ExpandableCard(
              title = "lubridate",
              fullBackground = TRUE,
              image = rstudio_hex("lubridate")$src,
              subtitle = "https://lubridate.tidyverse.org",
              "Make working with dates in R just that little bit easier."
            ),
            f7Card(
              title = "calendar",
              footer = "https://github.com/ATFutures/calendar",
              "Create, read, write, and work with iCalander (.ics, .ical or similar) files in R."
            ),
            f7Card(
              title = "reactable",
              footer = "https://glin.github.io/reactable/index.html",
              "Interactive data tables for R, based on the React Table library and made with reactR."
            ),
            f7Card(
              title = "prettyunits",
              footer = "https://github.com/r-lib/prettyunits",
              "Pretty, human readable formatting of quantities."
            ),
          )
        )
      )
    )
  )
)

server <- function(input, output, session) {
  selected_talks <- Stack$new()
  selected_in_current_view <- reactiveVal()

  schedule_view <- reactive({
    if (isTruthy(input$sch_day)) {
      if (input$sch_day == "one") {
        schedule <- schedule[
          schedule$time_gmt < ymd_hms("2021-01-22 04:00:00", tz = "UTC"),
        ]
      } else if (input$sch_day == "two") {
        schedule <- schedule[
          schedule$time_gmt >= ymd_hms("2021-01-22 04:00:00", tz = "UTC"),
        ]
      }
    }
    schedule$time <- with_tz(schedule$time_gmt, input$tz)
    if (isTruthy(input$sch_hours)) {
      schedule <- schedule[
        hour(schedule$time) >= input$sch_hours[1] & hour(schedule$time) <= input$sch_hours[2],
      ]
    }
    if (shiny::isTruthy(input$sch_search)) {
      schedule <- schedule[
        grepl(input$sch_search, tolower(paste(schedule$title_text, schedule$abstract_text))),
      ]
    }
    if (isTruthy(input$sch_type)) {
      schedule <- schedule[schedule$type %in% input$sch_type, ]
    }
    if (isTruthy(input$sch_topic)) {
      schedule <- schedule[schedule$topic %in% input$sch_topic, ]
    }
    if (isTruthy(input$sch_presenter)) {
      schedule <- schedule[schedule$name %in% input$sch_presenter, ]
    }
    schedule$info <- schedule$talk_id
    common_vars <- c(
      "id", "info", "talk_id", "type", "title_text", "name", "time",
      "duration", "track", "topic", "url"
    )
    schedule <- schedule[, common_vars]
    schedule
  })

  selected_by_user_current_view <- reactive(getReactableState("schedule", "selected"))

  observeEvent(selected_by_user_current_view(), {
    current <- selected_talks$stack()
    on.exit(ignore_schedule_change(FALSE))
    if (!is.null(current) && is.null(selected_by_user_current_view()) && ignore_schedule_change()) {
      return()
    }
    in_view <- intersect(current, schedule_view()$id)

    if (is.null(selected_by_user_current_view()) && length(in_view)) {
      selected_talks$remove(in_view)
      return()
    }

    selected <- schedule_view()$id[selected_by_user_current_view()]

    talks_to_add <- setdiff(selected, current)
    talks_to_drop <- setdiff(in_view, selected)

    if (length(talks_to_add)) {
      selected_talks$add(talks_to_add)
    }
    if (length(talks_to_drop)) {
      selected_talks$remove(talks_to_drop)
    }
  }, ignoreNULL = FALSE, ignoreInit = TRUE)

  output$your_talks <- renderUI({
    req(selected_talks$stack())
    tagList(
      f7DownloadButton(
        "download_calendar",
        glue(
          "Download Calendar ({n} talk{s})",
          n = length(selected_talks$stack()),
          s = if (length(selected_talks$stack()) == 1) "" else "s"
        )
      ),
      f7Button("reset", "Reset Selection")
    )
  })

  output$download_calendar <- downloadHandler(
    filename = "rstudio-global-talks.ics",
    content = function(file) {
      talks <- schedule[schedule$id %in% selected_talks$stack(), ]
      talks$start_time <- with_tz(talks$time_gmt, tzone = input$tz)
      talks$end_time <- talks$start_time + seconds(talks$duration)
      talk_events <- lapply(seq_len(nrow(talks)), function(idx) {
        desc <- paste0("Presenter: ", talks$name[[idx]], "\n\n", talks$abstract_text[[idx]])
        desc <- gsub("\n", "\\n", desc, fixed = TRUE)
        desc <- strwrap(desc, 75)
        desc <- paste(desc, collapse = " \n ")
        desc <- gsub(",", "\\,", desc)
        ev <- calendar::ic_event(
          start_time = talks$start_time[[idx]],
          end_time = talks$end_time[[idx]],
          summary = talks$title_text[[idx]],
          more_properties = TRUE,
          event_properties = c(
            DESCRIPTION = desc,
            URL = talks$url[[idx]]
          )
        )
        ev
      })
      calendar::ic_write(do.call(rbind, talk_events), file)
    }
  )

  observeEvent(input$reset, {
    selected_talks$update(NULL)
    reactable::updateReactable(
      "schedule",
      selected = NA
    )
  })

  ignore_schedule_change <- reactiveVal(FALSE)

  output$schedule <- reactable::renderReactable({
    ignore_schedule_change(TRUE)
    reactable(
      schedule_view(),
      selection = "multiple",
      defaultSelected = which(schedule_view()$id %in% isolate(selected_talks$stack())),
      highlight = TRUE,
      borderless = TRUE,
      paginationType = "simple",
      columns = list(
        talk_id = colDef(show = FALSE),
        id = colDef(show = FALSE),
        url = colDef(show = FALSE),
        time = colDef(
          name = "Time",
          html = TRUE,
          cell = function(value) {
            strftime(
              value,
              format = '<span class="white-space:pre;">%a</span> %H:%M',
              tz = input$tz
            )
          }
        ),
        duration = colDef(
          name = "Length",
          minWidth = 80,
          cell = function(value, index) prettyunits::pretty_sec((value %/% 60) * 60)
        ),
        type = colDef(
          name = "Type",
          html = TRUE,
          align = "center",
          cell = function(value) {
            value <- paste(value)
            glue(
              '<span class="badge color-{type}">{value}</span>',
              type = switch(
                value,
                keynote = "blue",
                lightning = "yellow",
                talk = "green",
                "gray"
              ),
              value = paste0(toupper(substr(value, 1, 1)), substr(value, 2, nchar(value)))
            )
          }
        ),
        track = colDef(
          name = "Track",
          html = TRUE,
          minWidth = 80,
          align = "center",
          cell = function(value) {
            if (!is.na(value)) {
              glue(
                '<span class="badge color-{type}">{value}</span>',
                type = switch(
                  paste(value),
                  A = "gray",
                  B = "lightblue",
                  C = "black",
                  "gray"
                )
              )
            }
          }
        ),
        topic = colDef(name = "Topic", minWidth = 100, align = "center"),
        name = colDef(name = "Presenter", minWidth = 200),
        title_text = colDef(
          name = "Title",
          minWidth = 300,
          html = TRUE,
          cell = JS("
            function(cellInfo) {
              var url = cellInfo.row['url']
              return url ?
                '<a class=\"external\" href=\"' + url + '\" target=\"_blank\" title=\"Go to Official Talk Page\">' + cellInfo.value + '<a>' :
                cellInfo.value
            }
          ")
        ),
        info = colDef(
          name = "",
          html = TRUE,
          minWidth = 60,
          sortable = FALSE,
          class = "cell-info-button",
          cell = function(value) {
            if (!isTruthy(value)) return()
            tags$button(
              class = "button button-small btn-talk-more-info",
              `data-value` = value,
              title = "More info...",
              icon("info")
            )
          },
          style = list(
            position = "sticky",
            left = 30,
            background = "#202020",
            zIndex = 1,
            borderRight = "2px solid #eee"
          ),
          headerStyle = list(
            position = "sticky",
            left = 30,
            background = "#202020",
            zIndex = 1,
            borderRight = "2px solid #eee"
          )
        ),
        .selection = colDef(
          width = 30,
          style = list(
            cursor = "pointer",
            position = "sticky",
            left = 0,
            background = "#202020",
            zIndex = 1
          ),
          headerStyle = list(
            cursor = "pointer",
            position = "sticky",
            left = 0,
            background = "#202020",
            zIndex = 1
          )
        )
      )
    )
  })

  # Berk!!! evil is evil ...
  output$more_popup <- renderUI({
    req(input$talk_more_info)

    talk <- schedule[!is.na(schedule$talk_id) & schedule$talk_id == as.numeric(input$talk_more_info), ]
    req(nrow(talk))

    speaker_names <- strsplit(talk$name[[1]], ", ")[[1]]
    speaker_bios <- strsplit(talk$bio_html[[1]], "\n</p>\n<p>")[[1]]
    if (length(speaker_bios) == 2) {
      speaker_bios[1] <- paste0(speaker_bios[1], "</p>")
      speaker_bios[2] <- paste0("<p>", speaker_bios[2])
    }


    html_speaker_bio <- function(idx) {
      spkr_name <- speaker_names[idx]
      spkr_bio <- speaker_bios[idx]
      spkr_img <- tolower(gsub("[ '-]", "", spkr_name))
      spkr_img <- if (file.exists(file.path("www", "speakers", paste0(spkr_img, ".png")))) {
        file.path("speakers", paste0(spkr_img, ".png"))
      } else if (file.exists(file.path("www", "speakers", paste0(spkr_img, ".jpg")))) {
        file.path("speakers", paste0(spkr_img, ".jpg"))
      }
      tagList(
        h2(spkr_name),
        if (!is.null(spkr_img)) {
          div(
            class = "row",
            div(
              class = "col-sm-3 order-1 order-sm-2",
              tags$img(
                src = spkr_img,
                style = "max-width: 100%",
                class = "rounded-lg"
              )
            ),
            div(
              class = "col-sm-9 order-2 order-sm-1",
              HTML(spkr_bio)
            )
          )
        } else HTML(spkr_bio)
      )
    }

    tagList(
      h2("Abstract"),
      HTML(talk$abstract_html[[1]]),
      lapply(seq_along(speaker_names), html_speaker_bio),
      f7Link(
        href = talk$url[[1]],
        "Go To Talk Page"
      )
    )
  })

  observeEvent(input$talk_more_info, {
    Sys.sleep(3)
    updateF7Popup("more_info_popup")
  })

  observeEvent(input$browser_tz, {
    if (input$browser_tz %in% OlsonNames()) {
      updateF7Select("tz", selected = input$browser_tz)
    }
  })


  observeEvent(input$options, {
    updateF7Sheet("sheet1")
  })
}

shinyApp(ui = ui, server = server)
