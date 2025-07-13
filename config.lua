Config = {}

Config.Locations = {
    {
        coords = vec3(-1034.6, -2733.6, 19.1),
        heading = 330.0,
        label = 'Location Aéroport',
    },
    {
        coords = vec3(215.8, -810.2, 29.7),
        heading = 160.0,
        label = 'Location Centre-Ville',
    },
}

Config.ReturnLocations = {
    {
        coords = vec3(237.60, -792.830, 30.50),
        label = "Retour de location",
        heading = 90.0
    },
}

Config.Vehicles = {
    { label = "Blista", model = "blista", price = 100, duration = 5 },
    { label = "Panto", model = "panto", price = 75, duration = 6 },
    { label = "Faggio", model = "faggio", price = 50, duration = 7 },
}

Config.Ped = {
    model = 'csb_car3guy1',
    coords = vec4(-1034.6, -2733.6, 20.1, 330.0),
    scenario = 'WORLD_HUMAN_CLIPBOARD'
}