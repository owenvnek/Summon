module.exports = {
    AccountDetails: AccountDetails
}

function AccountDetails() {

}

AccountDetails.prototype.set_username = function(username) {
    this.username = username
}

AccountDetails.prototype.set_display_name = function(display_name) {
    this.display_name = display_name
}