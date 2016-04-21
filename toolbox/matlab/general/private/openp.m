function out = openp(filename)
%OPENP   Open the matching M-file of a *.P file if one
%   exists.  Helper function for OPEN.
%
%   See OPEN.

%   Chris Portal 1-23-98
%   Copyright 1984-2002 The MathWorks, Inc. 
%   $Revision: 1.10 $  $Date: 2002/04/10 17:05:13 $

if nargout, out = []; end
edit(filename)
