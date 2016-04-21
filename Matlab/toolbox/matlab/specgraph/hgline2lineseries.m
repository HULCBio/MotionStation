function newh = hgline2lineseries(h,varargin)
%HGLINE2LINESERIES Construct lineseries from line
%  This file is an internal helper file for graphics tools
%  and shouldn't be called directly by users.

%  HS = HGLINE2LINESERIES(H) creates a lineseries HS with the same
%  properties values as line H.
%  HS = HGLINE2LINESERIES(H,PROP1,VAL1,PROP2,VAL2,...) applies the
%  property-value pairs PROP1,VAL1 etc to HS. Use the 'Parent'
%  property to create the lineseries in a different axes than H.
%
%  Example:
%    h = line('Color','r');
%    figure;
%    ax = axes;
%    h2 = hgline2lineseries(h,'Parent',ax);

%   Copyright 1984-2004 The MathWorks, Inc. 

error(nargchk(1,inf,nargin,'struct'));
h = handle(h);
if isempty(h) || ~ishandle(h) || ~isa(h,'line')
  error('First argument must be a line handle.');
end

hgpkg = findpackage('hg');
linecls = findclass(hgpkg,'line');
lineprops = get(linecls,'Properties');

% remove hidden properties
lineprops(strcmp(get(lineprops,'Visible'),'off')) = [];

fields = get(lineprops,'Name');

[dummy,ia,ib] = intersect(fields,{'BeingDeleted','Children','Type','UIContextMenu'});
fields(ia) = [];
vals = get(h,fields);
pvpairs = [fields(:).' ; vals(:).'];
lineseries('init'); % register lineseries with UDD if needed
newh = double(graph2d.lineseries(pvpairs{:},varargin{:}));
delete(h);