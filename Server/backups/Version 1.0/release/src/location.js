let data = require('./data.js')

function query_location(location_id, call_back) {
    if (location_id !== undefined) {
        data.parse_query_with_values('SELECT * FROM locations WHERE id = ?', [location_id], call_back)
    } else {
        call_back(undefined)
    }
}

function query_save_location(location, call_back) {
    if (location !== undefined) {
        let name = location.name
        let longitude = location.longitude
        let latitude = location.latitude
        let street = location.street
        let city = location.city
        let state = location.state
        let postalCode = location.postalCode
        let country = location.country
        let isoCountryCode = location.isoCountryCode
        let subAdministrativeArea = location.subAdministrativeArea
        let subLocality = location.subLocality
        let values = [name, longitude, latitude, street, city, state, postalCode, country, isoCountryCode, subAdministrativeArea, subLocality]
        data.query_with_values('INSERT INTO locations (name, longitude, latitude, street, city, state, postalCode, country, isoCountryCode, subAdministrativeArea, subLocality) VALUES (?)', values, function() {
            data.parse_query('SELECT LAST_INSERT_ID()', function(result) {
                let id = result[0]['LAST_INSERT_ID()']
                call_back(id)
            })
        })
    } else {
        call_back(undefined)
    }
}

module.exports.query_location = query_location
module.exports.query_save_location = query_save_location