function mcodeConstructor(this,code)
%MCODECONSTRUCTOR Constructor code generation 

%   Copyright 1984-2003 The MathWorks, Inc. 

setConstructorName(code,'stairs')

plotutils('makemcode',this,code)
  
% process XData
ignoreProperty(code,'XData');
ignoreProperty(code,'XDataMode');
if strcmp(this.xdatamode,'manual')
  arg = codegen.codeargument('Name','X','Value',this.xdata,'IsParameter',true);
  addConstructorArgin(code,arg);
end

% process YData
ignoreProperty(code,'YData');
arg = codegen.codeargument('Name','Y','Value',this.ydata,'IsParameter',true);
addConstructorArgin(code,arg);

% process Color
if strcmp(this.CodeGenColorMode,'auto')
  ignoreProperty(code,'Color')
end

generateDefaultPropValueSyntax(code);

