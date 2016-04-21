function schema
%SCHEMA defines the scribe.COLORBAR schema
%
%  See also PLOTEDIT

%   Copyright 1984-2003 The MathWorks, Inc.
%   $Revision: 1.1.6.11 $  $  $

pkg   = findpackage('scribe'); % Scribe package
hgPk = findpackage('hg');  % Handle Graphics package
h = schema.class(pkg, 'colorbar', hgPk.findclass('axes'));
if isempty(findtype('ColorbarLocationPreset'))
    schema.EnumType('ColorbarLocationPreset',{...
        'North','South','East','West', ...
        'NorthOutside','SouthOutside','EastOutside','WestOutside', ...
        'manual'});
end  

% STYLE PROPERTIES
p = schema.prop(h,'EdgeColor','axesColorType');
p.AccessFlags.Init = 'on';
p.FactoryValue = get(0,'DefaultAxesXColor');
p.Visible = 'off';

p = schema.prop(h,'Image','MATLAB array');
p.AccessFlags.Init = 'on';
p.FactoryValue = [];
p.Visible = 'off';

p = schema.prop(h,'ColormapMoveInitialMap','MATLAB array');
p.AccessFlags.Init = 'off';
p.Visible = 'off';

p = schema.prop(h,'BaseColormap','MATLAB array');
p.AccessFlags.Init = 'off';
p.Visible = 'off';

p = schema.prop(h,'CmapNodeIndices','NReals');
p.AccessFlags.Init = 'off';
p.Visible = 'off';

p = schema.prop(h,'CmapNodeFrx','NReals');
p.AccessFlags.Init = 'off';
p.Visible = 'off';

p = schema.prop(h,'MovingNodeIndex','NReals');
p.AccessFlags.Init = 'off';
p.Visible = 'off';

p = schema.prop(h,'MovingNodeFrx','NReals');
p.AccessFlags.Init = 'off';
p.Visible = 'off';

p = schema.prop(h,'Location','ColorbarLocationPreset');
p.AccessFlags.Init = 'on';
p.FactoryValue = 'EastOutside';

% editing colormap from colorbar
p = schema.prop(h,'Editing','on/off');
p.AccessFlags.Init = 'on';
p.FactoryValue = 'off';
p.Visible = 'off';

% peer axes
p = schema.prop(h,'Axes','handle');
p.Visible = 'off';

% delete proxy for peer axes
p = schema.prop(h,'DeleteProxy','handle');
p.Visible = 'off';

pl = schema.prop(h, 'PropertyListeners', 'handle vector');
pl.AccessFlags.Serialize = 'off';
pl.AccessFlags.PublicSet = 'off';
pl.Visible = 'off';

pl = schema.prop(h, 'DeleteListener', 'handle');
pl.AccessFlags.Serialize = 'off';
pl.AccessFlags.PublicGet = 'off';
pl.AccessFlags.PublicSet = 'off';
p.Visible = 'off';