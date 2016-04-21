function th = text(x,y,string,opt_sc)
%TEXT   Text annotation.
%   TEXT(X,Y,'string') adds the text in the quotes to location (X,Y)
%   on the current axes, where (X,Y) is in units from the current
%   plot. If X and Y are vectors, TEXT writes the text at all locations
%   given. If 'string' is an array the same number of rows as the
%   length of X and Y, TEXT marks each point with the corresponding row
%   of the 'string' array.
%
%   TEXT(X,Y,Z,'string') adds text in 3-D coordinates.
%
%   TEXT returns a column vector of handles to TEXT objects, one
%   handle per text object. TEXT objects are children of AXES objects.
%
%   The X,Y pair (X,Y,Z triple for 3-D) can be followed by 
%   parameter/value pairs to specify additional properties of the text.
%   The X,Y pair (X,Y,Z triple for 3-D) can be omitted entirely, and
%   all properties specified using parameter/value pairs.
%
%   Execute GET(H), where H is a text handle, to see a list of text
%   object properties and their current values. Execute SET(H) to see a
%   list of text object properties and legal property values.
%
%   See also XLABEL, YLABEL, ZLABEL, TITLE, GTEXT, LINE, PATCH.

%   Archaic, but grandfathered:
%   TEXT(X,Y,'string','sc') interprets the (X,Y) points in normalized
%   axis coordinates, where (0,0) is the lower-left corner of the current
%   axes, and (1,1) is the upper-right.

%   Copyright 1984-2002 The MathWorks, Inc. 
%   $Revision: 5.9 $  $Date: 2002/04/15 04:07:33 $
%   Built-in function.
