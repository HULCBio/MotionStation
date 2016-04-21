function mcodeConstructor(this,code)
%MCODECONSTRUCTOR Constructor code generation 

%   Copyright 1984-2003 The MathWorks, Inc. 

is3D = ~isempty(this.zdata);

if is3D
   setConstructorName(code,'quiver3')
else
    setConstructorName(code,'quiver')
end

plotutils('makemcode',this,code)

ignoreProperty(code,{'XData','YData','ZData',...
                     'XDataMode','YDataMode',...
                     'UData','VData','WData'});

% process XData
if strcmp(this.xdatamode,'manual')
  arg = codegen.codeargument('Name','X','Value',this.xdata,'IsParameter',true);
  addConstructorArgin(code,arg);
end

% process YData
if strcmp(this.ydatamode,'manual')
  arg = codegen.codeargument('Name','Y','Value',this.ydata,'IsParameter',true);
  addConstructorArgin(code,arg);
end

% process ZData
if is3D
  arg = codegen.codeargument('Name','Z','Value',this.zdata,'IsParameter',true);
  addConstructorArgin(code,arg);
end

% process UData
arg = codegen.codeargument('Name','U','Value',this.udata,'IsParameter',true);
addConstructorArgin(code,arg);

% process VData
arg = codegen.codeargument('Name','V','Value',this.vdata,'IsParameter',true);
addConstructorArgin(code,arg);

% process WData
if is3D
  arg = codegen.codeargument('Name','W','Value',this.wdata,'IsParameter',true);
  addConstructorArgin(code,arg);
end

% process Color
if strcmp(this.CodeGenColorMode,'auto')
  ignoreProperty(code,'Color')
end

generateDefaultPropValueSyntax(code);

