;CONSOLE CONTROLS
; based on a script from the ahkscript.org forums
Cadd(text, exception := "", lineNumber := "")
{
   global
   FormatTime, NowStamp, %A_now%, HH:mm:ss

   if (lineNumber != "")
      text := lineNumber . " " . text

   text := NowStamp . "   " . text


   if (exception != "")
   {
      text := text . " !Exception! `n" . A_Tab . "what: " exception.what "`n" . A_Tab . "file: " exception.file . "`n" . A_Tab . "line: " exception.line "`n" . A_Tab . "message: " exception.message "`n" . A_Tab . "extra: " exception.extra
   }

   Ctext := text . "`n" . Ctext ;newest lines on top of course
   GuiControl,consoleLog:, Ctext, %Ctext%
}

Cclear()
{
   global
   FormatTime, NowStamp, %A_now%, HH:mm:ss
   Ctext := "## " . NowStamp . " - CLEAR"
   GuiControl,, Ctext, %Ctext%
}

Cexport(filename = 0)
{
   Global Ctext
   If !filename
   {
      filename := a_scriptdir . "\ConsoleExport" . A_now . ".txt"
   }

   FileAppend, %Ctext%, %filename%
   Run, Notepad.exe %filename%

   Return
}

Cfile(file,text)
{
   filename := a_scriptdir . "\" . file

   FileAppend, %text%, %filename%

   Return
}

Cinit()
{
   global
   ;; LOG CONSOLE GUI
   Gui, consoleLog:Add, Edit, w400 h200 vCtext hScroll, %Ctext%
   Gui, consoleLog:Add, Button, gCexport y+5 x+-200, EXPORT
   Gui, consoleLog:Add, Button, gCclear yp+0 x+-150, CLEAR
   Gui, consoleLog:show, AutoSize x0 y0
}

Cdestroy()
{
   Gui, consoleLog:destroy
}

Cexport:
   Cexport()
return

Cclear:
   Cclear()
return