# kakuro
Data entry and solver for kakuro puzzles. A MacOS app.
# What is a kakuro puzzle?
A kakuro puzzle is similar to a crossword puzzle except for numbers instead of for words.
Where a crossword uses word definitions as clues for each across and down, a kakuro uses totals as clues for each across and down.
Where in a crossword the numbers in the puzzle are a reference to the clues, in a kakuro the numbers are the clues.
In a crossword the solver must fill in the empty cells with letters that form a word that matches the clue.
But in a kakuro the solver must fill in the empty cells with digits (1 through 9 only) that sum to the total that matches the clue.
Furthermore in kakuro, no digit may be repeated when summing to a total.

The totals that form the clues may be any number from 3 through 45.
That is because of the rule that there must be at least two cells to form a total.
Also the no duplicates limits the number of empty of cells in a total to 9.
So 3 is the smallest total since it equals 1 plus 2.
The largest total is 45 because that is the sum of all 9 digits.

A kakuro puzzle presents as a rectangular grid of cells.  There are three types of cells:
1. Unused Cells - are used as filler to define the shape of the puzzle.
2. Empty Cells - are the cells that must be filled in by the person solving the puzzle.
3. Header Cells - are the cells containing the clues for solving the puzzle.  
A header cell is depicted as a square divided in half by an upper left to lower right diagonal.
A number above the diagonal is the across clue for the empty cells to the right.
A number below the diagonal is the down clue for the empty cells below.
# What is the kakuro app?
The kakuro app is currently a graphical editor for kakuro puzzles.  It reads and writes .kkr files.
A .kkr file is a plain text format for representing a single kakuro puzzle.  You can open a .kkr file or create a new one.
The corresponding puzzle is displayed graphically.
One of the puzzle cells is highlighted as the selected cell.  You can move the selection to a different cell.
You can add and delete cells.  You can also make changes to the selected cell.  Once satisfied you can save the puzzle to disk.
There are also tools to help you catch mistakes.
# How do I use the kakuro app?
The kakuro app is a traditional MacOS document base app.  As such, you can have multiple windows open each with its own kakuro puzzle.
The file menu is pretty much as you would expect with a couple of exceptions detailed below.
Editing is almost completely done with the keyboard but you can use the mouse to select a cell or part of a total that you are editing.
There are basically two modes of editing: puzzle level editing and total editing.
## Editing at the puzzle level
This mode is used for moving the selection, changing a cell type, adding cells, and deleting cells.
You can also transition into total editing mode to set the totals in header cells.
### Getting started
There is a sample.kkr file included with this repo to use as a starting point.
### Moving the selection
1. Left Arrow - move the selection one cell to the left.
2. Right Arrow - move the selection one cell to the right.
3. Up Arrow - move the selection one cell up.
4. Down Arrow - move the selection one cell down.
5. Command Left Arrow - move the selection to the leftmost cell of the current row.
6. Command Right Arrow - move the selection to the rightmost cell of the current row.
7. Command Up Arrow - move the selection to the leftmost cell of the first row.
8. Command Down Arrow - move the selection to the rightmost cell of the last row.
### Changing the type of the selected cell
1. U - change the cell to unused.
2. E - change the cell to empty.
3. . - same as E for historical reasons.
4. H - change the cell to a header cell if it is not already.  Enter total editing mode to edit the horizontal (across) total.
5. V - change the cell to a header cell if it is not already.  Enter total editing mode to edit the vertical (down) total.
### Hybrid either move selection or add a cell
1. Tab - move the selection one cell to the right.  If there is no cell there, add one.
2. Enter (or return) - move the selection to the leftmost cell of the next row, creating a new row if needed.
If the row (before the move) is shorter than the other rows, then pad the row with new cells.
### Add cells
Back Tab (shift tab) - Add a cell to the left of the current cell.
Control Enter (or return) - Add a row below the current one.
### Delete cells
1. Right Delete - delete the current cell and move trailing cells left.  If it was last cell in the row, the row is also deleted.
2. Left Delete - delete the cell to the left of the current cell and move trailing cells left.
If it was last cell in the row, the row is also deleted.
## Total editing mode
When you enter total editing mode, a text field is displayed to allow you to edit the relevant (horizontal or vertical) total.
It is pretty much a normal rext field, except that you can only input numbers and when you attempt to exit the field the value is checked.
If the value is not a number between 3 and 45, you get an error and remain in total editing mode.

There are a number of ways to exit the text field and return to puzzle editing mode.
### Accept the new value
1. H - if entering the vertical total and it is valid, accept and start editing the horizontal total.
2. V - if entering the horizontal total and it is valid, accept and start editing the vertical total.
3. Tab - if the total value is valid, accept it, return to puzzle editing mode, and perform the normal Tab action.
4. Enter (or return) - if the total value is valid, accept it, return to puzzle editing mode, and perform the normal Enter action.
5. Back Tab (shift tab) - if the total value is valid, accept it, return to puzzle editing mode, and perform the normal Back Tab action.
6. Control Enter (or return) - if the total value is valid, accept it, return to puzzle editing mode,
and perform the normal Control Enter action.
7. Mouse click - if the total value is valid, accept it and select the clicked on cell.
### Reject the new value (revert to the old value)
The ESC key will exit total editing mode and return the total to the value it had before editing began.
## Help with find errors
The bane of data entry is checking for errors.  The kakuro app provides two tools to help.  They are both items in the File menu.
### Check for Errors
This menu item will check the puzzle for obvious errors and bring up a dialog to report them.
Note than row are column numbers are one based for normal human consumption.
An example error is an empty cell to the right of an unused cell.
It has no across total to belong to and is reported as an orphaned cell.
### Audio Verify
This menu item uses the Mac speech synthesis capability to read the contents of the puzzle aloud.
This allows you to look at your source material and easily compare it to what was entered.
The kakuro app is geared towards entering the puzzle starting in the topmost row left to right, then moving down to the next row.
Audio Verify reads the puzzle column wise in hopes that the different perspective will help prevent making the same mistake twice.
Note that column numbers are also one based, not zero based.  Also to stop the speech, hit the ESC key.
# What's next?
I built the kakuro app for these reasons:
1. I wanted to build a kakuro puzzle solver
2. To build a solver, I need test data
3. I wanted to learn Swift and Cocoa programming
So now that I have a test data editor the obvious next step is the puzzle solver.  But first I think kakuro app needs in app help.
