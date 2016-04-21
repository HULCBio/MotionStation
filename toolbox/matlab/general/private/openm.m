function out = openm(filename)
%OPENM   Open M-file in M-file Editor.  Helper function
%   for OPEN.
%
%   See OPEN.

%   Chris Portal 1-23-98
%   Copyright 1984-2002 The MathWorks, Inc. 
%   $Revision: 1.11 $  $Date: 2002/04/10 17:05:04 $

if nargout, out = []; end
edit(filename)

