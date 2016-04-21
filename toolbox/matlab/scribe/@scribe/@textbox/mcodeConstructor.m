function mcodeConstructor(this,code)
%MCODECONSTRUCTOR Customize object code generation
% code is a codegen.codeblock object

% Copyright 2003-2004 The MathWorks, Inc.

set(code,'Name','textbox');
% Specify constructor name used in code
setConstructorName(code,'annotation');

fig=ancestor(this,'figure');
arg=codegen.codeargument('IsParameter',true,'Name','figure','Value',fig);
addConstructorArgin(code,arg)

arg=codegen.codeargument('Value','textbox');
addConstructorArgin(code,arg);

propsToIgnore = {'HitTest','Parent'};
ignoreProperty(code,propsToIgnore);

% Work around for code generation bug
% Remove String property is string is empty
str = get(this,'String');
if isempty(str)
  ignoreProperty(code,'String');
end

% Generate remaining properties as property/value syntax
generateDefaultPropValueSyntax(code);

posProp = findprop(this,'Position');
if strcmp(get(this,'FitHeightToText'),'on') && ...
      ~isequal(get(this,'Position'),get(posProp,'FactoryValue'))
  arg=codegen.codeargument('Value','FitHeightToText');
  addConstructorArgin(code,arg);
  arg=codegen.codeargument('Value','on');
  addConstructorArgin(code,arg);
end