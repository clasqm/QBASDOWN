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

    ![Markdown logo](https://upload.wikimedia.org/wikipedia/commons/thumb/4/48/Markdown-mark.svg/96px-Markdown-mark.svg.png)

You've already seen the image at the top of the page. Images must appear on a new line. NOTE that the "Optional title" attribute is not supported ATM. You don't have to remove them from your document: they will simply be ignored.

Size your image before you put it into your Markdown file. QBASDOWN does not resize images.

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

To use an literal asterisk, surround it with spaces: * . Other characters you may want to surround with spaces are & @ < > / \ - and _ in which case they will be changed into HTML codes, _except in headings_. Or you can escape the character with a backslash: \* \& \@ \< \> \/ \\ \- and \_. \| must be escaped if it starts a new line, or it will start a table.

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
    >The \> character must be in front of each new line. Unlike other markdown implementations, you cannot just put the \> in front of the first line in a list of lines and wait for an empty line to show up. Unlike code blocks, blockquotes are fully processed for character styles and substitutions.
     

>These lines are blockquoted:
>The \> character must be in front of each new line. Unlike other markdown implementations, you cannot just put the \> in front of the first line in a list of lines and wait for an empty line to show up. Unlike code blocks, blockquotes are fully processed for charcter styles and substitutions.

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


Tables follow the Github convention: an opening \| is required, as is a closing \|. 

Tables consist of a single header row, a delimiter row (in which justification can be set with colons), and several data rows. Padding with spaces for readability is allowed in the header and  data lines, but not in the delimiter line. Colons can be used in the delimiter line to indicate justification. The header line determines the number of columns. Column-spanning and line-spanning are not supported.

An empty cell should at least have a space in it for readability. Always leave a blank line between two tables. *Italics* are allowed in the data section only.

Try to keep your tables simple: this code is not very robust. If you really need something more complex, inserting a raw HTML section is safer. Also, if you ever need to start or end a line with \| outside a table, escape it with \\|.

**Code**
~~~

|Header1         |      Header2     |              Header 3|
|:---------------|:----------------:|---------------------:|
|left -justified |   centred text   |       right-justified|
|plain text      |     *italics*    |    back to plain text|
|The next four cells are empty| | |
| | | Bye-bye|

~~~

In this example, it is the colons in the second row that determine the justification. The padding in the first four lines is just for readability as plain text. This is demonstrated by not padding the last two lines.

|Header1         |      Header2     |              Header 3|
|:---------------|:----------------:|---------------------:|
|left -justified |   centred text   |       right-justified|
|plain text      |     *italics*    |    back to plain text|
|The next four cells are empty| | |
| | | Bye-bye|


Miscellaneous
-------------

**Unicode:**

QBASDOWN is not Unicode-aware, but characters like ā, ø, ṭ and so on are simply passed through to the HTML code. If you can't see them, update your browser.

However, QBASDOWN also has its own system of creating diacritical marks and combining these with letters. This may be easier if you are doing text input in a CLI environment, and you can create letters that don't even exist in reality!

**Code:**
     
    Macron: A%M B%M C%M D%M E%M F%M G%M H%M I%M J%M K%M L%M M%M N%M O%M P%M Q%M R%M S%M T%M U%M V%M W%M X%M Y%M Z%M a%M b%M c%M d%M e%M f%M g%M h%M i%M j%M k%M l%M m%M n%M o%M p%M q%M r%M s%M t%M u%M v%M w%M x%M y%M z%M.  
    Tilde: A%~ B%~ C%~ D%~ E%~ F%~ G%~ H%~ I%~ J%~ K%~ L%~ M%~ N%~ O%~ P%~ Q%~ R%~ S%~ T%~ U%~ V%~ W%~ X%~ Y%~ Z%~ a%~ b%~ c%~ d%~ e%~ f%~ g%~ h%~ i%~ j%~ k%~ l%~ m%~ n%~ o%~ p%~ q%~ r%~ s%~ t%~ u%~ v%~ w%~ x%~ y%~ z%~.  
    Acute: A%' B%' C%' D%' E%' F%' G%' H%' I%' J%' K%' L%' M%' N%' O%' P%' Q%' R%' S%' T%' U%' V%' W%' X%' Y%' Z%' a%' b%' c%' d%' e%' f%' g%' h%' i%' j%' k%' l%' m%' n%' o%' p%' q%' r%' s%' t%' u%' v%' w%' x%' y%' z%'.  
    Grave: A%` B%` C%` D%` E%` F%` G%` H%` I%` J%` K%` L%` M%` N%` O%` P%` Q%` R%` S%` T%` U%` V%` W%` X%` Y%` Z%` a%` b%` c%` d%` e%` f%` g%` h%` i%` j%` k%` l%` m%` n%` o%` p%` q%` r%` s%` t%` u%` v%` w%` x%` y%` z%`.  
    Dot above: A%D B%D C%D D%D E%D F%D G%D H%D I%D J%D K%D L%D M%D N%D O%D P%D Q%D R%D S%D T%D U%D V%D W%D X%D Y%D Z%D a%D b%D c%D d%D e%D f%D g%D h%D i%D j%D k%D l%D m%D n%D o%D p%D q%D r%D s%D t%D u%D v%D w%D x%D y%D z%D.  
    Dot below: A%d B%d C%d D%d E%d F%d G%d H%d I%d J%d K%d L%d M%d N%d O%d P%d Q%d R%d S%d T%d U%d V%d W%d X%d Y%d Z%d a%d b%d c%d d%d e%d f%d g%d h%d i%d j%d k%d l%d m%d n%d o%d p%d q%d r%d s%d t%d u%d v%d w%d x%d y%d z%d.  
    Diaeresis/umlaut: A%: B%: C%: D%: E%: F%: G%: H%: I%: J%: K%: L%: M%: N%: O%: P%: Q%: R%: S%: T%: U%: V%: W%: X%: Y%: Z%: a%: b%: c%: d%: e%: f%: g%: h%: i%: j%: k%: l%: m%: n%: o%: p%: q%: r%: s%: t%: u%: v%: w%: x%: y%: z%:.  
    Ring: A%O B%O C%O D%O E%O F%O G%O H%O I%O J%O K%O L%O M%O N%O O%O P%O Q%O R%O S%O T%O U%O V%O W%O X%O Y%O Z%O a%O b%O c%O d%O e%O f%O g%O h%O i%O j%O k%O l%O m%O n%O o%O p%O q%O r%O s%O t%O u%O v%O w%O x%O y%O z%O.  
    Caron: A%^ B%^ C%^ D%^ E%^ F%^ G%^ H%^ I%^ J%^ K%^ L%^ M%^ N%^ O%^ P%^ Q%^ R%^ S%^ T%^ U%^ V%^ W%^ X%^ Y%^ Z%^ a%^ b%^ c%^ d%^ e%^ f%^ g%^ h%^ i%^ j%^ k%^ l%^ m%^ n%^ o%^ p%^ q%^ r%^ s%^ t%^ u%^ v%^ w%^ x%^ y%^ z%^.  
    Hook: A%H B%H C%H D%H E%H F%H G%H H%H I%H J%H K%H L%H M%H N%H O%H P%H Q%H R%H S%H T%H U%H V%H W%H X%H Y%H Z%H a%H b%H c%H d%H e%H f%H g%H h%H i%H j%H k%H l%H m%H n%H o%H p%H q%H r%H s%H t%H u%H v%H w%H x%H y%H z%H.  
    Breve: A%B B%B C%B D%B E%B F%B G%B H%B I%B J%B K%B L%B M%B N%B O%B P%B Q%B R%B S%B T%B U%B V%B W%B X%B Y%B Z%B a%B b%B c%B d%B e%B f%B g%B h%B i%B j%B k%B l%B m%B n%B o%B p%B q%B r%B s%B t%B u%B v%B w%B x%B y%B z%B.  
    Miscellaneous: %AE %ae %/O %/o %IJ %ij %SZ.
     
Macron: A%M B%M C%M D%M E%M F%M G%M H%M I%M J%M K%M L%M M%M N%M O%M P%M Q%M R%M S%M T%M U%M V%M W%M X%M Y%M Z%M a%M b%M c%M d%M e%M f%M g%M h%M i%M j%M k%M l%M m%M n%M o%M p%M q%M r%M s%M t%M u%M v%M w%M x%M y%M z%M.  
Tilde: A%~ B%~ C%~ D%~ E%~ F%~ G%~ H%~ I%~ J%~ K%~ L%~ M%~ N%~ O%~ P%~ Q%~ R%~ S%~ T%~ U%~ V%~ W%~ X%~ Y%~ Z%~ a%~ b%~ c%~ d%~ e%~ f%~ g%~ h%~ i%~ j%~ k%~ l%~ m%~ n%~ o%~ p%~ q%~ r%~ s%~ t%~ u%~ v%~ w%~ x%~ y%~ z%~.  
Acute: A%' B%' C%' D%' E%' F%' G%' H%' I%' J%' K%' L%' M%' N%' O%' P%' Q%' R%' S%' T%' U%' V%' W%' X%' Y%' Z%' a%' b%' c%' d%' e%' f%' g%' h%' i%' j%' k%' l%' m%' n%' o%' p%' q%' r%' s%' t%' u%' v%' w%' x%' y%' z%'.  
Grave: A%` B%` C%` D%` E%` F%` G%` H%` I%` J%` K%` L%` M%` N%` O%` P%` Q%` R%` S%` T%` U%` V%` W%` X%` Y%` Z%` a%` b%` c%` d%` e%` f%` g%` h%` i%` j%` k%` l%` m%` n%` o%` p%` q%` r%` s%` t%` u%` v%` w%` x%` y%` z%`.  
Dot above: A%D B%D C%D D%D E%D F%D G%D H%D I%D J%D K%D L%D M%D N%D O%D P%D Q%D R%D S%D T%D U%D V%D W%D X%D Y%D Z%D a%D b%D c%D d%D e%D f%D g%D h%D i%D j%D k%D l%D m%D n%D o%D p%D q%D r%D s%D t%D u%D v%D w%D x%D y%D z%D.  
Dot below: A%d B%d C%d D%d E%d F%d G%d H%d I%d J%d K%d L%d M%d N%d O%d P%d Q%d R%d S%d T%d U%d V%d W%d X%d Y%d Z%d a%d b%d c%d d%d e%d f%d g%d h%d i%d j%d k%d l%d m%d n%d o%d p%d q%d r%d s%d t%d u%d v%d w%d x%d y%d z%d.  
Diaeresis/umlaut: A%: B%: C%: D%: E%: F%: G%: H%: I%: J%: K%: L%: M%: N%: O%: P%: Q%: R%: S%: T%: U%: V%: W%: X%: Y%: Z%: a%: b%: c%: d%: e%: f%: g%: h%: i%: j%: k%: l%: m%: n%: o%: p%: q%: r%: s%: t%: u%: v%: w%: x%: y%: z%:.  
Ring: A%O B%O C%O D%O E%O F%O G%O H%O I%O J%O K%O L%O M%O N%O O%O P%O Q%O R%O S%O T%O U%O V%O W%O X%O Y%O Z%O a%O b%O c%O d%O e%O f%O g%O h%O i%O j%O k%O l%O m%O n%O o%O p%O q%O r%O s%O t%O u%O v%O w%O x%O y%O z%O.  
Caron: A%^ B%^ C%^ D%^ E%^ F%^ G%^ H%^ I%^ J%^ K%^ L%^ M%^ N%^ O%^ P%^ Q%^ R%^ S%^ T%^ U%^ V%^ W%^ X%^ Y%^ Z%^ a%^ b%^ c%^ d%^ e%^ f%^ g%^ h%^ i%^ j%^ k%^ l%^ m%^ n%^ o%^ p%^ q%^ r%^ s%^ t%^ u%^ v%^ w%^ x%^ y%^ z%^.  
Hook: A%H B%H C%H D%H E%H F%H G%H H%H I%H J%H K%H L%H M%H N%H O%H P%H Q%H R%H S%H T%H U%H V%H W%H X%H Y%H Z%H a%H b%H c%H d%H e%H f%H g%H h%H i%H j%H k%H l%H m%H n%H o%H p%H q%H r%H s%H t%H u%H v%H w%H x%H y%H z%H.  
Breve: A%B B%B C%B D%B E%B F%B G%B H%B I%B J%B K%B L%B M%B N%B O%B P%B Q%B R%B S%B T%B U%B V%B W%B X%B Y%B Z%B a%B b%B c%B d%B e%B f%B g%B h%B i%B j%B k%B l%B m%B n%B o%B p%B q%B r%B s%B t%B u%B v%B w%B x%B y%B z%B.  
Miscellaneous: %AE %ae %/O %/o %IJ %ij %SZ.

Why? Because in my day job, I often have to write things like *pat%diccasamuppa%Mda* ... Let me know if I missed something you need in your language.

Diacriticals will work in headers and blockquotes, but not in code blocks.

QBASDOWN supports a few simple emoji-style characters:

**Code:**
     
    Faces:   :-), :-(, :)  
    Arrows:  <-. ->, |^|. |v|, <=, =>, ||^|| and ||v||.  
    Gender:  \MAL,\FEM, \MAF, \MAM, \FAF and \AND.  
    Currency: \UKP \USD \USC \YEN \EUR \NAI \RPL \RPI \RUB \LIR \BIT.  
    Misc:    (c), (r), {||, |b|, |c|. |x|, (X), %X, d-d, {o}, |p ||p and -o-.  



Faces: :-), :-(, :) - No I don't know why the angry face is larger. Ask the Unicode guys.  
Arrows: <-. ->, |^|. |v|, <=, =>, ||^||, ||v||.  
Currency: \UKP \USD \USC \YEN \EUR \NAI \RPL \RPI \RUB \LIR \BIT.  
Gender: \MAL,\FEM, \MAF, \MAM, \FAF and \AND.  
Misc: (c), (r), (tm), \CAD, {||, |b|, |c|. |x|, (X), %X, d-d, {o}, |p ||p and -o-.  

Presentation of these varies between browsers. For example, on my system Firefox displays -o- in colour, while Chrome does not. Also the Bitcoin currency symbol is not well supported by browsers yet.

Be careful with those arrows. The left and right single arrows conflict with the centring codes of the Discount dialect, and if you start or end a line with any of the up or down arrows QBASDOWN will think you are trying to make a table.

Emojis do not work in headings, tables, blockquotes or code blocks.

Two other codes you can use are \\NBS for a nonbreaking space and \\NBH for a non-breaking hyphen.

**Code:**
     
    Some common fractions are automatically prettified, but only if surrounded by spaces. If you do not want this, just put something else next to it that is not a space: 1/3.  
    e.g. 1/2 1/3 2/3 1/4 3/4 1/5 2/5 3/5 4/5 1/6 5/6 1/7 1/8 3/8 5/8 7/8 1/9 1/10 
     

Some common fractions are automatically prettified, but only if surrounded by spaces. If you do not want this, just put something else next to it that is not a space: 1/3.  
e.g. 1/2 1/3 2/3 1/4 3/4 1/5 2/5 3/5 4/5 1/6 5/6 1/7 1/8 3/8 5/8 7/8 1/9 1/10 

Fractions do not work in headings, tables, blockquotes or code blocks.

Any actual HTML in your document will be passed through. Let's do a link that way: <a href="http://www.google.com">http://www.google.com</a>.

----

To-Do
-----
Footnotes  
Bullet lists  
numbered lists  

### Maybe One day ...
Encode email links  
Fenced Code blocks using backticks

### Not gonna happen
Table of Contents  
Links and images by reference  
