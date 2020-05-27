REM QBASDOWN
REM version 0.1
REM A Markdown to HTML converter.
               
REM Usage: QBASDOWN.EXE Markdown_file
REM        QBASDOWN.EXE Markdown_file --verbose"

REM If no filename is given, the user is prompted for one.

REM Written for FreeDOS in QuickBASIC 4.5, mostly under
REM a hybrid DOSEMU/FreeDOS 1.2 installation, but the
REM final compilation in a release will always be tested on
REM bare silicon in a dedicated FreeDOS installation.

REM QuickBASIC? Why? To see if it could be done, I guess, and
REM also to re-familiarize myself with this BASIC dialect.
REM It should also compile in FreeBASIC, and maybe in QB64, but
REM why bother? Linux has dozens of Markdown implementations,
REM probably better than this one, too, but I don't know of
REM any on FreeDOS.

REM This program will ONLY work on DOS/Windows-formatted text files,
REM which end lines with CRLF. If no CRLF is detected in the first
REM 512 bytes of the file, it will tell the user to run a utility
REM such as UNIX2DOS. Most documents have at least a title line, so
REM that should not be a problem, but you can change that value in
REM the subroutine ChkDorU to 1024 or 2048 if you like, at the expanse
REM of some speed.

REM QBASDOWN is distributed as QuickBASIC source code and released as
REM a single OS executable, called QBASDOWN.EXE.

REM Please download the file TEST.MD and use QBASDOWN to convert it to HTML.
REM That will show you which aspects of Markdown I've so far managed to
REM implement in QuickBASIC.

REM The long-term goal is to implement all of Gruber's original Markdown,
REM plus selected extensions from MultiMarkdown and other developments,
REM a few modest ideas of my own (see the emoji section in test.md),
REM and some prettyprinting. Technically, I suppose that means I am
REM inventing a new dialect of Markdown. Fame at last!

REM This code needs a LOT of optimization. I know that. One specific
REM issue is that things need to be done in a very specific order.
REM Bad design and practice, that. One day I will fix it.

REM (c) Michel Clasquin-Johnson 2020
REM Released into the Public Domain.

DECLARE SUB ChkImg ()
DECLARE SUB ChkFCB (fence$)
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

REM Ugh, too many global variables. But let me get
REM this working before I clean it up
COMMON SHARED Printed%, Skip%, linecounter%, Verbose%, codeblock%
COMMON SHARED PastLine$, CurrentLine$, NextLine$, Infile$, OutFile$
COMMON SHARED a$()
OPTION BASE 1

REM Initialising ... not really necessary, but it reminds
REM me of what my global variables are

Infile$ = ""
OutFile$ = ""
CurrentLine$ = ""
PastLine$ = ""
NextLine$ = ""
Printed% = 0
linecounter% = 0
Skip% = 0
Verbose% = 0
codeblock% = 0

PRINT "QBASDOWN 0.1"
PRINT "A Markdown to HTML converter"

REM first check for InFile$
REM get a filename if none was given
GetInFile

REM check if InFile$ is formatted for DOS
REM Disable this if compiling for Linux
ChkDorU

REM start to construct OutFile$
MakeOutFile

REM find out how big this file is
GetFileSize

REM feed the file into an array
MakeArray

REM ####################################
REM ##########Main Loop#################
REM ####################################
FOR f = 1 TO linecounter%
        CurrentLine$ = a$(f)
        REM The PRINT statement: the debugger of the Stone Age
        REM PRINT CurrentLine$
        IF f > 1 THEN PastLine$ = a$(f - 1)
        IF f < linecounter% THEN NextLine$ = a$(f + 1)
        REM check if a previous pass ordered a skip
        REM in case of a line-style heading, code block, table etc
        ChkSkip

        REM code blocks
        REM spaces-delimited code block
        IF Printed% = 0 THEN ChkSDCB
        REM Fenced code block
        IF Printed% = 0 THEN CALL ChkFCB("~~~")
        REM IF Printed% = 0 THEN CALL ChkFCB("```")
        REM backticks SHOULD work, but they don't. I have no idea why.
        REM It picks up the code block opening but not the ending.

        REM first check things on their own line
        REM horizontal Rule
        IF Printed% = 0 THEN ChkHR
        REM Check for Images
        IF Printed% = 0 THEN ChkImg
        IF Printed% = o THEN ChkBQ

        REM check for links
        REM absolute links <www.google.com>
        IF Printed% = 0 THEN ChkAL
        REM inline links [google](www.google.com)
        IF Printed% = 0 THEN ChkIL

        REM check for things that affect the whole line, but may still  
        REM need to be checked for embeds
        REM Hash (atx) Headings
        IF Printed% = 0 THEN ChkHH
        REM Line (setext) Headings
        IF Printed% = 0 THEN ChkLH
       
        REM check for things that are embedded
        REM first, standalone codes (including some prettyprinting)
        IF Printed% = 0 THEN
                REM 2 spaces at end of line
                Chk2S
                REM transform selected charaters surrounded by spaces
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
                REM emojis
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
                REM blavk flag
                CALL ChkSolo("||p", "&#9873")
                REM white flag
                CALL ChkSolo("|p", "&#9872")
                CALL ChkSolo("-o-", "&#9940")
                REM telephone
                CALL ChkSolo("{||", "&#9743")
                REM prettyprinting
        END IF
       
        REM next, paired codes
        IF Printed% = 0 THEN
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

        END IF
       
        REM print an empty line
        IF Printed% = 0 THEN PrEL
       
        REM print line of plain text possibly with embeds
        REM This is the default
        IF Printed% = 0 THEN PRINT #2, CurrentLine$
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
                        leftpos% = INSTR(CurrentLine$, "<http:")
                        IF leftpos% = 0 THEN leftpos% = INSTR(CurrentLine$, "<https:")
                        IF leftpos% = 0 THEN leftpos% = INSTR(CurrentLine$, "<mailto:")
                        leftpos% = leftpos% + 1
                        linelen% = LEN(CurrentLine$)
                        FOR n = leftpos% TO linelen%
                              IF MID$(CurrentLine$, n, 1) = ">" THEN
                                rightpos% = n
                                EXIT FOR
                              END IF
                        NEXT n
                        URL$ = MID$(CurrentLine$, leftpos%, rightpos% - leftpos%)
                        IF Verbose% = 1 THEN PRINT "Found link: " + URL$
                        URL$ = "<a href=" + CHR$(34) + URL$ + CHR$(34) + ">" + URL$ + "</a>"
                        CurrentLine$ = LEFT$(CurrentLine$, leftpos% - 2) + URL$ + MID$(CurrentLine$, rightpos% + 1)

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
        REM PRINT a$
        CLOSE #1
        IF INSTR(a$, CHR$(13) + CHR$(10)) THEN
                EXIT SUB
        ELSE
                PRINT Infile$ + " does not look like a DOS-formatted text file!"
                PRINT "You may want to run UNIX2DOS or a similar utility first."
                SYSTEM
        END IF
END SUB

SUB ChkFCB (fence$)
        REM opening line
        IF codeblock% = 0 THEN
                IF LEFT$(CurrentLine$, 3) = fence$ AND LEFT$(PastLine$, 3) <> fence$ THEN
                        IF Verbose% = 1 THEN PRINT "Found a code block"
                        CurrentLine$ = "<pre><code><p style=background-color:LightGray;>"
                        Printed% = 1
                        codeblock% = 1
                        PRINT #2, CurrentLine$
                        EXIT SUB
                END IF
        END IF
        IF codeblock% = 1 THEN
                REM closing line
                IF INSTR(CurrentLine$, fence$) > 0 THEN
                        IF Verbose% = 1 THEN PRINT "Closing code block"
                        CurrentLine$ = "</code></pre>"
                        Printed% = 1
                        codeblock% = 0
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
                        midpos% = INSTR(CurrentLine$, "](") - 1
                        looper% = midpos%
                        DO UNTIL (looper% = 0)
                                IF (MID$(CurrentLine$, looper%, 1) = "[") THEN
                                       
                                        startpos% = looper% + 1
                                        Description$ = MID$(CurrentLine$, startpos%, midpos% - startpos% + 1)
                                        EXIT DO
                                END IF
                                looper% = looper% - 1
                        LOOP
                        IF Description$ = "" THEN EXIT SUB
                        REM PRINT Description$
                        midpos% = midpos% + 3
                       
                        looper% = midpos%
                        DO UNTIL (looper% = LEN(CurrentLine$) + 1)
                                IF MID$(CurrentLine$, looper%, 1) = ")" THEN
                                        rightpos% = looper%
                                        URL$ = MID$(CurrentLine$, midpos%, rightpos% - midpos%)
                                        IF Verbose% = 1 THEN PRINT "Found link: " + URL$
                                        EXIT DO
                                END IF
                                looper% = looper% + 1
                        LOOP
                        IF URL$ = "" THEN EXIT SUB
                        URL$ = "<a href=" + CHR$(34) + URL$ + CHR$(34) + ">" + Description$ + "</a>"
                        NewLine$ = MID$(CurrentLine$, 1, (startpos% - 2))
                        NewLine$ = NewLine$ + URL$
                        NewLine$ = NewLine$ + MID$(CurrentLine$, (rightpos% + 1))
                        CurrentLine$ = NewLine$
                WEND
        END IF

END SUB

SUB ChkImg
        IF LEFT$(CurrentLine$, 2) = "![" THEN
        CurrentLine$ = RTRIM$(CurrentLine$)
        midpoint% = INSTR(CurrentLine$, "](")
        Description$ = MID$(CurrentLine$, 3, midpoint% - 3)
        urlstart% = midpoint% + 2
        URL$ = MID$(CurrentLine$, urlstart%, LEN(CurrentLine$) - urlstart%)
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
                startpos% = INSTR(CurrentLine$, Pair$)
                CurrentLine$ = LEFT$(CurrentLine$, startpos% - 1) + Replacement$ + MID$(CurrentLine$, startpos% + PairLen%)

        WEND
END SUB

SUB ChkSDCB
        IF LEFT$(CurrentLine$, 4) = "    " AND LEFT$(PastLine$, 4) <> "    " THEN
                IF Verbose% = 1 THEN PRINT "Found a code block"
                CurrentLine$ = "<pre><code><p style=background-color:LightGray;>" + MID$(CurrentLine$, 5)
                PRINT #2, CurrentLine$
                Printed% = 1
        ELSEIF LEFT$(CurrentLine$, 4) = "    " AND LEFT$(PastLine$, 4) = "    " AND LEFT$(NextLine$, 4) = "    " THEN
                CurrentLine$ = MID$(CurrentLine$, 5)
                PRINT #2, CurrentLine$
                Printed% = 1
        ELSEIF LEFT$(CurrentLine$, 4) = "    " AND LEFT$(NextLine$, 4) <> "    " THEN
                CurrentLine$ = MID$(CurrentLine$, 5) + "</code></pre>"
                PRINT #2, CurrentLine$
                Printed% = 1
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
                startpos% = INSTR(CurrentLine$, Original$)
                CurrentLine$ = LEFT$(CurrentLine$, startpos% - 1) + Replacement$ + MID$(CurrentLine$, startpos% + OrLen%)
        WEND
END SUB

SUB GetFileSize
        OPEN Infile$ FOR INPUT AS #1
        WHILE NOT (EOF(1))
                LINE INPUT #1, CurrentLine$
                linecounter% = linecounter% + 1
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
        DIM a$(linecounter%)
        OPEN Infile$ FOR INPUT AS #1
        FOR f = 1 TO linecounter%
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
        PRINT #2, "<body>"
END SUB

SUB PrEL
        REM OK, don't look too closely at this beastly hack
        REM Luckily HTML is very forgiving
        IF CurrentLine$ = "" THEN
                PRINT #2, "</p><p>"
                Printed% = 1
        END IF
END SUB

