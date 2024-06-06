--Создаем таблицу--
IF OBJECT_ID('Notes', 'U') IS NULL
    BEGIN
        CREATE TABLE Notes (NoteID INT IDENTITY(1,1) PRIMARY KEY,
                            NoteTitle NVARCHAR(50),
                            NoteText NVARCHAR(MAX),
                            CreatingDate DATETIME DEFAULT GETDATE());

--Создаю первую заметку по умолчанию--
        DECLARE @DefaultNoteText NVARCHAR(MAX) = 'Это приложение заметки где вы можете создавать, хранить, изменять и удалять свои заметки используя команды'
        DECLARE @DefaultNoteTitle NVARCHAR(MAX) = 'О заметках'
        INSERT INTO Notes (NoteTitle, NoteText)
        VALUES (@DefaultNoteTitle, @DefaultNoteText);

        PRINT @DefaultNoteTitle + @DefaultNoteText + CHAR(10) + 'Чтобы посмотреть все команды приложения введите EXEC Info';
    END
ELSE
    BEGIN
        PRINT 'Таблица с заметками уже существует' +
              'Чтобы посмотреть все команды приложения введите EXEC Info';
        SELECT * FROM Notes;
    END;
GO
-- Создаю таблицу для хранения истории изменений заметок--
IF OBJECT_ID('History', 'U') IS NULL
CREATE TABLE History
(
    Id INT IDENTITY PRIMARY KEY,
    NoteId INT NOT NULL,
    Operation NVARCHAR(MAX) NOT NULL,
    CreateAt DATETIME NOT NULL DEFAULT GETDATE());

--Создаю процедуру для создания заметок--
IF OBJECT_ID('AddNote', 'P') IS NOT NULL
    DROP PROCEDURE  AddNote;
GO
CREATE PROCEDURE AddNote
    @NoteTitle NVARCHAR(50),
    @NoteText NVARCHAR(MAX)
AS
BEGIN

    INSERT INTO Notes (NoteTitle, NoteText)
    VALUES (@NoteTitle, @NoteText);
    PRINT 'Заметка успешно сохранена';

END;
GO
-- Создаю триггер, который сохраняет информацию о добавлении или обновлении заметок в таблицу History--
IF OBJECT_ID('triggerInsert', 'TR') IS NOT NULL
    BEGIN
        DROP TRIGGER triggerInsert;
    end
GO
CREATE TRIGGER triggerInsert
    ON Notes
    FOR INSERT, UPDATE
    AS
BEGIN
    IF EXISTS(SELECT * FROM INSERTED) AND NOT EXISTS(SELECT * FROM DELETED)
        BEGIN
            INSERT INTO History(NoteId, Operation)
            SELECT NoteId, 'Добавлена заметка ' + NoteTitle
            FROM INSERTED;
        end
    IF EXISTS(SELECT * FROM INSERTED) AND EXISTS (SELECT * FROM DELETED)
        BEGIN
            INSERT INTO History(NoteID, Operation)
            SELECT Deleted.NoteID, 'Обновлена заметка ' + Deleted.NoteTitle
            FROM DELETED
                     INNER JOIN INSERTED ON DELETED.NoteID = INSERTED.NoteID;
        end
END;
GO
--Создаю процедуру для вывода списка заметок--
IF OBJECT_ID('GetNotes', 'P') IS NOT NULL
    DROP PROCEDURE GetNotes;
GO
CREATE PROCEDURE GetNotes
AS
BEGIN
    SELECT NoteID, NoteTitle, NoteText, CreatingDate FROM Notes;
    EXEC PrintNotes;
END;
GO

--Создаю прцедуру для редактирования заметки(обновление)--
IF OBJECT_ID('EditNote', 'P') IS NOT NULL
    DROP PROCEDURE EditNote;
GO
CREATE PROCEDURE EditNote
    @NoteID INT,
    @NoteTitle NVARCHAR(50),
    @NoteText NVARCHAR(MAX)
AS
BEGIN
    UPDATE Notes SET NoteTitle = @NoteTitle, NoteText = @NoteText
    WHERE NoteID = @NoteID;
    PRINT 'Заметка успешно изменена';
END;
GO

--Создаю процедуру полученя заметки по ID--
IF OBJECT_ID('GetNote', 'P') IS NOT NULL
    DROP PROCEDURE GetNote;
GO
CREATE PROCEDURE GetNote
@NoteID INT
AS
BEGIN
    SELECT NoteID, NoteTitle, NoteText, CreatingDate From Notes
    WHERE NoteID = @NoteID;
    EXEC PrintNotes;
END;
GO

--Процедура удаления заметки по ID--
IF OBJECT_ID('DeleteNote', 'P') IS NOT NULL
    DROP PROCEDURE DeleteNote;
GO
CREATE PROCEDURE DeleteNote
@NoteID INT
AS
BEGIN
    DECLARE @DeletedNoteTitle NVARCHAR(MAX)
    SELECT NoteTitle = @DeletedNoteTitle FROM Notes WHERE NoteID = @NoteID;

    DELETE FROM Notes
    WHERE NoteID = @NoteID;

    IF @@ROWCOUNT > 0
        BEGIN
            PRINT 'Заметка ' + @DeletedNoteTitle + 'удалена'
        end
    ELSE
        BEGIN
            PRINT 'Заметка с таким ID не найдена, проверьте ID заметки, которую хотите удалить'
        end
END;
GO

-- Создаю триггер, который сохраняет информацию об удалении заметок в таблицу History--
IF OBJECT_ID('triggerDelete', 'TR') IS NOT NULL
    BEGIN
        DROP TRIGGER triggerDelete;
    end
GO

CREATE TRIGGER triggerDelete
    ON Notes
    FOR DELETE
    AS
BEGIN
    INSERT INTO History(NoteID, Operation)
    SELECT NoteID, 'Удалена заметка ' + NoteTitle
    FROM DELETED;
end;
GO

--Создаю процедуру для вывода заметок с помощью курсора--
IF OBJECT_ID('PrintNotes', 'P') IS NOT NULL
    BEGIN
        DROP PROCEDURE PrintNotes;
    END;

GO
CREATE PROCEDURE PrintNotes
AS
BEGIN
    DECLARE @NoteID INT;
    DECLARE @NoteTitle NVARCHAR(MAX);
    DECLARE @NoteText NVARCHAR(MAX);
    DECLARE @DateOfCreating DATETIME;

    DECLARE NotesCursor CURSOR FOR
        SELECT NoteID, NoteTitle, NoteText, CreatingDate
        FROM Notes;

    OPEN NotesCursor;
    FETCH NEXT FROM NotesCursor INTO @NoteID, @NoteTitle, @NoteText, @DateOfCreating;

    WHILE @@FETCH_STATUS = 0
        BEGIN
            PRINT 'NoteID: ' + CAST(@NoteID AS NVARCHAR) + ', Заголовок: ' + @NoteTitle + CHAR(10) + ' Текст заметки: ' + @NoteText + ' Время создания: ' + CAST (@DateOfCreating AS NVARCHAR);
            FETCH NEXT FROM NotesCursor INTO @NoteID, @NoteTitle, @NoteText, @DateOfCreating;
        END;

    CLOSE NotesCursor;
    DEALLOCATE NotesCursor;
END;
GO
--Вывод истории изменений--
IF OBJECT_ID('GetEditingHistory', 'P') IS NOT NULL
    BEGIN
        DROP PROCEDURE GetEditingHistory;
    END
GO
CREATE PROCEDURE GetEditingHistory
AS
BEGIN
    SELECT * FROM History;
END;

GO

--INFO--
IF OBJECT_ID('Info', 'P') IS NOT NULL
    BEGIN
        DROP PROCEDURE Info;
    END;
GO
CREATE PROCEDURE Info
AS
BEGIN
    PRINT 'Чтобы посмотреть все заметки введите команду: EXEC GetNotes' +
          CHAR(10) +'Чтобы создать новую заметку введите команду: EXEC AddNote и введите текст заголовка и текст заметки в одиночных кавычках' +
          CHAR(10) +'Чтобы просмотреть заметку введите команду: EXEC GetNote и номер ID заметки, которую хотите открыть' +
          CHAR(10) + 'Чтобы удалить заметку введите команду EXEC: DeleteNote и номер ID заметки' +
          CHAR(10) + 'Чтобы посмотреть историю изменений заметок введите команду EXEC GetEditingHistory';

END;
GO



