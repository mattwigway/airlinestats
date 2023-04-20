devtools::load_all()

data = load_data("../odum-modular-design/data/air_sample.csv", "../odum-modular-design/data/L_CITY_MARKET_ID.csv", "../odum-modular-design/data/L_CARRIERS.csv")
busiest_routes(data, Origin, Dest)
