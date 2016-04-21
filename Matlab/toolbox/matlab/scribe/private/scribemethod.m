function varargout = scribemethod(varargin)
% SCRIBEMETHOD - gets the scribe object that contains the hg object
% h and calls that objects method with fcn and varargin

%   Copyright 1984-2003 The MathWorks, Inc. 

% nargin can be 2 or 3 (not called from function handle callback) or 4 or 5
% (from function handle callback).

n=1;
if nargin>3
    n=3;
end
h = varargin{n};
fcn = varargin{n+1};

if nargin>n+1
    args = varargin(n+2:nargin);
else
    args = {};
end

if ~ishandle(h), return; end
h = handle(h);

if isequal(get(h,'Type'),'figure')
    % if a figure is passed its a scribe overlay method
    obj = handle(getappdata(double(h),'Scribe_ScribeOverlay'));
elseif isa(h,'scribe.scribeaxes')
    % scribeaxes, colorbar and legend it is the object itself
    obj = h;
else
    % other scribe objects it is their parent group
    obj = handle(get(h,'Parent'));
end

if ~isempty(obj) && ishandle(obj)
    fig = ancestor(double(obj),'figure');
    if isappdata(fig,'scribeActive')
        if nargout==0
            obj.methods(fcn,args{:});
        else
            [varargout{1:nargout}] = obj.methods(fcn,args{:});
        end
    end
end
