-- Criação do Database Restaurante
CREATE DATABASE restaurante;
USE restaurante;

-- Tabela para Diferenciar Produtos: Bebidas, Massas, Lanches
CREATE TABLE categorias_produto (
    id_categoria INT NOT NULL AUTO_INCREMENT,
    nome_categoria VARCHAR(50) NOT NULL,
    descricao TEXT,
    PRIMARY KEY (id_categoria)
);

-- Tabela para Tipos de Prato
CREATE TABLE pratos (
    id_prato INT NOT NULL AUTO_INCREMENT,
    nome_prato VARCHAR(100) NOT NULL,
    id_categoria INT,
    preco DECIMAL(10, 2) CHECK (preco > 0),
    PRIMARY KEY (id_prato),
    FOREIGN KEY (id_categoria) REFERENCES categorias_produto (id_categoria)
);

-- Tabela para Clientes
CREATE TABLE clientes (
    id_cliente INT NOT NULL AUTO_INCREMENT,
    nome_cliente VARCHAR(100) NOT NULL,
    telefone VARCHAR(15),
    email VARCHAR(100),
    PRIMARY KEY (id_cliente)
);

-- Tabela para Pedido
CREATE TABLE pedidos (
    id_pedido INT NOT NULL AUTO_INCREMENT,
    id_cliente INT NOT NULL,
    data_pedido DATETIME DEFAULT CURRENT_TIMESTAMP,
    valor_total DECIMAL(10, 2) CHECK (valor_total > 0),
    PRIMARY KEY (id_pedido),
    FOREIGN KEY (id_cliente) REFERENCES clientes (id_cliente)
);

-- Tabela para Itens de Pedido (Produtos que o cliente pediu)
CREATE TABLE itens_pedido (
    id_item INT NOT NULL AUTO_INCREMENT,
    id_pedido INT NOT NULL,
    id_prato INT NOT NULL,
    quantidade INT CHECK (quantidade > 0),
    preco DECIMAL(10, 2) CHECK (preco > 0),
    PRIMARY KEY (id_item),
    FOREIGN KEY (id_pedido) REFERENCES pedidos (id_pedido),
    FOREIGN KEY (id_prato) REFERENCES pratos (id_prato)
);

-- Tabela para Incidências nos Pedidos
CREATE TABLE incidencias (
    id_incidencia INT NOT NULL AUTO_INCREMENT,
    id_pedido INT NOT NULL,
    descricao TEXT,
    tipo_incidencia VARCHAR(50) CHECK (tipo_incidencia IN ('Erro na Preparação', 'Atraso', 'Cancelamento', 'Troca de Produto', 'Outros')),
    status_resolucao VARCHAR(50) CHECK (status_resolucao IN ('Pendente', 'Resolvido', 'Cancelado')),
    data_ocorrencia DATETIME DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (id_incidencia),
    FOREIGN KEY (id_pedido) REFERENCES pedidos (id_pedido)
);
