function mcodeConstructor(this,code)
%MCODECONSTRUCTOR Constructor code generation 

%   Copyright 1984-2003 The MathWorks, Inc. 

setConstructorName(code,'errorbar')
  
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
arg = codegen.codeargument('Name','Y','Value',this.YData,'IsParameter',true);
addConstructorArgin(code,arg);

% process LData and UData
ignoreProperty(code,'LData');
ignoreProperty(code,'UData');
if isequal(this.LData,this.UData)
  arg = codegen.codeargument('Name','E','Value',this.LData,'IsParameter',true);
  addConstructorArgin(code,arg);
else
  arg = codegen.codeargument('Name','L','Value',this.LData,'IsParameter',true);
  addConstructorArgin(code,arg);
  
  arg = codegen.codeargument('Name','U','Value',this.UData,'IsParameter',true);
  addConstructorArgin(code,arg);
end

% process Color
if strcmp(this.CodeGenColorMode,'auto')
  ignoreProperty(code,'Color')
end

generateDefaultPropValueSyntax(code);
