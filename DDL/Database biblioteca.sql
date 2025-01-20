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

-- Automatização para quando atualizar status dos membros
DELIMITER //

CREATE TRIGGER atualizar_status_membro
AFTER UPDATE ON emprestimos
FOR EACH ROW
BEGIN
    IF NEW.data_devolucao IS NOT NULL THEN
        DECLARE livros_em_aberto INT;
        SELECT COUNT(*) INTO livros_em_aberto 
        FROM emprestimos 
        WHERE id_membro = NEW.id_membro AND data_devolucao IS NULL;
        
        IF livros_em_aberto = 0 THEN
            UPDATE membros 
            SET status_membro = 'Ativo' 
            WHERE id_membro = NEW.id_membro;
        END IF;
    END IF;
END;

DELIMITER ;



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

-- Atualização para quando realizar emprestimo e devolução
DELIMITER //

ALTER TABLE livros ADD COLUMN estoque INT DEFAULT 1;
CREATE TRIGGER atualizar_estoque_emprestimo
AFTER INSERT ON emprestimos
FOR EACH ROW
BEGIN
    UPDATE livros 
    SET estoque = estoque - 1 
    WHERE id_livro = NEW.id_livro;
END;
CREATE TRIGGER atualizar_estoque_devolucao
AFTER UPDATE ON emprestimos
FOR EACH ROW
BEGIN
    IF NEW.data_devolucao IS NOT NULL THEN
        UPDATE livros 
        SET estoque = estoque + 1 
        WHERE id_livro = NEW.id_livro;
    END IF;
END;

DELIMITER ;