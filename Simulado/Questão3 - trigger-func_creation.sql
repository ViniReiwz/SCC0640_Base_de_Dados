CREATE OR REPLACE FUNCTION verifica_entrega()
RETURNS TRIGGER AS $$
    DECLARE data_ped DATE;
    BEGIN
        SELECT P.DATA_PED INTO data_ped FROM PEDIDOS P WHERE P.PedidoID = NEW.PedidoID;

        IF data_ped > NEW.DataEntrega THEN 
            NEW.DataEntrega := data_ped;
        END IF;
    RETURN NEW;
    END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER tr_verifica_entr BEFORE INSERT ON ENTREGA_PEDIDO
    FOR EACH ROW EXECUTE FUNCTION verifica_entrega();
