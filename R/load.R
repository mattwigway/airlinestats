#' Load DB1B data
#'
#' Load and join DB1B data with carrier and city names.
#'
#' Loads DB1B dataset, and joins in origin and destination city as well as ticketing and
#' operating carrier names
#'
#' @param datafile path to file with DB1B data
#' @param cityfile path to file with city data
#' @param carrierfile path to data with carrier names
#'
#' @returns joined DB1B data
#'
#' @export
load_data = function (datafile, cityfile, carrierfile) {
  # first, we need to load the data
  data = readr::read_csv(datafile)

  # The data have seven columns: origin and destination airport, origin and destination cities
  # carrier, and distance. The city and carrier are coded, so we will merge in other
  # (the airports have codes as well, but these are fairly well known - e.g. RDU is
  # Raleigh-Durham and LAX is Los Angeles; we won't match those with the official airport
  # names)

  market_ids = readr::read_csv(cityfile)
  data = dplyr::left_join(data, dplyr::rename(market_ids, OriginCity="Description"), by=c(OriginCityMarketID="Code"))
  data = dplyr::left_join(data, dplyr::rename(market_ids, DestCity="Description"), by=c(DestCityMarketID="Code"))

  carriers = readr::read_csv(carrierfile)
  data = dplyr::left_join(data, dplyr::rename(carriers, OperatingCarrierName="Description"), by=c(OpCarrier="Code"))
  data = dplyr::left_join(data, dplyr::rename(carriers, TicketingCarrierName="Description"), by=c(TkCarrier="Code"))

  return(data)
}
