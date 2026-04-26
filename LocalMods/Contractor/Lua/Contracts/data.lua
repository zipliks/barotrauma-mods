ContractData = {}

ContractData.CREATURE_TABLE = {
    { species = "crawler", name = "Crawler", weight = 25, difficulty = 1, baseReward = 150 },
    { species = "swarmfeeder", name = "Swarm Feeder", weight = 20, difficulty = 1, baseReward = 120 },
    { species = "husk", name = "Husk", weight = 18, difficulty = 2, baseReward = 200 },
    { species = "crawlerhusk", name = "Husked Crawler", weight = 12, difficulty = 2, baseReward = 180 },
    { species = "mudraptor", name = "Mudraptor", weight = 15, difficulty = 2, baseReward = 220 },
    { species = "mantis", name = "Mantis", weight = 10, difficulty = 3, baseReward = 300 },
    { species = "tigerthresher", name = "Tiger Thresher", weight = 12, difficulty = 3, baseReward = 350 },
    { species = "molochbaby", name = "Moloch Baby", weight = 8, difficulty = 2, baseReward = 250 },
    { species = "watcher", name = "Watcher", weight = 10, difficulty = 3, baseReward = 400 },
    { species = "fractalguardian2", name = "Fractal Guardian", weight = 5, difficulty = 4, baseReward = 500 },
    { species = "molochblack", name = "Black Moloch", weight = 4, difficulty = 5, baseReward = 800 },
    { species = "hammerheadgold", name = "Golden Hammerhead", weight = 4, difficulty = 5, baseReward = 850 },
    { species = "latcher", name = "Latcher", weight = 3, difficulty = 6, baseReward = 1000 },
    { species = "cyborgworm", name = "Cyborg Worm", weight = 2, difficulty = 7, baseReward = 1500 },
    { species = "husk_prowler", name = "Husk Prowler", weight = 6, difficulty = 3, baseReward = 320 },
    { species = "husk_chimera", name = "Husk Chimera", weight = 3, difficulty = 4, baseReward = 550 },
    { species = "husk_exosuit", name = "Husk Exosuit", weight = 4, difficulty = 4, baseReward = 600 },
    { species = "spineling_morbusine", name = "Morbusine Spineling", weight = 5, difficulty = 3, baseReward = 380 },
    { species = "fractalguardian_emp", name = "EMP Fractal Guardian", weight = 3, difficulty = 5, baseReward = 700 },
    { species = "defensebot", name = "Defense Bot", weight = 4, difficulty = 2, baseReward = 180 },
}

ContractData.POISON_TYPES = {
    { identifier = "sufforinpoisoning", name = "Sufforin", reward = 400 },
    { identifier = "morbusinepoisoning", name = "Morbusine", reward = 350 },
    { identifier = "cyanidepoisoning", name = "Cyanide", reward = 500 },
    { identifier = "deliriuminepoisoning", name = "Deliriumine", reward = 300 },
}

ContractData.getDifficultyColor = function(difficulty)
    if difficulty <= 2 then return Color(100, 255, 100, 255)
    elseif difficulty <= 4 then return Color(255, 255, 100, 255)
    else return Color(255, 100, 100, 255) end
end