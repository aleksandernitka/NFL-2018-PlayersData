# remove scientific notation
options(scipen = 999)

# list all files in directory
files = list.files(path = 'teams', pattern = '.csv')

# Legend, after www.pro-football-reference.com
# No. -- Uniform number
# Age -- Player's age on December 31st of that year
# Pos -- Position
# G -- Games played
# GS -- Games started as an offensive or defensive player
# Wt -- Weight in Pounds
# Ht -- Height (ft-inches)
# Yrs -- Experience
# Years the player was/has been in pro football.
# Drafted (tm/rnd/yr) -- 
# Order within the round is not yet available.
# Cap Hit -- Player's cap hit for this year, does not reflect splits among teams if he's traded mid-season.

# load all data into one data frame
for (i in 1:length(files)){
    
    # Get team code from file name
    teamCode = strsplit(files[i], "_")[[1]][2]
    teamCode = strsplit(teamCode, "[.]")[[1]][1]
    
    # Load team data
    tmpTeam = read.csv(paste('teams', files[i], sep = '/'), header = TRUE)
    # Add team code
    tmpTeam$Team = teamCode
    
    # set type for some variables
    tmpTeam$Player = as.character(tmpTeam$Player)
    tmpTeam$Cap.Hit = as.character(tmpTeam$Cap.Hit)
    tmpTeam$Ht = as.character(tmpTeam$Ht)
    tmpTeam$HeightCM = NA
    tmpTeam$WeightKG = NA

    for (p in 1:nrow(tmpTeam)){
        # Separate player Id
        tmpTeam$PlayerId[p] = strsplit(tmpTeam$Player[p], "\\\\")[[1]][2]
        # Separate name
        tmpTeam$Player[p] = strsplit(tmpTeam$Player[p], "\\\\")[[1]][1]
        # Convert pay to number (rm $)
        tmpTeam$Cap.Hit[p] = strsplit(tmpTeam$Cap.Hit[p], "\\$")[[1]][2]
        # Convert height to cm
        tmpTeam$HeightCM[p] = ( as.numeric(strsplit(tmpTeam$Ht[p], '\\-')[[1]][1]) * 30.48 ) + 
            ( as.numeric(strsplit(tmpTeam$Ht[p], '\\-')[[1]][2]) * 2.54)
        # Convert pounds to kg
        tmpTeam$WeightKG[p] = tmpTeam$Wt[p] * 0.453592
    }
    
    # Append to data frame
    if (i == 1){
        # Create the data frame
        allPlayers = data.frame(matrix(nrow = 1, ncol = ncol(tmpTeam)))
        names(allPlayers) = names(tmpTeam)
        
        # append to df
        allPlayers = rbind(allPlayers, tmpTeam)
        
        # rm firs empty row
        allPlayers = subset(allPlayers, is.na(allPlayers$Player) == FALSE)
    }
    else {
        # append to df
        allPlayers = rbind(allPlayers, tmpTeam)
    }
    
}

#remove(tmpTeam, teamCode, p, i)

# Drop empty column
allPlayers = allPlayers[ , !(names(allPlayers) %in% c("AV"))]

# Convert pay to numeric
allPlayers$Cap.Hit = as.numeric(allPlayers$Cap.Hit)

# Save to csv
write.csv(allPlayers, file = "2018allPlayersData.csv")
