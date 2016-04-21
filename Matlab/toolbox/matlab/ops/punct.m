%Punctuation.
% .   Decimal point. 325/100, 3.25 and .325e1 are all the same.
%
% .   Array operations.  Element-by-element multiplicative operations
%     are obtained using .* , .^ , ./ , .\ or .'.  For example,
%     C = A ./ B is the matrix with elements c(i,j) = a(i,j)/b(i,j).
%
% .   Field access.  A.field and A(i).field, when A is a structure, access
%     the contents of the field with the name "field".  If A isn't a
%     scalar structure, this produces a comma separated list (see LISTS).
%     You can nest structure access as in X(2).field(3).name.  You can
%     also combine structure, cell array, and paren subscripting if that
%     makes sense for the arrays stored in the structure (see PAREN).
%
% ..  Parent directory.  See CD.
%
% ... Continuation. Three or more periods at the end of a line continue the
%     current command or function call onto the next line. Three or more
%     periods before the end of a line cause MATLAB to ignore the remaining
%     text on the current line and continue the command or function call onto
%     the next line. This effectively makes a comment out of anything on the
%     current line that follows the periods.
%
% ,   Comma.  The comma is used to separate matrix subscripts
%     and arguments to functions.  It is also used to separate
%     statements in multi-statement lines. In this situation,
%     it may be replaced by a semicolon to suppress printing.
%
% ;   Semicolon.  The semicolon is used inside brackets to indicate
%     the ends of the rows of a matrix.  It is also used after an
%     expression or statement to suppress printing.
%
% %   Percent.  The percent symbol is used to begin comments.
%     Logically, it serves as an end-of-line character.  Any
%     following text on the line is ignored or printed by the
%     HELP system.
%
% !   Exclamation point.  Any text following the '!' is issued
%     as a command to the underlying computer operating system.
%     On the PC, adding & to the end of the ! command line, as in
%        !dir &
%     causes the output to appear in a separate window and for the window
%     to remain open after the command completes.
%
% '   Transpose.   X' is the complex conjugate transpose of X. 
%     X.' is the non-conjugate transpose.
%
% '   Quote. 'ANY TEXT' is a vector whose components are the
%     ASCII codes for the characters. A quote within the text
%     is indicated by two quotes.  For example: 'Don''t forget.'
%
% =   Assignment.  B = A stores the elements of A in B.
%
% @   At.  The at symbol is used to create a function_handle.
%     It is also used at the beginning of directory names that contain
%     matlab object methods and the constructor for the object, e.g.
%     the directory @inline contains the constructor inline.m for the 
%     inline object and all methods for inline objects.
%
%
%     See also RELOP, COLON, LISTS, PAREN, CD, FUNCTION_HANDLE.

%   Copyright 1984-2003 The MathWorks, Inc.
%   $Revision: 5.11.4.2 $  $Date: 2004/04/16 22:08:02 $
