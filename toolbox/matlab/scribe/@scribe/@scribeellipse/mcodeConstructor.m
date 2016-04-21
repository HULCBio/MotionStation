function mcodeConstructor(this,code)
%MCODECONSTRUCTOR Customize object code generation
% code is a codegen.codeblock object

% Copyright 2003-2004 The MathWorks, Inc.

set(code,'Name','ellipse');

% Specify constructor name used in code
setConstructorName(code,'annotation');

fig=ancestor(this,'figure');
arg=codegen.codeargument('IsParameter',true,'Name','figure','Value',fig);
addConstructorArgin(code,arg)

arg=codegen.codeargument('Value','ellipse');
addConstructorArgin(code,arg);

% next args are position
pos = get(this,'Position');
arg=codegen.codeargument('Value',pos,'Name','Position');
addConstructorArgin(code,arg);

propsToIgnore = {'HitTest','Parent','Position'};
ignoreProperty(code,propsToIgnore);

% Generate remaining properties as property/value syntax
generateDefaultPropValueSyntax(code);