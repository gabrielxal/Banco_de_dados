-- Criação Banco de dados para Biblioteca
CREATE DATABASE biblioteca;
USE biblioteca;

-- Tabela para relacionar por autores
CREATE TABLE autores (
    id_autor INT NOT NULL AUTO_INCREMENT,
    nome_autor VARCHAR(100) NOT NULL,
    nacionalidade VARCHAR(50),
    PRIMARY KEY (id_autor)
);

-- Tabela para Livros
CREATE TABLE livros (
    id_livro INT NOT NULL AUTO_INCREMENT,
    titulo_livro VARCHAR(200) NOT NULL,
    id_autor INT,
    ano_publicacao YEAR,
    genero VARCHAR(50),
    PRIMARY KEY (id_livro),
    FOREIGN KEY (id_autor) REFERENCES autores (id_autor)
);

-- Tabela para clientes/membros
CREATE TABLE membros (
    id_membro INT NOT NULL AUTO_INCREMENT,
    nome_membro VARCHAR(100) NOT NULL,
    telefone VARCHAR(15),
    email VARCHAR(100),
    status_membro VARCHAR(20) DEFAULT 'Ativo' CHECK (status_membro IN ('Ativo', 'Inativo')),
    PRIMARY KEY (id_membro)
);

-- Tabela para empréstimos/devolução
CREATE TABLE emprestimos (
    id_emprestimo INT NOT NULL AUTO_INCREMENT,
    id_membro INT NOT NULL,
    id_livro INT NOT NULL,
    data_emprestimo DATE DEFAULT CURRENT_TIMESTAMP,
    data_devolucao DATE,
    PRIMARY KEY (id_emprestimo),
    FOREIGN KEY (id_membro) REFERENCES membros (id_membro),
    FOREIGN KEY (id_livro) REFERENCES livros (id_livro)
);