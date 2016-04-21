%LOADHTML  HTML parser for HTHELP.
%   LOADHTML(CMD,FN,LNK,TXT,FIG,AX,LH,COMP) performs HTML loading,
%   parsing, and display for HTHELP.  This function is not intended to
%   be called directly by users.
%
%   Valid CMD strings are 'load' and 'loadstr' which load HTML source
%   from either a file (named FN) or a given string (TXT) respectively.
%   If LNK is not empty, the section named LNK will be displayed.  The
%   HTML will be viewed in a figure of handle FIG and axis of handle AX.
%   LH provides a vector of line heights for the various heading sizes
%   available, and COMP contains the name of the host machine.
%
%   TS = LOADHTML(CMD,FN,LNK,TXT,FIG,AX,LH,COMP) returns the HTML text
%   string contained in section LNK.
%
%   See also HTHELP and HTPP.
%
%   This function is OBSOLETE and may be removed in future versions.

%   P. Barnard 12-22-94
%   Copyright 1984-2002 The MathWorks, Inc. 
%   $Revision: 1.12 $  $Date: 2002/04/15 03:24:10 $

