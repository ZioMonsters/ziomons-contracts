function monster (id, atk, def, spd) {
    this.id = id;
    this.atk = atk;
    this.def = def;
    this.spd = spd;
}

module.exports = (team1, team2) => {
    return {
        Team1: [
            new monster(team1[0], team1[5], team1[10], team1[15]),
            new monster(team1[1], team1[6], team1[11], team1[16]),
            new monster(team1[2], team1[7], team1[12], team1[17]),
            new monster (team1[3], team1[8], team1[13], team1[18]),
            new monster (team1[4], team1[9], team1[14], team1[19])
        ],
        Team2: [
            new monster (team2[0], team2[5], team2[10], team2[15]),
            new monster (team2[1], team2[6], team2[11], team2[16]),
            new monster (team2[2], team2[7], team2[12], team2[17]),
            new monster (team2[3], team2[8], team2[13], team2[18]),
            new monster (team2[4], team2[9], team2[14], team2[19])
        ]
    }
}
