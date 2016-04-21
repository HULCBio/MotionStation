function out = openmdl(filename)
%OPENMDL   Open *.MDL model in Simulink.  Helper function for OPEN.
%
%   See OPEN.

%   Chris Portal 1-23-98
%   Copyright 1984-2002 The MathWorks, Inc. 
%   $Revision: 1.13 $  $Date: 2002/04/10 17:05:10 $

if nargout, out = []; end

if exist('open_system','builtin')
    open_system(filename);
else
    error('Simulink is not installed.')
end
