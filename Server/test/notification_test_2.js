let apn = require('apn')

let options = {
    token: {
        key: "keys/AuthKey_8F8B2U52Q4.p8",
        keyId: "8F8B2U52Q4",
        teamId: "A33SP8Q4D7"
    },
    production: false
};
let apnProvider = new apn.Provider(options)

let note = new apn.Notification()
let token = '987abcd191633026eb1656cd5705d15a1af57e9fbdbf4e397cde446b0eb3082a'

note.expiry = Math.floor(Date.now() / 1000) + 3600 // Expires 1 hour from now.
note.badge = 3
note.sound = "default"
note.alert = 'this is a test'
note.payload = {
    "aps": {
    "alert": 'this is a test',
    "sound": "default",
    "link_url": "https://raywenderlich.com"
    }
}
note.topic = "com.gmail.niopullus.Summon"
apnProvider.send(note, token).then((result) => {
    // see documentation for an explanation of result
})