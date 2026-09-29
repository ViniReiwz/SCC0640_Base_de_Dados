-- Arquivo para popular o banco de dados e testar as consultas

-- =========================
-- CLIENTES
-- =========================

INSERT INTO CLIENTES (NomeC, Email, Cidade) VALUES
('Joao Silva',     'joao@email.com',     'Sao Carlos'),
('Maria Souza',    'maria@email.com',    'Araraquara'),
('Pedro Santos',   'pedro@email.com',   'Sao Paulo'),
('Ana Oliveira',   'ana@email.com',      'Campinas'),
('Lucas Lima',     'lucas@email.com',    'Ribeirao Preto'),
('Carla Mendes',   'carla@email.com',    'Sao Carlos'),
('Paulo Rocha',    'paulo@email.com',    'Sao Paulo');


-- =========================
-- RESTAURANTES
-- =========================

INSERT INTO RESTAURANTES (NomeR, Categoria, TaxaEntrega) VALUES
('Sabor Caseiro',    'Brasileira',    8.50),
('Pizza Mania',      'Pizzaria',     10.00),
('Burger House',     'Hamburgueria',  7.50),
('Temaki Sushi',     'Japonesa',     12.00),
('Cantina Italiana', 'Italiana',      9.00),
('Veggie Life',      'Vegetariana',   6.50),
('Churrasco Gaucho', 'Churrascaria', 11.00);


-- =========================
-- ENTREGADORES
-- =========================

INSERT INTO ENTREGADORES (NomeE, Veiculo, Placa) VALUES
('Carlos Mendes',   'Moto',       'ABC1234'),
('Fernanda Alves',  'Bicicleta',  NULL),
('Rafael Costa',    'Carro',      'DEF5678'),
('Bruno Martins',   'Moto',       'GHI9012'),
('Juliana Rocha',   'Bicicleta',  NULL),
('Marcos Silva',    'Carro',      'JKL3456');


-- =========================
-- PEDIDOS
-- =========================

INSERT INTO PEDIDOS
    (ClienteID, RestID, DATA_PED, STATUS_PED)
VALUES

-- Joao:
-- 2 pedidos no Pizza Mania
-- 1 pedido no Sabor Caseiro
(1, 2, '2026-09-20', 'Entregue'),
(1, 2, '2026-09-21', 'Entregue'),
(1, 1, '2026-09-22', 'Entregue'),

-- Maria:
-- 2 pedidos no Burger House
-- 1 pedido no Pizza Mania
(2, 3, '2026-09-21', 'Entregue'),
(2, 3, '2026-09-23', 'Entregue'),
(2, 2, '2026-09-24', 'Recebido'),

-- Pedro:
-- pedidos em restaurantes diferentes
(3, 1, '2026-09-22', 'Cancelado'),
(3, 4, '2026-09-25', 'Entregue'),

-- Ana:
-- vários pedidos no mesmo restaurante
(4, 5, '2026-09-23', 'Entregue'),
(4, 5, '2026-09-26', 'Em preparo'),

-- Lucas:
-- apenas um pedido
(5, 4, '2026-09-24', 'Entregue');


-- Carla (ClienteID = 6)
-- NÃO possui nenhum pedido.


-- Paulo (ClienteID = 7)
-- NÃO possui nenhum pedido.


-- =========================
-- ENTREGA_PEDIDO
-- =========================

INSERT INTO ENTREGA_PEDIDO
    (PedidoID, EntregadorID, DataEntrega)
VALUES

-- Entregas de pedidos entregues
(1, 1, '2026-09-20'),
(2, 2, '2026-09-21'),
(3, 3, '2026-09-22'),
(4, 4, '2026-09-21'),
(5, 1, '2026-09-23'),
(8, 2, '2026-09-25'),
(9, 3, '2026-09-23'),
(11, 4, '2026-09-24'),

-- Pedido cancelado que chegou a ter entregador
-- útil para testar a consulta de entregadores
-- que entregaram pedidos cancelados
(7, 1, '2026-09-22');