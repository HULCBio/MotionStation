function mcodeConstructor(this,code)
%MCODECONSTRUCTOR Constructor code generation 

%   Copyright 1984-2003 The MathWorks, Inc. 

setConstructorName(code,'scatter')

plotutils('makemcode',this,code)
  
ignoreProperty(code,{'XData','YData','ZData','SizeData','CData'});

% process XData
arg = codegen.codeargument('Name','X','Value',this.XData,'IsParameter',true);
addConstructorArgin(code,arg);

% process YData
arg = codegen.codeargument('Name','Y','Value',this.YData,'IsParameter',true);
addConstructorArgin(code,arg);

ZData = get(this,'ZData');
if isempty(ZData)
  arg = codegen.codeargument('Name','Z','Value',this.ZData,'IsParameter',true);
  addConstructorArgin(code,arg);
end

% process SizeData
arg = codegen.codeargument('Name','S','Value',this.SizeData,'IsParameter',true);
addConstructorArgin(code,arg);

% process CData
arg = codegen.codeargument('Name','C','Value',this.CData,'IsParameter',true);
addConstructorArgin(code,arg);

generateDefaultPropValueSyntax(code);

