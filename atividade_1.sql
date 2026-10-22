--tabelas
create table clientes (
id serial primary key,
nome VARCHAR(100) not null,
total_compras numeric(10, 2) default 0.00
);

create table pedidos (
id serial primary key,
cliente_id int not null,
valor_total numeric(10, 2) not null,
data_pedido TIMESTAMP DEFAULT current_timestamp,

foreign key (cliente_id) references clientes(id) on delete cascade
);

--funcoes
CREATE OR REPLACE FUNCTION fn_atualiza_total_cliente()
RETURNS TRIGGER AS $$
DECLARE
    v_cliente_id INT;
BEGIN
    IF (TG_OP = 'DELETE') THEN
        v_cliente_id := OLD.cliente_id;
		    UPDATE clientes
    SET total_compras = COALESCE((
        SELECT SUM(valor_total) 
        FROM pedidos 
        WHERE cliente_id = v_cliente_id
    ), 0.00)
    WHERE id = v_cliente_id;
    ELSE
        v_cliente_id := NEW.cliente_id;
		  UPDATE clientes
        SET total_compras = COALESCE((
            SELECT SUM(valor_total) 
            FROM pedidos 
            WHERE cliente_id = OLD.cliente_id
        ), 0.00)
        WHERE id = OLD.cliente_id;
    END IF;
	  RETURN NULL; 
END;

$$ LANGUAGE plpgsql;

--2
CREATE TRIGGER trg_atualiza_total_pedidos
AFTER INSERT OR UPDATE OR DELETE ON pedidos
FOR EACH ROW
EXECUTE FUNCTION fn_atualiza_total_cliente();

--inserts
INSERT INTO clientes (nome) VALUES ('Roberto Carlos'), ('Ana Maria Braga');
INSERT INTO clientes (nome) VALUES ('Paulo Antunes'), ('Ana Souza');

INSERT INTO pedidos (cliente_id, valor_total) VALUES (1, 150.00);
INSERT INTO pedidos (cliente_id, valor_total) VALUES (1, 50.00);
INSERT INTO pedidos (cliente_id, valor_total) VALUES (2, 300.00);

UPDATE pedidos SET valor_total = 100.00 WHERE id = 2;

DELETE FROM pedidos WHERE id = 1;