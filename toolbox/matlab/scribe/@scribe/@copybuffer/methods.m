function h = methods(this,fcn,varargin)
% METHODS - methods for copybuffer class

%   Copyright 1984-2003 The MathWorks, Inc.
%   $Revision: 1.1.6.3 $  $  $

h = [];

if strcmpi(fcn,'addcopy')
    addcopy(this,varargin{1});
elseif strcmpi(fcn,'clearcopies')
    clearcopies(this);
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function addcopy(h, c)

oldcopies = h.copies;
if isempty(oldcopies)
    copies = c;
else
    copies = oldcopies;
    copies(end+1) = c;
end
    
h.copies = copies;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function clearcopies(h)

oldcopies = h.copies;
if ~isempty(oldcopies)
    for i=0:length(oldcopies)
        delete(h);
    end
end
h.copies = [];

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
