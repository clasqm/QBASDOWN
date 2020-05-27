![Markdown logo](https://upload.wikimedia.org/wikipedia/commons/thumb/4/48/Markdown-mark.svg/96px-Markdown-mark.svg.png)

QBASDOWN 0.1
~~~
Usage:
	QBASDOWN.EXE Markdown_file  
	QBASDOWN.EXE Markdown_file --verbose

If no filename is given, the user is prompted for one.
~~~
Introduction
==================
Markdown is a [lightweight markup language](https://en.wikipedia.org/wiki/Lightweight_markup_language) created by John Gruber and Aaron Schwartz. It was specifically designed to be easily readable in its raw state, but then be translated into HTML. Since then it has become quite popular and a variety of dialects and  implementations in different computer languages have come into being.

QBASDOWN is a Markdown to HTML converter written for FreeDOS in QuickBASIC 4.5. Why? To see if it could be done, I guess, and also to re-familiarize myself with this BASIC dialect.

The long-term goal is to implement all of Gruber's original Markdown, plus selected extensions from MultiMarkdown, Discount, Github-flavored Markdown and other developments,a few modest ideas of my own and some prettyprinting. Technically, I suppose that means I am inventing a new dialect of Markdown. Fame at last!

&copy; Michel Clasquin-Johnson 2020  
Released into the Public Domain.

Basics
------
Most of the time, you will just be writing as usual. Paragraphs are separated by an empty line, as you can see above

Two spaces at the end of a line  
will produce a break, which you  
can use for single spacing.

Images
------
**Code:**
~~~
![Markdown logo](https://upload.wikimedia.org/wikipedia/commons/thumb/4/48/Markdown-mark.svg/96px-Markdown-mark.svg.png)

~~~
You've already seen the image at the top of the page. Images must appear on a new line. NOTE that the "Optional title" attribute is not supported ATM. You don't have to remove them from your document: they will simply be ignored.

Character modes
--------------
**Code:**
    
    _italic_, __bold__, and ___bold italic___
    *italic*, **bold** and ***bold italic***
    * & @ < > / \ - and _
    \* \& \@ \< \> \/ \\ \- and \_
     ~~Strikethrough~~ --underline-- and `monospace`
     
You can use underscores for _italic_, __bold__, and ___bold italic___.

Or if you prefer, you can use asterisks: *italic*, **bold** and ***bold italic***. But don't mix them up! \_\*\_This\*\_\* or \_\_\_this\*\*\* will not work reliably.

To use an literal asterisk, surround it with spaces: * . Other characters you may want to surround with spaces are & @ < > / \ - and _ in which case they will be changed into HTML codes, _except in headings_. Or you can escape the character with a backslash: \* \& \@ \< \> \/ \\ \- and \_.

~~Strikethrough~~ is also supported. so are --underline-- (a non-standard addition) and `monospace`, but use monospace only for variable names and such: to make sure your code appears as it should, rather use code blocks. Inside headings, only _italics mode_ is supported.

Let's make a horizontal rule. Note the empty lines around the three (or more) dashes, so that it does not get mistaken for a Line style subheading.

---

Headings
--------
QBASDOWN supports both kinds of headings in Markdown

**Code:**
     
    One kind of heading, level 1
    =============================
    level 2
    -------
     
One kind of heading, level 1
=============================

level 2
-------

**Code:**
     
    # Level 1
    ## Level 2
    ### Level 3
    #### Level 4
    ##### Level 5
    ###### Level 6
     
# Level 1
## Level 2
### Level 3
#### Level 4
##### Level 5
###### Level 6

Note the required space behind the # symbol. NOTE: Closing hashes are NOT supported ATM.

###This line is missing the space after the hash symbols, so it will not be translated into a level 3 heading.

#### You can put _italics_ in a heading! Links too: <https://facebook.com>.

---

Links
-----
**Code:**
~~~
&lthttp://www.google.com&gt
[Google](http://www.google.com) or [Facebook](https://facebook.com)

~~~
Absolute links are supported if they start with _http:_, _https:_ or _mailto:_, like this:  <http://www.google.com>.

Inline links are supported if the URL section starts with http https or mailto, like  [Google](http://www.google.com) or [Facebook](https://facebook.com).

NOTE: email links are not encoded ATM

---

Blocks
------
**Code:**
     
    >These lines are blockquoted.
    >The \> character must be in front of each new line, and multiple levels of quoting can be performed. Unlike other markdown implementations, you cannot just put the \> in front of the first line in a list of lines and wait for an empty line to show up. Unlike code blocks, blockquotes are fully processed for character styles and substitutions.
     

>These lines are blockquoted.
>The \> character must be in front of each new line, and multiple levels of quoting can be performed. Unlike other markdown implementations, you cannot just put the \> in front of the first line in a list of lines and wait for an empty line to show up. Unlike code blocks, blockquotes are fully processed for charcter styles and substitutions.

QBASDOWN supports both types of code block. Unfortunately it is a little difficult to render code block code when the result would also become a code block! Please see the explantions in the code blocks below and compare the test.md file.

     
    This is one kind of code block.
    It is made by indenting each line by four spaces (no tabs, sorry)
        This line is manually indented with eight spaces instead of four.
            How deep do you want to go?
    Code blocks are processed before anything else,
    and you can put stuff like < > /\ * @ in there
    so they are literal representations of your text
    As you may have noticed, code blocks show up with a light grey background.
    If you think the block is a little crowded, just make a line with five spaces.
     
     
~~~ #####LOOK! You can put nonprinting comments here.#####
This is a different kind of code block,
made with a "fence" of three tilde (~) characters above and below the text
	This line is indented with a tab
		and two tabs
and back to normal
If you think the block is a little crowded, just make an empty line.

~~~
Don't try to mix the two styles of code boxes, it won't work. If the one doesn't work for you, just try the other one. Sorry, backticks *should* work as well as tildes, but I cannot get that to work in QuickBASIC.

---

Miscellaneous
-------------
Unicode: QBASDOWN is not Unicode-aware, but characters like ā, ø, ṭ and so on are simply passed through to the HTML code. If you can't see them, update your browser. 

**Code:**
    Faces:   :-), :-(, :)    
    Arrows:  <-. ->, |^|. |v|, <=, =>, ||^||, ||v||  
    Misc:    {||, |b|, |c|. |x|, (X), %X, d-d, {o}, |p ||p and -o-.  

QBASDOWN supports a few simple emoji-style characters:  
Faces::-), :-(, :) - No I don't know why the angry face is larger. Ask the Unicode guys.  
Arrows<-. ->, |^|. |v|, <=, =>, ||^||, ||v||  
Misc:  {||, |b|, |c|. |x|, (X), %X, d-d, {o}, |p ||p and -o-.  
Presentation of these varies between browsers. For example, on my system Firefox displays -o- in colour, while Chrome does not.  
Let me know if you'd like to see more. Emojis do not work in headings.

Any actual HTML in your document will be passed through. Let's do a link that way: <a href="http://www.google.com">http://www.google.com</a>.
<hr>

To-Do
-----
Footnotes  
Bullet lists  
numbered lists  

### Maybe One day ...
Encode email links  
Tables  
Fenced Code blocks using backticks

### Not gonna happen
Table of Contents  
Links and images by reference  
