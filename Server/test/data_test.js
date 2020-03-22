let object1 = {
    chicken: "frick",
    taco: "frack",
    poot: "jimmy"
}

let object2 = {
    harry: "orfr",
    med: "roifnen"
}

for (let [key, value] of Object.entries(object1)) {
    object2[key] = value
}

console.log(object2)