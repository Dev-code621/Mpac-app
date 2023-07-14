import 'package:flutter/material.dart';
import 'package:mpac_app/core/data/models/event_model_test.dart';
import 'package:mpac_app/core/data/models/post_model.dart';
import 'package:mpac_app/core/data/models/sport_model_test.dart';

class Nationality {
  static List<Map<String, dynamic>> get allFlags => [
        // A
        {"name": "Afghan", "countryCode1": "AF", "countryCode2": "AFG"},
        {"name": "Albanian", "countryCode1": "AL", "countryCode2": "ALB"},
        {"name": "Algerian", "countryCode1": "DZ", "countryCode2": "DZA"},
        {"name": "American", "countryCode1": "US", "countryCode2": "USA"},
        {"name": "Andorran", "countryCode1": "AD", "countryCode2": "AND"},
        {"name": "Angolan", "countryCode1": "AO", "countryCode2": "AGO"},
        {"name": "Anguillan", "countryCode1": "AI", "countryCode2": "AIA"},
        {
          "name": "Citizen of Antigua and Barbuda",
          "countryCode1": "AG",
          "countryCode2": "ATG"
        },
        {"name": "Argentine", "countryCode1": "AR", "countryCode2": "ARG"},
        {"name": "Armenian", "countryCode1": "AM", "countryCode2": "ARM"},
        {"name": "Australian", "countryCode1": "AU", "countryCode2": "AUS"},
        {"name": "Austrian", "countryCode1": "AT", "countryCode2": "AUT"},
        {"name": "Azerbaijani", "countryCode1": "AZ", "countryCode2": "AZE"},

        // B
        {"name": "Bahamian", "countryCode1": "BS", "countryCode2": "BHS"},
        {"name": "Bahraini", "countryCode1": "BH", "countryCode2": "BHR"},
        {"name": "Bangladeshi", "countryCode1": "BD", "countryCode2": "BGD"},
        {"name": "Barbadian", "countryCode1": "BB", "countryCode2": "BRB"},
        {"name": "Belarusian", "countryCode1": "BY", "countryCode2": "BLR"},
        {"name": "Belgian", "countryCode1": "BE", "countryCode2": "BEL"},
        {"name": "Belizean", "countryCode1": "BZ", "countryCode2": "BLZ"},
        {"name": "Beninese", "countryCode1": "BJ", "countryCode2": "BEN"},
        {"name": "Bermudian", "countryCode1": "BM", "countryCode2": "BMU"},
        {"name": "Bhutanese", "countryCode1": "BT", "countryCode2": "BTN"},
        {"name": "Bolivian", "countryCode1": "BO", "countryCode2": "BOL"},
        {
          "name": "Bosnia and Herzegovina",
          "countryCode1": "BA",
          "countryCode2": "BIH"
        },
        {"name": "Botswanan", "countryCode1": "BW", "countryCode2": "BWA"},
        {"name": "Brazilian", "countryCode1": "BR", "countryCode2": "BRA"},
        {"name": "British", "countryCode1": "UK", "countryCode2": "UK"},
        {
          "name": "British Virgin Islander",
          "countryCode1": "VG",
          "countryCode2": "VGB"
        },
        {"name": "Bruneian", "countryCode1": "BN", "countryCode2": "BRN"},
        {"name": "Bulgarian", "countryCode1": "BG", "countryCode2": "BGR"},
        {"name": "Burkinan", "countryCode1": "BF", "countryCode2": "BFA"},
        // {"name": "Burmese", "countryCode1": "" ,"countryCode2": ""},
        {"name": "Burundian", "countryCode1": "BI", "countryCode2": "BDI"},

        // C

        {"name": "Cambodian", "countryCode1": "KH", "countryCode2": "KHM"},
        {"name": "Cameroonian", "countryCode1": "CM", "countryCode2": "CMR"},
        {"name": "Canadian", "countryCode1": "CA", "countryCode2": "CAN"},
        {"name": "Cape Verdean", "countryCode1": "CV", "countryCode2": "CPV"},
        {
          "name": "Cayman Islander",
          "countryCode1": "KY",
          "countryCode2": "CYM"
        },
        {
          "name": "Central African",
          "countryCode1": "CF",
          "countryCode2": "CAF"
        },
        {"name": "Chadian", "countryCode1": "TD", "countryCode2": "TCD"},
        {"name": "Chilean", "countryCode1": "CL", "countryCode2": "CLH"},
        {"name": "Chinese", "countryCode1": "CN", "countryCode2": "CHN"},
        {"name": "Colombian", "countryCode1": "CO", "countryCode2": "COL"},
        {"name": "Comoran", "countryCode1": "KM", "countryCode2": "COM"},
        {
          "name": "Congolese (Congo)",
          "countryCode1": "CG",
          "countryCode2": "COG"
        },
        {
          "name": "Congolese (DRC)",
          "countryCode1": "CD",
          "countryCode2": "COD"
        },
        {"name": "Costa Rican", "countryCode1": "CR", "countryCode2": "CRI"},
        {"name": "Croatian", "countryCode1": "HR", "countryCode2": "HRV"},
        {"name": "Cuban", "countryCode1": "CU", "countryCode2": "CUB"},
        {"name": "Cypriot", "countryCode1": "CY", "countryCode2": "CYP"},
        {"name": "Czech", "countryCode1": "CZ", "countryCode2": "CZE"},

        // D
        // {"name": "Danish", "countryCode1": "" ,"countryCode2": ""},
        {"name": "Djiboutian", "countryCode1": "DJ", "countryCode2": "DJI"},
        {"name": "Dominican", "countryCode1": "DM", "countryCode2": "DMA"},
        {
          "name": "Dominican Republic",
          "countryCode1": "DO",
          "countryCode2": "DOM"
        },
        {"name": "Dutch", "countryCode1": "DE", "countryCode2": "DEU"},

        // E
        {"name": "East Timorese", "countryCode1": "TL", "countryCode2": "TLS"},
        {"name": "Ecuadorean", "countryCode1": "EC", "countryCode2": "ECU"},
        {"name": "Egyptian", "countryCode1": "EG", "countryCode2": "EGY"},
        {"name": "Emirati", "countryCode1": "AE", "countryCode2": "ARE"},
        {
          "name": "Equatorial Guinean",
          "countryCode1": "GQ",
          "countryCode2": "GNQ"
        },
        {"name": "Eritrean", "countryCode1": "ER", "countryCode2": "ERI"},
        {"name": "Estonian", "countryCode1": "EE", "countryCode2": "EST"},
        {"name": "Ethiopian", "countryCode1": "ET", "countryCode2": "ETH"},

        // F
        {"name": "Faroese", "countryCode1": "FO", "countryCode2": "FRO"},
        {"name": "Fijian", "countryCode1": "FJ", "countryCode2": "FJI"},
        {"name": "Filipino", "countryCode1": "PH", "countryCode2": "PHL"},
        // {"name": "Finnish", "countryCode1": "" ,"countryCode2": ""},
        {"name": "French", "countryCode1": "FR", "countryCode2": "FRA"},

        // G
        {"name": "Gabonese", "countryCode1": "GA", "countryCode2": "GAB"},
        {"name": "Gambian", "countryCode1": "GM", "countryCode2": "GMB"},
        {"name": "Georgian", "countryCode1": "GE", "countryCode2": "GEO"},
        {"name": "German", "countryCode1": "DE", "countryCode2": "DEU"},
        {"name": "Ghanaian", "countryCode1": "GH", "countryCode2": "GHA"},
        {"name": "Gibraltarian", "countryCode1": "GI", "countryCode2": "GIB"},
        {"name": "Greek", "countryCode1": "GR", "countryCode2": "GRC"},
        {"name": "Greenlandic", "countryCode1": "GL", "countryCode2": "GRL"},
        {"name": "Grenadian", "countryCode1": "GD", "countryCode2": "GRD"},
        {"name": "Guamanian", "countryCode1": "GU", "countryCode2": "GUM"},
        {"name": "Guatemalan", "countryCode1": "GT", "countryCode2": "GTM"},
        {"name": "Guinea-Bissau", "countryCode1": "GW", "countryCode2": "GNB"},
        {"name": "Guinean", "countryCode1": "GN", "countryCode2": "GIN"},
        {"name": "Guyanese", "countryCode1": "GY", "countryCode2": "GUY"},

        // H
        {"name": "Haitian", "countryCode1": "HT", "countryCode2": "HTI"},
        {"name": "Honduran", "countryCode1": "HN", "countryCode2": "HND"},
        {"name": "Hong Konger", "countryCode1": "HK", "countryCode2": "HKG"},
        {"name": "Hungarian", "countryCode1": "HU", "countryCode2": "HUN"},

        // I
        {"name": "Icelandic", "countryCode1": "IS", "countryCode2": "ISL"},
        {"name": "Indian", "countryCode1": "IN", "countryCode2": "IND"},
        {"name": "Indonesian", "countryCode1": "ID", "countryCode2": "IDN"},
        {"name": "Iranian", "countryCode1": "IR", "countryCode2": "IRN"},
        {"name": "Iraqi", "countryCode1": "IQ", "countryCode2": "IRQ"},
        {"name": "Irish", "countryCode1": "IE", "countryCode2": "IRL"},
        {"name": "Italian", "countryCode1": "IT", "countryCode2": "ITA"},
        {"name": "Ivorian", "countryCode1": "CI", "countryCode2": "CIV"},

        // J
        {"name": "Jamaican", "countryCode1": "JM", "countryCode2": "JAM"},
        {"name": "Japanese", "countryCode1": "JP", "countryCode2": "JPN"},
        {"name": "Jordanian", "countryCode1": "JO", "countryCode2": "JOR"},

        // K
        {"name": "Kazakh", "countryCode1": "KZ", "countryCode2": "KAZ"},
        {"name": "Kenyan", "countryCode1": "KE", "countryCode2": "KEN"},
        // {"name": "Kittitian", "countryCode1": "" ,"countryCode2": ""},
        {
          "name": "Citizen of Kiribati",
          "countryCode1": "KI",
          "countryCode2": "KIR"
        },
        {"name": "Kosovan", "countryCode1": "XK", "countryCode2": "XKX"},
        {"name": "Kuwaiti", "countryCode1": "KW", "countryCode2": "KWT"},
        {"name": "Kyrgyz", "countryCode1": "KG", "countryCode2": "KGZ"},

        // L
        {"name": "Lao", "countryCode1": "LA", "countryCode2": "LAO"},
        {"name": "Latvian", "countryCode1": "LV", "countryCode2": "LVA"},
        {"name": "Lebanese", "countryCode1": "LB", "countryCode2": "LBN"},
        {"name": "Liberian", "countryCode1": "LR", "countryCode2": "LBR"},
        {"name": "Libyan", "countryCode1": "LY", "countryCode2": "LBY"},
        {
          "name": "Liechtenstein citizen",
          "countryCode1": "LI",
          "countryCode2": "LIE"
        },
        {"name": "Lithuanian", "countryCode1": "LT", "countryCode2": "LTU"},
        {"name": "Luxembourger", "countryCode1": "LU", "countryCode2": "LUX"},

        // M
        {"name": "Macanese", "countryCode1": "MO", "countryCode2": "MAC"},
        {"name": "Macedonian", "countryCode1": "MK", "countryCode2": "MKD"},
        {"name": "Malawian", "countryCode1": "MW", "countryCode2": "MWI"},
        {"name": "Malaysian", "countryCode1": "MY", "countryCode2": "MYS"},
        {"name": "Maldivian", "countryCode1": "MV", "countryCode2": "MDV"},
        {"name": "Malian", "countryCode1": "ML", "countryCode2": "MLI"},
        {"name": "Maltese", "countryCode1": "MT", "countryCode2": "MLT"},
        {"name": "Marshallese", "countryCode1": "MH", "countryCode2": "MHL"},
        // {"name": "Martiniquais", "countryCode1": "" ,"countryCode2": ""},
        {"name": "Mauritanian", "countryCode1": "MR", "countryCode2": "MRT"},
        {"name": "Mauritian", "countryCode1": "MU", "countryCode2": "MUS"},
        {"name": "Mexican", "countryCode1": "MX", "countryCode2": "MEX"},
        {"name": "Moldovan", "countryCode1": "MD", "countryCode2": "MDA"},
        // {"name": "Monegasque", "countryCode1": "" ,"countryCode2": ""},
        {"name": "Mongolian", "countryCode1": "MN", "countryCode2": "MNG"},
        {"name": "Montenegrin", "countryCode1": "ME", "countryCode2": "MNE"},
        {"name": "Montserratian", "countryCode1": "MS", "countryCode2": "MSR"},
        {"name": "Moroccan", "countryCode1": "MA", "countryCode2": "MAR"},
        {"name": "Mozambican", "countryCode1": "MZ", "countryCode2": "MOZ"},

        // N
        {"name": "Namibian", "countryCode1": "NA", "countryCode2": "NAM"},
        {"name": "Nauruan", "countryCode1": "NR", "countryCode2": "NRU"},
        {"name": "Nepalese", "countryCode1": "NP", "countryCode2": "NPL"},
        {"name": "New Zealander", "countryCode1": "NZ", "countryCode2": "NPL"},
        {"name": "Nicaraguan", "countryCode1": "NI", "countryCode2": "NIC"},
        {"name": "Nigerian", "countryCode1": "NG", "countryCode2": "NGA"},
        {"name": "Nigerien", "countryCode1": "NE", "countryCode2": "NER"},
        {"name": "Niuean", "countryCode1": "NU", "countryCode2": "NIU"},
        {"name": "North Korean", "countryCode1": "KP", "countryCode2": "PRK"},
        // {"name": "Northern Irish", "countryCode1": "" ,"countryCode2": ""},
        {"name": "Norwegian", "countryCode1": "NO", "countryCode2": "NOR"},

        // O
        {"name": "Omani", "countryCode1": "OM", "countryCode2": "OMN"},

        // P
        {"name": "Pakistani", "countryCode1": "PK", "countryCode2": "PAK"},
        {"name": "Palauan", "countryCode1": "PW", "countryCode2": "PLW"},
        {"name": "Palestinian", "countryCode1": "PS", "countryCode2": "PSE"},
        {"name": "Panamanian", "countryCode1": "PA", "countryCode2": "PAN"},
        {
          "name": "Papua New Guinean",
          "countryCode1": "PG",
          "countryCode2": "PNG"
        },
        {"name": "Paraguayan", "countryCode1": "PY", "countryCode2": "PRY"},
        {"name": "Peruvian", "countryCode1": "PE", "countryCode2": "PER"},
        {
          "name": "Pitcairn Islander",
          "countryCode1": "PN",
          "countryCode2": "PCN"
        },
        {"name": "Polish", "countryCode1": "PL", "countryCode2": "POL"},
        {"name": "Portuguese", "countryCode1": "PT", "countryCode2": "PRT"},
        // {"name": "Prydeinig", "countryCode1": "" ,"countryCode2": ""},
        {"name": "Puerto Rican", "countryCode1": "PR", "countryCode2": "PRI"},

        // Q
        {"name": "Qatari", "countryCode1": "QA", "countryCode2": "QAT"},

        // R
        {"name": "Romanian", "countryCode1": "RO", "countryCode2": "ROU"},
        {"name": "Russian", "countryCode1": "RU", "countryCode2": "RUS"},
        {"name": "Rwandan", "countryCode1": "RW", "countryCode2": "RWA"},

        // S
        {"name": "Salvadorean", "countryCode1": "SV", "countryCode2": "SLV"},
        // {"name": "Sammarinese", "countryCode1": "" ,"countryCode2": ""},
        {"name": "Samoan", "countryCode1": "WS", "countryCode2": "WSM"},
        {"name": "Sao Tomean", "countryCode1": "ST", "countryCode2": "STP"},
        {"name": "Saudi Arabian", "countryCode1": "SA", "countryCode2": "SAU"},
        // {"name": "Scottish", "countryCode1": "" ,"countryCode2": ""},
        {"name": "Senegalese", "countryCode1": "SN", "countryCode2": "SEN"},
        {"name": "Serbian", "countryCode1": "RS", "countryCode2": "SRB"},
        {
          "name": "Citizen of Seychelles",
          "countryCode1": "SC",
          "countryCode2": "SYC"
        },
        {"name": "Sierra Leonean", "countryCode1": "SL", "countryCode2": "SLE"},
        {"name": "Singaporean", "countryCode1": "SG", "countryCode2": "SGP"},
        {"name": "Slovak", "countryCode1": "SK", "countryCode2": "SVK"},
        {"name": "Slovenian", "countryCode1": "SI", "countryCode2": "SVN"},
        {
          "name": "Solomon Islander",
          "countryCode1": "SB",
          "countryCode2": "SLB"
        },
        {"name": "Somali", "countryCode1": "SO", "countryCode2": "SOM"},
        {"name": "South African", "countryCode1": "ZA", "countryCode2": "ZAF"},
        {"name": "South Korean", "countryCode1": "KR", "countryCode2": "KOR"},
        {"name": "South Sudanese", "countryCode1": "SS", "countryCode2": "SSD"},
        {"name": "Spanish", "countryCode1": "ES", "countryCode2": "ESP"},
        {"name": "Sri Lankan", "countryCode1": "LK", "countryCode2": "LKA"},
        {"name": "St Helenian", "countryCode1": "SH", "countryCode2": "SHN"},
        {"name": "St Lucian", "countryCode1": "LC", "countryCode2": "LCA"},
        {"name": "Sudanese", "countryCode1": "SD", "countryCode2": "SDN"},
        {"name": "Surinamese", "countryCode1": "SR", "countryCode2": "SUR"},
        {"name": "Swazi", "countryCode1": "SZ", "countryCode2": "SWZ"},
        {"name": "Swedish", "countryCode1": "SE", "countryCode2": "SWE"},
        {"name": "Swiss", "countryCode1": "CH", "countryCode2": "CHE"},
        {"name": "Syrian", "countryCode1": "SY", "countryCode2": "SYR"},

        // T
        {"name": "Taiwanese", "countryCode1": "TW", "countryCode2": "TWN"},
        {"name": "Tajik", "countryCode1": "TJ", "countryCode2": "TJK"},
        {"name": "Tanzanian", "countryCode1": "TZ", "countryCode2": "TZA"},
        {"name": "Thai", "countryCode1": "TH", "countryCode2": "THA"},
        {"name": "Togolese", "countryCode1": "TG", "countryCode2": "TGO"},
        {"name": "Tongan", "countryCode1": "TO", "countryCode2": "TON"},
        {"name": "Trinidadian", "countryCode1": "TT", "countryCode2": "TTO"},
        // {"name": "Tristanian", "countryCode1": "" ,"countryCode2": ""},
        {"name": "Tunisian", "countryCode1": "TN", "countryCode2": "TUN"},
        {"name": "Turkish", "countryCode1": "TR", "countryCode2": "TUR"},
        {"name": "Turkmen", "countryCode1": "TM", "countryCode2": "TKM"},
        {
          "name": "Turks and Caicos Islander",
          "countryCode1": "TC",
          "countryCode2": "TCA"
        },
        {"name": "Tuvaluan", "countryCode1": "TV", "countryCode2": "TUV"},

        // U
        {"name": "Ugandan", "countryCode1": "UG", "countryCode2": "UGA"},
        {"name": "Ukrainian", "countryCode1": "UA", "countryCode2": "UKR"},
        {"name": "Uruguayan", "countryCode1": "UY", "countryCode2": "URY"},
        {"name": "Uzbek", "countryCode1": "UZ", "countryCode2": "UZB"},

        // V
        {
          "name": "Vatican citizen",
          "countryCode1": "VA",
          "countryCode2": "VAT"
        },
        {
          "name": "Citizen of Vanuatu",
          "countryCode1": "VU",
          "countryCode2": "VUT"
        },
        {"name": "Venezuelan", "countryCode1": "VE", "countryCode2": "VEN"},
        {"name": "Vietnamese", "countryCode1": "VN", "countryCode2": "VNM"},
        {"name": "Vincentian", "countryCode1": "VC", "countryCode2": "VCT"},

        // W
        {"name": "Wallisian", "countryCode1": "WF", "countryCode2": "WLF"},
        // {"name": "Welsh", "countryCode1": "" ,"countryCode2": ""},

        // Y
        {"name": "Yemeni", "countryCode1": "YE", "countryCode2": "YEM"},

        // Z
        {"name": "Zambian", "countryCode1": "ZM", "countryCode2": "ZMB"},
        {"name": "Zimbabwean", "countryCode1": "ZW", "countryCode2": "ZWE"},
      ];

  static List<String> get all => [
        // A
        "Afghan",
        "Albanian",
        "Algerian",
        "American",
        "Andorran",
        "Angolan",
        "Anguillan",
        "Citizen of Antigua and Barbuda",
        "Argentine",
        "Armenian",
        "Australian",
        "Austrian",
        "Azerbaijani",
        // B
        "Bahamian", "Bahraini", "Bangladeshi", "Barbadian",
        "Belarusian", "Belgian", "Belizean", "Beninese",
        "Bermudian", "Bhutanese", "Bolivian", "Bosnia and Herzegovina",
        "Botswanan", "Brazilian", "British", "British Virgin Islander",
        "Bruneian", "Bulgarian", "Burkinan", "Burmese",
        "Burundian",

        // C

        "Cambodian",
        "Cameroonian",
        "Canadian",
        "Cape",
        "Verdean",
        "Cayman Islander", "Central African", "Chadian", "Chilean",
        "Chinese", "Colombian", "Comoran", "Congolese (Congo)",
        "Congolese (DRC)", "Cook Islander", "Costa Rican", "Croatian",
        "Cuban", "Cymraes" "Cymro" "Cypriot",
        "Czech"

            // D

            "Danish",
        "Djiboutian",
        "Dominican",
        "Dominican Republic"
            "Dutch"

            // E

            "East Timorese",
        "Ecuadorean",
        "Egyptian",
        "Emirati",
        "English", "Equatorial Guinean", "Eritrean", "Estonian",
        "Ethiopian",

        // F

        "Faroese", "Fijian", "Filipino", "Finnish",
        "French",

        // G
        "Gabonese", "Gambian", "Georgian", "German",
        "Ghanaian", "Gibraltarian", "Greek", "Greenlandic",
        "Grenadian", 'Guamanian', "Guatemalan", "Guinea-Bissau",
        "Guinean", "Guyanese",

        // H
        "Haitian", "Honduran", "Hong Konger", "Hungarian",

        // I

        "Icelandic", "Indian", "Indonesian", "Iranian",
        "Iraqi", "Irish", "Italian",
        "Ivorian",

        // J

        "Jamaican", "Japanese", "Jordanian",

        // K

        "Kazakh", "Kenyan", "Kittitian", "Citizen of Kiribati",
        "Kosovan", "Kuwaiti", "Kyrgyz",

        // L

        "Lao", "Latvian", "Lebanese", "Liberian",
        "Libyan", "Liechtenstein citizen", "Lithuanian", "Luxembourger",

        // M

        "Macanese", "Macedonian", "Malagasy", "Malawian",
        "Malaysian", "Maldivian", "Malian", "Maltese",
        "Marshallese", "Martiniquais", "Mauritanian", "Mauritian",
        "Mexican", "Micronesian", "Moldovan", "Monegasque",
        "Mongolian", "Montenegrin", "Montserratian", "Moroccan",
        "Mosotho", "Mozambican",

        // N
        "Namibian", "Nauruan", "Nepalese", "New Zealander",
        "Nicaraguan", "Nigerian", "Nigerien", "Niuean",
        "North Korean", "Northern Irish", "Norwegian",

        // O

        "Omani",

        // P

        "Pakistani", "Palauan", "Palestinian", "Panamanian",
        "Papua New Guinean", "Paraguayan", "Peruvian", "Pitcairn Islander",
        "Polish", "Portuguese", "Prydeinig", "Puerto Rican",

        // Q

        "Qatari",

        // R

        "Romanian", "Russian", "Rwandan",

        // S

        "Salvadorean", "Sammarinese", "Samoan", "Sao Tomean",
        "Saudi Arabian", "Scottish", "Senegalese", "Serbian",
        "Citizen of Seychelles", "Sierra Leonean", "Singaporean" "Slovak",
        "Slovenian", "Solomon Islander", "Somali", "South African",
        "South Korean", "South Sudanese", "Spanish", "Sri Lankan",
        "St Helenian", "St Lucian", "Stateless", "Sudanese",
        "Surinamese", "Swazi", "Swedish", "Swiss",
        "Syrian",

        // T

        "Taiwanese", "Tajik", "Tanzanian", "Thai",
        "Togolese", "Tongan", "Trinidadian", "Tristanian",
        "Tunisian", "Turkish", "Turkmen", "Turks and Caicos Islander",
        "Tuvaluan",

        // U

        "Ugandan", "Ukrainian", "Uruguayan", "Uzbek",
        "United Arab Emirates",

        // V

        "Vatican citizen", "Citizen of Vanuatu", "Venezuelan", "Vietnamese",
        "Vincentian",

        // W

        "Wallisian", "Welsh",

        // Y

        "Yemeni",

        // Z

        "Zambian", "Zimbabwean"
      ];
}

class Event {
  static List<EventModelTest> swimming = [
    EventModelTest(
      title: 'Free Style',
      points: ['50 M', '100 M', '200 M', '400 M', '4x100 M'],
      color: const Color(0xffFFA24A),
      trailingMessage: 'Personal Best',
    ),
    EventModelTest(
      title: 'Back Stroke',
      points: ['50 M', '100 M', '200 M'],
      color: const Color(0xff64D098),
      trailingMessage: 'Personal Best',
    ),
    EventModelTest(
      title: 'Breaststroke',
      points: ['50 M', '100 M', '200 M'],
      color: const Color(0xff64D098),
      trailingMessage: 'Personal Best',
    ),
    EventModelTest(
      title: 'Butterfly',
      points: ['50 M', '100 M', '200 M'],
      color: const Color(0xff64D098),
      trailingMessage: 'Personal Best',
    ),
    EventModelTest(
      title: 'Individual Medley',
      points: ['50 M', '100 M', '200 M', '400 M', '4x100 M'],
      color: const Color(0xffFFA24A),
      trailingMessage: 'Personal Best',
    ),
  ];

  static List<EventModelTest> athletics = [
    EventModelTest(
      isExpanded: true,
      title: 'TRACK EVENTS',
      points: [],
      color: const Color(0xffFFECDB),
      icon: Padding(
        padding: const EdgeInsets.only(left: 6.0, right: 10.0),
        child: Image.asset(
          'assets/images/general/athletics_outdoor.png',
          width: 15,
          height: 15,
        ),
      ),
      subEvents: [
        SubEventModel(
          title: 'Sprints',
          points: ['100 M', '200 M', '400 M'],
          color: const Color(0xffF4F4F4),
        ),
        SubEventModel(
          title: 'Middle Distance',
          points: ["800m", "1,500m"],
          color: const Color(0xffF4F4F4),
        ),
        SubEventModel(
          title: 'Long Distance',
          points: ["3000m", "5000m", "10,000m", "Steepleachese"],
          color: const Color(0xffF4F4F4),
        ),
        SubEventModel(
          title: 'Hurdles',
          points: ["100/100m", "400m"],
          color: const Color(0xffF4F4F4),
        ),
        SubEventModel(
          title: 'Relays',
          points: ["4x100m", "4x400m"],
          color: const Color(0xffF4F4F4),
        ),
      ],
    )
  ];

  static List<EventModelTest> roadRacing = [
    EventModelTest(
      isExpanded: true,
      title: 'Road Racing',
      points: [],
      color: const Color(0xffFFECDB),
      icon: Padding(
        padding: const EdgeInsets.only(left: 6.0, right: 10.0),
        child: Image.asset(
          'assets/images/general/road_racing.png',
          width: 15,
          height: 15,
        ),
      ),
      subEvents: [
        SubEventModel(
          title: 'Road Racing',
          points: [
            "3 K",
            "5 K",
            "8 K",
            "10 K",
            "Half Marathon",
            "Full Marathon",
          ],
          color: const Color(0xffF4F4F4),
        ),
      ],
    )
  ];
}

class Sport {
  static List<SportModelTest> all = [
    SportModelTest(
      id: 1,
      title: 'Basketball',
      imagePath: 'assets/images/sports/basketball.png',
      subImagePath: 'assets/images/sub_sports/basketball.png',
      backgroundPath: 'assets/images/sports_new/basketball.png',
      color: const Color(0xffFEA41E),
      positions: [
        "Point guard",
        "Shooting guard",
        "Small forward",
        "Power forward",
        "Center"
      ],
    ),
    SportModelTest(
      id: 2,
      title: 'Football',
      imagePath: 'assets/images/sports/football.png',
      subImagePath: 'assets/images/sub_sports/football.png',
      backgroundPath: 'assets/images/sports_new/football.png',
      color: const Color(0x0ff86aff),
      positions: [
        "Goal Keeper",
        "Center Midfield",
        "Left Back",
        "Attacking Midfield",
        "Center Back",
        "Right Wing / Forward",
        "Defensive Midfield",
        "Striker",
        "Left Wing / Forward",
        "Right Back"
      ],
    ),
    SportModelTest(
      id: 3,
      title: 'Athletics',
      imagePath: 'assets/images/sports/athletics.png',
      subImagePath: 'assets/images/sub_sports/athletics.png',
      backgroundPath: 'assets/images/sports_new/athletics.png',
      color: const Color(0xff4CCA6F),
      positions: [],
    ),
    SportModelTest(
      id: 4,
      title: 'Boxing',
      imagePath: 'assets/images/sports/boking.png',
      subImagePath: 'assets/images/sub_sports/boxing.png',
      backgroundPath: 'assets/images/sports_new/boxing.png',
      color: const Color(0xff00FFE0),
      positions: [
        "Heavyweight",
        "Junior lightweight",
        "Cruiserweight",
        "Featherweight",
        "Light heavyweight",
        "Middleweight",
        "Bantamweight",
        "Junior flyweight",
        "Junior bantamweight",
        "Flyweight",
        "Lightweight",
        "Junior middleweight",
        "Junior welterweight",
        "Welterweight",
        "Strawweight",
        "Super middleweight",
        "Junior featherweight"
      ],
    ),
    SportModelTest(
      id: 5,
      title: 'Rugby',
      imagePath: 'assets/images/sports/rugby.png',
      subImagePath: 'assets/images/sub_sports/rugby.png',
      backgroundPath: 'assets/images/sports_new/rugby.png',
      color: const Color(0xffB8B5FF),
      positions: [
        "Loose head prop",
        "Scrum half",
        "Hooker",
        "Fly half",
        "Tight head",
        "Left wing",
        "Second row",
        "Full back",
        "Outside center",
        "Open side flanker",
        "Inside center",
        "Blind side flanker",
        "Right wing",
        "Number 8"
      ],
    ),
    SportModelTest(
      id: 6,
      title: 'Netball',
      imagePath: 'assets/images/sports/netball.png',
      subImagePath: 'assets/images/sub_sports/netball.png',
      backgroundPath: 'assets/images/sports_new/netball.png',
      color: const Color(0xffFFEEEE),
      positions: [
        "Goal Keeper",
        "Goal Defense",
        "Wing Defense",
        "Wing Attack",
        "Centre",
        "Goal Attack",
        "Goal Shooter"
      ],
    ),
    SportModelTest(
      id: 7,
      title: 'Swimming',
      imagePath: 'assets/images/sports/swimming.png',
      subImagePath: 'assets/images/sub_sports/swimming.png',
      backgroundPath: 'assets/images/sports_new/swimming.png',
      color: const Color(0xff6E8DFB),
      positions: [],
    ),
    SportModelTest(
      id: 8,
      title: 'Cricket',
      imagePath: 'assets/images/sports/cricket.png',
      subImagePath: 'assets/images/sub_sports/cricket.png',
      backgroundPath: 'assets/images/sports_new/cricket.png',
      color: const Color(0xffB6E388),
      positions: [
        "Wicketkeeper",
        "Fine leg",
        "Slip",
        "Mid wicket",
        "Gully",
        "Mid off",
        "Point",
        "Square leg",
        "Cover",
        "Captain",
        "Third man"
      ],
    ),
    SportModelTest(
      id: 9,
      title: 'American football',
      imagePath: 'assets/images/sports/american_football.png',
      subImagePath: 'assets/images/sub_sports/american_football.png',
      backgroundPath: 'assets/images/sports_new/american_football.png',
      color: const Color(0xffD078C8),
      positions: [
        "Quarterback",
        "Cornerback",
        "Offensive lineman",
        "Safety",
        "Running back",
        "Kick returner",
        "Fullback",
        "Punter",
        "Tight end",
        "Wide receiver",
        "Punt returner",
        "Defensive lineman",
        "Long snapper",
        "Linebacker",
        "Kicker"
      ],
    ),
    SportModelTest(
      id: 10,
      title: 'Martial arts',
      imagePath: 'assets/images/sports/material_arts.png',
      subImagePath: 'assets/images/sub_sports/material_arts.png',
      backgroundPath: 'assets/images/sports_new/material_arts.png',
      color: const Color(0xffF5B58B),
      positions: [
        "Aikido",
        "Kung fu",
        "Hapkido",
        "MMA",
        "Judo",
        "Muay thai",
        "Jiu jitsu",
        "Taekwondo",
        "Karate",
        "Tai chi",
        "Krav maga"
      ],
    ),
    SportModelTest(
      id: 11,
      title: 'Golf',
      imagePath: 'assets/images/sports/golf.png',
      subImagePath: 'assets/images/sub_sports/golf.png',
      backgroundPath: 'assets/images/sports_new/golf.png',
      color: const Color(0xffFFEEEE),
      positions: ["18 Holes", "12 Holes", "9 Holes"],
    ),
    SportModelTest(
      id: 12,
      title: 'Tennis',
      imagePath: 'assets/images/sports/tennis.png',
      subImagePath: 'assets/images/sub_sports/tennis.png',
      backgroundPath: 'assets/images/sports_new/tennis.png',
      color: const Color(0xffFFEEEE),
      positions: ["Singles", "Mixed doubles", "Doubles"],
    ),
    SportModelTest(
      id: 13,
      title: 'Gymnastic',
      imagePath: 'assets/images/sports/gymnastic.png',
      subImagePath: 'assets/images/sub_sports/gymnastic.png',
      backgroundPath: 'assets/images/sports_new/gymnastic.png',
      color: const Color(0xff566DD6),
      positions: [
        "Artistic",
        "Rythmic",
        "Trampoline",
        "Power tumbling",
        "Acrobatics",
        "Aerobics"
      ],
    ),
    SportModelTest(
      id: 14,
      title: 'Cycling',
      imagePath: 'assets/images/sports/cycling.png',
      subImagePath: 'assets/images/sub_sports/cycling.png',
      backgroundPath: 'assets/images/sports_new/cycling.png',
      color: const Color(0xffFFEEEE),
      positions: [
        "Road",
        "BMX racing",
        "Track",
        "Indoor cycling",
        "Mountain bike",
        "Trials",
        "BMX freestyle",
        "Cyclo-cross"
      ],
    ),
    SportModelTest(
      id: 15,
      title: 'Road Racing',
      imagePath: 'assets/images/sports/road_running.png',
      subImagePath: 'assets/images/sub_sports/road_running.png',
      backgroundPath: 'assets/images/sports_new/road_running.png',
      color: const Color(0xffFFEEEE),
      positions: [],
    ),
  ];
}

class Post {
  static List<PostModelTest> all = [
    PostModelTest(
      id: 1,
      reaction: "love",
      likesNum: "12k",
      commentsNum: "1k",
      username: "Basel Dev",
      desc:
          "Lorem ipsum dolor sit amet, consectetuer adipiscing elit. Fusce tellus. Cum sociis natoque penatibus et magnis dis parturient montes, nascetur ridiculus mus. Aenean placerat",
      image: "assets/images/general/post.png",
      name: "Basel Hijazi",
      sport: "Football Player",
    ),
    PostModelTest(
      id: 1,
      reaction: "love",
      likesNum: "8k",
      commentsNum: "586",
      username: "Ahmad Dev",
      desc:
          "Lorem ipsum dolor sit amet, consectetuer adipiscing elit. Fusce tellus. Cum sociis natoque penatibus et magnis dis parturient montes, nascetur ridiculus mus. Aenean placerat",
      image: "assets/images/general/post2.png",
      name: "Ahmad Namesa",
      sport: "Basketball Player",
    ),
    PostModelTest(
      id: 1,
      reaction: "love",
      likesNum: "6k",
      commentsNum: "985",
      username: "Saaed Dev",
      desc:
          "Lorem ipsum dolor sit amet, consectetuer adipiscing elit. Fusce tellus. Cum sociis natoque penatibus et magnis dis parturient montes, nascetur ridiculus mus. Aenean placerat",
      image: "assets/images/general/post3.png",
      name: "Saaed Beswedian",
      sport: "Basketball Player",
    ),
    PostModelTest(
      id: 1,
      reaction: "love",
      likesNum: "12k",
      commentsNum: "1k",
      username: "Basel Dev",
      desc:
          "Lorem ipsum dolor sit amet, consectetuer adipiscing elit. Fusce tellus. Cum sociis natoque penatibus et magnis dis parturient montes, nascetur ridiculus mus. Aenean placerat",
      image: "assets/images/general/post.png",
      name: "Basel Hijazi",
      sport: "Football Player",
    ),
    PostModelTest(
      id: 1,
      reaction: "love",
      likesNum: "8k",
      commentsNum: "586",
      username: "Ahmad Dev",
      desc:
          "Lorem ipsum dolor sit amet, consectetuer adipiscing elit. Fusce tellus. Cum sociis natoque penatibus et magnis dis parturient montes, nascetur ridiculus mus. Aenean placerat",
      image: "assets/images/general/post2.png",
      name: "Ahmad Namesa",
      sport: "Basketball Player",
    ),
    PostModelTest(
      id: 1,
      reaction: "love",
      likesNum: "6k",
      commentsNum: "985",
      username: "Saaed Dev",
      desc:
          "Lorem ipsum dolor sit amet, consectetuer adipiscing elit. Fusce tellus. Cum sociis natoque penatibus et magnis dis parturient montes, nascetur ridiculus mus. Aenean placerat",
      image: "assets/images/general/post3.png",
      name: "Saaed Beswedian",
      sport: "Basketball Player",
    ),
  ];
}

String enLanguage = 'en';
String arLanguage = 'ar';
String frLanguage = 'fr';

String defaultLanguage = 'en';

int homeTab = 0;
int trendingTab = 1;
int inboxTab = 2;
int profileTab = 3;

String sendbirdAppId = "";
String sendbirdToken = "";
