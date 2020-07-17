REM QBASDOWN
REM version 0.8
REM A Markdown to HTML converter.
REM
REM Usage: QBASDOWN.EXE Markdown_file
REM (DOS)  QBASDOWN.EXE Markdown_file --verbose
REM        QBASDOWN.EXE Markdown_file --silent
REM
REM Usage:   qbasdown Markdown_file
REM (Linux)  qbasdown Markdown_file --verbose
REM          qbasdown Markdown_file --silent

REM If no filename is given, the user is prompted for one.
REM
REM if compiled under FreeBASIC, force qb mode
REM this works with the REM in place!
REM $lang: "qb"
REM
REM Written for FreeDOS in QuickBASIC 4.5, mostly under
REM a hybrid DOSEMU/FreeDOS 1.2 installation, but the
REM final compilation in a release will always be tested on
REM bare silicon in a dedicated FreeDOS installation.
REM
REM QuickBASIC? Why? To see if it could be done, I guess, and
REM also to re-familiarize myself with this BASIC dialect.
REM It also compiles in FreeBASIC with the -lang qb switch.
REM Linux has dozens of Markdown implementations, probably better
REM than this one, too, but I don't know of any on FreeDOS.
REM
REM The DOS version of this program will ONLY work on DOS/Windows-
REM formatted text files, which end lines with CRLF. If no CRLF is
REM detected in the first 1024 bytes of the file, it will tell
REM the user to run a utility such as UNIX2DOS. Most documents have
REM at least a title line, so that should not be a problem. The Linux
REM version, compiled with FreeBASIC, should not have that problem.
REM
REM QBASDOWN is distributed as QuickBASIC source code and released as
REM a single DOS executable, called QBASDOWN.EXE, and a 64-bit Linux
REM executable called qbasdown.
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
REM This code needs a LOT of optimization. I know that.
REM
REM Best to run QB4.5 with the /L /AH switches when compiling this.
REM
REM (c) Michel Clasquin-Johnson 2020
REM Released into the Public Domain.
REM You may reuse any of this code in your own project.
REM You may use this to build a billion-dollar software empire.
REM Just don't bother me about it!
REM
DECLARE FUNCTION Strip$ (orig$, side, char$)
DECLARE SUB PrintToC ()
DECLARE SUB ChkPandocHeaders ()
DECLARE SUB PrintEndNotes ()
DECLARE SUB ChkEndNotes ()
DECLARE SUB ChkReferences ()
DECLARE SUB PrintBib ()
DECLARE SUB QuickSort (SortArray$())
DECLARE SUB MLCentre ()
DECLARE SUB MLInclude ()
DECLARE SUB MLSoloCurr ()
DECLARE SUB MLTbls ()
DECLARE SUB ChkTblData (cols%, LineEnd$, C$())
DECLARE SUB ChkTblCls ()
DECLARE SUB ChkTblHdr ()
DECLARE SUB ChkImg ()
DECLARE SUB ChkFCB ()
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
DECLARE SUB ChkAL ()
DECLARE SUB ChkIL ()
DECLARE SUB ChkDorU ()
DECLARE SUB ChkBQ ()
DECLARE SUB ChkSolo (Original$, Replacement$)
DECLARE SUB ChkPair (Pair$, StartReplacement$, EndReplacement$)
DECLARE SUB MLSolo ()
DECLARE SUB MLLists ()
DECLARE SUB ChkUOList ()
DECLARE SUB ChkOrList ()
DECLARE SUB MLSoloChars ()
DECLARE SUB MLSoloEmoji ()
DECLARE SUB MLSoloDiac ()
DECLARE SUB MLSoloMisc ()
DECLARE SUB MLPairs ()
DECLARE SUB MLBlocks ()
DECLARE SUB MLLinks ()
DECLARE SUB MLHeads ()
REM
REM Ugh, too many global variables. But let me get
REM this working before I clean it up
COMMON SHARED printed%, skip%, LineCounter%, Verbose%, CodeBlock%, ListOn%, OListOn%, RefsNum%, EndNotes%, CurrentEndnotes%
COMMON SHARED PastLine$, CurrentLine$, NextLine$, InFile$, OutFile$, AllReferences$, AllEndNotes$, AllToC$
OPTION BASE 1
REM
REM Initialising ... not really necessary, but it reminds
REM me of what my global variables are
REM
RefsNum% = 0
EndNotes% = 0
AllReference$ = ""
AllEndNotes$ = ""
InFile$ = ""
OutFile$ = ""
CurrentLine$ = ""
OriginalCurrentLine$ = ""
PastLine$ = ""
NextLine$ = ""
printed% = 0
LineCounter% = 0
skip% = 0
Verbose% = 0
CodeBlock% = 0
ListOn% = 0
OListOn% = 0
REM
REM first check for InFile$
REM get a filename if none was given
GetInFile
REM
REM check if InFile$ is formatted for DOS
ChkDorU
REM
IF Verbose% <> -1 THEN PRINT "QBASDOWN"
IF Verbose% <> -1 THEN PRINT "A Markdown to HTML converter"
REM
REM start to construct OutFile$
MakeOutFile
REM
REM find out how big this file is
REM and construct ToC
GetFileSize
REM
REM ####################################
REM ##########Main Loop#################
REM ####################################
OPEN InFile$ FOR INPUT AS #1
FOR f = 1 TO LineCounter% + 1
	IF Verbose% = 1 THEN PRINT "Processing line " + STR$(f)
	PastLine$ = CurrentLine$
	CurrentLine$ = NextLine$
	OriginalCurrentLine$ = CurrentLine$
	IF f <= LineCounter% THEN
	   LINE INPUT #1, NextLine$
	ELSE
		NextLine$ = ""
	END IF
	IF f = 1 THEN skip% = skip% + 1
	REM The PRINT statement: the debugger of the Stone Age (aka the 1980s)
	REM PRINT "mainloop pass: " + STR$(f)
	REM PRINT "past: " + PastLine$
	REM PRINT "present: " + CurrentLine$
	REM PRINT "future: " + NextLine$
	REM
	REM check if a previous pass ordered a skip
	REM mainly for line-style headings and tables
	ChkSkip
	REM
	REM print table of contents
	IF printed% = 0 THEN
		IF UCASE$(RTRIM$(LTRIM$(CurrentLine$))) = "\TOC" THEN
			IF AllToC$ <> "" THEN
				PrintToC
			END IF
		END IF
	END IF
	REM
	REM print bibliography
	IF printed% = 0 THEN
		IF UCASE$(RTRIM$(LTRIM$(CurrentLine$))) = "\BIB" THEN
			PrintBib
		END IF
	END IF
	REM
	REM check for included files
	IF printed% = 0 THEN MLInclude
	REM check for lists
	IF printed% = 0 THEN MLLists
	REM
	REM code blocks
	IF printed% = 0 THEN MLBlocks
	REM
	REM Check for tables
	IF printed% = 0 THEN MLTbls
	REM
	REM check for horizontal Rule
	IF printed% = 0 THEN ChkHR
	REM
	REM Check for Images
	IF printed% = 0 THEN ChkImg
	REM
	REM check for links
	IF printed% = 0 THEN MLLinks
	REM
	REM check for Headings
	IF printed% = 0 THEN MLHeads
	REM
	REM check for things that are embedded
	IF printed% = 0 THEN MLSolo
	REM
	REM next, paired codes
	IF printed% = 0 THEN MLPairs
	REM
	REM Check for references
	IF printed% = 0 THEN ChkReferences
	REM
	REM check for endnotes
	REM this must be the last check
	IF printed% = 0 THEN ChkEndNotes
	REM
	REM print an empty line
	IF printed% = 0 THEN PrEL
	REM
	REM print line of text, possibly with embeds
	IF printed% = 0 THEN PRINT #2, CurrentLine$
	REM
	REM feed original CurrentLine$ from before we mutilated it
	REM back into that variable so we can pass it to PastLine$
	REM on the next cycle.
	CurrentLine$ = OriginalCurrentLine$
	REM clear the Print-to-file status
	printed% = 0
NEXT f
CLOSE #1
REM ####################################
REM #######End of Main Loop#############
REM ####################################
IF AllReferences$ <> "" THEN PrintBib
IF AllEndNotes$ <> "" THEN PrintEndNotes
PRINT #2, "</body>"
PRINT #2, "</html>"
CLOSE #2
IF Verbose% <> -1 THEN PRINT "Done"
SYSTEM

SUB Chk2S
	REM this subprogram looks for two spaces at the end of a line
	REM which indicates a single-spacing block
	REM
	REM
	REM First line
	IF RIGHT$(CurrentLine$, 2) = "  " AND RIGHT$(PastLine$, 2) <> "  " THEN
		CurrentLine$ = "<p>" + MID$(CurrentLine$, 1, LEN(CurrentLine$) - 2) + "<br />"
		IF Verbose% = 1 THEN PRINT "Found a single-spacing block"
		EXIT SUB
	REM middle lines
	ELSEIF RIGHT$(CurrentLine$, 2) = "  " AND RIGHT$(PastLine$, 2) = "  " THEN
		CurrentLine$ = MID$(CurrentLine$, 1, LEN(CurrentLine$) - 2) + "<br />"
		EXIT SUB
	REM Block has ended
	REM works if there are no spaces in the last line of the block
	REM ansd also if there are, though the HTML is messier then.
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
	REM get operating system:
	REM Dos/windows or Unix-y
	REM check D or U, geddit?
	REM don't care about Mac, sorry
	SHELL "ver > whatos.txt"
	REM should give an error on linux (maybe BSD too, don't have one here to test)
	REM I'll clear the screen later to remove the error msg
	OPEN "whatos.txt" FOR INPUT AS #1
	WHILE NOT EOF(1)
		LINE INPUT #1, a$
		a$ = LCASE$(a$)
		REM A bit of guesswork here
		IF INSTR(a$, "freecom") <> 0 THEN OS$ = "D"
		IF INSTR(a$, "windows") <> 0 THEN OS$ = "D"
		IF INSTR(a$, "dos") <> 0 THEN OS$ = "D"
		IF INSTR(a$, "4dos") <> 0 THEN OS$ = "D"
		IF INSTR(a$, "4nt") <> 0 THEN OS$ = "D"
		IF INSTR(a$, "reactos") <> 0 THEN OS$ = "D"
		IF INSTR(a$, "os/2") <> 0 THEN OS$ = "D"
	WEND
	CLOSE #1
	KILL "whatos.txt"
	IF OS$ <> "D" THEN
		REM move cursor 1 up
		SHELL "tput cuu1"
		PRINT ""; ""
		EXIT SUB
	ELSE
		OPEN InFile$ FOR INPUT AS #1
		a$ = INPUT$(1024, #1)
		CLOSE #1
		IF INSTR(a$, CHR$(13) + CHR$(10)) THEN
			EXIT SUB
		ELSE
			PRINT InFile$ + " does not look like a DOS-formatted text file!"
			PRINT "You may want to run UNIX2DOS or a similar utility first."
			SYSTEM
		END IF
	END IF
END SUB

SUB ChkEndNotes
	startoff% = 1
	IF INSTR(CurrentLine$, "^") = 0 THEN
		EXIT SUB
	ELSE
		WHILE INSTR(CurrentLine$, "^")
			IF Verbose% = 1 THEN PRINT "Found an endnote"
			EndNotes% = EndNotes% + 1
			endnote$ = "<sup>" + LTRIM$(STR$(EndNotes%)) + "</sup>"
			OrLen% = LEN(CurrentLine$)
			StartPos% = INSTR(CurrentLine$, "^")
			CurrentLine$ = LEFT$(CurrentLine$, StartPos% - 1) + endnote$ + MID$(CurrentLine$, StartPos% + 1)
			OriginalCurrentLine$ = CurrentLine$
			IF startoff% = 1 THEN
				CurrentLine$ = NextLine$
			ELSE
				LINE INPUT #1, CurrentLine$
			END IF
			startoff% = startoff% + 1
			CurrentLine$ = MID$(CurrentLine$, 4)
			CurrentLine$ = LTRIM$(RTRIM$(CurrentLine$))
			MLSolo
			MLPairs
			skip% = 1
			AllEndNotes$ = AllEndNotes$ + "<p>" + LTRIM$(STR$(EndNotes%)) + ". " + CurrentLine$ + "</p>"
			CurrentLine$ = OriginalCurrentLine$
		WEND
	END IF
END SUB

SUB ChkFCB
	REM opening line
	IF CodeBlock% = 0 THEN
		IF LEFT$(CurrentLine$, 3) = "```" OR LEFT$(CurrentLine$, 3) = "~~~" THEN
		   IF Verbose% = 1 THEN PRINT "Found a code block"
		   CurrentLine$ = "<pre><code><p style=background-color:LightGray;>"
		   printed% = 1
		   CodeBlock% = 1
		   PRINT #2, CurrentLine$
		   EXIT SUB
		END IF
	ELSEIF CodeBlock% = 1 THEN
		REM closing line
		IF LEFT$(CurrentLine$, 3) = "```" OR LEFT$(CurrentLine$, 3) = "~~~" THEN
			IF Verbose% = 1 THEN PRINT "Closing code block"
			CurrentLine$ = "</code></pre>"
			printed% = 1
			CodeBlock% = 0
			PRINT #2, CurrentLine$
			EXIT SUB
		REM middle lines
		ELSE
			printed% = 1
			CodeBlock% = 1
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
	IF LEFT$(CurrentLine$, 1) <> "#" THEN EXIT SUB
	CurrentLine$ = Strip$(CurrentLine$, 1, "#")
	MLSoloDiac
	IF LEFT$(CurrentLine$, 2) = "# " THEN
		IF Verbose% = 1 THEN PRINT "Found Header 1"
		CurrentLine$ = "<h1>" + MID$(CurrentLine$, 2) + "</h1>"
		CALL ChkH4Stuff
		PRINT #2, CurrentLine$
		printed% = 1
	ELSEIF LEFT$(CurrentLine$, 3) = "## " THEN
		IF Verbose% = 1 THEN PRINT "Found Header 2"
		CurrentLine$ = "<h2>" + MID$(CurrentLine$, 3) + "</h2>"
		CALL ChkH4Stuff
		PRINT #2, CurrentLine$
		printed% = 1
	ELSEIF LEFT$(CurrentLine$, 4) = "### " THEN
		IF Verbose% = 1 THEN PRINT "Found Header 3"
		CurrentLine$ = "<h3>" + MID$(CurrentLine$, 4) + "</h3>"
		CALL ChkH4Stuff
		PRINT #2, CurrentLine$
		printed% = 1
	ELSEIF LEFT$(CurrentLine$, 5) = "#### " THEN
		IF Verbose% = 1 THEN PRINT "Found Header 4"
		CurrentLine$ = "<h4>" + MID$(CurrentLine$, 5) + "</h4>"
		CALL ChkH4Stuff
		PRINT #2, CurrentLine$
		printed% = 1
	ELSEIF LEFT$(CurrentLine$, 6) = "##### " THEN
		IF Verbose% = 1 THEN PRINT "Found Header 5"
		CurrentLine$ = "<h5>" + MID$(CurrentLine$, 6) + "</h5>"
		CALL ChkH4Stuff
		PRINT #2, CurrentLine$
		printed% = 1
	ELSEIF LEFT$(CurrentLine$, 7) = "###### " THEN
		IF Verbose% = 1 THEN PRINT "Found Header 6"
		CurrentLine$ = "<h6>" + MID$(CurrentLine$, 7) + "</h6>"
		CALL ChkH4Stuff
		PRINT #2, CurrentLine$
		printed% = 1
	END IF
END SUB

SUB ChkHR
	IF LEFT$(CurrentLine$, 3) = "---" AND PastLine$ = "" THEN
		IF Verbose% = 1 THEN PRINT "Found Horizontal rule"
		CurrentLine$ = "<hr />"
		PRINT #2, CurrentLine$
		printed% = 1
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
	IF LEFT$(CurrentLine$, 2) <> "![" THEN
		EXIT SUB
	ELSE
		CurrentLine$ = RTRIM$(CurrentLine$)
		MidPoint% = INSTR(CurrentLine$, "](")
		Description$ = MID$(CurrentLine$, 3, MidPoint% - 3)
		URLStart% = MidPoint% + 2
		URL$ = MID$(CurrentLine$, URLStart%, LEN(CurrentLine$) - URLStart%)
		IF Verbose% = 1 THEN PRINT "Found image: " + URL$
		CurrentLine$ = "<p><image alt=" + Description$
		CurrentLine$ = CurrentLine$ + " src=" + CHR$(34) + URL$ + CHR$(34) + " /></p>"
		PRINT #2, CurrentLine$
		printed% = 1
	END IF
END SUB

SUB ChkLH
	MLSoloDiac
	IF LEFT$(NextLine$, 3) = "===" AND CurrentLine$ <> "" THEN
		IF Verbose% = 1 THEN PRINT "Found Header 1"
		CurrentLine$ = "<h1>" + CurrentLine$ + "</h1>"
		ChkH4Stuff
		PRINT #2, CurrentLine$
		printed% = 1
		skip% = 1
	ELSEIF LEFT$(NextLine$, 3) = "---" AND CurrentLine$ <> "" THEN
		IF Verbose% = 1 THEN PRINT "Found Header 2"
		CurrentLine$ = "<h2>" + CurrentLine$ + "</h2>"
		ChkH4Stuff
		PRINT #2, CurrentLine$
		printed% = 1
		skip% = 1
	END IF
END SUB

SUB ChkOrList
	REM detect numbered list
	IF (LEFT$(CurrentLine$, 3) = "1. " AND OListOn% = 0) THEN OListOn% = 1
	IF OListOn% = 0 THEN EXIT SUB
	Definer% = INSTR(CurrentLine$, ". ") - 1
	IF Definer% < 1 THEN
		EXIT SUB
	ELSE
		Definer% = Definer% + 2
	END IF
	REM firstline
	IF (INSTR(PastLine$, ". ") - 1) < 1 THEN
		CurrentLine$ = "<ol><li>" + LTRIM$(RTRIM$(MID$(CurrentLine$, Definer%))) + "</li>"
		OListOn% = 1
		EXIT SUB
	REM lastline
	ELSEIF (INSTR(NextLine$, ". ") - 1) < 1 THEN
		CurrentLine$ = "<li>" + LTRIM$(RTRIM$(MID$(CurrentLine$, Definer%))) + "</li></ol>"
		OListOn% = 0
		EXIT SUB
	REM middle line
	ELSE
		CurrentLine$ = "<li>" + LTRIM$(RTRIM$(MID$(CurrentLine$, Definer%))) + "</li>"
		OListOn% = 1
		EXIT SUB
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

SUB ChkPandocHeaders
	OPEN InFile$ FOR INPUT AS #1
		LINE INPUT #1, a$
		IF LEFT$(a$, 2) = "% " THEN
			PRINT #2, "<title>" + MID$(a$, 3) + "</title>"
			skip% = skip% + 1
		END IF
		REM I'm not convinced the other two really add anything worthwhile
		REM we'll stick with the title for now
		REM author
		REM LINE INPUT #1, a$
		REM IF LEFT$(a$, 2) = "% " THEN
			REM PRINT #2, ""
			REM skip% = skip% + 1
		REM END IF
		REM date
		REM LINE INPUT #1, a$
		REM IF LEFT$(a$, 2) = "% " THEN
			REM PRINT #2, ""
			REM skip% = skip% + 1
		REM END IF
	CLOSE #1
END SUB

SUB ChkReferences
	IF LEFT$(UCASE$(LTRIM$(CurrentLine$)), 4) <> "\REF" THEN
		EXIT SUB
	ELSE
		IF Verbose% = 1 THEN PRINT "Found a reference"
			StartTheRef% = INSTR(CurrentLine$, "\REF") + 4
			ThisReference$ = MID$(CurrentLine$, StartTheRef%)
			AllReferences$ = AllReferences$ + ThisReference$ + "<br />"
			RefsNum% = RefsNum% + 1
		printed% = 1
	END IF
END SUB

SUB ChkSDCB
	IF LEFT$(CurrentLine$, 4) <> "    " THEN
		EXIT SUB
	ELSE
		REM only line
		IF LEFT$(PastLine$, 4) <> "    " AND LEFT$(NextLine$, 4) <> "    " THEN
			CurrentLine$ = "<pre><code><p style=background-color:LightGray;>" + MID$(CurrentLine$, 5) + "</code></pre>"
			PRINT #2, CurrentLine$
			printed% = 1
			EXIT SUB
		REM First line
		ELSEIF LEFT$(PastLine$, 4) <> "    " THEN
			IF Verbose% = 1 THEN PRINT "Found a code block"
			CurrentLine$ = "<pre><code><p style=background-color:LightGray;>" + MID$(CurrentLine$, 5)
			PRINT #2, CurrentLine$
			printed% = 1
			EXIT SUB
		REM middle lines
		ELSEIF LEFT$(PastLine$, 4) = "    " AND LEFT$(NextLine$, 4) = "    " THEN
			CurrentLine$ = MID$(CurrentLine$, 5)
			PRINT #2, CurrentLine$
			printed% = 1
			EXIT SUB
		REM last line
		ELSEIF LEFT$(NextLine$, 4) <> "    " THEN
			CurrentLine$ = MID$(CurrentLine$, 5) + "</code></pre>"
			PRINT #2, CurrentLine$
			printed% = 1
			EXIT SUB
		END IF
	END IF
END SUB

SUB ChkSkip
	IF skip% <> 0 THEN
		printed% = 1
		skip% = skip% - 1
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

SUB ChkTblData (cols%, LineEnd$, C$())
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
		PRINT #2, "<" + LineEnd$ + " style=" + C$(f) + ">" + LTRIM$(RTRIM$(b$(f))) + "</" + LineEnd$ + "d>"
	NEXT f
	PRINT #2, "</tr>"
END SUB

SUB ChkTblHdr
	PRINT #2, "<table>"
END SUB

SUB ChkUOList
	REM let's experiment with the dreaded GOTO
	IF ListOn% = 1 THEN GOTO UOLskipover
	SELECT CASE LEFT$(CurrentLine$, 2)
		CASE ("* ")
		CASE ("+ ")
		CASE ("- ")
		CASE ELSE
			EXIT SUB
		END SELECT
		REM first line
		CurrentLine$ = "<ul><li>" + LTRIM$(RTRIM$(MID$(CurrentLine$, 3))) + "</li>"
		ListOn% = 1
		EXIT SUB
UOLskipover:
		SELECT CASE LEFT$(NextLine$, 2)
		CASE ("* ")
			GOTO UOLSkipover2
		CASE ("+ ")
			GOTO UOLSkipover2
		CASE ("- ")
			GOTO UOLSkipover2
		CASE ELSE
			GOTO UOLSkipover3
		END SELECT
UOLSkipover2:
		REM middle line
		CurrentLine$ = "<li>" + LTRIM$(RTRIM$(MID$(CurrentLine$, 3))) + "</li>"
		ListOn% = 1
		EXIT SUB
UOLSkipover3:
		REM last line
		CurrentLine$ = "<li>" + LTRIM$(RTRIM$(MID$(CurrentLine$, 3))) + "</li></ul>"
		ListOn% = 0
		EXIT SUB
REM yes, in a contained environment like this GOTO still has its uses
END SUB

SUB GetFileSize
	OPEN InFile$ FOR INPUT AS #1
	WHILE NOT (EOF(1))
		LINE INPUT #1, CurrentLine$
		IF UCASE$(LEFT$(CurrentLine$, 3)) <> "\EN" THEN LineCounter% = LineCounter% + 1
		IF LEFT$(CurrentLine$, 1) = "#" THEN
			IF INSTR(CurrentLine$, "# ") <> 0 THEN
				level% = INSTR(CurrentLine$, "# ")
				IF INSTR(CurrentLine$, " #") <> 0 THEN
					MLSoloDiac
					CurrentLine$ = RTRIM$(CurrentLine$)
					CurrentLine$ = LTRIM$(RTRIM$(Strip$(CurrentLine$, 0, "#")))
					IF level% > 1 THEN
						FOR f = 1 TO level% - 1
							CurrentLine$ = "&#160;&#160;&#160;" + CurrentLine$
						NEXT f
					END IF
					CALL ChkPair("_", "<em>", "</em>")
					CALL ChkPair("*", "<em>", "</em>")
					AllToC$ = AllToC$ + CurrentLine$ + "<br />"
				END IF
			END IF
		END IF
	WEND
	IF Verbose% = 1 THEN PRINT "Total of " + LTRIM$(STR$(LineCounter%)) + " lines."
	CLOSE #1
END SUB

SUB GetInFile
	InFile$ = COMMAND$
	UCInfile$ = UCASE$(InFile$)
	IF INSTR(UCInfile$, "--VERBOSE") <> 0 THEN
		Verbose% = 1
		InFile$ = LTRIM$(RTRIM$(LEFT$(InFile$, LEN(InFile$) - 10)))
	ELSEIF INSTR(UCInfile$, "--SILENT") <> 0 THEN
		Verbose% = -1
		InFile$ = LTRIM$(RTRIM$(LEFT$(InFile$, LEN(InFile$) - 9)))
	END IF
	IF InFile$ = "" THEN
		InFile$ = " "
		WHILE INSTR(InFile$, " ")
			PRINT
			PRINT "Usage: qbasdown <Markdown_file)"
			PRINT "       qbasdown <Markdown_file) --verbose"
			PRINT "       qbasdown <Markdown_file) --silent"
			PRINT "Verbose mode will give you more information than"
			PRINT "you actually wanted ..."
			PRINT "Silent mode suppresses all screen output."
			PRINT
			PRINT "Filename to convert (no spaces in name)?"
			LINE INPUT "Or Press ENTER to exit: ", InFile$
		WEND
	END IF
	REM if user did not give a filename then exit
	IF InFile$ = "" THEN
		PRINT "No filename given. Exiting ..."
		SYSTEM
	END IF
	REM check if file exists by deliberately
	REM crashing the application if it doesn't!
	REM I'll fix that later ...
	REM OPEN Infile$ FOR INPUT AS #1
	CLOSE #1
END SUB

SUB MakeOutFile
	pointpos% = INSTR(InFile$, ".") - 1
	IF pointpos% <> -1 THEN
		REM there is an extension
		OutFile$ = LEFT$(InFile$, pointpos%) + ".htm"
	ELSE
		REM there is no extension
		OutFile$ = LEFT$(InFile$, 8) + ".htm"
	END IF
	IF Verbose% <> -1 THEN PRINT "Results will be placed in " + OutFile$ + " in the current directory."
	OPEN OutFile$ FOR OUTPUT AS #2
	PRINT #2, "<html>"
	PRINT #2, "<head><style> table,th {border: 1px solid black; padding: 5px;}"
	PRINT #2, "</style>"
	ChkPandocHeaders
	PRINT #2, "</head>"
	PRINT #2, "<body>"
END SUB

SUB MLBlocks
	REM do not remove the IF Printed% ... statements
	REM spaces-delimited code block
	IF printed% = 0 AND CodeBlock% = 0 THEN ChkSDCB
	REM
	REM Fenced code block
	IF printed% = 0 THEN ChkFCB
	REM
	REM check for centring
	IF printed% = 0 THEN MLCentre
	REM
	REM check for block quotes
	IF printed% = 0 THEN ChkBQ
END SUB

SUB MLCentre
	IF LEFT$(CurrentLine$, 2) <> ">>" AND RIGHT$(CurrentLine$, 2) <> "<<" THEN
		EXIT SUB
	ELSE
		CurrentLine$ = "<center>" + LTRIM$(RTRIM$(MID$(CurrentLine$, 3, LEN(CurrentLine$) - 4))) + "</center>"
	END IF
END SUB

SUB MLHeads
	REM do not remove IF Printed% ... statements
	REM Hash (atx) Headings
	IF printed% = 0 THEN ChkHH
	REM Line (setext) Headings
	IF printed% = 0 THEN ChkLH
END SUB

SUB MLInclude
	REM first three lines are reserved for Pandoc headers
	IF LineCounter% < 4 THEN EXIT SUB
	IF UCASE$(LEFT$(CurrentLine$, 8)) <> "%INCLUDE" THEN
		EXIT SUB
	ELSE
		File$ = LTRIM$(RTRIM$(MID$(CurrentLine$, 9)))
		OPEN File$ FOR INPUT AS #3
		WHILE NOT EOF(3)
			LINE INPUT #3, IncludedText$
			PRINT #2, IncludedText$
		WEND
		CLOSE #3
		printed% = 1
	END IF
END SUB

SUB MLLinks
	REM absolute links <www.google.com>
	ChkAL
	REM inline links [google](www.google.com)
	ChkIL
END SUB

SUB MLLists
	ChkUOList
	ChkOrList
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
	MLSoloDiac
	MLSoloChars
	MLSoloEmoji
	MLSoloCurr
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
	REM caron
	CALL ChkSolo(" ^ ", " &#94 ")
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
	REM caron
	CALL ChkSolo("\^", "&#94")
END SUB

SUB MLSoloCurr
	IF INSTR(CurrentLine$, "\") = 0 THEN EXIT SUB
	REM UK Pound
	CALL ChkSolo("\UKP", "&#163")
	REM cent
	CALL ChkSolo("\USC", "&#162")
	REM dollar
	REM No, not everyone has this on their keyboard
	CALL ChkSolo("\USD", "&#36")
	REM Yen
	CALL ChkSolo("\YEN", "&#165")
	REM Euro
	CALL ChkSolo("\EUR", "&#8364")
	REM Naira
	CALL ChkSolo("\NAI", "&#8358")
	REM Rupee (Latin)
	CALL ChkSolo("\RPL", "&#8360")
	REM Rupee (Indian)
	CALL ChkSolo("\RPI", "&#8377")
	REM Ruble
	CALL ChkSolo("\RUB", "&#8381")
	REM Peso
	CALL ChkSolo("\PES", "&#8369")
	REM Bitcoin
	CALL ChkSolo("\BIT", "&#8383")
	REM Lira
	CALL ChkSolo("\LIR", "&#8378")
END SUB

SUB MLSoloDiac
	IF INSTR(CurrentLine$, "%") = 0 THEN EXIT SUB
	REM Danish AE
	CALL ChkSolo("%AE", "&#198")
	CALL ChkSolo("%ae", "&#230")
	REM stroked O
	CALL ChkSolo("%/O", "&#216")
	CALL ChkSolo("%/o", "&#248")
	REM Dutch IJ
	CALL ChkSolo("%IJ", "&#306")
	CALL ChkSolo("%ij", "&#307")
	REM German eszed
	CALL ChkSolo("%SZ", "&#223")
	REM macron above
	CALL ChkSolo("%M", "&#772")
	REM  tilde
	CALL ChkSolo("%~", "&#771")
	REM  acute
	CALL ChkSolo("%'", "&#769")
	REM  grave
	CALL ChkSolo("%`", "&#768")
	REM  dot above
	CALL ChkSolo("%D", "&#775")
	REM  diaeresis/umlaut
	CALL ChkSolo("%:", "&#776")
	REM  ring above
	CALL ChkSolo("%O", "&#778")
	REM  dot below
	CALL ChkSolo("%d", "&#803")
	REM  caron
	CALL ChkSolo("%^", "&#770")
	REM  hook above
	CALL ChkSolo("%H", "&#777")
	REM breve above
	CALL ChkSolo("%B", "&#774")
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
	REM nonbreaking space
	CALL ChkSolo("\NBS", "&#160")
	REM nonbreaking hyphen
	CALL ChkSolo("\NBH", "&#8209")
	REM copyright
	CALL ChkSolo("(c)", "&#169")
	REM registered trademark
	CALL ChkSolo("(r)", "&#174")
	REM trademark
	CALL ChkSolo("(tm)", "&#8482")
	REM Male
	CALL ChkSolo("\MAL", "&#9794")
	REM female
	CALL ChkSolo("\FEM", "&#9792")
	REM male and female
	CALL ChkSolo("\MAF", "&#9892")
	REM Male and Male
	CALL ChkSolo("\MAM", "&#9891")
	REM Female and Female
	CALL ChkSolo("\FAF", "&#9890")
	REM Androgynous
	CALL ChkSolo("\AND", "&#9893")
	REM Caduceus
	CALL ChkSolo("\CAD", "&#9764")
	REM 1/2
	CALL ChkSolo(" 1/2 ", " &#189 ")
	REM 1/3
	CALL ChkSolo(" 1/3 ", " &#8531 ")
	REM 2/3
	CALL ChkSolo(" 2/3 ", " &#8532 ")
	REM 1/4
	CALL ChkSolo(" 1/4 ", " &#189 ")
	REM 3/4
	CALL ChkSolo(" 3/4 ", " &#190 ")
	REM 1/5
	CALL ChkSolo(" 1/5 ", " &#8533 ")
	REM 2/5
	CALL ChkSolo(" 2/5 ", " &#8534 ")
	REM 3/5
	CALL ChkSolo(" 3/5 ", " &#189 ")
	REM 4/5
	CALL ChkSolo(" 4/5 ", " &#8536 ")
	REM 1/6
	CALL ChkSolo(" 1/6 ", " &#8537 ")
	REM 5/6
	CALL ChkSolo(" 5/6 ", " &#8538 ")
	REM 1/7
	CALL ChkSolo(" 1/7 ", " &#8528 ")
	REM 1/8
	CALL ChkSolo(" 1/8 ", " &#8539 ")
	REM 3/8
	CALL ChkSolo(" 3/8 ", " &#8540 ")
	REM 5/8
	CALL ChkSolo(" 5/8 ", " &#8541 ")
	REM 7/8
	CALL ChkSolo(" 7/8 ", " &#8542 ")
	REM 1/9
	CALL ChkSolo(" 1/9 ", " &#8529 ")
	REM 1/10
	CALL ChkSolo(" 1/10 ", " &#8530 ")
	REM 0/3
	REM Why? What's the point of that one?
	REM CALL ChkSolo(" 0/3 ", " &#8585 ")
END SUB

SUB MLTbls STATIC
	IF LEFT$(LTRIM$(CurrentLine$), 1) <> "|" AND RIGHT$(RTRIM$(CurrentLine$), 1) <> "|" THEN
		EXIT SUB
	ELSE
		IF cols% = 0 THEN
			GOSUB getCols
			DIM C$(cols%)
		END IF
		REM headerline
		REM do both this and the next one, then skip
		IF LEFT$(LTRIM$(PastLine$), 1) <> "|" THEN
			ChkTblHdr
			GOSUB chkdlmtr
			CALL ChkTblData(cols%, "th", C$())
			skip% = 1
		REM closing line
		ELSEIF LEFT$(LTRIM$(NextLine$), 1) <> "|" THEN
			REM italic
			CALL ChkPair("_", "<em>", "</em>")
			CALL ChkPair("*", "<em>", "</em>")
			REM
			CALL ChkTblData(cols%, "td", C$())
			ChkTblCls
		REM regular data line
		ELSE
		REM italic
		CALL ChkPair("_", "<em>", "</em>")
		CALL ChkPair("*", "<em>", "</em>")
		REM
		CALL ChkTblData(cols%, "td", C$())
		END IF
		printed% = 1
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
			C$(Current%) = C$(Current%) + MID$(WorkingLine$, f, 1)
		ELSE
		   Current% = Current% + 1
		END IF
	NEXT f
	FOR f = 1 TO cols%
		IF LEFT$(C$(f), 1) = ":" AND RIGHT$(C$(f), 1) = ":" THEN
			C$(f) = CHR$(34) + "text-align:center" + CHR$(34)
		ELSEIF LEFT$(C$(f), 1) = ":" AND RIGHT$(C$(f), 1) <> ":" THEN
			C$(f) = CHR$(34) + "text-align:left" + CHR$(34)
		ELSEIF LEFT$(C$(f), 1) <> ":" AND RIGHT$(C$(f), 1) = ":" THEN
			C$(f) = CHR$(34) + "text-align:right" + CHR$(34)
		END IF
	NEXT f
	RETURN
END SUB

SUB PrEL
	REM OK, don't look too closely at this beastly hack
	REM Luckily HTML is very forgiving
	IF CurrentLine$ = "" THEN
		PRINT #2, "</p><p>"
		printed% = 1
	END IF
END SUB

SUB PrintBib
	REM print bibliography
	IF AllReferences$ = "" THEN
		CurrentLine$ = "No references found"
		EXIT SUB
	END IF
	IF Verbose% = 1 THEN PRINT "Printing Reference list"
	DIM a$(RefsNum%)
	z% = 1
	WHILE AllReferences$ <> ""
		a% = INSTR(AllReferences$, "<br />") - 1
		a$(z%) = LEFT$(AllReferences$, a%)
		AllReferences$ = MID$(AllReferences$, a% + 7)
		z% = z% + 1
	WEND
	CALL QuickSort(a$())
	FOR f = 1 TO UBOUND(a$)
		PRINT #2, "<p style=" + CHR$(34) + "margin-left: 30px;text-indent: -30px;" + CHR$(34) + ">"
		PRINT #2, a$(f)
		PRINT #2, "</p>"
	NEXT f
	RefsNum% = 0
	printed% = 1
END SUB

SUB PrintEndNotes
	IF Verbose% = 1 THEN PRINT "Printing endnotes"
	PRINT #2, AllEndNotes$
	AllEndNotes$ = ""
END SUB

SUB PrintToC
	IF Verbose% = 1 THEN PRINT "Printing table of contents"
	PRINT #2, AllToC$
	AllToC$ = ""
	printed% = 1
END SUB

SUB QuickSort (SortArray$())
REM ****************************************
REM *  non-recursive quicksort algorithm   *
REM adapted from a routine by Matthew R. Usner
REM *****************************************
	Lower% = LBOUND(SortArray$, 1)
	Upper% = UBOUND(SortArray$, 1)
	DIM SortStackLow%(128)
	DIM SortStackHigh%(128)
	StackPointer% = 1
	SortStackLow%(StackPointer%) = Lower%
	SortStackHigh%(StackPointer%) = Upper%
	StackPointer% = StackPointer% + 1
	DO
	   StackPointer% = StackPointer% - 1
	   Low% = SortStackLow%(StackPointer%)
	   High% = SortStackHigh%(StackPointer%)
	   DO
		I% = Low%
		J% = High%
		Mid% = (Low% + High%) \ 2
		Compare$ = SortArray$(Mid%)
		DO
			DO WHILE SortArray$(I%) < Compare$
			  I% = I% + 1
			LOOP
			DO WHILE SortArray$(J%) > Compare$
			   J% = J% - 1
			LOOP
			IF I% <= J% THEN
			   SWAP SortArray$(I%), SortArray$(J%)
			   I% = I% + 1
			   J% = J% - 1
			END IF
		LOOP WHILE I% <= J%
			IF J% - Low% < High% - I% THEN
				IF I% < High% THEN
				   SortStackLow%(StackPointer%) = I%
				   SortStackHigh%(StackPointer%) = High%
				   StackPointer% = StackPointer% + 1
				END IF
				High% = J%
			ELSE
				IF Low% < J% THEN
				   SortStackLow%(StackPointer%) = Low%
				   SortStackHigh%(StackPointer%) = J%
				   StackPointer% = StackPointer% + 1
				END IF
				Low% = I%
			END IF
		LOOP WHILE Low% < High%
	LOOP WHILE StackPointer% <> 1
END SUB

FUNCTION Strip$ (orig$, side, char$)
	REM ****************************************************************************
	REM Adapted from HOMONLIB by Raymond W. Marron/HOMONCULOUS PROGRAMMING
	REM ****************************************************************************
	REM Strips leading and/or trailing characters from a string.  It works like
	REM  LTRIM$() and RTRIM$() but on other characters in addition to spaces.
	REM The side argument is passed in one of the following ways:
	REM     <0 = Strip the left side
	REM      0 = Strip both sides
	REM     >0 = Strip the right side
	REM Combinations of characters can also be stripped from each side as well as
	REM individual characters.  In this case, the length of char$ would be greater
	REM than one.  The characters to be stripped ARE case sensitive.
	REM Examples:     Strip$("00100",-1, "0")  -->  "100"
	REM               Strip$("AABAa", 0, "A")  -->  "BAa"
	REM               Strip$("00100", 0, "0")  -->  "1"
	REM               Strip$("     ", 0, " ")  -->  ""
	REM               Strip$("ABCDE", 0, "AB") -->  "CDE"
	REM               Strip$("ABCDE", 1, "AB") -->  "ABCDE"
	REM ****************************************************************************
	l% = LEN(char$)                          'length of the char(s) to strip.
	IF orig$ = "" OR char$ = "" THEN        'If either argument is a null string,
		Strip$ = orig$                     'return the original because nothing
		EXIT FUNCTION                      'can be stripped from a null string,
	END IF                                  'and you can't search for a null.
	new$ = orig$                            'Don't alter the original.
	IF side <= 0 THEN                       'Strip the left side.  Notice how
		DO WHILE LEFT$(new$, l%) = char$    'both sides will get stripped if side
			new$ = MID$(new$, l% + 1)      'is equal to zero.
		LOOP
	END IF
	IF side >= 0 THEN                       'Strip the right side.
		DO WHILE RIGHT$(new$, l%) = char$
			new$ = LEFT$(new$, LEN(new$) - (l% + 1))
		LOOP
	END IF
	Strip$ = new$                           'Return the stripped string.
END FUNCTION

