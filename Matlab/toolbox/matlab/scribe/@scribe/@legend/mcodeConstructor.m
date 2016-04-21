function mcodeConstructor(this,code)
%MCODECONSTRUCTOR Customize object code generation
% code is a codegen.codeblock object

% Copyright 2003 The MathWorks, Inc.

% Specify constructor name used in code
setConstructorName(code,'legend');

% First arg is an axes
ax=double(this.Axes);
arg=codegen.codeargument('IsParameter',true,'Name','axes','Value',ax);
addConstructorArgin(code,arg);

% Next args the strings. Generate cell array so that property value
% pairs are not ambiguous.
str = get(this,'string');
arg=codegen.codeargument('Value',str);
addConstructorArgin(code,arg);

if strcmp(get(this,'Location'),'none')
  if strcmp(get(this,'ActivePositionProperty'),'position')
    propsToIgnore = {'Location','OuterPosition'};
  else
    propsToIgnore = {'Location','Position'};
  end
else
  propsToIgnore = {'OuterPosition','Position'};
end
propsToIgnore = {'Parent','Layer','ActivePositionProperty',...
                 'Title','XLabel','YLabel', ...
                 'YAxisLocation','YLim','ZLabel','ButtonDownFcn',...
                 'SelectionHighlight','Tag','Box','NextPlot','XTick',...
                 'YTick','UserData','String','Interruptible',propsToIgnore{:}};
ignoreProperty(code,propsToIgnore);

% Generate remaining properties as property/value syntax
generateDefaultPropValueSyntax(code);
