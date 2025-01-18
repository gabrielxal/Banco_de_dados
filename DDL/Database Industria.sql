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