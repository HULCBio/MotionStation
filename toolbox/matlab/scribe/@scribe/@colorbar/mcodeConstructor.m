function mcodeConstructor(this,code)
%MCODECONSTRUCTOR Customize object code generation
% code is a codegen.codeblock object

% Copyright 2003 The MathWorks, Inc.

% Generate constructor like this:
% h = myconstructor(val1,val2,'prop3',val3,'prop4',val4,...)
% First two arguments are values of 'prop1' and 'prop2'

% Specify constructor name used in code
setConstructorName(code,'colorbar');

% graphCodeGenHelper(this,code);

% Force properties 'prop2' and 'prop3' to always be parameters in 
% generated code
ax=double(this.Axes);
arg=codegen.codeargument('IsParameter',false,'Name','peer','Value','peer');
addConstructorArgin(code,arg);
arg=codegen.codeargument('IsParameter',true,'Name','axes','Value',ax);
addConstructorArgin(code,arg);

if ~strcmpi(get(this,'Location'),'manual')
    arg=codegen.codeargument('IsParameter',false,'Name','Orientation','Value',get(this,'Location'));
else
    arg=codegen.codeargument('IsParameter',false,'Name','Position','Value',this.Position);
end
addConstructorArgin(code,arg);

propsToIgnore = {'Parent','ActivePositionProperty','Layer',...
                 'OuterPosition','Position','Title','XLabel',...
                 'YLabel','YAxisLocation','YLim','ZLabel',...
                 'ButtonDownFcn','SelectionHighlight','Tag','Image',...
                 'Interruptible'};
ignoreProperty(code,propsToIgnore);

% % Generate remaining properties as property/value syntax
generateDefaultPropValueSyntax(code);