function clg(arg1);
%CLG    Clear Figure (graph window).
%   CLG is a pseudonym for CLF, provided for upward compatibility
%   from MATLAB 3.5.
%
%   See also CLF.

%   Copyright 1984-2002 The MathWorks, Inc. 
%   $Revision: 5.9 $  $Date: 2002/04/10 17:06:44 $

warning(sprintf(['This function is obsolete and may be removed in ',...
                 'future versions.\n         Use CLF instead.']))
if(nargin == 0)
    clf;
else
    clf(arg1);
end

