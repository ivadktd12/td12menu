--[[
TD12 - Simulador Local com Menu
Autor: ivadktd12

Este código implementa um simulador local em Lua com menu customizado.
Não acessa memória externa ou jogos multiplayer.

INSTRUÇÕES DE EXECUÇÃO:
- Requer LÖVE2D (love2d.org) para rodar este arquivo.
- Salve como 'main.lua' e execute com o comando: love .
- Pressione 'Insert' para abrir/fechar o menu TD12.
]]

local json = require("dkjson") -- Requer dkjson.lua na pasta do projeto ou substitua por outra lib/json

-- ======== VARIÁVEIS ========
local menu = {
    aberto = false,
    corFundo = {0, 0.7, 0, 0.95},
    abas = {"Visual", "Movimento", "Estado", "Config", "Sobre/Ética"},
    abaSelecionada = 1,
    largura = 600, altura = 420,
    x = 80, y = 60,
    rodape = "TD12 — Pressione Insert para abrir/fechar o menu.",
}

local config = {
    espAtivo = true,
    vooAtivo = false,
    vooVelocidade = 120,
    imortalidade = false,
    regenTaxa = 20,
    moveSpeed = 100,
    cameraLivre = false,
    preset = {},
}

local entidades = {}
local player = {x=400, y=300, z=0, r=20, hp=100, maxhp=100, nome="Player", cor={0,0.4,1}, tipo="player"}
local npcs = {}
local pontosTeleporte = {
    {nome="Centro", x=400, y=300}, {nome="Canto Esquerdo", x=60, y=60}, {nome="Canto Direito", x=740, y=540}
}
local camera = {x=0, y=0, livre=false}
local simulador = {tempo=0, largura=800, altura=600}
local espCores = {player={0,1,0,1}, npc={1,0.5,0,1}}
local entidadeID = 0

-- ======== INICIALIZAÇÃO ========
function love.load()
    love.window.setTitle("TD12 - Simulador Local")
    love.window.setMode(simulador.largura, simulador.altura)
    inicializaEntidades()
end

function inicializaEntidades()
    entidades = {}
    npcs = {}
    table.insert(entidades, player)
    for i=1,6 do
        local ang = math.rad(i*60)
        local npc = {
            x = 400 + math.cos(ang)*180 + math.random(-40,40),
            y = 300 + math.sin(ang)*120 + math.random(-30,30),
            z = 0,
            r = 16,
            hp = 100,
            maxhp = 100,
            nome = "NPC_" .. i,
            cor = {1,0.4,0},
            tipo = "npc",
            id = entidadeID
        }
        entidadeID = entidadeID + 1
        table.insert(entidades, npc)
        table.insert(npcs, npc)
    end
end

-- ======== DESENHO ========
function love.draw()
    desenhaSimulador()
    if menu.aberto then desenhaMenu() end
    desenhaRodape()
end

function desenhaSimulador()
    love.graphics.setBackgroundColor(0.18,0.18,0.21)
    for _,ent in ipairs(entidades) do
        love.graphics.setColor(ent.cor)
        love.graphics.circle("fill", ent.x - camera.x, ent.y - camera.y, ent.r)
        love.graphics.setColor(1,1,1)
        love.graphics.rectangle("fill", ent.x - camera.x - ent.r, ent.y - camera.y - ent.r - 10, ent.r*2, 5)
        love.graphics.setColor(0,1,0)
        love.graphics.rectangle("fill", ent.x - camera.x - ent.r, ent.y - camera.y - ent.r - 10, (ent.hp/ent.maxhp)*ent.r*2, 5)
    end
    if menu.aberto and menu.abaSelecionada == 1 and config.espAtivo then
        for _,ent in ipairs(entidades) do
            local cor = espCores[ent.tipo] or {1,1,1,1}
            love.graphics.setColor(cor)
            love.graphics.rectangle("line", ent.x - camera.x - ent.r-4, ent.y - camera.y - ent.r-4, ent.r*2+8, ent.r*2+8)
            love.graphics.setColor(1,1,1)
            love.graphics.print(ent.nome, ent.x - camera.x - ent.r, ent.y - camera.y - ent.r - 22)
        end
    end
end

function desenhaMenu()
    love.graphics.setColor(menu.corFundo)
    love.graphics.rectangle("fill", menu.x, menu.y, menu.largura, menu.altura, 12, 12)
    love.graphics.setColor(1,1,1)
    love.graphics.setFont(love.graphics.newFont(22))
    love.graphics.print("TD12", menu.x+24, menu.y+15)
    love.graphics.setFont(love.graphics.newFont(14))
    for i,aba in ipairs(menu.abas) do
        local cor = i == menu.abaSelecionada and {1,1,1} or {0.7,0.8,0.7}
        love.graphics.setColor(cor)
        love.graphics.rectangle("fill", menu.x+24 + (i-1)*110, menu.y+60, 102, 28, 7,7)
        love.graphics.setColor(0,0.3,0)
        love.graphics.print(aba, menu.x+36 + (i-1)*110, menu.y+68)
    end
    local x0, y0 = menu.x+32, menu.y+100
    if menu.abaSelecionada == 1 then desenhaAbaVisual(x0, y0)
    elseif menu.abaSelecionada == 2 then desenhaAbaMovimento(x0, y0)
    elseif menu.abaSelecionada == 3 then desenhaAbaEstado(x0, y0)
    elseif menu.abaSelecionada == 4 then desenhaAbaConfig(x0, y0)
    elseif menu.abaSelecionada == 5 then desenhaAbaSobreEtica(x0, y0) end
end

function desenhaAbaVisual(x,y)
    love.graphics.setColor(1,1,1)
    love.graphics.print("Simulação ESP:", x, y)
    desenhaToggle(x+150, y, "ESP Ativo", config.espAtivo, function(val) config.espAtivo=val end)
    love.graphics.print("Caixas e nomes desenhados para todos jogadores/NPCs.", x, y+30)
    love.graphics.print("Jogadores: Verde | NPCs: Laranja", x, y+55)
end

function desenhaAbaMovimento(x,y)
    love.graphics.setColor(1,1,1)
    desenhaToggle(x, y, "Ativar Voo", config.vooAtivo, function(val) config.vooAtivo=val end)
    desenhaSlider(x+200, y, "Velocidade Voo", config.vooVelocidade, 30, 350, function(val) config.vooVelocidade=val end)
    desenhaSlider(x, y+40, "Velocidade Movimento", config.moveSpeed, 40, 280, function(val) config.moveSpeed=val end)
    love.graphics.print("Teleporte para pontos:", x, y+90)
    for i,ponto in ipairs(pontosTeleporte) do
        desenhaBotao(x+20 + (i-1)*130, y+120, 120, 28, ponto.nome, function() player.x, player.y = ponto.x, ponto.y end)
    end
    desenhaBotao(x, y+160, 140, 28, "Spawn Entidade Teste", spawnEntidadeTeste)
    desenhaToggle(x+160, y+160, "Câmera Livre", config.cameraLivre, function(val) config.cameraLivre=val; camera.livre=val end)
end

function desenhaAbaEstado(x,y)
    desenhaToggle(x, y, "Imortalidade", config.imortalidade, function(val) config.imortalidade=val end)
    desenhaSlider(x+200, y, "Taxa Regeneração", config.regenTaxa, 2, 80, function(val) config.regenTaxa=val end)
    love.graphics.print("HP do player será regenerado automaticamente.", x, y+38)
end

function desenhaAbaConfig(x,y)
    desenhaBotao(x, y, 140, 28, "Salvar Configuração", salvarConfig)
    desenhaBotao(x+160, y, 140, 28, "Carregar Configuração", carregarConfig)
    desenhaBotao(x, y+40, 140, 28, "Salvar Preset", salvarPreset)
    desenhaBotao(x+160, y+40, 140, 28, "Carregar Preset", carregarPreset)
end

function desenhaAbaSobreEtica(x,y)
    love.graphics.setColor(1,1,1)
    love.graphics.printf(
        "Projeto TD12 para simulador local.",
        x, y, menu.largura-64, "left")
end

function desenhaToggle(x, y, texto, valor, callback)
    love.graphics.setColor(valor and {0,0.8,0} or {0.6,0.1,0.1})
    love.graphics.rectangle("fill", x, y, 22, 22, 7,7)
    love.graphics.setColor(1,1,1)
    love.graphics.print(texto, x+30, y+2)
    if mouseSobre(x,y,22,22) and love.mouse.isDown(1) then callback(not valor) end
end

function desenhaSlider(x, y, texto, valor, min, max, callback)
    local largura = 100
    love.graphics.setColor(0.4,0.4,0.6)
    love.graphics.rectangle("fill", x, y+18, largura, 8, 5,5)
    local pos = ((valor-min)/(max-min))*largura
    love.graphics.setColor(1,1,1)
    love.graphics.rectangle("fill", x+pos-4, y+14, 8, 16, 5,5)
    love.graphics.print(texto..": "..math.floor(valor), x, y)
    if mouseSobre(x, y+18, largura, 20) and love.mouse.isDown(1) then
        local mx = love.mouse.getX() - x
        mx = math.max(0, math.min(mx, largura))
        callback(min + (mx/largura)*(max-min))
    end
end

function desenhaBotao(x, y, w, h, texto, callback)
    local sobre = mouseSobre(x,y,w,h)
    love.graphics.setColor(sobre and {0,0.7,0.4} or {0.2,0.5,0.2})
    love.graphics.rectangle("fill", x, y, w, h, 7,7)
    love.graphics.setColor(1,1,1)
    love.graphics.print(texto, x+12, y+7)
    if sobre and love.mouse.isDown(1) then callback() end
end

function desenhaRodape()
    love.graphics.setColor(0,0,0,0.4)
    love.graphics.rectangle("fill", 0, simulador.altura-28, simulador.largura, 28)
    love.graphics.setColor(1,1,1)
    love.graphics.setFont(love.graphics.newFont(13))
    love.graphics.print(menu.rodape, 18, simulador.altura-22)
end

function mouseSobre(x,y,w,h)
    local mx, my = love.mouse.getX(), love.mouse.getY()
    return mx>=x and mx<=x+w and my>=y and my<=y+h
end

-- ======== ATUALIZAÇÃO ========
function love.update(dt)
    simulador.tempo = simulador.tempo + dt
    for _,npc in ipairs(npcs) do
        npc.x = npc.x + math.sin(simulador.tempo + npc.id)*1.3 + (math.random()-0.5)*2
        npc.y = npc.y + math.cos(simulador.tempo + npc.id*0.5)*1.1 + (math.random()-0.5)*2
    end
    if config.imortalidade then
        player.hp = math.min(player.maxhp, player.hp + dt*config.regenTaxa)
    end
    if config.vooAtivo then
        if love.keyboard.isDown("w") then player.z = player.z + dt*config.vooVelocidade end
        if love.keyboard.isDown("s") then player.z = math.max(0, player.z - dt*config.vooVelocidade) end
    else
        player.z = 0
    end
    local move = config.moveSpeed * dt
    if not config.cameraLivre then
        if love.keyboard.isDown("left") or love.keyboard.isDown("a") then player.x = player.x - move end
        if love.keyboard.isDown("right") or love.keyboard.isDown("d") then player.x = player.x + move end
        if love.keyboard.isDown("up") or love.keyboard.isDown("w") then player.y = player.y - move end
        if love.keyboard.isDown("down") or love.keyboard.isDown("s") then player.y = player.y + move end
    else
        if love.keyboard.isDown("left") then camera.x = camera.x - move end
        if love.keyboard.isDown("right") then camera.x = camera.x + move end
        if love.keyboard.isDown("up") then camera.y = camera.y - move end
        if love.keyboard.isDown("down") then camera.y = camera.y + move end
    end
end

-- ======== MENU E ENTRADA ========
function love.keypressed(key)
    if key == "insert" then menu.aberto = not menu.aberto end
    if menu.aberto then
        if key == "right" then menu.abaSelecionada = math.min(menu.abaSelecionada + 1, #menu.abas)
        elseif key == "left" then menu.abaSelecionada = math.max(menu.abaSelecionada - 1, 1) end
    end
end

function love.mousepressed(x, y, button)
    if menu.aberto and button == 1 then
        for i=1,#menu.abas do
            local bx,by,bw,bh = menu.x+24+(i-1)*110, menu.y+60, 102, 28
            if mouseSobre(bx,by,bw,bh) then menu.abaSelecionada = i end
        end
    end
end

-- ======== SIMULADOR E CONFIG ========
function spawnEntidadeTeste()
    local e = {
        x = math.random(80,simulador.largura-80),
        y = math.random(80,simulador.altura-80),
        z = 0,
        r = 12,
        hp = 100,
        maxhp = 100,
        nome = "Teste_"..entidadeID,
        cor = {0.6,0.2,1},
        tipo = "npc",
        id = entidadeID
    }
    entidadeID = entidadeID + 1
    table.insert(entidades, e)
    table.insert(npcs, e)
end

function salvarConfig()
    local arq = love.filesystem.newFile("td12_config.json", "w")
    arq:write(json.encode(config, {indent=true}))
    arq:close()
end

function carregarConfig()
    if love.filesystem.getInfo("td12_config.json") then
        local arq = love.filesystem.newFile("td12_config.json", "r")
        arq:open("r")
        local conteudo = arq:read()
        arq:close()
        local obj, pos, err = json.decode(conteudo)
        if obj then for k,v in pairs(obj) do config[k] = v end end
    end
end

function salvarPreset()
    config.preset = {}
    for k,v in pairs(config) do
        if type(v)~="table" or k=="preset" then config.preset[k] = v end
    end
    local arq = love.filesystem.newFile("td12_preset.json", "w")
    arq:write(json.encode(config.preset, {indent=true}))
    arq:close()
end

function carregarPreset()
    if love.filesystem.getInfo("td12_preset.json") then
        local arq = love.filesystem.newFile("td12_preset.json", "r")
        arq:open("r")
        local conteudo = arq:read()
        arq:close()
        local obj, pos, err = json.decode(conteudo)
        if obj then
            for k,v in pairs(obj) do config[k] = v end
        end
    end
end
