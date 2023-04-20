
KILOMETERS_PER_MILE = 1.609

#' Find busiest airport or city pairs
#'
#' This finds the busiest routes.
#'
#' It treats both directions of the route the same, so JFK-SFO and SFO-JFK are summed together.
#'
#' @param dataframe data to use
#' @param origincol origin
#' @param destcol destination
#'
#' @returns sorted data frame with most popular routes at the top. origin and dest become
#'   airport1 and airport2 columns in alphabetical order.
#' @export
busiest_routes = function (dataframe, origincol, destcol) {
  stopifnot(all(dataframe$Passengers >= 1))
  stopifnot(all(!is.na(dataframe$Passengers)))

  # Now, we can see what the most popular air route is, by summing up the number of
  # passengers carried.
  pairs = group_by(dataframe, {{ origincol }}, {{ destcol }}) %>%
    summarize(Passengers=sum(Passengers), distance_km=first(Distance) * KILOMETERS_PER_MILE)
  arrange(pairs, -Passengers)

  # we see that LAX-JFK (Los Angeles to New York Kennedy) is represented separately
  # from JFK-LAX. We'd like to combine these two. Create airport1 and airport2 fields
  # with the first and second airport in alphabetical order.
  pairs = mutate(
    pairs,
    airport1 = if_else({{ origincol }} < {{ destcol }}, {{ origincol }}, {{ destcol }}),
    airport2 = if_else({{ origincol }} < {{ destcol }}, {{ destcol }}, {{ origincol }})
  )

  pairs = group_by(pairs, airport1, airport2) %>%
    summarize(Passengers=sum(Passengers), distance_km=first(distance_km)) %>%
    ungroup()

  return(arrange(pairs, -Passengers))
}

#' Compute airline market shares
#'
#' Use passenger data to compute the percentage of passengers traveling on each airline
#' at each airport.
#'
#' Use by specifying a dataset, and columns for the airline and origin.
#'
#' @param dataframe data to use
#' @param carriercol column containing carrier name/ID
#' @param origincol column containing origin airport ID
#'
#' @returns Market shares as a data frame by airport and airline.
#'
#' @export
market_shares = function (dataframe, carriercol, origincol) {
  mkt_shares = group_by(dataframe, {{ carriercol }}, {{ origincol }}) %>%
    summarize(Passengers=sum(Passengers)) %>%
    group_by({{ origincol }}) %>%
    mutate(market_share=Passengers/sum(Passengers) * 100, total_passengers=sum(Passengers)) %>%
    ungroup()

  return(mkt_shares)
}
