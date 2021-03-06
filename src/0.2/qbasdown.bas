REM QBASDOWN
REM version 0.1
REM A Markdown to HTML converter.
REM          
REM Usage: QBASDOWN.EXE Markdown_file
REM        QBASDOWN.EXE Markdown_file --verbose"
REM
REM If no filename is given, the user is prompted for one.
REM
REM Written for FreeDOS in QuickBASIC 4.5, mostly under
REM a hybrid DOSEMU/FreeDOS 1.2 installation, but the
REM final compilation in a release will always be tested on
REM bare silicon in a dedicated FreeDOS installation.
REM
REM QuickBASIC? Why? To see if it could be done, I guess, and
REM also to re-familiarize myself with this BASIC dialect.
REM It should also compile in FreeBASIC, and maybe in QB64, but
REM why bother? Linux has dozens of Markdown implementations,
REM probably better than this one, too, but I don't know of
REM any on FreeDOS.
REM
REM This program will ONLY work on DOS/Windows-formatted text files,
REM which end lines with CRLF. If no CRLF is detected in the first
REM 512 bytes of the file, it will tell the user to run a utility
REM such as UNIX2DOS. Most documents have at least a title line, so
REM that should not be a problem, but you can change that value in
REM the subroutine ChkDorU to 1024 or 2048 if you like, at the expanse
REM of some speed.
REM
REM QBASDOWN is distributed as QuickBASIC source code and released as
REM a single OS executable, called QBASDOWN.EXE.
REM
REM Please download the file TEST.MD and use QBASDOWN to convert it to HTML.
REM That will show you which aspects of Markdown I've so far managed to
REM implement in QuickBASIC.
REM
REM The long-term goal is to implement all of Gruber's original Markdown,
REM plus selected extensions from MultiMarkdown and other developments,
REM a few modest ideas of my own (see the emoji section in test.md),
REM and some prettyprinting. Technically, I suppose that means I am
REM inventing a new dialect of Markdown. Fame at last!
REM
REM This code needs a LOT of optimization. I know that. One specific
REM issue is that things need to be done in a very specific order.
REM Bad design and practice, that. One day I will fix it.
REM
REM (c) Michel Clasquin-Johnson 2020
REM Released into the Public Domain.
REM
DECLARE SUB MLTbls ()
DECLARE SUB ChkTblData (cols%, LineEnd$, c$())
DECLARE SUB ChkTblCls ()
DECLARE SUB ChkTblHdr ()
DECLARE SUB ChkImg ()
DECLARE SUB ChkFCB (Fence$)
DECLARE SUB GetInFile ()
DECLARE SUB ChkH4Stuff ()
DECLARE SUB ChkSDCB ()
DECLARE SUB ChkHR ()
DECLARE SUB ChkLH ()
DECLARE SUB GetFileSize ()
DECLARE SUB ChkHH ()
DECLARE SUB ChkSkip ()
DECLARE SUB Chk2S ()
DECLARE SUB PrEL ()
DECLARE SUB MakeOutFile ()
DECLARE SUB MakeArray ()
DECLARE SUB ChkAL ()
DECLARE SUB ChkIL ()
DECLARE SUB ChkDorU ()
DECLARE SUB ChkBQ ()
DECLARE SUB ChkSolo (Original$, Replacement$)
DECLARE SUB ChkPair (Pair$, StartReplacement$, EndReplacement$)
DECLARE SUB MLSolo ()
DECLARE SUB MLSoloChars ()
DECLARE SUB MLSoloEmoji ()
DECLARE SUB MLSoloMisc ()
DECLARE SUB MLPairs ()
DECLARE SUB MLBlocks ()
DECLARE SUB MLLinks ()
DECLARE SUB MLHeads ()
REM
REM Ugh, too many global variables. But let me get
REM this working before I clean it up
COMMON SHARED Printed%, Skip%, LineCounter%, Verbose%, CodeBlock%
COMMON SHARED PastLine$, CurrentLine$, NextLine$, Infile$, OutFile$
COMMON SHARED a$()
OPTION BASE 1
REM
REM Initialising ... not really necessary, but it reminds
REM me of what my global variables are
REM
Infile$ = ""
OutFile$ = ""
CurrentLine$ = ""
PastLine$ = ""
NextLine$ = ""
Printed% = 0
LineCounter% = 0
Skip% = 0
Verbose% = 0
CodeBlock% = 0
REM
PRINT "QBASDOWN 0.1"
PRINT "A Markdown to HTML converter"
REM
REM first check for InFile$
REM get a filename if none was given
GetInFile
REM
REM check if InFile$ is formatted for DOS
REM Disable this if compiling for Linux
ChkDorU
REM
REM start to construct OutFile$
MakeOutFile
REM
REM find out how big this file is
GetFileSize
REM
REM feed the file into an array
MakeArray
REM
REM ####################################
REM ##########Main Loop#################
REM ####################################
FOR f = 1 TO LineCounter%
    CurrentLine$ = a$(f)
    REM The PRINT statement: the debugger of the Stone Age
    REM PRINT CurrentLine$
    IF f > 1 THEN PastLine$ = a$(f - 1)
    IF f < LineCounter% THEN NextLine$ = a$(f + 1)
    REM
    REM check if a previous pass ordered a skip
    REM mainly for line-style headings
    ChkSkip
    REM
    REM code blocks
    IF Printed% = 0 THEN MLBlocks
    REM
    REM Check for tables
    IF Printed% = 0 THEN MLTbls
    REM
    REM check for horizontal Rule
    ChkHR
    REM
    REM Check for Images
    ChkImg
    REM
    REM check for links
    IF Printed% = 0 THEN MLLinks
    REM
    REM check for Headings
    IF Printed% = 0 THEN MLHeads
    REM
    REM check for things that are embedded
    IF Printed% = 0 THEN MLSolo
    REM
    REM next, paired codes
    IF Printed% = 0 THEN MLPairs
    REM
    REM print an empty line
    IF Printed% = 0 THEN PrEL
    REM
    REM print line of plain text, possibly with embeds
    REM This is the default
    IF Printed% = 0 THEN PRINT #2, CurrentLine$
    REM
    REM reinitialize the values for the lines we are using
    REM not really necessary, but I like to clean things up
    CurrentLine$ = "": PastLine$ = "": NextLine$ = ""
    REM but this one is important
    Printed% = 0
NEXT f
REM ####################################
REM #######End of Main Loop#############
REM ####################################
PRINT #2, "</body>"
PRINT #2, "</html>"
CLOSE
PRINT "Done"
SYSTEM

SUB Chk2S
    IF RIGHT$(CurrentLine$, 2) = "  " AND RIGHT$(PastLine$, 2) <> "  " THEN
        CurrentLine$ = "<p>" + MID$(CurrentLine$, 1, LEN(CurrentLine$) - 2) + "<br />"
        IF Verbose% = 1 THEN PRINT "Found a single-spacing block"
    ELSEIF RIGHT$(CurrentLine$, 2) = "  " AND RIGHT$(PastLine$, 2) = "  " THEN
        CurrentLine$ = MID$(CurrentLine$, 1, LEN(CurrentLine$) - 2) + "<br />"
    ELSEIF RIGHT$(CurrentLine$, 2) <> "  " AND RIGHT$(PastLine$, 2) = "  " THEN
         CurrentLine$ = CurrentLine$ + "</p>"
    END IF
END SUB

SUB ChkAL
    IF INSTR(CurrentLine$, "<www.") + INSTR(CurrentLine$, "<http:") + INSTR(CurrentLine$, "<https:") + INSTR(CurrentLine$, "<mailto:") = 0 THEN
        EXIT SUB
     ELSE
        WHILE (INSTR(CurrentLine$, "<http:") OR INSTR(CurrentLine$, "<https:") OR INSTR(CurrentLine$, "<mailto:")) AND INSTR(CurrentLine$, ">")
            LeftPos% = INSTR(CurrentLine$, "<http:")
            IF LeftPos% = 0 THEN LeftPos% = INSTR(CurrentLine$, "<https:")
            IF LeftPos% = 0 THEN LeftPos% = INSTR(CurrentLine$, "<mailto:")
            LeftPos% = LeftPos% + 1
            LineLen% = LEN(CurrentLine$)
                FOR n = LeftPos% TO LineLen%
                    IF MID$(CurrentLine$, n, 1) = ">" THEN
                        RightPos% = n
                         EXIT FOR
                    END IF
                NEXT n
                URL$ = MID$(CurrentLine$, LeftPos%, RightPos% - LeftPos%)
                IF Verbose% = 1 THEN PRINT "Found link: " + URL$
                URL$ = "<a href=" + CHR$(34) + URL$ + CHR$(34) + ">" + URL$ + "</a>"
                CurrentLine$ = LEFT$(CurrentLine$, LeftPos% - 2) + URL$ + MID$(CurrentLine$, RightPos% + 1)
        WEND
    END IF
END SUB

SUB ChkBQ
    WHILE LEFT$(CurrentLine$, 1) = ">"
       CurrentLine$ = "<blockquote>" + MID$(CurrentLine$, 2) + "</blockquote>"
    WEND
END SUB

SUB ChkDorU
    OPEN Infile$ FOR INPUT AS #1
    a$ = INPUT$(512, #1)
    CLOSE #1
    IF INSTR(a$, CHR$(13) + CHR$(10)) THEN
        EXIT SUB
    ELSE
        PRINT Infile$ + " does not look like a DOS-formatted text file!"
        PRINT "You may want to run UNIX2DOS or a similar utility first."
        SYSTEM
    END IF
END SUB

SUB ChkFCB (Fence$)
    REM opening line
    IF CodeBlock% = 0 THEN
        IF LEFT$(CurrentLine$, 3) = Fence$ AND LEFT$(PastLine$, 3) <> Fence$ THEN
           IF Verbose% = 1 THEN PRINT "Found a code block"
           CurrentLine$ = "<pre><code><p style=background-color:LightGray;>"
           Printed% = 1
           CodeBlock% = 1
           PRINT #2, CurrentLine$
           EXIT SUB
        END IF
    END IF
    IF CodeBlock% = 1 THEN
        REM closing line
        IF INSTR(CurrentLine$, Fence$) > 0 THEN
            IF Verbose% = 1 THEN PRINT "Closing code block"
            CurrentLine$ = "</code></pre>"
            Printed% = 1
            CodeBlock% = 0
            PRINT #2, CurrentLine$
            EXIT SUB
        REM middle lines
        ELSE
            Printed% = 1
            PRINT #2, CurrentLine$
            EXIT SUB
        END IF
    END IF
END SUB

SUB ChkH4Stuff
    REM check for links
    REM absolute links <www.google.com>
    ChkAL
    REM inline links [google](www.google.com)
    ChkIL
    REM italic
    CALL ChkPair("_", "<em>", "</em>")
    CALL ChkPair("*", "<em>", "</em>")
END SUB

SUB ChkHH
    IF LEFT$(CurrentLine$, 2) = "# " THEN
        IF Verbose% = 1 THEN PRINT "Found Header 1"
        CurrentLine$ = "<h1>" + MID$(CurrentLine$, 2) + "</h1>"
        CALL ChkH4Stuff
        PRINT #2, CurrentLine$
        Printed% = 1
    ELSEIF LEFT$(CurrentLine$, 3) = "## " THEN
        IF Verbose% = 1 THEN PRINT "Found Header 2"
        CurrentLine$ = "<h2>" + MID$(CurrentLine$, 3) + "</h2>"
        CALL ChkH4Stuff
        PRINT #2, CurrentLine$
        Printed% = 1
    ELSEIF LEFT$(CurrentLine$, 4) = "### " THEN
        IF Verbose% = 1 THEN PRINT "Found Header 3"
        CurrentLine$ = "<h3>" + MID$(CurrentLine$, 4) + "</h3>"
        CALL ChkH4Stuff
        PRINT #2, CurrentLine$
        Printed% = 1
    ELSEIF LEFT$(CurrentLine$, 5) = "#### " THEN
        IF Verbose% = 1 THEN PRINT "Found Header 4"
        CurrentLine$ = "<h4>" + MID$(CurrentLine$, 5) + "</h4>"
        CALL ChkH4Stuff
        PRINT #2, CurrentLine$
        Printed% = 1
    ELSEIF LEFT$(CurrentLine$, 6) = "##### " THEN
        IF Verbose% = 1 THEN PRINT "Found Header 5"
        CurrentLine$ = "<h5>" + MID$(CurrentLine$, 6) + "</h5>"
        CALL ChkH4Stuff
        PRINT #2, CurrentLine$
        Printed% = 1
    ELSEIF LEFT$(CurrentLine$, 7) = "###### " THEN
        IF Verbose% = 1 THEN PRINT "Found Header 6"
        CurrentLine$ = "<h6>" + MID$(CurrentLine$, 7) + "</h6>"
        CALL ChkH4Stuff
        PRINT #2, CurrentLine$
        Printed% = 1
    END IF
END SUB

SUB ChkHR
    IF LEFT$(CurrentLine$, 3) = "---" AND PastLine$ = "" THEN
        IF Verbose% = 1 THEN PRINT "Found Horizontal rule"
        CurrentLine$ = "<hr />"
        PRINT #2, CurrentLine$
        Printed% = 1
    END IF
END SUB

SUB ChkIL
    IF INSTR(CurrentLine$, "](") + INSTR(CurrentLine$, "www.") + INSTR(CurrentLine$, "http:") + INSTR(CurrentLine$, "https:") + INSTR(CurrentLine$, "mailto:") = 0 THEN
        EXIT SUB
    ELSE
        WHILE INSTR(CurrentLine$, "](") <> 0
            MidPos% = INSTR(CurrentLine$, "](") - 1
            Looper% = MidPos%
            DO UNTIL (Looper% = 0)
                IF (MID$(CurrentLine$, Looper%, 1) = "[") THEN
                    StartPos% = Looper% + 1
                    Description$ = MID$(CurrentLine$, StartPos%, MidPos% - StartPos% + 1)
                    EXIT DO
                END IF
                Looper% = Looper% - 1
            LOOP
            IF Description$ = "" THEN EXIT SUB
            MidPos% = MidPos% + 3
            Looper% = MidPos%
            DO UNTIL (Looper% = LEN(CurrentLine$) + 1)
                IF MID$(CurrentLine$, Looper%, 1) = ")" THEN
                    RightPos% = Looper%
                    URL$ = MID$(CurrentLine$, MidPos%, RightPos% - MidPos%)
                    IF Verbose% = 1 THEN PRINT "Found link: " + URL$
                    EXIT DO
                END IF
                Looper% = Looper% + 1
            LOOP
            IF URL$ = "" THEN EXIT SUB
            URL$ = "<a href=" + CHR$(34) + URL$ + CHR$(34) + ">" + Description$ + "</a>"
            NewLine$ = MID$(CurrentLine$, 1, (StartPos% - 2))
            NewLine$ = NewLine$ + URL$
            NewLine$ = NewLine$ + MID$(CurrentLine$, (RightPos% + 1))
            CurrentLine$ = NewLine$
        WEND
    END IF
END SUB

SUB ChkImg
    IF LEFT$(CurrentLine$, 2) = "![" THEN
        CurrentLine$ = RTRIM$(CurrentLine$)
        MidPoint% = INSTR(CurrentLine$, "](")
        Description$ = MID$(CurrentLine$, 3, MidPoint% - 3)
        URLStart% = MidPoint% + 2
        URL$ = MID$(CurrentLine$, URLStart%, LEN(CurrentLine$) - URLStart%)
        IF Verbose% = 1 THEN PRINT "Found image: " + URL$
        CurrentLine$ = "<p><image alt=" + Description$
        CurrentLine$ = CurrentLine$ + " src=" + CHR$(34) + URL$ + CHR$(34) + " /></p>"
        PRINT #2, CurrentLine$
        Printed% = 1
    END IF
END SUB

SUB ChkLH
    IF LEFT$(NextLine$, 3) = "===" AND CurrentLine$ <> "" THEN
        IF Verbose% = 1 THEN PRINT "Found Header 1"
        CurrentLine$ = "<h1>" + CurrentLine$ + "</h1>"
        ChkH4Stuff
        PRINT #2, CurrentLine$
        Printed% = 1
        Skip% = 1
    ELSEIF LEFT$(NextLine$, 3) = "---" AND CurrentLine$ <> "" THEN
        IF Verbose% = 1 THEN PRINT "Found Header 2"
        CurrentLine$ = "<h2>" + CurrentLine$ + "</h2>"
        ChkH4Stuff
        PRINT #2, CurrentLine$
        Printed% = 1
        Skip% = 1
    END IF
END SUB

SUB ChkPair (Pair$, StartReplacement$, EndReplacement$)
    PairLen% = LEN(Pair$)
    Replaced% = 0
    REM assumes that opening and closing codes are in the same line
    REM inform user of this limitation
    WHILE INSTR(CurrentLine$, Pair$)
        IF Replaced% = 0 THEN
            IF Verbose% = 1 THEN PRINT "Opening paired code"
            Replacement$ = StartReplacement$
            Replaced% = 1
        ELSE
            IF Verbose% = 1 THEN PRINT "Closing paired code"
            Replacement$ = EndReplacement$
            Replaced% = 0
        END IF
        StartPos% = INSTR(CurrentLine$, Pair$)
        CurrentLine$ = LEFT$(CurrentLine$, StartPos% - 1) + Replacement$ + MID$(CurrentLine$, StartPos% + PairLen%)
    WEND
END SUB

SUB ChkSDCB
    IF LEFT$(CurrentLine$, 4) <> "    " THEN
        EXIT SUB
    ELSE
        REM only line
        IF LEFT$(PastLine$, 4) <> "    " AND LEFT$(NextLine$, 4) <> "    " THEN
            CurrentLine$ = "<pre><code><p style=background-color:LightGray;>" + MID$(CurrentLine$, 5) + "</code></pre>"
            PRINT #2, CurrentLine$
            Printed% = 1
            EXIT SUB
        REM First line
        ELSEIF LEFT$(PastLine$, 4) <> "    " THEN
            IF Verbose% = 1 THEN PRINT "Found a code block"
            CurrentLine$ = "<pre><code><p style=background-color:LightGray;>" + MID$(CurrentLine$, 5)
            PRINT #2, CurrentLine$
            Printed% = 1
            EXIT SUB
        REM middle lines
        ELSEIF LEFT$(PastLine$, 4) = "    " AND LEFT$(NextLine$, 4) = "    " THEN
            CurrentLine$ = MID$(CurrentLine$, 5)
            PRINT #2, CurrentLine$
            Printed% = 1
            EXIT SUB
        REM last line
        ELSEIF LEFT$(NextLine$, 4) <> "    " THEN
            CurrentLine$ = MID$(CurrentLine$, 5) + "</code></pre>"
            PRINT #2, CurrentLine$
            Printed% = 1
            EXIT SUB
        END IF
    END IF
END SUB

SUB ChkSkip
    IF Skip% = 1 THEN
        Printed% = 1
        Skip% = 0
    END IF
END SUB

SUB ChkSolo (Original$, Replacement$)
    OrLen% = LEN(Original$)
    Replaced% = 0
    WHILE INSTR(CurrentLine$, Original$)
        IF Verbose% = 1 THEN PRINT "Found reserved character or emoji"
        StartPos% = INSTR(CurrentLine$, Original$)
        CurrentLine$ = LEFT$(CurrentLine$, StartPos% - 1) + Replacement$ + MID$(CurrentLine$, StartPos% + OrLen%)
    WEND
END SUB

SUB ChkTblCls
    PRINT #2, "</table>"
END SUB

SUB ChkTblData (cols%, LineEnd$, c$())
    WorkingLine$ = LTRIM$(RTRIM$(CurrentLine$))
    PRINT #2, "<tr>"
    Current% = 1
    DIM b$(cols%)
    IF LEFT$(WorkingLine$, 1) = "|" THEN WorkingLine$ = MID$(WorkingLine$, 2)
    FOR f = 1 TO LEN(WorkingLine$)
        IF MID$(WorkingLine$, f, 1) <> "|" THEN
            b$(Current%) = b$(Current%) + MID$(WorkingLine$, f, 1)
        ELSE
           Current% = Current% + 1
        END IF
    NEXT f
    FOR f = 1 TO cols%
        PRINT #2, "<" + LineEnd$ + " style=" + c$(f) + ">" + LTRIM$(RTRIM$(b$(f))) + "</" + LineEnd$ + "d>"
    NEXT f
    PRINT #2, "</tr>"
END SUB

SUB ChkTblHdr
    PRINT #2, "<table>"
END SUB

SUB GetFileSize
    OPEN Infile$ FOR INPUT AS #1
    WHILE NOT (EOF(1))
        LINE INPUT #1, CurrentLine$
        LineCounter% = LineCounter% + 1
    WEND
    CLOSE #1
END SUB

SUB GetInFile
    Infile$ = COMMAND$
    IF INSTR(Infile$, "--VERBOSE") <> 0 THEN
        Verbose% = 1
        Infile$ = RTRIM$(LEFT$(Infile$, LEN(Infile$) - 10))
    END IF
    IF Infile$ = "" THEN
        PRINT
        PRINT "Usage: QBASDOWN.EXE <Markdown_file)"
        PRINT "       QBASDOWN.EXE <Markdown_file) --verbose"
        PRINT
        INPUT "Filename to convert?", Infile$
        PRINT
    END IF
    REM if user did not give a filename then exit
    IF Infile$ = "" THEN
        PRINT "No filename given. Exiting ..."
        SYSTEM
    END IF
    REM check if file exists by deliberately
    REM crashing the application if it doesn't!
    REM I'll fix that later ...
    REM OPEN Infile$ FOR INPUT AS #1
    CLOSE #1
END SUB

SUB MakeArray
    DIM a$(LineCounter%)
    OPEN Infile$ FOR INPUT AS #1
    FOR f = 1 TO LineCounter%
        LINE INPUT #1, CurrentLine$
        a$(f) = CurrentLine$
    NEXT f
    CLOSE #1
END SUB

SUB MakeOutFile
    pointpos% = INSTR(Infile$, ".") - 1
    IF pointpos% <> -1 THEN
        REM there is an extension
        OutFile$ = LEFT$(Infile$, pointpos%) + ".HTM"
    ELSE
        REM there is no extension
        OutFile$ = LEFT$(Infile$, 8) + ".HTM"
    END IF
    PRINT "Results will be placed in " + OutFile$ + " in the current directory."
    OPEN OutFile$ FOR OUTPUT AS #2
    PRINT #2, "<html>"
    PRINT #2, "<head><style> table,th {border: 1px solid black; padding: 5px;}"
    REM PRINT #2, "td {border-collapse=collapse;}"
    PRINT #2, "</style>"
    PRINT #2, "</head>"
    PRINT #2, "<body>"
END SUB

SUB MLBlocks
    REM do not remove the IF Printed% ... statements
    REM spaces-delimited code block
    IF Printed% = 0 THEN ChkSDCB
    REM
    REM Fenced code block
    IF Printed% = 0 THEN CALL ChkFCB("~~~")
    REM IF Printed% = 0 THEN CALL ChkFCB("```")
    REM backticks SHOULD work, but they don't. I have no idea why.
    REM unless it is because QuickBASIC uses backticks as asynonym for REM.
    REM It picks up the code block opening but not the ending.
    REM
    REM check for block quotes
    IF Printed% = 0 THEN ChkBQ
END SUB

SUB MLHeads
    REM do not remove IF Printed% ... statements
    REM Hash (atx) Headings
    IF Printed% = 0 THEN ChkHH
    REM Line (setext) Headings
    IF Printed% = 0 THEN ChkLH
END SUB

SUB MLLinks
    REM absolute links <www.google.com>
    ChkAL
    REM inline links [google](www.google.com)
    ChkIL
END SUB

SUB MLPairs
    REM do not change the order of the next three
    REM bold italic
    CALL ChkPair("___", "<em><strong>", "</em></strong>")
    CALL ChkPair("***", "<em><strong>", "</em></strong>")
    REM bold
    CALL ChkPair("__", "<strong>", "</strong>")
    CALL ChkPair("**", "<strong>", "</strong>")
    REM italic
    CALL ChkPair("_", "<em>", "</em>")
    CALL ChkPair("*", "<em>", "</em>")
    REM strikethrough
    CALL ChkPair("~~", "<strike>", "</strike>")
    REM monospace
    CALL ChkPair("`", "<code>", "</code>")
    REM underline
    CALL ChkPair("--", "<u>", "</u>")
END SUB

SUB MLSolo
    MLSoloChars
    MLSoloEmoji
    MLSoloMisc
END SUB

SUB MLSoloChars
    REM transform certain characters surrounded by spaces
    REM asterisk
    CALL ChkSolo(" * ", " &#42 ")
    REM at sign
    CALL ChkSolo(" @ ", " &#64 ")
    REM ampersand
    CALL ChkSolo(" & ", " &#38 ")
    REM left arrow
    CALL ChkSolo(" < ", " &#60 ")
    REM right arrow
    CALL ChkSolo(" > ", " &#62 ")
    REM slash
    CALL ChkSolo(" / ", " &#47 ")
    REM backslash
    CALL ChkSolo(" \ ", " &#92 ")
    REM underscore
    CALL ChkSolo(" _ ", " &#95 ")
    REM hyphen
    CALL ChkSolo(" - ", " &#45 ")
    REM transform escaped characters
    REM asterisk
    CALL ChkSolo("\*", "&#42")
    REM at sign
    CALL ChkSolo("\@", "&#64")
    REM ampersand
    CALL ChkSolo("\&", "&#38")
    REM left arrow
    CALL ChkSolo("\<", "&#60")
    REM right arrow
    CALL ChkSolo("\>", "&#62")
    REM slash
    CALL ChkSolo("\/", "&#47")
    REM backslash
    CALL ChkSolo("\\", "&#92")
    REM underscore
    CALL ChkSolo("\_", "&#95")
    REM hyphen
    CALL ChkSolo("\-", "&#45")
    REM pipe
    CALL ChkSolo("\|", "&#124")
END SUB

SUB MLSoloEmoji
    REM white smiley face
    CALL ChkSolo(":-)", "&#9786")
    REM white angry face
    CALL ChkSolo(":-(", "&#9785")
    REM black smiley face
    CALL ChkSolo(":)", "&#9787")
    REM do not change the order of the arrows!
    REM double left arrow
    CALL ChkSolo("<=", "&#8656")
    REM double right arrow
    CALL ChkSolo("=>", "&#8658")
    REM double up arrow
    CALL ChkSolo("||^||", "&#8657")
    REM double down arrow
    CALL ChkSolo("||v||", "&#8659")
    REM left arrow
    CALL ChkSolo("<-", "&#8592")
    REM right arrow
    CALL ChkSolo("->", "&#8594")
    REM up arrow
    CALL ChkSolo("|^|", "&#8593")
    REM down arrow
    CALL ChkSolo("|v|", "&#8595")
    REM empty box
    CALL ChkSolo("|b|", "&#9744")
    REM checked box
    CALL ChkSolo("|c|", "&#9745")
    REM box with x
    CALL ChkSolo("|x|", "&#9746")
    REM radioactive
    CALL ChkSolo("(X)", "&#9762")
    REM skull & crossbones
    CALL ChkSolo("%X", "&#9760")
    REM musical notes
    CALL ChkSolo("d-d", "&#9836")
    REM recycle
    CALL ChkSolo("{o}", "&#9851")
    REM black flag
    CALL ChkSolo("||p", "&#9873")
    REM white flag
    CALL ChkSolo("|p", "&#9872")
    CALL ChkSolo("-o-", "&#9940")
    REM telephone
    CALL ChkSolo("{||", "&#9743")
END SUB

SUB MLSoloMisc
    REM 2 spaces at end of line
    Chk2S
END SUB

SUB MLTbls STATIC
    IF LEFT$(LTRIM$(CurrentLine$), 1) <> "|" AND RIGHT$(RTRIM$(CurrentLine$), 1) <> "|" THEN
        EXIT SUB
    ELSE
        IF cols% = 0 THEN
            GOSUB getCols
            DIM c$(cols%)
        END IF
        REM headerline
        REM do both this and the next one, then skip
        IF LEFT$(LTRIM$(PastLine$), 1) <> "|" THEN
            ChkTblHdr
            GOSUB chkdlmtr
            CALL ChkTblData(cols%, "th", c$())
            Skip% = 1
        REM closing line
        ELSEIF LEFT$(LTRIM$(NextLine$), 1) <> "|" THEN
            REM italic
            CALL ChkPair("_", "<em>", "</em>")
            CALL ChkPair("*", "<em>", "</em>")
            REM
            CALL ChkTblData(cols%, "td", c$())
            ChkTblCls
        REM regular data line
        ELSE
        REM italic
        CALL ChkPair("_", "<em>", "</em>")
        CALL ChkPair("*", "<em>", "</em>")
        REM
        CALL ChkTblData(cols%, "td", c$())
        END IF
        Printed% = 1
    END IF
    EXIT SUB
getCols:
    REM old-fashioned subroutine to calculate the number of columns
    REM Yes I tried a function, but it crashed my stack space. This works.
    cols% = 0
    FOR f = 2 TO LEN(CurrentLine$)
        IF MID$(CurrentLine$, f, 1) = "|" THEN cols% = cols% + 1
    NEXT f
    RETURN
chkdlmtr:
    REM old-fashioned subroutine to work out the alignment
    WorkingLine$ = LTRIM$(RTRIM$(NextLine$))
    Current% = 1
    IF LEFT$(WorkingLine$, 1) = "|" THEN WorkingLine$ = MID$(WorkingLine$, 2)
    FOR f = 1 TO LEN(WorkingLine$)
        IF MID$(WorkingLine$, f, 1) <> "|" THEN
            c$(Current%) = c$(Current%) + MID$(WorkingLine$, f, 1)
        ELSE
           Current% = Current% + 1
        END IF
    NEXT f
    FOR f = 1 TO cols%
        IF LEFT$(c$(f), 1) = ":" AND RIGHT$(c$(f), 1) = ":" THEN
            c$(f) = CHR$(34) + "text-align:center" + CHR$(34)
        ELSEIF LEFT$(c$(f), 1) = ":" AND RIGHT$(c$(f), 1) <> ":" THEN
            c$(f) = CHR$(34) + "text-align:left" + CHR$(34)
        ELSEIF LEFT$(c$(f), 1) <> ":" AND RIGHT$(c$(f), 1) = ":" THEN
            c$(f) = CHR$(34) + "text-align:right" + CHR$(34)
        END IF
    NEXT f
    RETURN
END SUB

SUB PrEL
    REM OK, don't look too closely at this beastly hack
    REM Luckily HTML is very forgiving
    IF CurrentLine$ = "" THEN
        PRINT #2, "</p><p>"
        Printed% = 1
    END IF
END SUB

