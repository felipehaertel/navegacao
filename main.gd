extends Node2D

const ESTADO_LIVRE: int = 0
const ESTADO_OCUPADO: int = 1
const CUSTO_DIAGONAL: float = 1.414 
const CUSTO_RETO: float = 1.0

@export var tamanho_celula: int = 64
@export var cor_linha: Color = Color.GRAY
@export var cor_ocupada: Color = Color.WHITE
@export var cor_origem: Color = Color.BLUE
@export var cor_destino: Color = Color.GREEN
@export var espessura_linha: float = 1.0
@export var margem_simbolo: float = 4.0

var origem_agente: Vector2i = Vector2i(-1, -1)  
var destino_agente: Vector2i = Vector2i(-1, -1) 

var pares_clicados: Array = []
var proximo_clique_e_origem: bool = true

var num_celulas_x: int = 0
var num_celulas_y: int = 0
var grid: Array = [] 
var agentes: Array = [] 
var contador_agente: int = 0

var resolucao_tela_x: int = 0
var resolucao_tela_y: int = 0

func _ready():
	var viewport_size = get_viewport_rect().size
	resolucao_tela_x = int(viewport_size.x)
	resolucao_tela_y = int(viewport_size.y)
	
	criar_grid()
	queue_redraw() 

func criar_grid():
	num_celulas_x = int(resolucao_tela_x / tamanho_celula)
	num_celulas_y = int(resolucao_tela_y / tamanho_celula)
	
	grid.clear()
	for y in range(num_celulas_y):
		var linha: Array = []
		for x in range(num_celulas_x):
			linha.append(0) 
		grid.append(linha)

func _draw():
	for x in range(num_celulas_x + 1):
		var inicio = Vector2(x * tamanho_celula, 0)
		var fim = Vector2(x * tamanho_celula, num_celulas_y * tamanho_celula) 
		
		draw_line(inicio, fim, cor_linha, espessura_linha)

	for y in range(num_celulas_y + 1):
		var inicio = Vector2(0, y * tamanho_celula)
		var fim = Vector2(num_celulas_x * tamanho_celula, y * tamanho_celula)
		
		draw_line(inicio, fim, cor_linha, espessura_linha)
		
	for y in range(num_celulas_y):
		for x in range(num_celulas_x):
			if grid[y][x] == ESTADO_OCUPADO:
				var rect = Rect2(x * tamanho_celula, y * tamanho_celula, tamanho_celula, tamanho_celula)
				draw_rect(rect, cor_ocupada)
				
	if origem_agente != Vector2i(-1, -1):
		desenhar_celula_especial(origem_agente, cor_origem)
		
	if destino_agente != Vector2i(-1, -1):
		desenhar_celula_especial(destino_agente, cor_destino)

	var cor_caminho: Color = Color.YELLOW
	var metade_celula = Vector2(tamanho_celula / 2.0, tamanho_celula / 2.0)
		
	var raio_agente: float = tamanho_celula / 3.0 # Agente tem 1/3 do tamanho da célula
	
	for agente in agentes:
		if agente.caminho_a_seguir.size() > 0:
			var ponto_anterior: Vector2 = Vector2(agente.posicao_grid) * tamanho_celula + metade_celula
			
			for i in range(agente.indice_passo, agente.caminho_a_seguir.size()):
				var ponto_atual: Vector2 = Vector2(agente.caminho_a_seguir[i]) * tamanho_celula + metade_celula
				draw_line(ponto_anterior, ponto_atual, cor_caminho, 3.0, true)
				ponto_anterior = ponto_atual
		draw_circle(agente.posicao_pixel_atual, raio_agente, Color.from_hsv(agente.id * 0.1, 0.8, 1.0))
		
	for i in range(pares_clicados.size()):
		var coord = pares_clicados[i]
		var cor: Color
		
		if i % 2 == 0: # Índice 0, 2, 4... (Origem)
			cor = cor_origem
		else: # Índice 1, 3, 5... (Destino)
			cor = cor_destino
			
		desenhar_celula_especial(coord, cor)
						
func pixel_para_grid_coord(posicao_pixel: Vector2) -> Vector2i:
	var grid_x = floor(posicao_pixel.x / tamanho_celula)
	var grid_y = floor(posicao_pixel.y / tamanho_celula)
	return Vector2i(grid_x, grid_y)

func _unhandled_input(event):
	var mouse_pos = get_global_mouse_position() 
	var grid_coord = pixel_para_grid_coord(mouse_pos)
	var x = grid_coord.x
	var y = grid_coord.y

	if not (x >= 0 and x < num_celulas_x and y >= 0 and y < num_celulas_y):
		return
	
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		
		if grid[y][x] == ESTADO_LIVRE:
			grid[y][x] = ESTADO_OCUPADO
			if origem_agente == grid_coord: origem_agente = Vector2i(-1, -1)
			if destino_agente == grid_coord: destino_agente = Vector2i(-1, -1)
		else:
			grid[y][x] = ESTADO_LIVRE
			
		queue_redraw()
		get_viewport().set_input_as_handled()
	
	elif event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_RIGHT:
		
		if grid[y][x] == ESTADO_OCUPADO:
			print("Não é possível definir Origem/Destino em um obstáculo.")
			return
		
		# Adiciona a coordenada à lista
		pares_clicados.append(grid_coord)
		
		if proximo_clique_e_origem:
			print("Origem %d definida em: %s (Próximo: Destino)" % [pares_clicados.size() / 2 + 1, grid_coord])
		else:
			print("Destino %d definido em: %s (Próximo: Origem)" % [pares_clicados.size() / 2, grid_coord])

		# Alterna o estado para o próximo clique
		proximo_clique_e_origem = not proximo_clique_e_origem
		
		queue_redraw()
		get_viewport().set_input_as_handled()
		
func desenhar_celula_especial(coord: Vector2i, cor: Color):
	var x = coord.x
	var y = coord.y
	
	var rect = Rect2(x * tamanho_celula, y * tamanho_celula, tamanho_celula, tamanho_celula)
	var rect_menor = rect.grow(-margem_simbolo)
	draw_rect(rect_menor, cor)
	
class No:
	var g_custo: float = INF   # Custo do início (Origem) até este nó.
	var h_custo: float = 0.0   # Custo heurístico (estimativa) até o destino.
	var f_custo: float = INF   # Custo total: F = G + H
	var coord: Vector2i        # Posição (x, y) no grid.
	var pai: No = null         # O nó anterior no caminho.

	func _init(c: Vector2i):
		coord = c
		
class Agente:
	var id: int
	var posicao_grid: Vector2i # Coordenada atual do Agente (Origem)
	var caminho_a_seguir: Array = [] # Lista de Vector2i (os passos)
	var indice_passo: int = 0      # Índice do caminho_a_seguir
	var velocidade: float = 4.0   # Velocidade de movimento (células por segundo)
	var posicao_pixel_atual: Vector2 # Posição real em pixels para movimento suave

	func _init(origem: Vector2i, novo_id: int):
		id = novo_id
		posicao_grid = origem
		posicao_pixel_atual = Vector2(origem) * 32.0 # Usamos 32.0 como tamanho_celula inicial

func calcular_heuristica(a: Vector2i, b: Vector2i) -> float:
	return a.distance_to(b)

func encontrar_menor_custo_f(lista_aberta: Array) -> No:
	var menor_f = INF
	var melhor_no = null
	
	for no in lista_aberta:
		if no.f_custo < menor_f:
			menor_f = no.f_custo
			melhor_no = no
	
	return melhor_no

func recriar_caminho(no_destino: No) -> Array:
	var caminho_reverso: Array = []
	var atual: No = no_destino
	
	while atual != null:
		caminho_reverso.append(atual.coord)
		atual = atual.pai
	
	caminho_reverso.reverse()
	if caminho_reverso.size() > 0:
		caminho_reverso.remove_at(0)
		
	return caminho_reverso

func encontrar_caminho_para(inicio: Vector2i, fim: Vector2i) -> Array:
	
	if inicio == Vector2i(-1, -1) or fim == Vector2i(-1, -1):
		print("Defina Origem e Destino primeiro.")
		return []

	if inicio == fim:
		print("Origem e Destino são o mesmo ponto.")
		return []

	var lista_aberta: Array = [] 
	var lista_fechada: Array = [] 
	var no_mapa: Dictionary = {} 

	var no_origem = No.new(inicio)
	no_origem.g_custo = 0.0
	no_origem.h_custo = calcular_heuristica(inicio, fim)
	no_origem.f_custo = no_origem.h_custo
	lista_aberta.append(no_origem)
	no_mapa[inicio] = no_origem

	while not lista_aberta.is_empty():
		var atual: No = encontrar_menor_custo_f(lista_aberta)
		
		lista_aberta.erase(atual)
		lista_fechada.append(atual)
		
		if atual.coord == fim:
			var temp_caminho = recriar_caminho(atual)
			print("Caminho encontrado! Número de passos: ", temp_caminho.size())
			return temp_caminho

		for dx in range(-1, 2):
			for dy in range(-1, 2):
				if dx == 0 and dy == 0:
					continue 
				
				var vizinho_coord = atual.coord + Vector2i(dx, dy)
				
				if vizinho_coord.x < 0 or vizinho_coord.x >= num_celulas_x or \
				   vizinho_coord.y < 0 or vizinho_coord.y >= num_celulas_y:
					continue

				if grid[vizinho_coord.y][vizinho_coord.x] == ESTADO_OCUPADO:
					continue
				
				var custo_movimento = CUSTO_RETO if dx == 0 or dy == 0 else CUSTO_DIAGONAL
				var no_vizinho: No
				
				if not no_mapa.has(vizinho_coord):
					no_vizinho = No.new(vizinho_coord)
					no_mapa[vizinho_coord] = no_vizinho
				else:
					no_vizinho = no_mapa[vizinho_coord]

				if no_vizinho in lista_fechada:
					continue

				var novo_g_custo = atual.g_custo + custo_movimento

				if novo_g_custo < no_vizinho.g_custo or no_vizinho.g_custo == INF:
					no_vizinho.g_custo = novo_g_custo
					no_vizinho.h_custo = calcular_heuristica(vizinho_coord, fim)
					no_vizinho.f_custo = no_vizinho.g_custo + no_vizinho.h_custo
					no_vizinho.pai = atual
					
					if not no_vizinho in lista_aberta:
						lista_aberta.append(no_vizinho)

	print("Caminho NÃO encontrado!")
	return []

func _process(delta):
	for agente in agentes:
		mover_agente(agente, delta)
	
	if agentes.size() > 0:
		queue_redraw()
		
	if Input.is_action_just_pressed("ui_accept"): 
		print("--- Ativando Agentes em Lote (SPACE) ---")
		ativar_agentes_em_lote()
		
	if Input.is_action_just_pressed("gerar_aleatorios"):
		print("--- Gerando Agentes Aleatórios (A) ---")
		gerar_agentes_aleatorios(randi_range(2, 10))

func mover_agente(agente: Agente, delta: float):
	if agente.caminho_a_seguir.is_empty():
		return
	
	var proxima_coord = agente.caminho_a_seguir[agente.indice_passo]
	
	var centro_proximo_passo = Vector2(proxima_coord) * tamanho_celula + Vector2(tamanho_celula / 2.0, tamanho_celula / 2.0)
	
	var distancia_a_percorrer = agente.velocidade * tamanho_celula * delta
	
	var vetor_movimento = (centro_proximo_passo - agente.posicao_pixel_atual).normalized() * distancia_a_percorrer
	
	if agente.posicao_pixel_atual.distance_to(centro_proximo_passo) <= vetor_movimento.length():
		agente.posicao_pixel_atual = centro_proximo_passo
		agente.indice_passo += 1
		
		if agente.indice_passo >= agente.caminho_a_seguir.size():
			agente.caminho_a_seguir.clear()
			agente.indice_passo = 0
			agente.posicao_grid = proxima_coord
		else:
			agente.posicao_grid = proxima_coord
	else:
		agente.posicao_pixel_atual += vetor_movimento

func ativar_agentes_em_lote():
	# Verifica se há um número ímpar de cliques (um par incompleto)
	if pares_clicados.size() % 2 != 0:
		print("Erro: Clique em um ponto de Destino para completar o último par (Origem %d)." % (pares_clicados.size() / 2 + 1))
		return
	
	if pares_clicados.is_empty():
		print("Nenhuma Origem/Destino definido para criar agentes.")
		return
		
	# Processa os pares e cria os agentes
	for i in range(0, pares_clicados.size(), 2):
		var origem_lote = pares_clicados[i]
		var destino_lote = pares_clicados[i+1]

		# CORREÇÃO: Chama a função auxiliar que agora existe
		var sucesso = criar_e_ativar_agente(origem_lote, destino_lote)
		
		if not sucesso:
			print("Não foi possível encontrar uma rota de %s para %s. Agente não criado." % [origem_lote, destino_lote])


	# Limpa o estado após a criação
	pares_clicados.clear()
	proximo_clique_e_origem = true
	queue_redraw()

func gerar_agentes_aleatorios(quantidade: int):
	agentes.clear()
	contador_agente = 0
	
	for i in range(quantidade):
		var origem_aleatoria: Vector2i = Vector2i()
		var destino_aleatorio: Vector2i = Vector2i()
		var caminho_encontrado: Array = []
		
		var tentativas = 0
		while tentativas < 100:
			origem_aleatoria = Vector2i(randi_range(0, num_celulas_x - 1), randi_range(0, num_celulas_y - 1))
			destino_aleatorio = Vector2i(randi_range(0, num_celulas_x - 1), randi_range(0, num_celulas_y - 1))
			
			if grid[origem_aleatoria.y][origem_aleatoria.x] == ESTADO_LIVRE and \
			   grid[destino_aleatorio.y][destino_aleatorio.x] == ESTADO_LIVRE and \
			   origem_aleatoria != destino_aleatorio:
				
				caminho_encontrado = encontrar_caminho_para(origem_aleatoria, destino_aleatorio)
				
				if not caminho_encontrado.is_empty():
					criar_e_ativar_agente(origem_aleatoria, destino_aleatorio)
					break
					
			tentativas += 1
		
		if tentativas == 100:
			print("Alerta: Não foi possível gerar o Agente #%d com rota válida." % (i + 1))
	
	randomize()

func criar_e_ativar_agente(spawn_coord: Vector2i, target_coord: Vector2i):
	
	if spawn_coord == Vector2i(-1, -1) or target_coord == Vector2i(-1, -1):
		# Esta checagem é mais relevante para o modo manual (batch)
		return
	
	# 1. Calcula o caminho (Pathfinding)
	var caminho_encontrado = encontrar_caminho_para(spawn_coord, target_coord)
	
	if caminho_encontrado.is_empty():
		return false # Retorna falso se a rota falhar
	
	# 2. Cria o Agente
	contador_agente += 1
	var novo_agente = Agente.new(spawn_coord, contador_agente)
	novo_agente.caminho_a_seguir = caminho_encontrado
	
	# Ajusta a posição de pixels inicial para o centro da célula
	novo_agente.posicao_pixel_atual = Vector2(spawn_coord) * tamanho_celula + Vector2(tamanho_celula / 2.0, tamanho_celula / 2.0)
	
	agentes.append(novo_agente)
	print("Agente #%d criado (O: %s -> D: %s). Rota com %d passos." % [contador_agente, spawn_coord, target_coord, caminho_encontrado.size()])
	return true
