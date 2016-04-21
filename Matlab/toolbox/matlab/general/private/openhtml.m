function out = openhtml(filename)
%OPENHTML Display HTML file in the Help Browser
%   Helper function for OPEN.
%
%   See OPEN.

%   Copyright 1984-2002 The MathWorks, Inc. 
%   $Revision: 1.9 $  $Date: 2002/04/10 17:05:31 $

if nargout, out = []; end
web(filename);
