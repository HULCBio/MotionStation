function mcodeConstructor(this,code)
%MCODECONSTRUCTOR Constructor code generation 

%   Copyright 1984-2003 The MathWorks, Inc. 

is3D = ~isempty(this.ZData);

if is3D
  setConstructorName(code,'stem3');
else
  setConstructorName(code,'stem');
end

plotutils('makemcode',this,code)

% Ignore certain properties
ignoreProperty(code,{'XData','XDataMode','YData','ZData','baseline'});

% process XData
if strcmp(this.XDataMode,'manual')
  arg = codegen.codeargument('Name','X','Value',this.XData,'IsParameter',true);
  addConstructorArgin(code,arg);
end

% process YData
arg = codegen.codeargument('Name','Y','Value',this.YData,'IsParameter',true);
addConstructorArgin(code,arg);

% process ZData 
if is3D
    arg = codegen.codeargument('Name','Z','Value',...
                             this.ZData, ...
                             'IsParameter',true);
    addConstructorArgin(code,arg);
end

% process Color
if strcmp(this.CodeGenColorMode,'auto')
  ignoreProperty(code,'Color')
end

% process LineStyle
if strcmp(this.CodeGenLineStyleMode,'auto')
  ignoreProperty(code,'LineStyle')
end

% process Marker
if strcmp(this.CodeGenMarkerMode,'auto')
  ignoreProperty(code,'Marker')
end

generateDefaultPropValueSyntax(code);
