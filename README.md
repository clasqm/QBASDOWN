# QBASDOWN

A Markdown implementation for FreeDOS
Version 0.8.1

Please Note: This Github project is no longer maintained. Please go to https://sourceforge.net/projects/qbasdown/ for the latest version.

~~~
Usage:
	qbasdown Markdown_file
	qbasdown Markdown_file --verbose
	qbasdown Markdown_file --silent

Verbose mode will give you more information about the inner workings
of the program than you knew you wanted ...
Silent mode suppresses all screen output. This is most useful when
calling QBASDOWN from a batch file, shell script or another program.
If no filename is given, the user is prompted for one. Note that at
that stage you cannot add the --verbose or --silent switches.
~~~
Written for FreeDOS in QuickBASIC 4.5, mostly under a hybrid DOSEMU/FreeDOS 1.2 installation, but the final compilation in a release will always be tested on bare silicon in a dedicated FreeDOS installation.

QuickBASIC? Why? To see if it could be done, I guess, and also to re-familiarize myself with this BASIC dialect.

It also compiles in FreeBASIC using the *-lang qb* switch. Linux has dozens of Markdown implementations, probably better than this one, too, but I don't know of any on FreeDOS. But after I started adding in features other implementations don't have, I thought "But I want to use this on Linux myself!" So from version 0.6 onwards, there will be an X86 64-bit Linux version as well.

The DOS version of this program will ONLY work on DOS/Windows-formatted text files, which end lines with CRLF. If no CRLF is detected in the first 1024 bytes of the file, it will tell the user to run a utility such as UNIX2DOS. Most documents have at least a title line, so that should not be a problem. The Linux version should be able to swallow any input file.

QBASDOWN is distributed as QuickBASIC source code and released as a single OS executable, called *QBASDOWN.EXE* and a 64-bit Linux executable called *qbasdown*. Yes, I've kept the name, even if it is now compiled in FreeBASIC. Unzip either one to any directory in your PATH.

Once you've unzipped the Linux version, you can find the dependencies with *ldd qbasdown*. You should also have the *tput* command, normally part of *ncurses*. QBASDOWN will work without *tput*, it just doesn't look as pretty.

Please download the file TEST.MD, cd to where you saved it and use QBASDOWN to convert it to HTML. It will create a file called TEST.HTM in the same directory. That file will show you which aspects of Markdown I've so far managed to implement in QuickBASIC.

The long-term goal is to implement all of Gruber's original Markdown, plus selected extensions from MultiMarkdown and other developments, a few modest ideas of my own (see the emoji and diacriticals section in *test.md*), and some prettyprinting. Technically, I suppose that means I am inventing a new dialect of Markdown. Fame at last!


Limitations:
------------

Since version 0.5, QBASDOWN is no longer constrained by the size of a string array. I have used it to convert a 532KB MarkDown file of over 10 000 lines into a 707KB HTML file. That's about half of *War and Peace*.

Complexity, however, is another matter. Whenever a file has failed on me with an out-of-string space error, it always seems to be one with an enormous amount of raw HTML in it. I have written an INCLUDE function for that problem.

This code needs a LOT of optimization. I know that.

(c) Michel Clasquin-Johnson 2020  
Released into the Public Domain.
