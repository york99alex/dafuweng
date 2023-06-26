function PrintTable(kvData, str)
    if str == nil then
        str = " "
    end
    print(str, "输出table====================")
    for key, value in pairs(kvData) do
        print(str, key, "-------", value)
        if type(value) == "table" then
            PrintTable(value, str .. "  ")
        end
    end
    print(str, "结束table====================")
end
