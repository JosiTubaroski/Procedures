
EXEC SP_SRVROLEPERMISSION 'bulkadmin'

-- Cria��o de um banco para nossos testes
CREATE DATABASE RoleTest
GO

USE RoleTest
GO

--Tabela pra teste

CREATE TABLE dbo.Roles(
linha INT NULL,
nome VARCHAR(20) NULL,
descricao VARCHAR(100) NULL)

select * from dbo.Roles

-- Cria��o dos logins para teste
USE MASTER
GO
-- Esse cara foi eleito BulkAdmin pela comiss�o oficial dos databases do brasil
CREATE LOGIN CarinhaBulkAdmin WITH PASSWORD = 'bulkadmin1', CHECK_POLICY = OFF;

-- Adiciona o login � role Bulkadmin
EXEC sp_addsrvrolemember 'CarinhaBulkAdmin', 'bulkadmin';

--Esse cara ter� permiss�o de inser��o e nada mais (nem arquivo externo)
CREATE LOGIN CarinhaDoInsert WITH PASSWORD = 'insert1', CHECK_POLICY = OFF;

/* Criando usu�rios para ambos os logins na base */

USE RoleTest

EXEC sp_addsrvrolemember CarinhaDoInsert, 'bulkadmin'

--O usu�rio foi criado. Lembrando: ele tem role de servidor Bulkadmin
CREATE USER usrBulkInsert FOR LOGIN CarinhaBulkAdmin

-- O usu�rio que s� pode inserir e n�o pode fazer bulk insert
CREATE USER usrInsert FOR LOGIN CarinhaDoInsert

-- Ou seja...O �nico que tem permiss�o de Insert � o usrInsert
GRANT INSERT ON Object::dbo.Roles TO usrInsert

GRANT select ON Object::dbo.Roles TO usrBulkInsert

--- Logando com o carinha

USE RoleTest
GO
-- Insert deve funcionar normalmente.
INSERT INTO dbo.Roles (linha,nome,descricao) VALUES (0,'bulkadm','Come�o de teste')
-- Agora tente dar um BULK INSERT sem ter permiss�o...
BULK INSERT dbo.Roles 
FROM 'C:\temp\carga.txt' WITH  (FIELDTERMINATOR = ',',   
ROWTERMINATOR   = 'n')

select * from dbo.Roles