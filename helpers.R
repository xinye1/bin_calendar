getUA <- function(source_url = "https://raw.githubusercontent.com/selwin/python-user-agents/master/user_agents/devices.json") {
  user_agents <- fromJSON(source_url)
  is_bot <- sapply(
    user_agents, function(x) {
      x$is_bot}) %>% unname()
  user_agents_non_bot <- user_agents[!is_bot]
  sapply(
    user_agents_non_bot, function(x) {
      x$ua_string})
}

getRaw <- function(request_url, uprn, ua_string) {
  request_url %>%
    param_set('u', uprn) %>%
    GET(user_agent(ua_string)) %>%
    content(as = 'parsed') 
}

binIcon <- function(x) {
  recode(
    x,
    'RESIDUAL' = 'green-grey',
    'FOOD' = 'black-caddy',
    'RECYCLABLES' = 'blue',
    .default = 'brown'
  )
}


cleanBins <- function(raw_bin, asset_url) {
  c('last', 'next') %>%
    map(function(x) {
      all_bins <- raw_bin[[x]]
      seq_along(all_bins) %>%
        map(function(y) {
          d <- (names(all_bins))[y] %>% as.Date()
          bins <- all_bins[[y]] %>% names
          icons <- binIcon(bins)
          data.frame(
            date_d = d, bin = bins, icon = icons,
            url = paste0(asset_url, icons, '-128.png'),
            stringsAsFactors = F)
        }) %>%
        bind_rows() %>%
        mutate(row_type = x)
    }) %>% bind_rows()
}

makeBinCal <- function(bins) {
  bins %>%
    mutate(
      StartTime = date_d - days(1) + hours(18),
      EndTime = date_d - days(1) + hours(24)) %>%
    group_by(StartTime, EndTime) %>%
    summarise(
      Title = paste0(
        'Bins: ',
        paste(str_to_title(bin), collapse = ', ')),
      icon_url = paste(url, collapse = '|')
    ) %>% ungroup() %>%
    separate(
      icon_url,
      into = paste0('Bin ', 1:3),
      sep = '\\|', fill = 'right')
}

getCal <- function(request_url, uprn, ua_string, asset_url) {
  getRaw(
    request_url, uprn,
    sample(ua_strings, 1)
    ) %>%
    cleanBins(asset_url) %>%
    makeBinCal()
}