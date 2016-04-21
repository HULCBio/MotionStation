function schema
%SCHEMA defines the scribe.TEXTARROW schema
%

%   Copyright 1984-2004 The MathWorks, Inc.
%   $  $  $

pkg   = findpackage('scribe'); % Scribe package
h = schema.class(pkg, 'textarrow', pkg.findclass('line'));
if isempty(findtype('ArrowHeadType'))
    schema.EnumType('ArrowHeadType', ...
        {'none','plain','ellipse','vback1','vback2','vback3','cback1','cback2',...
        'cback3','fourstar','rectangle','diamond','rose','hypocycloid','astroid','deltoid'});
end

% TAIL STYLE PROPS
p = schema.prop(h,'TailLineWidth','double');
p.FactoryValue = get(0,'DefaultLineLineWidth');
p.Visible='off';
p = schema.prop(h,'TailColor','lineColorType');
p.FactoryValue = get(0,'DefaultLineColor');
p.Visible='off';
p = schema.prop(h,'TailLineStyle','lineLineStyleType');
p.FactoryValue = get(0,'DefaultLineLineStyle');
p.Visible='off';

% HEAD
p = schema.prop(h,'Heads','handle vector');
p.AccessFlags.Serialize = 'off';
p.Visible='off';

% HEAD STYLE PROPS
p = schema.prop(h,'HeadStyle','ArrowHeadType');
p.FactoryValue = 'vback2';
p = schema.prop(h,'HeadBackDepth','double');
p.FactoryValue = .35;
p.Visible='off';
p = schema.prop(h,'HeadRosePQ','double');
p.FactoryValue = 2;
p.Visible='off';
p = schema.prop(h,'HeadHypocycloidN','double');
p.FactoryValue = 3;
p.Visible='off';
p = schema.prop(h,'HeadFaceColor','patchFaceColorType');
p.FactoryValue = get(0,'DefaultLineColor');
p.Visible='off';
p = schema.prop(h,'HeadFaceAlpha','NReals');
p.FactoryValue = 1;
p.Visible='off';
p = schema.prop(h,'HeadLineWidth','double');
p.FactoryValue = get(0,'DefaultLineLineWidth');
p.Visible='off';
p = schema.prop(h,'HeadEdgeColor','patchEdgeColorType');
p.FactoryValue = get(0,'DefaultLineColor');
p.Visible='off';
p = schema.prop(h,'HeadLineStyle','patchLineStyleType');
p.FactoryValue = 'none';
p.Visible='off';
p = schema.prop(h,'HeadWidth','double');
p.FactoryValue = 10;
p = schema.prop(h,'HeadLength','double');
p.FactoryValue = 10;
p = schema.prop(h,'HeadSize','double');
p.Visible='off';

% FOR TEXT OBJECT
p = schema.prop(h,'ObserveText','on/off');
p.AccessFlags.Serialize = 'off';
p.FactoryValue = 'on';
p.Visible = 'off';

p = schema.prop(h,'Text','handle');
p.AccessFlags.Serialize = 'off';
p.Visible = 'off';

p = schema.prop(h,'String','textStringType');
p.FactoryValue = {''};

p = schema.prop(h,'TextEraseMode','textEraseModeType');
p.FactoryValue = 'normal';
p.Visible = 'off';

p = schema.prop(h,'TextEditing','on/off');
p.AccessFlags.Serialize = 'off';
p.FactoryValue = 'off';
p.Visible = 'off';

p = schema.prop(h,'FontAngle','textFontAngleType');
p.FactoryValue = get(0,'DefaultTextFontAngle');

p = schema.prop(h,'FontName','textFontNameType');
p.FactoryValue = get(0,'DefaultTextFontName');

p = schema.prop(h,'FontSize','double');
p.FactoryValue = get(0,'DefaultTextFontSize');

p = schema.prop(h,'FontUnits','textFontUnitsType');
p.FactoryValue = get(0,'DefaultTextFontUnits');
p.Visible = 'off';

p = schema.prop(h,'FontWeight','textFontWeightType');
p.FactoryValue = get(0,'DefaultTextFontWeight');

p = schema.prop(h,'HorizontalAlignment','textHorizontalAlignmentType');
p.FactoryValue = 'center';

p = schema.prop(h,'VerticalAlignment','textVerticalAlignmentType');
p.FactoryValue = 'middle';

p = schema.prop(h,'VerticalAlignmentMode','axesXLimModeType');
p.Visible = 'off';
p.FactoryValue = 'auto';

p = schema.prop(h,'Interpreter','textInterpreterType');
p.FactoryValue = get(0,'DefaultTextInterpreter');

p = schema.prop(h,'TextMargin','double');
p.FactoryValue = 2;

p = schema.prop(h,'TextRotation','double');
p.FactoryValue = 0;

p = schema.prop(h,'TextBackgroundColor','patchFaceColorType');
p.FactoryValue = get(0,'DefaultTextBackgroundColor');

p = schema.prop(h,'TextColor','textColorType');
p.FactoryValue = get(0,'DefaultTextColor');

p = schema.prop(h,'TextLineWidth','double');
p.FactoryValue = get(0,'DefaultLineLineWidth');

p = schema.prop(h,'TextEdgeColor','textEdgeColorType');
p.FactoryValue = get(0,'DefaultTextEdgeColor');

