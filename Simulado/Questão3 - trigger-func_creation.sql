-- Cria a função para verificar se a data da entrega é condizente
CREATE OR REPLACE FUNCTION verifica_entrega()
RETURNS TRIGGER AS $$
    DECLARE data_ped DATE;  -- Uso de variável, declara a variável data_ped do tipo DATE
    BEGIN
        -- Seleciona a data e a atribui a data_ped de acordo com o poedido do ID
        SELECT P.DATA_PED INTO data_ped FROM PEDIDOS P WHERE P.PedidoID = NEW.PedidoID;

        IF data_ped > NEW.DataEntrega THEN 
            NEW.DataEntrega := data_ped;    -- Atribuição é feita com ':='
        END IF;
    RETURN NEW;
    END;
$$ LANGUAGE plpgsql;

-- Cria o trigger que executa sempre antes da inserção em entrega pedido e verifica os dados
CREATE TRIGGER tr_verifica_entr BEFORE INSERT ON ENTREGA_PEDIDO
    FOR EACH ROW EXECUTE FUNCTION verifica_entrega();
