function schema
%SCHEMA defines the scribe.DOUBLEARROW schema
%

%   Copyright 1984-2003 The MathWorks, Inc. 
%   $  $  $

pkg   = findpackage('scribe'); % Scribe package
h = schema.class(pkg, 'doublearrow', pkg.findclass('line'));
if isempty(findtype('ArrowHeadType'))
    schema.EnumType('ArrowHeadType', ...
        {'none','plain','ellipse','vback1','vback2','vback3','cback1','cback2',...
        'cback3','fourstar','rectangle','diamond','rose','hypocycloid','astroid','deltoid'});
end

% TAIL STYLE
p = schema.prop(h,'TailLineWidth','double');
p.AccessFlags.Init = 'on'; 
p.FactoryValue = get(0,'DefaultLineLineWidth');
p.Visible='off';
p = schema.prop(h,'TailColor','lineColorType');
p.AccessFlags.Init = 'on'; 
p.FactoryValue = get(0,'DefaultLineColor');
p.Visible='off';
p = schema.prop(h,'TailLineStyle','lineLineStyleType');
p.AccessFlags.Init = 'on'; 
p.FactoryValue = get(0,'DefaultLineLineStyle');
p.Visible='off';
% HEADS
p = schema.prop(h,'Heads','handle vector');
p.AccessFlags.Serialize = 'off';
p.Visible='off';
% HEAD STYLE PROPS - BOTH HEADS
p = schema.prop(h,'HeadStyle','ArrowHeadType');
p.AccessFlags.Init = 'on'; 
p.FactoryValue = 'vback2';
p.Visible='off';
p = schema.prop(h,'HeadBackDepth','double');
p.AccessFlags.Init = 'on'; 
p.FactoryValue = .35;
p.Visible='off';
p = schema.prop(h,'HeadRosePQ','double');
p.AccessFlags.Init = 'on'; 
p.FactoryValue = 2;
p.Visible='off';
p = schema.prop(h,'HeadHypocycloidN','double');
p.AccessFlags.Init = 'on'; 
p.FactoryValue = 3;
p.Visible='off';
p = schema.prop(h,'HeadFaceColor','patchFaceColorType');
p.AccessFlags.Init = 'on'; 
p.FactoryValue = get(0,'DefaultLineColor');
p.Visible='off';
p = schema.prop(h,'HeadFaceAlpha','NReals');
p.AccessFlags.Init = 'on'; 
p.FactoryValue = 1;
p.Visible='off';
p = schema.prop(h,'HeadLineWidth','double');
p.AccessFlags.Init = 'on'; 
p.FactoryValue = get(0,'DefaultLineLineWidth');
p.Visible='off';
p = schema.prop(h,'HeadEdgeColor','patchEdgeColorType');
p.AccessFlags.Init = 'on'; 
p.FactoryValue = get(0,'DefaultLineColor');
p.Visible='off';
p = schema.prop(h,'HeadLineStyle','patchLineStyleType');
p.AccessFlags.Init = 'on'; 
p.FactoryValue = 'none';
p.Visible='off';
p = schema.prop(h,'HeadWidth','double');
p.AccessFlags.Init = 'on'; 
p.FactoryValue = 10;
p.Visible='off';
p = schema.prop(h,'HeadLength','double');
p.AccessFlags.Init = 'on'; 
p.FactoryValue = 10;
p.Visible='off';
p = schema.prop(h,'HeadSize','double');
p.AccessFlags.Init = 'off';
p.Visible='off';
% HEAD 1
p = schema.prop(h,'Head1Style','ArrowHeadType');
p.AccessFlags.Init = 'on'; 
p.FactoryValue = 'vback2';
p = schema.prop(h,'Head1BackDepth','double');
p.AccessFlags.Init = 'on'; 
p.FactoryValue = .35;
p.Visible='off';
p = schema.prop(h,'Head1RosePQ','double');
p.AccessFlags.Init = 'on'; 
p.FactoryValue = 2;
p.Visible='off';
p = schema.prop(h,'Head1HypocycloidN','double');
p.AccessFlags.Init = 'on'; 
p.FactoryValue = 3;
p.Visible='off';
p = schema.prop(h,'Head1FaceColor','patchFaceColorType');
p.AccessFlags.Init = 'on'; 
p.FactoryValue = get(0,'DefaultLineColor');
p.Visible='off';
p = schema.prop(h,'Head1FaceAlpha','NReals');
p.AccessFlags.Init = 'on'; 
p.FactoryValue = 1;
p.Visible='off';
p = schema.prop(h,'Head1LineWidth','double');
p.AccessFlags.Init = 'on'; 
p.FactoryValue = get(0,'DefaultLineLineWidth');
p.Visible='off';
p = schema.prop(h,'Head1EdgeColor','patchEdgeColorType');
p.AccessFlags.Init = 'on'; 
p.FactoryValue = get(0,'DefaultLineColor');
p.Visible='off';
p = schema.prop(h,'Head1LineStyle','patchLineStyleType');
p.AccessFlags.Init = 'on'; 
p.FactoryValue = 'none';
p.Visible='off';
p = schema.prop(h,'Head1Width','double');
p.AccessFlags.Init = 'on'; 
p.FactoryValue = 10;
p = schema.prop(h,'Head1Length','double');
p.AccessFlags.Init = 'on'; 
p.FactoryValue = 10;
% HEAD 2
p = schema.prop(h,'Head2Style','ArrowHeadType');
p.AccessFlags.Init = 'on'; 
p.FactoryValue = 'vback2';
p = schema.prop(h,'Head2BackDepth','double');
p.AccessFlags.Init = 'on'; 
p.FactoryValue = .35;
p.Visible='off';
p = schema.prop(h,'Head2RosePQ','double');
p.AccessFlags.Init = 'on'; 
p.FactoryValue = 2;
p.Visible='off';
p = schema.prop(h,'Head2HypocycloidN','double');
p.AccessFlags.Init = 'on'; 
p.FactoryValue = 3;
p.Visible='off';
p = schema.prop(h,'Head2FaceColor','patchFaceColorType');
p.AccessFlags.Init = 'on'; 
p.FactoryValue = get(0,'DefaultLineColor');
p.Visible='off';
p = schema.prop(h,'Head2FaceAlpha','NReals');
p.AccessFlags.Init = 'on'; 
p.FactoryValue = 1;
p.Visible='off';
p = schema.prop(h,'Head2LineWidth','double');
p.AccessFlags.Init = 'on'; 
p.FactoryValue = get(0,'DefaultLineLineWidth');
p.Visible='off';
p = schema.prop(h,'Head2EdgeColor','patchEdgeColorType');
p.AccessFlags.Init = 'on'; 
p.FactoryValue = get(0,'DefaultLineColor');
p.Visible='off';
p = schema.prop(h,'Head2LineStyle','patchLineStyleType');
p.AccessFlags.Init = 'on'; 
p.FactoryValue = 'none';
p.Visible='off';
p = schema.prop(h,'Head2Width','double');
p.AccessFlags.Init = 'on'; 
p.FactoryValue = 10;
p = schema.prop(h,'Head2Length','double');
p.AccessFlags.Init = 'on'; 
p.FactoryValue = 10;
