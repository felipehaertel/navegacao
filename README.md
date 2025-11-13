# ***🚀 A (A-Star) Pathfinding Grid Simulator \- Godot 4.x*****\***

Repositório dedicado à visualização e análise de desempenho do algoritmo de busca de caminho **A\* (A-Star)** em um ambiente de grid 2D interativo. O projeto permite configurar obstáculos, definir múltiplos agentes e extrair métricas de custo computacional.

## **✨ Recursos e Interação**

O projeto é executado como um simulador 2D onde o usuário pode interagir com o grid para definir o ambiente e acionar a simulação.

| Tecla / Evento | Ação | Descrição |
| ----- | ----- | ----- |
| **Clique Esquerdo (LMB)** | **Definir Obstáculo** | Alterna o estado da célula clicada entre **Livre** e **Ocupado (Branco)**. |
| **Clique Direito (RMB)** | **Definir Origem/Destino** | Alterna sequencialmente: 1º clique é **Origem (Azul)**, 2º clique é **Destino (Verde)**. Permite definir vários pares (O1, D1, O2, D2, etc.). |
| **SPACE** (`ui_accept`) | **Ativar Agentes em Lote** | Cria e ativa um agente para cada par (Origem $\\rightarrow$ Destino) definido pelo RMB. Os pares são apagados após a ativação. |
| **A** (`gerar_aleatorios`) | **Gerar Aleatórios** | Limpa a simulação atual e gera um número aleatório de agentes com rotas de Origem/Destino válidas e aleatórias. |
| **E** (`exportar_dados`) | **Exportar Dados CSV** | Salva as métricas de desempenho de todos os cálculos de A\* realizados desde o início da simulação. |

## **📐 Conceito Central: Algoritmo A\***

O A\* é um algoritmo de busca de caminho (pathfinding) que encontra a rota de menor custo entre um ponto inicial e um ponto final. Ele combina:

* **Custo G (Custo Real):** A distância percorrida do ponto inicial até o nó atual.  
* **Custo H (Heurística):** A distância estimada do nó atual até o ponto final (utilizamos a distância Euclidiana neste projeto).  
* **Custo F (Custo Total):** $F \= G \+ H$. O A\* sempre prioriza a exploração do nó com o menor custo F.

## **📊 Análise de Desempenho e Geração de Dados**

Ao pressionar a tecla **E** (Exportar Dados), o projeto gera o arquivo **`dados_custo_a_star.csv`** no diretório de usuário do Godot (`user://`).

Este arquivo é fundamental para a análise de desempenho do A\*, registrando o tempo que o algoritmo leva para calcular cada rota.

| Coluna | Descrição |
| ----- | ----- |
| **Agente\_ID** | Ordem de criação do agente na simulação. |
| **Tempo\_ms** | Tempo de execução (em milissegundos) do algoritmo `encontrar_caminho_para` para este agente. |
| **Passos\_Rota** | O número de células no caminho final encontrado. |
| **Distancia\_Reta** | Distância Euclidiana (em células) entre Origem e Destino. |
| Origem\_X/Y, Destino\_X/Y | Coordenadas do grid do início e fim da rota. |

### **Gráficos de Análise Sugeridos**

Com os dados em mãos, as seguintes análises de custo computacional podem ser feitas (usando ferramentas externas como Python/Pandas/Colab):

1. **Custo vs. Número de Agentes:**  
   * **Plotar:** `Tempo_ms` (Y) vs. `Agente_ID` (X).  
   * **Objetivo:** Verificar se o custo de cálculo de cada rota é independente do número total de agentes no sistema, demonstrando a natureza **isolada** do A\*.  
2. **Desempenho vs. Complexidade da Rota:**  
   * **Plotar:** `Tempo_ms` (Y) vs. `Distancia_Reta` (X).  
   * **Objetivo:** Observar se o tempo de cálculo aumenta em cenários de **"Labirinto"** (muitos obstáculos) em comparação com cenários **"Abertos"**, validando que a complexidade é determinada pelo número de nós explorados, e não apenas pela distância em linha reta.

## **⚙️ Como Rodar o Projeto**

1. **Pré-requisito:** Instale a Godot Engine 4.x (o projeto foi desenvolvido na versão 4.x).  
2. **Clone o Repositório:** `git clone [Insira o link do seu repositório aqui]`  
3. **Abra na Godot:** Importe a pasta clonada como um projeto na Godot Engine.  
4. **Execute:** Execute a cena principal (pressione F5).  
5. **Análise:** Pressione **E** para exportar os dados e utilize o notebook do Google Colab para plotar os gráficos de desempenho.

