%CMDLNEND Cleans up after command line demos called after CMDLNBGN.
%
%   See also DEMO, CMDLNBGN

%   Ned Gulley, 6-21-93
%   Copyright 1984-2002 The MathWorks, Inc. 
%   $Revision: 5.9 $  $Date: 2002/04/15 03:31:32 $

oldFigNumber=findobj('Type', 'figure', 'Name', 'Command Line Demos');
watchoff(oldFigNumber);
