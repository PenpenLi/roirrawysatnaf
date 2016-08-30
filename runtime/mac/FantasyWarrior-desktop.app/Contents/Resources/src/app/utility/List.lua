--
-- Author: Hao Liu
-- Date: 2016-08-29 15:24:49
--
--[[
	List, table的重新封装
]]

cc.exports.List = {}

function List.new()
	return {first = 0, last = -1}
end

function List.pushfirst(list, value)
	local first = list.first - 1
	list.first = first
	list[first] = value
end

function List.pushlast(list, value)
	local last = list.last + 1
	list.last = last
	list[last] = value
end

function List.popfirst(list)
	local first = list.first
	if first > list.last then return nil end
	local value = list[first]
	list[first] = nil
	list.first = first + 1
	return value
end

function List.poplast(list)
	local last = list.last
	if list.first > last then return nil end
	local value = list[last]
	list[last] = nil
	list.last = last - 1
	return value	
end

function List.removeAll(list)
	local function removeAll(table)
	    while true do
	        local k =next(table)
	        if not k then break end
	        table[k] = nil
	    end
	end
    removeAll(list)
    list.first = 0
    list.last = -1
end

function List.getSize(list)
    return list.last - list.first + 1
end

function List.first(list)
    local value = nil
    if list.first <= list.last then
        value = list[first]
    end
    
    return value
end

function List.remove(list, index)
    if index < list.first or index > list.last then return end
    
    while index <= list.last do
        list[index] = nil
        list[index] = list[index+1]
        index = index + 1
    end
    
    list.last = list.last -1
end

function List.removeObj(list, obj)
    if obj == nil or List.getSize(list) == 0 then return end
    
    for index=list.first, List.getSize(list) do
    	if list[index] == obj then
    		List.remove(list,index)
    		break
    	end
    end    
end
