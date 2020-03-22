let moment = require('moment-timezone')
/** 

let now = moment()

console.log(now.format())
console.log(now.toJSON())
console.log(now_us.format())
console.log(now_us.toJSON())
console.log(datetime_moment.format())
console.log(datetime_moment.diff(now, 'minutes'))
console.log(datetime_moment.diff(now_us, 'minutes'))
*/
var now = moment.utc();
// get the zone offsets for this time, in minutes
var NewYork_tz_offset = moment.tz.zone("America/New_York").utcOffset(now); 
var HongKong_tz_offset = moment.tz.zone("Europe/London").utcOffset(now);
// calculate the difference in hours
let offset = (NewYork_tz_offset - HongKong_tz_offset) / 60;

let now_us = moment().add(-offset, 'hours')
let datetime = { day: 29, hour: 12, month: 1, year: 2020, minute: 1 }
let datetime_moment = moment(datetime.year + '-' + datetime.month + '-' + datetime.day + ' ' + datetime.hour + ':' + datetime.minute, 'YYYY-MM-DD HH:mm').tz('America/New_York')
console.log(datetime_moment.diff(now_us, 'minutes'))