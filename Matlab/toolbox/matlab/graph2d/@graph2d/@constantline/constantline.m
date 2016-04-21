function h = constantline(val, varargin)
% CONSTANTLINE Create a line from a constant.
%    H = CONSTANTLINE(VAL) where VAL is a scalar creates a 
%    horizontal line at VAL. If VAL is a vector, it creates
%    a one line that looks like a set of lines, one at each value, 
%    returning just one handle.  To create vertical lines, use 
%    CHANGEDEPENDVAR method.
%
%    H = CONSTANTLINE(VAL,PARAM1,VALUE1,PARAM2,VALUE2) creates a line
%    with properties specified by the param value pairs.

%   Copyright 1984-2002 The MathWorks, Inc. 
%   $Revision: 1.9 $  $Date: 2002/04/15 03:58:50 $

pkg = findpackage('graph2d'); % get handle to graph2d package
hgpkg = findpackage('hg');    % get handle to hg package

if isequal(val, 'parent')
   % This condition should only happen when we are being
   % called by the FIG-file loader which always passes
   % our constructor ('parent', parent) arguments.
   val = 0;
   curraxes = varargin{1};
   varargin = {};
else
   parent = find(strncmpi('parent',varargin,6));
   if ~isempty(parent)
      curraxes = varargin{parent+1};
   else
      curraxes = gca;
   end
end

% Construct the line
if ~isempty(varargin)
   h = graph2d.constantline('xdata',get(curraxes,'xlim'),'ydata',get(curraxes,'ylim'),varargin{:});  % calls built-in constructor
else
   h = graph2d.constantline('xdata',get(curraxes,'xlim'),'ydata',get(curraxes,'ylim'));
end
% Initialize
h.value = val;       % Constant
% Install a listener for the axes limits
axesC = hgpkg.findclass('axes');
xlimP = axesC.findprop('xlim');
ylimP = axesC.findprop('ylim');
h.listenerAxes = handle.listener(get(h,'parent'), [xlimP ylimP], 'PropertyPostSet', {@localUpdateLine, h});

% Install a listener for the constantline Value and DependVar property
h.listenerValue = handle.listener(h, [h.findprop('Value') h.findprop('DependVar')], 'PropertyPostSet', {@localUpdateLine, h});

% Draw the line
update(h);

%-----------------------------------------------------------
function localUpdateLine(src, eventData, hCline)
% LOCALUPDATELINE Callback to update constantline when axes limits change.
update(hCline);
