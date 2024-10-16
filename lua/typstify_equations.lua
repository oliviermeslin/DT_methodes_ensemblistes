-- Encapsulate all displaymode equations with the mitex environment
function Para(elem)
    -- Loop over the elements of the Para element
    for i, item in ipairs(elem.content) do
    -- Modify the element if it is a Math Element with a DisplayMath type
    if item.t == "Math" then
        for key, value in pairs(item) do
            print(key)
        end
        if item.mathtype == "DisplayMath" then
            print("kikou")
            return pandoc.RawBlock("typst", "#mitex(`\n$" .. item.text .. "$\n`)")
        else
            return elem
        end


    end
end
return elem
end

-- Encapsulate all inline equations with the mi environment
function Math(elem)
    if elem.mathtype == "InlineMath" then
        return pandoc.RawInline("typst", "#mi(\"$" .. elem.text .. "$\")")
    else return elem
    end
end
