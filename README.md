# Severstal
Проект заметки для стажировки в компании Северсталь

Я реализовала приложение "Заметки" в соответствии с техническим заданием. Приложение разработано с использованием T-SQL для использования через консоль, TSQLCMD или Microsoft SQL Server Management Studio

Функциональные возможности 
• Создание заметок: Пользователь может создавать новые заметки. 
• Редактирование заметок: В приложении предусмотрена возможность редактирования существующих заметок. 
• Удаление заметок: Пользователь может удалять ненужные заметки. 
• Получение всех заметок 
• Получение заметки по ID 
• Просмотр истории изменений заметок 

Заметки сохраняются и надежно хранятся в базе данных MS SQL Server, обеспечивая их сохранность между сеансами использования приложения.

Особенности При первом запуске приложения автоматически создается заметка по умолчанию с описанием функционала приложения, чтобы пользователь мог сразу ознакомиться с его возможностями.

Команды для использования приложения: 
  EXEC GetNotes - просмотр всех заметок
  Для создания новой заметки введите: EXEC AddNote текст заголовка и текст заметки  
  Для редактирования заметки введите: EXEC EditNote и номер ID заметки, которую нужно изменить, новый заголовок и новый текст заметки
  Для просмотра заметки введите команду: EXEC GetNote и номер ID заметки, которую хотите открыть  
  Для удаления заметки введите команду: EXEC DeleteNote и номер ID заметки
  Для просмотра истории изменений заметок введите команду: EXEC GetEditingHistory

Для запуска приложения требуется создать БД с названием NotesApp и подключить его в IntelliJ IDEA для использования через консоль

Также вы можете запустить его через командную строку. 
Для этого убедитесь, что у вас есть SQLCMD. Затем отредактируйте файл run_notes.bat, если неободимо, указав имя сервера и имя БД, запустите его, для настройки подключения к БД.
В командной строке введите sqlcmd -S SEREVERNAME -D DATABASENAME -E
где SERVERNAME и DATABASENAME - соответственно имя сервера и имя БД
Настройки расчитаны на использование Windows Authentication для подключения к БД
