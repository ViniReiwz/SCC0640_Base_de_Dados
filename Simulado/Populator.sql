-- Arquivo simples para popular o banco de dados e fazer os testes (feito por ia generateiva)

-- =========================
-- CLIENTES
-- =========================

INSERT INTO CLIENTES (NomeC, Email, Cidade) VALUES
('Joao Silva', 'joao@email.com', 'Sao Carlos'),
('Maria Souza', 'maria@email.com', 'Araraquara'),
('Pedro Santos', 'pedro@email.com', 'Sao Paulo'),
('Ana Oliveira', 'ana@email.com', 'Campinas'),
('Lucas Lima', 'lucas@email.com', 'Ribeirao Preto');


-- =========================
-- RESTAURANTES
-- =========================

INSERT INTO RESTAURANTES (NomeR, Categoria, TaxaEntrega) VALUES
('Sabor Caseiro', 'Brasileira', 8.50),
('Pizza Mania', 'Pizzaria', 10.00),
('Burger House', 'Hamburgueria', 7.50),
('Temaki Sushi', 'Japonesa', 12.00),
('Cantina Italiana', 'Italiana', 9.00);


-- =========================
-- ENTREGADORES
-- =========================

INSERT INTO ENTREGADORES (NomeE, Veiculo, Placa) VALUES
('Carlos Mendes', 'Moto', 'ABC1234'),
('Fernanda Alves', 'Bicicleta', NULL),
('Rafael Costa', 'Carro', 'DEF5678'),
('Bruno Martins', 'Moto', 'GHI9012'),
('Juliana Rocha', 'Bicicleta', NULL);


-- =========================
-- PEDIDOS
-- =========================

INSERT INTO PEDIDOS
    (ClienteID, RestID, DATA_PED, STATUS_PED)
VALUES
    (1, 1, '2026-09-20', 'Entregue'),
    (2, 2, '2026-09-21', 'Entregue'),
    (3, 3, '2026-09-21', 'Em preparo'),
    (4, 4, '2026-09-22', 'Recebido'),
    (5, 5, '2026-09-22', 'Cancelado'),
    (1, 2, '2026-09-23', 'Entregue'),
    (2, 3, '2026-09-23', 'Entregue'),
    (3, 1, '2026-09-24', 'Cancelado');


-- =========================
-- ENTREGA_PEDIDO
-- =========================

INSERT INTO ENTREGA_PEDIDO
    (PedidoID, EntregadorID, DataEntrega)
VALUES
    (1, 1, '2026-09-20'),
    (2, 2, '2026-09-21'),
    (6, 3, '2026-09-23'),
    (7, 4, '2026-09-23'),
    (8, 1, '2026-09-24');