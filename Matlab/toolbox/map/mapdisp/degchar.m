function str = degchar

%DEGCHAR  Sets the degree symbol character
%
%  str = DEGCHAR sets the degree symbol character in a LaTeX format.
%  The text interpreter must be set to LaTeX to have this symbol
%  properly displayed.
%
%  See also ANGL2STR

%  Copyright 1996-2003 The MathWorks, Inc.
% $Revision: 1.8.4.1 $
%  Written by:  E. Byrns, E. Brown, W. Stumpf



%
% Old approach was to set the ascii code to a value which would
% map to the degree character for the font encoding of each platform.
% Now that LaTeX commands are understood by matlab displayed text commands,
% we can make use of them to create the degree symbol in a platform-
% independent way.
%

str = '^{\circ}';
