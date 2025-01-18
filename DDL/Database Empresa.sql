-- Criação do Database Empresa
CREATE DATABASE empresa;
USE empresa;

-- Tabela para Departamentos
CREATE TABLE departamento (
    id_departamento INT NOT NULL AUTO_INCREMENT,
    nome_departamento VARCHAR(100) NOT NULL,
    localizacao VARCHAR(100),
    PRIMARY KEY (id_departamento)
);

-- Tabela para Cargos dos Funcionarios
CREATE TABLE cargo (
    id_cargo INT NOT NULL AUTO_INCREMENT,
    nome_cargo VARCHAR(100) NOT NULL,
    salario DECIMAL(10, 2) CHECK (salario > 0),
    PRIMARY KEY (id_cargo)
);

-- Tabela para Projetos
CREATE TABLE projetos (
    id_projeto INT NOT NULL AUTO_INCREMENT,
    nome_projeto VARCHAR(100) NOT NULL,
    data_inicio DATE,
    data_fim DATE,
    status_projeto VARCHAR(20) DEFAULT 'Em andamento' CHECK (status_projeto IN ('Em andamento', 'Concluído', 'Cancelado')),
    PRIMARY KEY (id_projeto)
);

-- Tabela para Funcionários
CREATE TABLE registro_funcionario (
    cod_funcionario INT NOT NULL AUTO_INCREMENT, 
    nome_completo VARCHAR(100) NOT NULL,
    idade INT NOT NULL CHECK (idade > 0),
    data_contrato DATETIME DEFAULT CURRENT_TIMESTAMP,
    status_funcionario VARCHAR(20) DEFAULT 'Ativo' CHECK (status_funcionario IN ('Ativo', 'Inativo')),
    genero CHAR(1) CHECK (genero IN ('M', 'F', 'O')),
    id_departamento INT,
    id_cargo INT,
    PRIMARY KEY (cod_funcionario),
    FOREIGN KEY (id_departamento) REFERENCES departamento (id_departamento),
    FOREIGN KEY (id_cargo) REFERENCES cargo (id_cargo)
);

-- Tabela para Participação em Projetos
CREATE TABLE participacao_projeto (
    id_funcionario INT NOT NULL,
    id_projeto INT NOT NULL,
    horas_trabalhadas INT CHECK (horas_trabalhadas >= 0),
    PRIMARY KEY (id_funcionario, id_projeto),
    FOREIGN KEY (id_funcionario) REFERENCES registro_funcionario (cod_funcionario),
    FOREIGN KEY (id_projeto) REFERENCES projetos (id_projeto)
);

-- Verificação de Idade
DELIMITER //

CREATE TRIGGER check_idade_funcionario
BEFORE INSERT ON registro_funcionario
FOR EACH ROW
BEGIN
    IF NEW.idade < 18 THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Funcionário deve ter pelo menos 18 anos';
    END IF;
END//

DELIMITER ;

-- Atualizar Status do Projeto ao Concluir Tarefas
DELIMITER //

CREATE TRIGGER atualizar_status_projeto
AFTER UPDATE ON tarefas
FOR EACH ROW
BEGIN
    DECLARE total_tarefas INT;
    DECLARE tarefas_concluidas INT;
    DECLARE projeto_existente INT;
    
    -- Verificar se o projeto existe
    SELECT COUNT(*) INTO projeto_existente
    FROM projetos
    WHERE id_projeto = NEW.id_projeto;
    
    IF projeto_existente = 0 THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Projeto não encontrado.';
    ELSE
        -- Contar o número total de tarefas do projeto
        SELECT COUNT(*) INTO total_tarefas
        FROM tarefas
        WHERE id_projeto = NEW.id_projeto;
        
        -- Contar o número de tarefas concluídas
        SELECT COUNT(*) INTO tarefas_concluidas
        FROM tarefas
        WHERE id_projeto = NEW.id_projeto AND status_tarefa = 'Concluída';
        
        -- Se todas as tarefas foram concluídas, mudar o status do projeto
        IF total_tarefas = tarefas_concluidas THEN
            UPDATE projetos
            SET status_projeto = 'Concluído'
            WHERE id_projeto = NEW.id_projeto;
        END IF;
    END IF;
END//

DELIMITER ;

-- Atualizar Status do Funcionário ao Tornar-se Inativo
DELIMITER //

CREATE TRIGGER update_funcionario_status
AFTER UPDATE ON registro_funcionario
FOR EACH ROW
BEGIN
    IF NEW.status_funcionario = 'Inativo' AND OLD.status_funcionario != 'Inativo' THEN
        -- Verifica se o funcionário estava participando de algum projeto e atualiza as horas
        UPDATE participacao_projeto
        SET horas_trabalhadas = 0
        WHERE id_funcionario = NEW.cod_funcionario;
    END IF;
END//

DELIMITER ;

-- Atualizar Status do Projeto ao Alterar Status do Funcionário
DELIMITER //

CREATE TRIGGER verificar_status_projeto_funcionario
AFTER UPDATE ON registro_funcionario
FOR EACH ROW
BEGIN
    DECLARE total_funcionarios INT;
    DECLARE funcionarios_ativos INT;
    DECLARE projeto_existente INT;

    -- Verificar se o projeto existe
    SELECT COUNT(*) INTO projeto_existente
    FROM projetos
    WHERE id_projeto IN (SELECT id_projeto FROM participacao_projeto WHERE id_funcionario = NEW.cod_funcionario);

    IF projeto_existente > 0 THEN
        -- Contar o número total de funcionários envolvidos no projeto
        SELECT COUNT(*) INTO total_funcionarios
        FROM participacao_projeto
        WHERE id_projeto IN (SELECT id_projeto FROM participacao_projeto WHERE id_funcionario = NEW.cod_funcionario);

        -- Contar o número de funcionários ativos no projeto
        SELECT COUNT(*) INTO funcionarios_ativos
        FROM participacao_projeto pp
        JOIN registro_funcionario rf ON pp.id_funcionario = rf.cod_funcionario
        WHERE pp.id_projeto IN (SELECT id_projeto FROM participacao_projeto WHERE id_funcionario = NEW.cod_funcionario)
        AND rf.status_funcionario = 'Ativo';

        -- Se não houver funcionários ativos, atualizar o status do projeto para 'Cancelado'
        IF total_funcionarios = funcionarios_ativos THEN
            UPDATE projetos
            SET status_projeto = 'Cancelado'
            WHERE id_projeto IN (SELECT id_projeto FROM participacao_projeto WHERE id_funcionario = NEW.cod_funcionario);
        END IF;
    END IF;
END//

DELIMITER ;

