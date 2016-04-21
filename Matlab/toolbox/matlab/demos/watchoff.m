function watchoff(figNumber)
%WATCHOFF Sets the current figure pointer to the arrow.
%   WATCHOFF(figNumber) will set the figure figNumber's pointer
%   to an arrow. If no argument is given, figNumber is taken to
%   be the current figure.
%
%   See also WATCHON.

%   Ned Gulley, 6-21-93
%   Copyright 1984-2003 The MathWorks, Inc.
%   $Revision: 5.8.4.2 $  $Date: 2004/04/10 23:25:53 $

if nargin<1,
    figNumber=gcf;
end;

% If watchon is used before a window has been opened, it will 
% set the figNumber to the flag NaN, which is why the next line
% checks to make sure that the figNumber is not NaN before resetting
% the pointer.
if ~isnan(figNumber),
    set(figNumber,'Pointer','arrow');
end
