use TPU_Project
GO

--Создание таблицы с типами меню
create table [Типы меню]
(Menutype VARCHAR(20) not null,
PRIMARY KEY(Menutype))
GO
INSERT INTO [Типы меню]
VALUES
('LINK'),
('FEED_LIST'),
('LINKS_LIST'),
('ARTICLE')
GO

--Добавляем в таблицу Пункт меню колонку Тип меню и URL
ALTER TABLE [Пункт меню]
ADD [Тип меню] varchar(20) null
GO
ALTER TABLE [Пункт меню]
ADD FOREIGN KEY([Тип меню]) REFERENCES [Типы меню](Menutype)
GO
ALTER TABLE [Пункт меню]
ADD URL VARCHAR(100) null
GO

--Изменяем представление Menu
ALTER VIEW Menu AS
SELECT P1.[Id пункта меню] 'ID', Pr1.Наименование 'Подчинённый', P1.Позиция 'Уровень меню', P1.[Тип меню] 'Тип', P1.[URL] 'Ссылка', P1.[Порядок отображения], Jz1.Наименование 'Язык подчинённого',P2.[Id пункта меню] 'ID родителя', Pr2.Наименование 'Родитель'
FROM ([Пункт меню] P1 INNER JOIN [Представление меню] Pr1 ON P1.[Id пункта меню] = Pr1.[Id пункта меню]
INNER JOIN Языки Jz1 ON Pr1.[ID языка] = Jz1.[ID языка])
LEFT JOIN ([Пункт меню] P2 INNER JOIN [Представление меню] Pr2 ON P2.[Id пункта меню]=Pr2.[Id пункта меню])
ON P1.[FK_Id пункта меню] = P2.[Id пункта меню]
GO

--Изменение процедуры вставки меню
ALTER PROCEDURE [AddMenuItem]
@Level int,@NameMenu varchar(45), @NameUpperMenu varchar(45), @Language varchar(45), @Order int, @type varchar(20), @url varchar(100)
AS
DECLARE @MenuId uniqueidentifier
DECLARE @UpperMenuId uniqueidentifier
DECLARE @LanguageId uniqueidentifier
SELECT @MenuId = NEWID()
SELECT @LanguageId=Языки.[ID языка]
FROM Языки
WHERE Языки.Наименование = @Language
IF @Level!=1
BEGIN
IF @NameUpperMenu is not NULL
BEGIN
SELECT @UpperMenuId = [Пункт меню].[Id пункта меню]
FROM [Пункт меню] INNER JOIN [Представление меню]
ON [Пункт меню].[Id пункта меню] = [Представление меню].[Id пункта меню]
INNER JOIN Языки ON [Представление меню].[ID языка] = Языки.[ID языка]
WHERE [Представление меню].Наименование = @NameUpperMenu AND Языки.Наименование=@Language
IF @UpperMenuId is not NULL
BEGIN
INSERT INTO [Пункт меню]([Id пункта меню],Позиция,[FK_Id пункта меню], [Порядок отображения], [Тип меню], [URL])
VALUES(@MenuId,@Level,@UpperMenuId, @Order, @type, @url)
INSERT INTO [Представление меню]([Id пункта меню],Наименование,[ID языка])
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
INSERT INTO [Пункт меню]([Id пункта меню],Позиция, [Порядок отображения], [Тип меню], [URL])
VALUES(@MenuId,@Level, @Order, @type, @url)
INSERT INTO [Представление меню]([Id пункта меню],Наименование,[ID языка])
VALUES(@MenuId,@NameMenu,@LanguageId)
END;
--Вставка пунктов меню
exec AddMenuItem 1, 'Учеба', null, 'Русский', 1, 'LINKS_LIST', null
exec AddMenuItem 1, 'Преподаватели', null, 'Русский', 2, 'LINK', 'some link here'
exec AddMenuItem 2, 'Расписание', 'Учеба', 'Русский', 1, 'LINK', 'some link here'
exec AddMenuItem 1, 'Общежития', null, 'Русский', 3, 'FEED_LIST', null
exec AddMenuItem 2, 'Корпуса', 'Учеба', 'Русский', 2, 'LINK', 'some link here'

go
--добавил колонку ID статьи убрал ссылки и медиа(для них потом будет создана отдельная таблица)
ALTER VIEW ArticlesInfo AS
SELECT Страница.Название 'Страница', [Представление меню].Наименование 'Пункт меню', Языки.Наименование 'Язык', Статья.[Id статьи] 'ID статьи',
Статья.Название 'Название статьи', Статья.Текст 'Текст статьи', Статья.[Время создания] 'Время создания статьи'
FROM Страница INNER JOIN [Страницы пункты меню]
ON Страница.[Id страницы] = [Страницы пункты меню].[Id страницы]
INNER JOIN [Представление меню] ON [Представление меню].[Id пункта меню] = [Страницы пункты меню].[Id пункта меню]
INNER JOIN Языки ON Языки.[ID языка] = Страница.[ID языка]
INNER JOIN [Статьи в страницах] ON [Статьи в страницах].[Id страницы] = Страница.[Id страницы]
INNER JOIN Статья ON Статья.[Id статьи] = [Статьи в страницах].[Id статьи] 
