var apn = require('apn');

var options = {
    token: {
        key: "../../Client/AuthKey_8F8B2U52Q4.p8",
        keyId: "8F8B2U52Q4",
        teamId: "A33SP8Q4D7"
    },
    production: false
};

let deviceToken = "e34e85ad9869855d04f558497b657699fa82fef409062d658a926393ad270b32"
  
var apnProvider = new apn.Provider(options);

var note = new apn.Notification();

note.expiry = Math.floor(Date.now() / 1000) + 3600; // Expires 1 hour from now.
note.badge = 3;
note.sound = "ping.aiff";
note.alert = "\uD83D\uDCE7 \u2709 You have a new message";
note.payload = {
    "aps": {
      "alert": "Breaking News!",
      "sound": "default",
      "link_url": "https://raywenderlich.com"
    }
}
note.topic = "com.gmail.niopullus.Summon";

apnProvider.send(note, deviceToken).then( (result) => {
    // see documentation for an explanation of result
});