# 0garage0
Garage Page: ![image](https://user-images.githubusercontent.com/113702628/207255438-4389737e-c71f-48d1-aa21-77c7170cdf8d.png)

### Feature
* Display vehicle name, plate and health
* Garage and impound both included
* simple UI
* exports to open the UI and to store vehicles (can be used to integrate with property scripts)
```
--isImpound (boolean)
--SpawnPoint (vector4)
--parking? (string): The name of garage to be opened, leave blank (nil) if not using seperate garage
exports['0garage0']:OpenGarageMenu(isImpound, SpawnPoint, parking)

--parking? (string): The name of garage to be stored, leave blank (nil) if not using seperate garage
exports['0garage0']:StoreVehicle(parking)
```

### Installation
1. Download the zip file and unzip it into your resource folder
3. name the folder 0garage0
2. add ensure 0garage0 to your server.cfg

### Requirement
* ESX Legacy
* oxmysql

### Support
Discord: https://discord.gg/pjuPHPrHnx
