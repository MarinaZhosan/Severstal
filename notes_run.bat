@echo off
REM 
set SERVERNAME=localhost
set DATABASENAME=NotesApp

sqlcmd -S %LOCALHOST% -d %NOTESAPP% -E -i Notes.sql