-- Criação do Database escola de cursos online
CREATE DATABASE escolacursos_online;
USE escolacursos_online;

-- Tabela para Registro de Professores / RH
CREATE TABLE professores (
    id_professor INT NOT NULL AUTO_INCREMENT,
    nome_professor VARCHAR(100) NOT NULL,
    especialidade VARCHAR(100),
    email VARCHAR(100),
    PRIMARY KEY (id_professor)
);

-- Tabela para Cursos Disponíveis
CREATE TABLE cursos (
    id_curso INT NOT NULL AUTO_INCREMENT,
    nome_curso VARCHAR(100) NOT NULL,
    id_professor INT,
    carga_horaria INT CHECK (carga_horaria > 0),
    preco DECIMAL(10, 2) CHECK (preco > 0),
    PRIMARY KEY (id_curso),
    FOREIGN KEY (id_professor) REFERENCES professores (id_professor)
);

-- Tabela para Alunos Matriculados
CREATE TABLE alunos (
    id_aluno INT NOT NULL AUTO_INCREMENT,
    nome_aluno VARCHAR(100) NOT NULL,
    email VARCHAR(100),
    telefone VARCHAR(15),
    status_aluno VARCHAR(20) DEFAULT 'Ativo' CHECK (status_aluno IN ('Ativo', 'Inativo')),
    PRIMARY KEY (id_aluno)
);

-- Tabela para Matrículas
CREATE TABLE matriculas (
    id_matricula INT NOT NULL AUTO_INCREMENT,
    id_aluno INT NOT NULL,
    id_curso INT NOT NULL,
    data_matricula DATE DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (id_matricula),
    FOREIGN KEY (id_aluno) REFERENCES alunos (id_aluno),
    FOREIGN KEY (id_curso) REFERENCES cursos (id_curso)
);
