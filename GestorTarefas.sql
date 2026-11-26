CREATE TABLE funcionarios(
id serial primary key,
nome varchar(150) not null,
email varchar(150) not null unique,
senha varchar(200) not null,
ativo boolean default true not null
);


CREATE TABLE atividades(
id serial primary key,
nome varchar(200) not null,
descricao text not null,
status varchar(30) default 'Em andamento'
check(status in ('Em andamento', 'Cancelado', 'Pausado'))
);


CREATE TABLE compromissos(
id serial primary key,
atividade_id int references atividades(id) not null,
funcionario_id int references funcionarios(id) not null,
titulo varchar(150) not null,
categoria varchar(250) not null,
descricao text not null,
data_criacao timestamp default current_timestamp,
prazo date not null,
status varchar(30) default 'Em andamento'
check(status in ('Em andamento', 'Cancelado', 'Pausado'))
);


CREATE TABLE registro_atividades(
id serial primary key,
compromisso_id int references compromissos(id) not null,
evento varchar(150) not null,
data_evento timestamp default current_timestamp,
detalhes text
);


INSERT INTO funcionarios (nome, email, senha) VALUES
('Pedro', 'pedro@email.com', 'senha123'),
('Lucas', 'lucas@email.com', 'senha456'),
('Maria', 'maria@email.com', 'senha789');


INSERT INTO atividades (nome, descricao, status) VALUES
('Desenvolvimento do site', 'Criacao de um site para a empresa', 'Em andamento'),
('Banco de dados', 'Organizacao do banco de dados', 'Em andamento'),
('Sistema financeiro', 'Desenvolvimento de sistema financeiro', 'Pausado');


INSERT INTO compromissos (atividade_id, funcionario_id, titulo, categoria, descricao, prazo) VALUES
(1, 1, 'Criar pagina inicial', 'Programacao', 'Desenvolver a pagina principal do site', CURRENT_DATE + 5),
(2, 2, 'Criar tabelas', 'Banco de dados', 'Montar as tabelas do sistema', CURRENT_DATE + 10),
(3, 3, 'Criar sistema de login', 'Desenvolvimento', 'Desenvolver o login dos usuarios', CURRENT_DATE + 15);


CREATE VIEW vw_painel_atividades AS
SELECT
funcionarios.nome,
compromissos.titulo,
compromissos.categoria,
compromissos.prazo,
compromissos.status
FROM compromissos
JOIN funcionarios
ON compromissos.funcionario_id = funcionarios.id;


CREATE VIEW vw_cronograma AS
SELECT
funcionarios.nome,
atividades.nome AS atividade,
compromissos.titulo,
compromissos.categoria,
compromissos.data_criacao,
compromissos.prazo,
compromissos.status
FROM compromissos
JOIN funcionarios
ON compromissos.funcionario_id = funcionarios.id
JOIN atividades
ON compromissos.atividade_id = atividades.id
ORDER BY compromissos.prazo ASC;


CREATE OR REPLACE FUNCTION fn_validar_compromisso()
RETURNS TRIGGER AS $$
BEGIN

IF NOT EXISTS (
SELECT id
FROM funcionarios
WHERE id = NEW.funcionario_id
AND ativo = TRUE
) THEN
RAISE EXCEPTION 'Funcionario inativo ou inexistente!';
END IF;

RETURN NEW;

END;
$$ LANGUAGE plpgsql;


CREATE TRIGGER trg_validar_compromisso
BEFORE INSERT ON compromissos
FOR EACH ROW
EXECUTE FUNCTION fn_validar_compromisso();
