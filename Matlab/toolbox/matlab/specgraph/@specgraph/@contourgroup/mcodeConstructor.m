function mcodeConstructor(this,code)
%MCODECONSTRUCTOR Constructor code generation 

%   Copyright 1984-2003 The MathWorks, Inc. 

setConstructorName(code,'contour')

plotutils('makemcode',this,code)
  
% process XData
ignoreProperty(code,'XData');
ignoreProperty(code,'XDataMode');
if strcmp(this.XDataMode,'manual')
  arg = codegen.codeargument('Name','X','Value',this.XData,'IsParameter',true);
  addConstructorArgin(code,arg);
end

% process YData
ignoreProperty(code,'YData');
ignoreProperty(code,'YDataMode');
if strcmp(this.YDataMode,'manual')
  arg = codegen.codeargument('Name','Y','Value',this.YData,'IsParameter',true);
  addConstructorArgin(code,arg);
end

% process ZData
ignoreProperty(code,'ZData');
arg = codegen.codeargument('Name','Z','Value',this.ZData,'IsParameter',true);
addConstructorArgin(code,arg);

ignoreProperty(code,'LevelListMode');
ignoreProperty(code,'LevelStepMode');
ignoreProperty(code,'TextListMode');
ignoreProperty(code,'TextStepMode');

if strcmp(this.ShowText,'off')
  ignoreProperty(code,'TextList');
  ignoreProperty(code,'TextStep');
end

generateDefaultPropValueSyntax(code);
