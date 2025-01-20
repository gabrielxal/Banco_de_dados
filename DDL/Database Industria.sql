CREATE DATABASE industria;
USE industria;

-- Tabela para funcionários
CREATE TABLE funcionarios (
    id_funcionario INT NOT NULL AUTO_INCREMENT,
    nome_funcionario VARCHAR(100) NOT NULL,
    cargo VARCHAR(50) NOT NULL,
    salario DECIMAL(10, 2) CHECK (salario > 0),
    data_admissao DATE NOT NULL,
    status_funcionario VARCHAR(20) DEFAULT 'Ativo' CHECK (status_funcionario IN ('Ativo', 'Inativo')),
    PRIMARY KEY (id_funcionario)
);

-- Tabela para informações do cliente
CREATE TABLE clientes (
    id_cliente INT NOT NULL AUTO_INCREMENT,
    nome_cliente VARCHAR(100) NOT NULL,
    telefone VARCHAR(15),
    email VARCHAR(100),
    endereco TEXT,
    PRIMARY KEY (id_cliente)
);

-- Tabela para tipo de produtos
CREATE TABLE tipo_produtos (
    id_produto INT NOT NULL AUTO_INCREMENT,
    nome_produto VARCHAR(100) NOT NULL,
    preco DECIMAL(10, 2) CHECK (preco > 0),
    categoria VARCHAR(50),
    PRIMARY KEY (id_produto)
);

-- Tabela para Inventário de estoque
CREATE TABLE inventario (
    id_estoque INT NOT NULL AUTO_INCREMENT,
    id_produto INT NOT NULL,
    quantidade INT NOT NULL CHECK (quantidade >= 0),
    localizacao VARCHAR(100),
    PRIMARY KEY (id_estoque),
    FOREIGN KEY (id_produto) REFERENCES tipo_produtos (id_produto)
);

-- Verificar estoque antes de concluir o pedido
DELIMITER //
CREATE TRIGGER verificar_estoque_antes_de_concluir_pedido
BEFORE UPDATE ON pedidos
FOR EACH ROW
BEGIN
    DECLARE quantidade_estoque INT;
    DECLARE quantidade_pedida INT;
    DECLARE id_produto INT;
    
    -- Para cada item no pedido
    DECLARE item_cursor CURSOR FOR
        SELECT id_produto, quantidade
        FROM itens_pedido
        WHERE id_pedido = OLD.id_pedido;
    
    OPEN item_cursor;
    FETCH item_cursor INTO id_produto, quantidade_pedida;

    WHILE @@FETCH_STATUS = 0 DO
        -- Verificar o estoque disponível para o produto
        SELECT quantidade INTO quantidade_estoque 
        FROM inventario 
        WHERE id_produto = id_produto;

        -- Impedir o update se o estoque não for suficiente
        IF quantidade_estoque < quantidade_pedida THEN
            SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Estoque insuficiente para concluir o pedido';
        END IF;
        FETCH item_cursor INTO id_produto, quantidade_pedida;
    END WHILE;
    
    CLOSE item_cursor;
END;
//

-- Atualizar Estoque pós pedido
CREATE TRIGGER atualizar_estoque_apos_pedido
AFTER INSERT ON itens_pedido
FOR EACH ROW
BEGIN
    UPDATE inventario
    SET quantidade = quantidade - NEW.quantidade
    WHERE id_produto = NEW.id_produto;
END;
//
DELIMITER ;
-- Tabela para registrar pedidos
CREATE TABLE pedidos (
    id_pedido INT NOT NULL AUTO_INCREMENT,
    id_cliente INT NOT NULL,
    id_funcionario INT NOT NULL,
    data_pedido DATE DEFAULT CURRENT_TIMESTAMP,
    valor_total DECIMAL(10, 2) CHECK (valor_total > 0),
    status_pedido VARCHAR(20) DEFAULT 'Pendente' CHECK (status_pedido IN ('Pendente', 'Concluído', 'Cancelado')),
    PRIMARY KEY (id_pedido),
    FOREIGN KEY (id_cliente) REFERENCES clientes (id_cliente),
    FOREIGN KEY (id_funcionario) REFERENCES funcionarios (id_funcionario)
);

-- Atualizar Valor Total do Pedido
DELIMITER //

CREATE TRIGGER atualizar_valor_total_pedido
AFTER INSERT ON itens_pedido
FOR EACH ROW
BEGIN
    DECLARE valor DECIMAL(10, 2);
    SET valor = NEW.quantidade * NEW.preco_unitario;
    UPDATE pedidos
    SET valor_total = valor_total + valor
    WHERE id_pedido = NEW.id_pedido;
END;
//

DELIMITER ;

-- Tabela de itens do pedido
CREATE TABLE itens_pedido (
    id_item INT NOT NULL AUTO_INCREMENT,
    id_pedido INT NOT NULL,
    id_produto INT NOT NULL,
    quantidade INT NOT NULL CHECK (quantidade > 0),
    preco_unitario DECIMAL(10, 2) NOT NULL CHECK (preco_unitario > 0),
    PRIMARY KEY (id_item),
    FOREIGN KEY (id_pedido) REFERENCES pedidos (id_pedido),
    FOREIGN KEY (id_produto) REFERENCES tipo_produtos (id_produto)
);