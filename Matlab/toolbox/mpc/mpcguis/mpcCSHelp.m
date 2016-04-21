function mpcCSHelp(varargin)

%  MPCCSHELP  Display MPC context sensitive help
%
%  Threecalling formats:
%  
%  mpcCSHelp(eventSrc, eventData, Tag) (for event callbacks)
%
%  mpcCSHelp(eventSrc, eventData, Tag, Parent) (for callbacks from a modal
%  diagram with handle Parent)
%
%  mpcCSHelp(Tag)  (for standalone use)
%
%  Tag must be a string defined in the mpctool.map file.

%  Author:  Larry Ricker
%  Copyright 1986-2004 The MathWorks, Inc. 
%  $Revision: 1.1.6.1 $ $Date: 2004/03/24 20:42:25 $

Parent = [];
if length(varargin) == 3
    Tag = varargin{end};
elseif length(varargin) == 4
    Tag = varargin{3};
    Parent = varargin{4};
else
    Tag = varargin{1};
end
if ischar(Tag) && ~isempty(Tag)
    if isempty(Parent)
        helpview([docroot, '/mapfiles/mpctool.map'], Tag, ...
            'CSHelpWindow');
    else
        helpview([docroot, '/mapfiles/mpctool.map'], Tag, ...
            'CSHelpWindow', Parent);
    end
end
