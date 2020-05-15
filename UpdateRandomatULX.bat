@echo off
set /p changes="Enter Changes: "
"C:\Program Files (x86)\Steam\steamapps\common\GarrysMod\bin\gmpublish.exe"  update -addon "TTT-Randomat-20-ULX.gma" -id "2096758509" -changes "%changes%"
pause