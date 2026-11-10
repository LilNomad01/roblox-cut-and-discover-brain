-- Public catalog. Secret locations and reward eligibility remain on the server.
local C = {}
C.Backpacks = {
    {name="Mochila de Pano", bonus=25, price=250, color={101,198,128}},
    {name="Mochila Reforçada", bonus=75, price=900, color={71,155,211}},
    {name="Mochila de Couro", bonus=180, price=3200, color={174,109,63}},
    {name="Mochila do Explorador", bonus=450, price=11000, color={232,153,62}},
    {name="Mochila Encantada", bonus=1000, price=38000, color={166,107,222}},
}
C.Vendors = {
    Guto={name="Guto, o Mochileiro", color={99,202,112}, accent={255,211,74}, icon="🎒", dialogue="Bolso cheio? A aventura merece uma mochila maior!"},
    Lia={name="Lia, a Exploradora", color={90,175,235}, accent={255,168,71}, icon="🧭", dialogue="Marque o caminho de volta. As pedras azuis guardam uma história..."},
    Teca={name="Teca, a Botânica", color={155,220,126}, accent={191,147,228}, icon="🌼", dialogue="As flores do orvalho crescem longe da trilha. Traga algumas para minha pesquisa!"},
    Nilo={name="Nilo, o Gnomo Colecionador", color={164,109,211}, accent={255,211,92}, icon="🍄", dialogue="Não estou perdido. Estou colecionando caminhos!"},
}
C.Products = {}
for i,b in ipairs(C.Backpacks) do
    C.Products["backpack"..i]={vendor="Guto",name=b.name,icon="🎒",price=b.price,kind="backpack",level=i,effect="+"..b.bonus.." de capacidade. Substitui o bônus anterior."}
end
local products = {
    lantern={vendor="Lia",name="Lanterna portátil",icon="🔦",price=180,kind="equipment",effect="Equipe para iluminar até 18 studs ao redor."},
    compass={vendor="Lia",name="Bússola simples",icon="🧭",price=140,kind="equipment",effect="Aponta para comerciantes que você já visitou."},
    marker={vendor="Lia",name="Marcador de trilha",icon="📍",price=100,kind="equipment",effect="Marque seu local atual; veja-o no mapa de campo."},
    kit={vendor="Lia",name="Kit de exploração",icon="🔎",price=65,kind="kit",effect="Consumo: destaca pistas visíveis num raio de 16 studs por 12 s. Não detecta tesouros."},
    sellFlower={vendor="Teca",name="Vender flor do orvalho",icon="🌼",price=0,kind="flower",effect="Troque 1 flor por 40 moedas."},
    tradeKit={vendor="Teca",name="Troca botânica",icon="🍄",price=0,kind="trade",effect="Troque 3 cogumelos raros por 1 kit de exploração."},
    contract={vendor="Teca",name="Pesquisa do orvalho",icon="📜",price=0,kind="contract",effect="Aceite; entregue 3 flores. Receba 120 moedas e restaure a caçamba da cabana."},
    gnomeQuest={vendor="Nilo",name="Coleção de histórias",icon="📜",price=0,kind="gnomeQuest",effect="Registre 3 relíquias da floresta. Recompensa única: 90 moedas e 35 XP."},
    gnomeSkin={vendor="Nilo",name="Mochila do Gnomo",icon="🎒",price=0,kind="skin",effect="Troque 3 cogumelos + 1 fragmento de mapa por uma aparência exclusiva. Sem bônus de capacidade."},
    caveHint={vendor="Nilo",name="Segredo das pedras azuis",icon="🪨",price=0,kind="hint",effect="Troque 1 cogumelo por uma pista da caverna. Compra única."},
}
for id,p in pairs(products) do C.Products[id]=p end
C.Order={Guto={"backpack1","backpack2","backpack3","backpack4","backpack5"},Lia={"lantern","compass","marker","kit"},Teca={"sellFlower","tradeKit","contract"},Nilo={"gnomeQuest","gnomeSkin","caveHint"}}
function C.capacity(base,level)
    local b=C.Backpacks[level]
    return base+(b and b.bonus or 0)
end
return C
