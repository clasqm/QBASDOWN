# QBASDOWN
A Markdown implementation for FreeDOS
Version 0.4

~~~               
Usage: QBASDOWN.EXE Markdown_file
       QBASDOWN.EXE Markdown_file --verbose"
If no filename is given, the user is prompted for one.
~~~
Written for FreeDOS in QuickBASIC 4.5, mostly under a hybrid DOSEMU/FreeDOS 1.2 installation, but the final compilation in a release will always be tested on bare silicon in a dedicated FreeDOS installation.

QuickBASIC? Why? To see if it could be done, I guess, and also to re-familiarize myself with this BASIC dialect. It should also compile in FreeBASIC, and maybe in QB64, but why bother? Linux has dozens of Markdown implementations, probably better than this one, too, but I don't know of any on FreeDOS.

This program will ONLY work on DOS/Windows-formatted text files, which end lines with CRLF. If no CRLF is detected in the first 512 bytes of the file, it will tell the user to run a utility such as UNIX2DOS. Most documents have at least a title line, so that should not be a problem, but you can change that value in the subroutine *ChkDorU* to 1024 or 2048 if you like, at the expense of some speed.

QBASDOWN is distributed as QuickBASIC source code and released as a single OS executable, called *QBASDOWN.EXE*.

Please download the file TEST.MD and use QBASDOWN to convert it to HTML.That will show you which aspects of Markdown I've so far managed to implement in QuickBASIC.

The long-term goal is to implement all of Gruber's original Markdown, plus selected extensions from MultiMarkdown and other developments, a few modest ideas of my own (see the emoji section in *test.md*), and some prettyprinting. Technically, I suppose that means I am inventing a new dialect of Markdown. Fame at last!

This program can currently read Markdown files up to 64K in size. Breaking that barrier is Priority #1.

This code needs a LOT of optimization. I know that. One specific issue is that things need to be done in a very specific order. Bad design and practice, that. One day I will fix it.

(c) Michel Clasquin-Johnson 2020  
Released into the Public Domain.
