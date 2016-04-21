function mcodeConstructor(this,code)
%MCODECONSTRUCTOR Customize object code generation
% code is a codegen.codeblock object

%   Copyright 1984-2003 The MathWorks, Inc. 

% Specify name used in generated code comment
set(code,'Name','arrow');

methods(this,'mcodeConstructor',code,'arrow');
