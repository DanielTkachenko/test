use TPU_Project
GO

--�������� ������� � ������ ����
create table [���� ����]
(Menutype VARCHAR(20) not null,
PRIMARY KEY(Menutype))
GO
INSERT INTO [���� ����]
VALUES
('LINK'),
('FEED_LIST'),
('LINKS_LIST'),
('ARTICLE')
GO

--��������� � ������� ����� ���� ������� ��� ���� � URL
ALTER TABLE [����� ����]
ADD [��� ����] varchar(20) null
GO
ALTER TABLE [����� ����]
ADD FOREIGN KEY([��� ����]) REFERENCES [���� ����](Menutype)
GO
ALTER TABLE [����� ����]
ADD URL VARCHAR(100) null
GO

--�������� ������������� Menu
ALTER VIEW Menu AS
SELECT P1.[Id ������ ����] 'ID', Pr1.������������ '����������', P1.������� '������� ����', P1.[��� ����] '���', P1.[URL] '������', P1.[������� �����������], Jz1.������������ '���� �����������',P2.[Id ������ ����] 'ID ��������', Pr2.������������ '��������'
FROM ([����� ����] P1 INNER JOIN [������������� ����] Pr1 ON P1.[Id ������ ����] = Pr1.[Id ������ ����]
INNER JOIN ����� Jz1 ON Pr1.[ID �����] = Jz1.[ID �����])
LEFT JOIN ([����� ����] P2 INNER JOIN [������������� ����] Pr2 ON P2.[Id ������ ����]=Pr2.[Id ������ ����])
ON P1.[FK_Id ������ ����] = P2.[Id ������ ����]
GO

--��������� ��������� ������� ����
ALTER PROCEDURE [AddMenuItem]
@Level int,@NameMenu varchar(45), @NameUpperMenu varchar(45), @Language varchar(45), @Order int, @type varchar(20), @url varchar(100)
AS
DECLARE @MenuId uniqueidentifier
DECLARE @UpperMenuId uniqueidentifier
DECLARE @LanguageId uniqueidentifier
SELECT @MenuId = NEWID()
SELECT @LanguageId=�����.[ID �����]
FROM �����
WHERE �����.������������ = @Language
IF @Level!=1
BEGIN
IF @NameUpperMenu is not NULL
BEGIN
SELECT @UpperMenuId = [����� ����].[Id ������ ����]
FROM [����� ����] INNER JOIN [������������� ����]
ON [����� ����].[Id ������ ����] = [������������� ����].[Id ������ ����]
INNER JOIN ����� ON [������������� ����].[ID �����] = �����.[ID �����]
WHERE [������������� ����].������������ = @NameUpperMenu AND �����.������������=@Language
IF @UpperMenuId is not NULL
BEGIN
INSERT INTO [����� ����]([Id ������ ����],�������,[FK_Id ������ ����], [������� �����������], [��� ����], [URL])
VALUES(@MenuId,@Level,@UpperMenuId, @Order, @type, @url)
INSERT INTO [������������� ����]([Id ������ ����],������������,[ID �����])
VALUES(@MenuId,@NameMenu,@LanguageId)
END
ELSE
print 'No such upper menu item'
END
ELSE
print 'Error no upper menu name'
END
IF @Level=1
BEGIN
INSERT INTO [����� ����]([Id ������ ����],�������, [������� �����������], [��� ����], [URL])
VALUES(@MenuId,@Level, @Order, @type, @url)
INSERT INTO [������������� ����]([Id ������ ����],������������,[ID �����])
VALUES(@MenuId,@NameMenu,@LanguageId)
END;
--������� ������� ����
exec AddMenuItem 1, '�����', null, '�������', 1, 'LINKS_LIST', null
exec AddMenuItem 1, '�������������', null, '�������', 2, 'LINK', 'some link here'
exec AddMenuItem 2, '����������', '�����', '�������', 1, 'LINK', 'some link here'
exec AddMenuItem 1, '���������', null, '�������', 3, 'FEED_LIST', null
exec AddMenuItem 2, '�������', '�����', '�������', 2, 'LINK', 'some link here'

go
--������� ������� ID ������ ����� ������ � �����(��� ��� ����� ����� ������� ��������� �������)
ALTER VIEW ArticlesInfo AS
SELECT ��������.�������� '��������', [������������� ����].������������ '����� ����', �����.������������ '����', ������.[Id ������] 'ID ������',
������.�������� '�������� ������', ������.����� '����� ������', ������.[����� ��������] '����� �������� ������'
FROM �������� INNER JOIN [�������� ������ ����]
ON ��������.[Id ��������] = [�������� ������ ����].[Id ��������]
INNER JOIN [������������� ����] ON [������������� ����].[Id ������ ����] = [�������� ������ ����].[Id ������ ����]
INNER JOIN ����� ON �����.[ID �����] = ��������.[ID �����]
INNER JOIN [������ � ���������] ON [������ � ���������].[Id ��������] = ��������.[Id ��������]
INNER JOIN ������ ON ������.[Id ������] = [������ � ���������].[Id ������] 
