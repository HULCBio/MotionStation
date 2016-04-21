function r=rptproptable(varargin)
%RPTPROPTABLE Report Generator Property Table
%   A Property Table is a general class of component which
%   displays property-value pairs in a table.  The user can
%   set the number of columns and rows in the table, set the
%   contents of each cell, and specify how each cell is formatted.
%
%   The fastest way to get a complete property table is to use a
%   "preset" table.  Each property table has a variety of prepared
%   tables which the user can apply.  Select a table from the
%   "Select a preset table" popup menu in the upper left hand corner
%   of the screen.  Once you have selected a table, the "Reset" button
%   will become active.  Selecting the Reset button will delete
%   the current table and replace it with the selected preset table.
%
%   Property tables have two distinct "modes".  When the "split
%   property/value cells" mode is ON (as indicated by a check in the
%   box in the upper right hand corner of the screen) the property
%   table allows only one property per cell and no extra text.  When
%   the table is produced, the property name will appear in one cell
%   and the value will appear in a separate cell to the right of the
%   name cell.  When "split" mode is off, each cell may have multiple
%   properties and extra text, all of which are rendered in the 
%   same cell.
%
%   To add a property to a cell, select the cell on the table.  Select
%   the desired property from the listbox on the right side of the 
%   screen and double-click or use the "Add" button.  In split-cell
%   mode, the selected property will replace the existing property in
%   the cell, otherwise the property will be added to the end of the
%   cell text.  Cell text can be hand-edited in both modes.
%
%   Justification can be controlled individually for each cell by
%   using the four togglebuttons on the bottom of the screen.
%   Justification rules work slightly differently for split and 
%   non-split modes.  Left, right, center, and double-justified 
%   alignment options work traditionally for non-split cells.  Split
%   cells render with the closest analogue for a two-cell operation.
%
%                          Non-Split             Split Mode
%   Left Justify        |Prop Val     |        |Prop    |Val      |
%   Right Justify       |     Prop Val|        |    Prop|      Val|
%   Center Justify      |  Prop Val   |        |    Prop|Val      |
%   Double Justify      |Prop      Val|        |Prop    |      Val|
%
%   

%   Copyright 1997-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2004/04/15 00:17:09 $


r.Desc='Report Generator Property Table';
r=class(r,'rptproptable');
inferiorto('rptcomponent');
