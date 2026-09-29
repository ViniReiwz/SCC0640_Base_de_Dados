-- Item a) =====================================================================================

SELECT P.PedidoID, P.DATA_PED, C.NomeC, R.NomeR FROM PEDIDOS P
JOIN CLIENTES C ON C.ClienteID = P.ClienteID
JOIN RESTAURANTES R ON R.RestauranteID = P.RestID
WHERE P.status_ped = 'Entregue';

-- =============================================================================================

-- Item b) =====================================================================================

SELECT C.NomeC, COUNT(P.PedidoID) AS num_ped, R.NomeR FROM CLIENTES C
LEFT JOIN PEDIDOS P ON P.ClienteID = C.ClienteID
LEFT JOIN RESTAURANTES R ON R.RestauranteID = P.RestID
GROUP BY C.ClienteID, R.NomeR;

-- =============================================================================================