-- Pure shared placement for distant grass. No secret positions or gameplay state.
local S={}
function S.offset(x,z,index)
    local phase=math.noise(x*.071,z*.071,index*.61)*3.7
    local angle=(index-1)*math.pi*.5+phase
    local radius=4.8+math.noise(z*.13,x*.13,index*.37)*2.5
    return Vector3.new(math.cos(angle)*radius+math.sin(x*.21+index)*1.1,0,
        math.sin(angle)*radius+math.cos(z*.19+index)*1.1)
end
function S.scatter(x,z)
    return (math.sin(x*12.9898+z*78.233)*43758.5453)%1
end
return S
