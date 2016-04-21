%LINE   Create line.
%   LINE(X,Y) adds the line in vectors X and Y to the current axes. 
%   If X and Y are matrices the same size, one line per column is added.
%   LINE(X,Y,Z) creates lines in 3-D coordinates.
%
%   LINE returns a column vector of handles to LINE objects, 
%   one handle per line. LINEs are children of AXES objects.
%
%   The X,Y pair (X,Y,Z triple for 3-D) can be followed by 
%   parameter/value pairs to specify additional properties of the lines.
%   The X,Y pair (X,Y,Z triple for 3-D) can be omitted entirely, and
%   all properties specified using parameter/value pairs.
%
%   Execute GET(H), where H is a line handle, to see a list of line
%   object properties and their current values. Execute SET(H) to see a 
%   list of line object properties and legal property values.
%
%   See also PATCH, TEXT, PLOT, PLOT3.

%   Copyright 1984-2002 The MathWorks, Inc. 
%   $Revision: 5.8 $  $Date: 2002/04/10 17:06:47 $
%   Built-in function.
