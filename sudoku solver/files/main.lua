----------- FUNCTIONS -----------
-- Main Variables
local BlockSize = {} 

local BoardSize

local game = {
    
}

local draft = {
    
}

local repdraft = {

}


local missing = {}


local numberleft = {

}


local funcs = {}
funcs.__index = funcs



----- ERROR HANDLER

-- Verify input board

function ManageInput(text)
    

    for i = 1, BoardSize do
        if not game[i] then game[i] = {} end
        setmetatable(game[i], funcs)
        for v = 1, BoardSize do
            table.insert(game[i], "_")
        end
    end



    for i = 1, #text do
        if i > BoardSize then
            error("inputsudoku has more lines than the game supports (" .. BoardSize .. ")")
        end
        text[i] = string.gsub(text[i], "_+", "_")
        local maxvalue = 1
        local v = 1
        for token in string.gmatch(text[i], "%S+") do
            if v > BoardSize then
                error("inputsudoku has more elements in line '"..i.."' than the game supports ("..BoardSize..")")
            end
            

            if tonumber(token) then
                maxvalue = tonumber(token)
            end

            
            if maxvalue > BoardSize then
                error("Board size is only "..BoardSize.."x"..BoardSize..". Can't handle up to ".. maxvalue .. " numbers as in inputsudoku line '"..i .. "' token number '".. #game.line[i] .. "'")
            end

           if tonumber(token) then
            -- can it come?
                if CanNumberHere(tonumber(token), i, v) then
                    numberleft[tonumber(token)] = numberleft[tonumber(token)] - 1

                    game[i][v] = tonumber(token)
                    RemoveDraft(tonumber(token), i, v)
                else
                    error("number ".. tonumber(token) .. " cannot come in line ".. i .. " row ".. v)
                end
           

            elseif token == "_" then
                game[i][v] = token
            else
                error("Wrong token type, you can only input numbers and underscores, got: '" .. token .. "' at inputsudoku line '" .. i .. "' token number '" .. #game.line[i]+1 .. "'")
            end
            v = v+1
        end
    end

    


    
end


----- ESSENTIAL FUNCTIONS


-- Remove Missing

function RemoveDraft(number, i, v, only, whitelistpos) -- i: line, v: row
    if whitelistpos then
        setmetatable(whitelistpos, funcs)
    end

    -- cleans the slot i v
    if not only then
        for value = 1, #draft[i][v] do
            table.remove(draft[i][v], 1)    
        end
    end
    
    -- removes number from i, v only
    if only and (only ~= "block" and only ~= "row" and only ~= "line") then
        setmetatable(draft[i][v], funcs)
        local found, count, index = draft[i][v]:find(number) 
        if found then
            table.remove(draft[i][v], index[1])
        end
    end

    -- updates for line
    if only ~= "row" and only ~= "block" and only ~= "single" then
        local t = 1
        while t <= #draft[i] do
            -- line
            if whitelistpos and whitelistpos:find({
                i = i,
                v = t
            }) then
                t = t + 1
            else
                setmetatable(draft[i][t], funcs)
        
        
                local hasnumber, count, index = draft[i][t]:find(number)
        
                if hasnumber then
                    table.remove(draft[i][t], index[1])
                    --draft[i][t][index[1]] = 0
                end
                    
                t = t+1

            end
            
        end
        
        
    

    
        
    end

    -- updates for row
    
    if only ~= "line" and only ~= "block" and only ~= "single" then
        
        local i = 1
        while i <= #draft do

            if whitelistpos and whitelistpos:find({
                i = i,
                v = v
            }) then
                i = i+1
            else
                setmetatable(draft[i][v], funcs)
                local hasnumber, count, index = draft[i][v]:find(number)
                if hasnumber then
                    --draft[i][v][index[1]] = 0
        
                    table.remove(draft[i][v], index[1])
                end
                for value = 1, #draft[i][v] do
                    --print(draft[i][v][value])
                end
                i = i+1

            end

        end
    end

    -- updates for block
    if only ~= "line" and only ~= "row" and only ~= "single" then
        
        local blocknumberi, blocknumberv, starti, endi, startv, endv = GetBlock(i, v)
    
        
        --print("starti: ".. starti)
        --print("startv: ".. startv)
        --print("endi: ".. endi)
        --print("endv: ".. endv)
        local currenti = starti
        local currentv = startv
        while currenti <= endi do
            
            while currentv <= endv do
                if only == "block" then
                    for index, table in pairs(whitelistpos) do
                        --print('(from removedraft) position '..index.." = " ..table.i, table.v)
                    end
                end
                if whitelistpos and whitelistpos:find({i = currenti, v = currentv}) then
                    --print("skipping from "..currentv.. " to "..currentv+1)
                    currentv = currentv + 1
                else
                    setmetatable(draft[currenti][currentv], funcs)
                    local found, count, index = draft[currenti][currentv]:find(number)
                    if found then
                        --print("removing number "..number.. " from draft ".. currenti .. currentv .. " at index ".. index[1])
                        table.remove(draft[currenti][currentv], index[1])
                        --draft[currenti][currentv][index[1]] = 0
                    end
                    currentv = currentv + 1

                end
            end
            currentv = startv
            currenti = currenti + 1
        end
        currenti = starti
    
        local count = 0
        for lines = 1, #draft do
            for row = 1, #draft[lines] do
                for value = 1, #draft[lines][row] do
                    count = count+1
                    --print(count)
                    --print(draft[lines][row][value])
                end
            end
        end
    end

end








-- Can number here?
function CanNumberHere(number, i, v) -- i: line, v: row
    setmetatable(draft[i][v], funcs)
    local found =  draft[i][v]:find(number)
    if found then return true end
    return false
end


-- Count Dict Number
function funcs:size()
    local size = 0
    for key, _ in pairs(self) do
        size = size + 1
    end
    return size
end





-- Find in table 
function funcs:find(value)
    if type(value) == "table" then
        setmetatable(value, funcs)
    end
    local found = false
    local index = {}
    local count = 0
    for i = 1, #self do
        if type(value) == "table" then
            if value:compare(self[i]) then
                found = true
                count = count + 1
                table.insert(index, i)
            end
        else
            if self[i] == value then
                found = true
                count = count + 1
                table.insert(index, i)
            end
        end
    end
    return found, count, index
end

-- copy table

function funcs:copy() 

    local newTable = {} 
  
    for key, value in pairs(self) do 
  
      if type(value) == "table" then 
        setmetatable(value, funcs)
        newTable[key] = value:copy() -- Recursively copy nested tables 
  
      else 
  
        newTable[key] = value 
  
      end 
  
    end 
  
    return newTable 
  
end


-- compare childs

function funcs:comparechild()
    local lastkey
    for key, value in pairs(self) do
        if lastkey then
            -- compares
            if (type(self[key]) == "table") and (type(self[lastkey]) == "table") then
                setmetatable(self[key], funcs)
                if not self[key]:compare(self[lastkey]) then
                    lastkey = key
                    return false
                end
            elseif (type(value) == "table") or (type(self[lastkey]) == "table") then
                return false
            else
                if not (self[key] == self[lastkey]) then
                    return false
                end
            end
        else
            lastkey = key
        end
    end
    return true
end


-- compare tables

function funcs:compare(table2)
    setmetatable(table2, funcs)
    if table2:size() ~= self:size() then
        return false
    end
    for key, value in pairs(table2) do
        if type(value) == "table" then
            setmetatable(self[key], funcs)
            setmetatable(value, funcs)
            if value:size() ~= self[key]:size() then
                return false
            end
            if not self[key]:compare(value) then
                return false
            end
        else
            
            if value ~= self[key]  then
                return false
            end
        end

    end
    return true
end




-- check block (by a given i, v, returns blocki, blockv, starti, endi, startv, endv)
function GetBlock(i, v)
    local blocki, blockv, starti, startv, endi, endv
    blocki = math.ceil(i/BlockSize.Y)
    blockv = math.ceil(v/BlockSize.X)
    endi = blocki * BlockSize.Y
    endv = blockv * BlockSize.X
    starti = endi - BlockSize.Y + 1
    startv = endv - BlockSize.X + 1
    return blocki, blockv, starti, endi, startv, endv
end



-- Manage Settings

function LoadSettings()
    
    local file = io.open("settings.txt")
    local text
    if file then
        text = file:read("a")
        BlockSize["X"] = string.match(text, "%d+")

        if not BlockSize["X"] then
            error("Settings BlockSizeX has wrong value, make sure it is a number and is not empty")
        end
        

        local second_line = string.find(text, "%d+$")

        BlockSize["Y"] = string.match(text, "%d+", second_line)

        if not BlockSize["Y"] then
            error("Settings BlockSizeY has wrong value, make sure it is a number and is not empty")
        end
        


    else
        error("There is no 'settings.txt' file, make sure it is in the same directory as inputsudoku.txt and files folder")
    end
    
    BoardSize = BlockSize.X * BlockSize.Y
    
end



-- Create Draft and missings and numberleft

function CreateDraft()
    for i = 1, BoardSize do
        if not draft[i] then draft[i] = {} end
        if not repdraft[i] then repdraft[i] = {} end
        for v = 1, BoardSize do
            if not draft[i][v] then draft[i][v] = {} end
            if not repdraft[i][v] then repdraft[i][v] = {} end
            for z = 1, BoardSize do
                table.insert(draft[i][v], z)
                
            end
        end
        table.insert(missing, i)

        table.insert(numberleft, BoardSize)


    end
    
end




-- Text copy / build game (each line)




function CreateGame()
    local file = io.open("inputsudoku.txt")
    local text = {}
    local line = 1
    if file then
        repeat
            text[line] = file:read("l")
            
            if text[line] == nil then
                break
            end
            line = line + 1
            
        until false
    else
        error([[File "inputsudoku.txt" doesn't exist. Make sure it is on the same path as the folder 'files']])
    end
    


    ManageInput(text)

end








----- RUNNING PROCESS
local runs = 0
local returnn
local status
local returni
local returnv
-- Start Verifying and solving
function Solve()
    status = nil
    runs = runs + 1
    setmetatable(draft, funcs)
    local repetitiontablesample = {}
    for i = 1, BoardSize+1 do
        table.insert(repetitiontablesample, {})
    end
    for i =1, BoardSize do
        repetitiontablesample[0+1][tostring(i)] = {}
    end
    setmetatable(repetitiontablesample, funcs)
    local finished
    local repetitiontable



    setmetatable(game, funcs)
    
    local backup = draft:copy()
    


    
    -- check for each slot
    for i = 1, BoardSize do
        for v = 1, BoardSize do
            if #draft[i][v] == 1 then
                game[i][v] = draft[i][v][1]
                numberleft[draft[i][v][1]] = numberleft[draft[i][v][1]] - 1
                RemoveDraft(draft[i][v][1], i, v)
            end
            
            if #draft[i][v] == 0 and game[i][v] == "_" then
                --print("--BACKUP")
                for i = 1, #backup do
                    for v = 1, #backup[i] do
                        --print(backup[i][v])
                    end
                end
                --print("--GAME")
                for i = 1, #game do
                    for v = 1, #game[i] do
                       -- print(game[i][v])
                    end
                end
                status = 'Impossible'
                returni = i
                returnv = v
        
                return
                
            end
        end
    end
    
    
    
    
    
    finished = 0
    for i = 1, BoardSize do
        if numberleft[i] == 0 then
            finished = finished + 1
        end
    end
    if finished == BoardSize then
        status = 'Solved'

        return
    end
    
    -- check for each line
    for i = 1, BoardSize do -- change to board size
        -- checks the repdraft for cross logics
        for v = 1, BoardSize do
            local whitelistpos = {}
            local count = 0
            setmetatable(repdraft[i][v], funcs)
            
            local needcount = repdraft[i][v]:size()
            if needcount > 0 then
                table.insert(whitelistpos, {
                    i = i,
                    v = v
                })
                for currentv = v, BoardSize do

                    if repdraft[i][v]:compare(repdraft[i][currentv]) then
                        --print(repdraft[i][v]:compare(repdraft[i][currentv]))
                        --print("repdraft"..i..v.."is the same as "..i..currentv)
                        table.insert(whitelistpos, {
                            i = i,
                            v = currentv
                        })
                        --print("line: "..i .. " row: "..currentv .. " for "..v)
                        for key, _ in pairs(repdraft[i][v]) do
                            --print(repdraft[i][v][key])
                            --print("got ", repdraft[i][currentv][key])
                        end
                        count = count +1
                        --print("count is now "..count.. " trying to find "..needcount)
                    end
                end
                --print("ended: ",count, needcount)
                if count == needcount then
                    for key, _ in pairs(repdraft[i][v]) do
                        RemoveDraft(tonumber(key), i, v, "line", whitelistpos)
                        --print("executing super impressive logic for ", key, i, v)
                    end
                elseif count > needcount then
                    status = "Impossible5"
                    returni = i
                    returnn = {count, needcount}
                    return
                end
            end
        end

    
        repetitiontable = repetitiontablesample:copy()
        for number = 1, BoardSize do
            if numberleft[number] > 0 then
                local backuppos = {i = {}, v = {}}
                local repcount = 0
                local isalreadyput = false
                for v = 1, BoardSize do
                    if game[i][v] == number then
                        isalreadyput = true
                        break
                    end
                    setmetatable(draft[i][v], funcs)
                    local found, count, index = draft[i][v]:find(number)
                    if found then
                        repetitiontable[repcount+1][tostring(number)] = nil
                    
                        repcount = repcount + 1
                        repetitiontable[repcount+1][tostring(number)] = {i = {}, v = {}}
                        for key, value in pairs(backuppos) do
                            setmetatable(value, funcs)
                            repetitiontable[repcount+1][tostring(number)][key] = value:copy()
                        end
                        table.insert(repetitiontable[repcount+1][tostring(number)].i, i)
                        table.insert(repetitiontable[repcount+1][tostring(number)].v, v)
                        table.insert(backuppos.i, i)
                        table.insert(backuppos.v, v)

                    
                    end
                end


                if repcount == 1 then -- puts number if thats only where it can come
                    game[i][repetitiontable[1+1][tostring(number)].v[1]] = number
                    RemoveDraft(number, i, repetitiontable[1+1][tostring(number)].v[1])
                    numberleft[number] = numberleft[number] - 1
                elseif repcount == 0 and not isalreadyput then -- if number cant come in line, and isnt put, return error
                    status = "Impossible2"
                    returni = i
                    returnn = number
                    return
                end
            end
        end    



        for r = 2, BoardSize do
            setmetatable(repetitiontable[r+1], funcs)
            if repetitiontable[r+1]:size() == r then
                
                setmetatable(repetitiontable[r+1], funcs)
                if repetitiontable[r+1]:comparechild() then -- compares the children, so if they have same values (same pos) it executes the code
                
                    --print(r)
                    -- block comparation
                    local blockv = {}
                    local firstkey
                    local index = 1
                    local whitelistpos = {}
                    for key, value in pairs(repetitiontable[r+1]) do
                        if not firstkey then firstkey = key end
                        if key ~= firstkey then break end
                        for posindex = 1, #value.i do
                            local i = value.i[posindex]
                            local v = value.v[posindex]
                            table.insert(whitelistpos, {
                                i = i,
                                v = v
                            })
                            local _, thisblockv = GetBlock(i, v)
                            
                            blockv[tostring(index)] = thisblockv -- uses dict system so we can use :comparechild() later
                            index = index + 1
                            
                        end
                    end
                    setmetatable(blockv, funcs)
                    if blockv:comparechild() then -- they are in the same block
                        
                        for index, table in pairs(whitelistpos) do
                            --print('position '..index.." = " ..table.i, table.v)
                        end
                        for key, _ in pairs(repetitiontable[r+1]) do
                            --print("calling remove functions for ".. tonumber(key))
                            RemoveDraft(tonumber(key), i, whitelistpos[1].v, "block", whitelistpos)
                        end
                    end

                    -- adds to the repdraft
                    for key, value in pairs(repetitiontable[r+1]) do
                        for index = 1, #value.v do
                            repdraft[i][value.v[index]][key] = key
                        end
                    end


                    -- removes every other number from that pos
                    local whitelistnum = {}
                    setmetatable(whitelistnum, funcs)
                    for key, _ in pairs(repetitiontable[r+1]) do
                        
                        table.insert(whitelistnum, tonumber(key))
                    end
                    for _, pos in pairs(whitelistpos) do
                        for n = 1, BoardSize do
                            if not whitelistnum:find(n) then
                                --print(draft[1][1][1])
                                --print("calling remove function single for ", n, pos.i, pos.v)
                                RemoveDraft(n, pos.i, pos.v, "single")
                            end
                        end
                    end
                end
            end
        end
    end
    
            
    
        
    
    
    finished = 0
    for i = 1, BoardSize do
        if numberleft[i] == 0 then
            finished = finished + 1
        end
    end
    if finished == BoardSize then
        status = 'Solved'
        return
    end


    -- checks for each row
    for v = 1, BoardSize do -- change to board size
        -- checks the repdraft for cross logics
        for i = 1, BoardSize do
            local whitelistpos = {}
            local count = 0
            setmetatable(repdraft[i][v], funcs)
            
            local needcount = repdraft[i][v]:size()
            if needcount > 0 then
                table.insert(whitelistpos, {
                    i = i,
                    v = v
                })
                for currenti = i, BoardSize do

                    if repdraft[i][v]:compare(repdraft[currenti][v]) then
                        --print(repdraft[i][v]:compare(repdraft[currenti][v]))
                        --print("repdraft"..i..v.."is the same as "..currenti..v)
                        table.insert(whitelistpos, {
                            i = currenti,
                            v = v
                        })
                        --print("line: "..currenti .. " row: "..v .. " for "..v)
                        for key, _ in pairs(repdraft[i][v]) do
                            --print(repdraft[i][v][key])
                            --print("got ", repdraft[currenti][v][key])
                        end
                        count = count +1
                        --print("count is now "..count.. " trying to find "..needcount)
                    end
                end
                --print("ended: ",count, needcount)
                if count == needcount then
                    for key, _ in pairs(repdraft[i][v]) do
                        RemoveDraft(tonumber(key), i, v, "row", whitelistpos)
                        --print("executing super impressive logic for ", key, i, v)
                    end
                elseif count > needcount then
                    status = "Impossible5"
                    returnv = v
                    returnn = {count, needcount}
                    return
                end
            end
        end
    

    
        repetitiontable = repetitiontablesample:copy()
        for number = 1, BoardSize do
            if numberleft[number] > 0 then
                local backuppos = {i = {}, v = {}}
                local repcount = 0
                local isalreadyput = false
                for i = 1, BoardSize do
                    if game[i][v] == number then
                        isalreadyput = true
                        break
                    end
                    setmetatable(draft[i][v], funcs)
                    local found, count, index = draft[i][v]:find(number)
                    if found then
                        repetitiontable[repcount+1][tostring(number)] = nil
                    
                        repcount = repcount + 1
                        repetitiontable[repcount+1][tostring(number)] = {i = {}, v = {}}
                        for key, value in pairs(backuppos) do
                            setmetatable(value, funcs)
                            repetitiontable[repcount+1][tostring(number)][key] = value:copy()
                        end
                        table.insert(repetitiontable[repcount+1][tostring(number)].i, i)
                        table.insert(repetitiontable[repcount+1][tostring(number)].v, v)
                        table.insert(backuppos.i, i)
                        table.insert(backuppos.v, v)

                    
                    end
                end


                if repcount == 1 then -- puts number if thats only where it can come
                    game[repetitiontable[1+1][tostring(number)].i[1]][v] = number
                    RemoveDraft(number, repetitiontable[1+1][tostring(number)].i[1], v)
                    numberleft[number] = numberleft[number] - 1
                elseif repcount == 0 and not isalreadyput then -- if number cant come in line, and isnt put, return error
                    status = "Impossible3"
                    returnv = v
                    returnn = number
                    return
                end
            end
        end    



        for r = 2, BoardSize do
            setmetatable(repetitiontable[r+1], funcs)
            if repetitiontable[r+1]:size() == r then
                
                setmetatable(repetitiontable[r+1], funcs)
                if repetitiontable[r+1]:comparechild() then -- compares the children, so if they have same values (same pos) it executes the code
                    --print(r)
                    -- block comparation
                    local blocki = {}
                    local firstkey
                    local index = 1
                    local whitelistpos = {}
                    for key, value in pairs(repetitiontable[r+1]) do
                        if not firstkey then firstkey = key end
                        if key ~= firstkey then break end
                        for posindex = 1, #value.v do
                            local i = value.i[posindex]
                            local v = value.v[posindex]
                            table.insert(whitelistpos, {
                                i = i,
                                v = v
                            })
                            local thisblocki = GetBlock(i, v)
                            
                            blocki[tostring(index)] = thisblocki -- uses dict system so we can use :comparechild() later
                            index = index + 1
                            
                        end
                    end
                    setmetatable(blocki, funcs)
                    if blocki:comparechild() then -- they are in the same block
                        
                        for index, table in pairs(whitelistpos) do
                            --print('position '..index.." = " ..table.i, table.v)
                        end
                        for key, _ in pairs(repetitiontable[r+1]) do
                            --print("calling remove functions for ".. tonumber(key))
                            RemoveDraft(tonumber(key), whitelistpos[1].i, v, "block", whitelistpos)
                        end
                    end

                    -- adds to the repdraft
                    for key, value in pairs(repetitiontable[r+1]) do
                        for index = 1, #value.i do
                            repdraft[value.i[index]][v][key] = key
                        end
                    end

                    -- removes every other number from that pos
                    local whitelistnum = {}
                    setmetatable(whitelistnum, funcs)
                    for key, _ in pairs(repetitiontable[r+1]) do
                        table.insert(whitelistnum, tonumber(key))
                    end
                    for _, pos in pairs(whitelistpos) do
                        for n = 1, BoardSize do
                            if not whitelistnum:find(n) then
                                --print(draft[1][1][1])
                                --print("calling remove function single for ", n, pos.i, pos.v)
                                RemoveDraft(n, pos.i, pos.v, "single")
                            end
                        end
                    end
                end
            end
        end
    end
    




    
    finished = 0
    for i = 1, BoardSize do
        if numberleft[i] == 0 then
            finished = finished + 1
        end
    end
    if finished == BoardSize then
        status = 'Solved'
        return
    end

    -- check each number for each block
    for blocki = 1, BlockSize.X do
        local starti, endi
        endi = blocki * BlockSize.Y
        starti = endi - BlockSize.Y + 1
        for blockv = 1, BlockSize.Y do
            repetitiontable = repetitiontablesample:copy()
            local startv, endv
            endv = blockv * BlockSize.X
            startv = endv - BlockSize.X + 1
            
            for number = 1, BoardSize do
                if numberleft[number] > 0 then
                    local backuppos = {i = {}, v = {}}
                    local repcount = 0
                    local isalreadyput = false
                    for i = starti, endi do
                        for v = startv, endv do
                            if game[i][v] == number then
                                isalreadyput = true
                                break
                            end
                            setmetatable(draft[i][v], funcs)
                            local found, count, index = draft[i][v]:find(number)
                            if found then
                                 repetitiontable[repcount+1][tostring(number)] = nil
                                    
                                repcount = repcount + 1
                                repetitiontable[repcount+1][tostring(number)] = {i = {}, v = {}}
                                for key, value in pairs(backuppos) do
                                    setmetatable(value, funcs)
                                    repetitiontable[repcount+1][tostring(number)][key] = value:copy()
                                end
                                table.insert(repetitiontable[repcount+1][tostring(number)].i, i)
                                table.insert(repetitiontable[repcount+1][tostring(number)].v, v)
                                table.insert(backuppos.i, i)
                                table.insert(backuppos.v, v)
                
                                    
                            end
                        end
                        if isalreadyput then break end
                    end
                
                
                    if repcount == 1 then -- puts number if thats only where it can come
                        game[repetitiontable[1+1][tostring(number)].i[1]][repetitiontable[1+1][tostring(number)].v[1]] = number
                        
                        RemoveDraft(number, repetitiontable[1+1][tostring(number)].i[1], repetitiontable[1+1][tostring(number)].v[1])
                         numberleft[number] = numberleft[number] - 1
                    elseif repcount == 0 and not isalreadyput then -- if number cant come in line, and isnt put, return error
                        status = "Impossible4"
                        returni = blocki
                        returnv = blockv
                        returnn = number
                        return
                    end
                end
            end
                
                
                
            for r = 2, BoardSize do
                setmetatable(repetitiontable[r+1], funcs)
                if repetitiontable[r+1]:size() == r then
                                
                    setmetatable(repetitiontable[r+1], funcs)
                    if repetitiontable[r+1]:comparechild() then -- compares the children, so if they have same values (same pos) it executes the code
                        --print(r)
                        local ipos = {}
                        local vpos = {}
                        local firstkey
                        local index = 1
                        local whitelistpos = {}

                        -- load i and v pos
                        for key, value in pairs(repetitiontable[r+1]) do
                            if not firstkey then firstkey = key end
                            if key ~= firstkey then break end
                            while index <= #value.i do
                                --print('inserting ipos index'.. index .. ": "..value.i[index].. " at ipos")
                                table.insert(ipos, value.i[index])
                                --print('inserted: ' ..ipos[index])
                                --print('inserting vpos '.. index .. ": "..value.v[index].. " at vpos")
                                table.insert(vpos, value.v[index])
                                --print('inserted: ' ..vpos[index])
                                index = index + 1
                            end
                            
                        end
                        index = 1

                        -- load whitelistpos

                        for key = 1, #ipos do
                            table.insert(whitelistpos, {
                                i = ipos[key],
                                v = vpos[key]
                            })
                        end
                        -- line comparation
                        setmetatable(ipos, funcs)
                        
                        for key, value in pairs(ipos) do
                            --print(key, value)
                        end
                        if ipos:comparechild() then -- they are in the same line
                            --print("same block and line")
                            for key, _ in pairs(repetitiontable[r+1]) do
                                --print("Calling remove draft line for ", tonumber(key), ipos[1], vpos[1])
                                RemoveDraft(tostring(key), ipos[1], vpos[1], "line", whitelistpos)
                            end
                        end

                        -- row comparation
                        setmetatable(vpos, funcs)
                        if vpos:comparechild() then -- they are in the same line
                            for key, _ in pairs(repetitiontable[r+1]) do
                                --print("same block and row")
                                --print("Calling remove draft row for ", tonumber(key), ipos[1], vpos[1])
                                RemoveDraft(tostring(key), ipos[1], vpos[1], "row", whitelistpos)
                            end
                        end

                        -- adds to the repdraft
                        for key, value in pairs(repetitiontable[r+1]) do
                            for index = 1, #value.i do
                                repdraft[value.i[index]][value.v[index]][key] = key
                            end
                        end


                        -- removes every other number from that pos
                        local whitelistnum = {}
                        setmetatable(whitelistnum, funcs)
                        for key, _ in pairs(repetitiontable[r+1]) do
                            table.insert(whitelistnum, tonumber(key))
                        end
                        for _, pos in pairs(whitelistpos) do
                            for n = 1, BoardSize do
                                if not whitelistnum:find(n) then
                                    --print("calling remove function single for ", n, pos.i, pos.v)
                                    RemoveDraft(n, pos.i, pos.v, "single")
                                end
                            end
                        end
                    end
                end
            end
        end
    end

    
    finished = 0
    for i = 1, BoardSize do
        if numberleft[i] == 0 then
            finished = finished + 1
        end
    end
    if finished == BoardSize then
        status = "Solved"
        return
    end


    -- checks for each block
    


    -- end and debug

    --print("--BACKUP")
    for i = 1, #backup do
        for v = 1, #backup[i] do
            --print(backup[i][v])
        end
    end
    --print("--GAME")
    for i = 1, #game do
        for v = 1, #game[i] do
            --print(game[i][v])
        end
    end
    if draft:compare(backup) then
        status = "Multiple"
        
        return
    end
    if status then return end
    Solve()
    
end

function printsolved(status, i, v, n)
    
    if status == "Solved" then
        print("Solved Sudoku:")
    elseif status == "Impossible" then
        print("The Sudoku provided is impossible. No number can come at line '".. i .. "' row '".. v .. "'. Here is what I could solve so far:")
    elseif status == "Impossible2" then
        print("Sudoku is impossible. Number '".. n .. "' can't come in line '"..i.."'. Here is what I could solve so far:")
    elseif status == "Impossible3" then
        print("Sudoku is impossible. Number '".. n .. "' can't come in row '"..v.."'. Here is what I could solve so far:")
    elseif status == "Impossible4" then
        print("Sudoku is impossible. Number '".. n .. "' can't come in block '"..i..", ".. v .. "'. Here is what I could solve so far:")
    elseif status == "Impossible5" then
        print("Sudoku is impossible. There are ".. n[1] .. "repetition being shared while max number is ".. n[2].. " at line ".. i)
    elseif status == "Multiple" then
        print("The Sudoku has more than one solution, here is what i could solve so far:")
    end

    local printgame = {}
    for z = 1, BoardSize do
        printgame[z] = table.concat(game[z], " ")
        print(printgame[z])
    end


end

----- START PROGRAM
LoadSettings()
CreateDraft()
CreateGame()
Solve()


printsolved(status, returni, returnv, returnn)
print("ran "..runs.. " times")