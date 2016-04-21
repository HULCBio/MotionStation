function schema
%SCHEMA defines the scribe.TEXTBOX schema
%

%   Copyright 1984-2004 The MathWorks, Inc. 

pkg   = findpackage('scribe'); % Scribe package
hgPk = findpackage('hg');  % Handle Graphics package
h = schema.class(pkg, 'textbox', hgPk.findclass('hggroup'));

p = schema.prop(h,'ShapeType','ScribeShapeType');
p.AccessFlags.PublicSet = 'off';
p.FactoryValue = 'textbox';
p.Visible = 'off';

p = schema.prop(h,'MoveMode','int32');
p.AccessFlags.Serialize = 'off';
p.FactoryValue = 0;
p.Visible = 'off';

% Selected shadows the GObject Selected property on purpose so
% that HG doesn't draw the built-in selection handles.
p = schema.prop(h,'Selected','on/off');
p.AccessFlags.Serialize = 'off';
p.FactoryValue = 'off';
p.Visible = 'off';

p = schema.prop(h,'Position','axesPositionType');
p.FactoryValue = [.3 .3 .1 .1];

% end of common properties
p = schema.prop(h,'BackgroundColor','surfaceFaceColorType');
p.FactoryValue = 'none';

p = schema.prop(h,'FaceAlpha','NReals');
p.FactoryValue = 1.0;

p = schema.prop(h,'Image','MATLAB array');
p.AccessFlags.Serialize = 'off';
p.FactoryValue = [];
p.Visible = 'off';

% % current style properties
% p = schema.prop(h,'Border','on/off');
% p.AccessFlags.Init = 'on';
% p.FactoryValue = 'off';

p = schema.prop(h,'LineWidth','double');
p.FactoryValue = get(0,'DefaultAxesLineWidth');

p = schema.prop(h,'EdgeColor','surfaceEdgeColorType');
p.FactoryValue = get(0,'DefaultAxesXColor');

p = schema.prop(h,'LineStyle','surfaceLineStyleType');
p.FactoryValue = get(0,'DefaultAxesLineStyle');

p = schema.prop(h,'ObserveStyle','on/off');
p.AccessFlags.Serialize = 'off';
p.FactoryValue = 'on';
p.Visible = 'off';

p = schema.prop(h,'ObservePos','on/off');
p.AccessFlags.Serialize = 'off';
p.FactoryValue = 'on';
p.Visible = 'off';

p = schema.prop(h,'FirstEdit','on/off');
p.AccessFlags.Serialize = 'off';
p.FactoryValue = 'on';
p.Visible = 'off';

p = schema.prop(h,'Units','string');
p.FactoryValue = 'normalized';
p.Visible = 'off';

p = schema.prop(h,'PinPosition','real point');
p.AccessFlags.Serialize = 'off';
p.FactoryValue = [0 0];
p.Visible = 'off';

% this will be used to track pinned position
p = schema.prop(h,'Pin','handle');
p.AccessFlags.Serialize = 'off';
p.Visible = 'off';

p = schema.prop(h,'Rect','handle');
p.AccessFlags.Serialize = 'off';
p.Visible = 'off';

p = schema.prop(h,'Srect','handle vector');
p.AccessFlags.Serialize = 'off';
p.Visible = 'off';

p = schema.prop(h,'Pinrect','handle vector');
p.AccessFlags.Serialize = 'off';
p.Visible = 'off';

% SPECIAL TEXT BOX PROPERTIES

p = schema.prop(h,'Editable','on/off');
p.FactoryValue = 'on';
p.Visible = 'off';

p = schema.prop(h,'Maxw','double');
p.FactoryValue = 700;
p.Visible = 'off';

p = schema.prop(h,'Maxh','double');
p.FactoryValue = 700;
p.Visible = 'off';

p = schema.prop(h,'Minw','double');
p.FactoryValue = 25;
p.Visible = 'off';

p = schema.prop(h,'Minh','double');
p.FactoryValue = 25;
p.Visible = 'off';

% TEXT PROPERTIES

p = schema.prop(h,'ObserveText','on/off');
p.AccessFlags.Serialize = 'off';
p.FactoryValue = 'on';
p.Visible = 'off';

p = schema.prop(h,'Text','handle');
p.AccessFlags.Serialize = 'off';
p.Visible = 'off';

p = schema.prop(h,'Color','textColorType');
p.FactoryValue = get(0,'DefaultTextColor');

p = schema.prop(h,'Editing','on/off');
p.AccessFlags.Serialize = 'off';
p.FactoryValue = 'off';
p.Visible = 'off';

p = schema.prop(h,'FitHeightToText','on/off');
p.FactoryValue = 'on';

p = schema.prop(h,'FontAngle','textFontAngleType');
p.FactoryValue = get(0,'DefaultTextFontAngle');

p = schema.prop(h,'FontName','textFontNameType');
p.FactoryValue = get(0,'DefaultTextFontName');

p = schema.prop(h,'FontSize','double');
p.FactoryValue = get(0,'DefaultTextFontSize');

p = schema.prop(h,'FontUnits','textFontUnitsType');
p.FactoryValue = get(0,'DefaultTextFontUnits');

p = schema.prop(h,'FontWeight','textFontWeightType');
p.FactoryValue = get(0,'DefaultTextFontWeight');

p = schema.prop(h,'HorizontalAlignment','textHorizontalAlignmentType');
p.FactoryValue = 'left';

% Margin is distance between outer rect and inner text
% and is distinct from margin within the text object, which is set to 1.
p = schema.prop(h,'Margin','double');
p.FactoryValue = 5;

p = schema.prop(h,'Rotation','double');
p.FactoryValue = 0;
p.Visible = 'off';

p = schema.prop(h,'String','textStringType');
p.FactoryValue = {''};

% p = schema.prop(h,'String','string');
% p.AccessFlags.Init = 'on';
% p.FactoryValue = '';
% p.Visible = 'off';
% 
% p = schema.prop(h,'Cstring','string vector');
% p.AccessFlags.Init = 'on';
% p.FactoryValue = {''};
% % p.Visible = 'off';

p = schema.prop(h,'Interpreter','textInterpreterType');
p.FactoryValue = get(0,'DefaultTextInterpreter');

p = schema.prop(h,'VerticalAlignment','textVerticalAlignmentType');
p.FactoryValue = 'top';

p = schema.prop(h,'MoveX0','double');
p.AccessFlags.Serialize = 'off';
p.Visible = 'off';

p = schema.prop(h,'MoveY0','double');
p.AccessFlags.Serialize = 'off';
p.Visible = 'off';

p = schema.prop(h,'Afsiz','double');
p.AccessFlags.Serialize = 'off';
p.FactoryValue = 6;
p.Visible = 'off';

pl = schema.prop(h, 'PropertyListeners', 'handle vector');
pl.AccessFlags.Serialize = 'off';
pl.AccessFlags.PublicSet = 'off';
pl.Visible = 'off';

pl = schema.prop(h, 'DeleteListener', 'handle');
pl.AccessFlags.Serialize = 'off';
pl.AccessFlags.PublicGet = 'off';
pl.AccessFlags.PublicSet = 'off';
pl.Visible = 'off';
