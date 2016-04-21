function schema

% Copyright 2003-2004 The MathWorks, Inc.

% Construct class
pk = findpackage('codegen');
cls = schema.class(pk,'codeargument');

% Add new enumeration type
if (isempty(findtype('ArgumentType')))
  schema.EnumType('ArgumentType',{'PropertyName','PropertyValue','None'});
end

% Public properties
schema.prop(cls,'Name','MATLAB array');
schema.prop(cls,'Value','MATLAB array');
p = schema.prop(cls,'IsParameter','MATLAB array');
set(p,'FactoryValue',false);
p = schema.prop(cls,'Ignore','MATLAB array');
set(p,'FactoryValue',false);
schema.prop(cls,'Comment','MATLAB array');
p = schema.prop(cls,'ArgumentType','ArgumentType');
set(p,'FactoryValue','None');

% Hidden properties
% These properties should have package visibility but
% that can't be done in MATLAB now.
p = schema.prop(cls,'IsOutputArgument','MATLAB array');
set(p,'Visible','off')
set(p,'FactoryValue',false);
p = schema.prop(cls,'String','MATLAB array');
set(p,'Visible','off');





