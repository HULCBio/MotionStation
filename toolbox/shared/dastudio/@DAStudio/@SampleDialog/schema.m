function schema

% Copyright 2004 The MathWorks, Inc.

  hDeriveFromPackage = findpackage('DAStudio');
  hDeriveFromClass   = findclass(hDeriveFromPackage, 'Object');
  hCreateInPackage   = findpackage('DAStudio');
  
  hThisClass = schema.class(hCreateInPackage, 'SampleDialog', hDeriveFromClass);
  
  m = schema.method(hThisClass, 'getDialogSchema');
  s = m.Signature;
  s.varargin    = 'off';
  s.InputTypes  = {'handle', 'string'};
  s.OutputTypes = {'mxArray'};
  
  schema.EnumType('TestLevels', {'lvlOne', 'lvlTwo', 'lvlThree'});
  schema.EnumType('MyEnum', {'Red', 'Green', 'Blue', 'Black', 'White', 'Gray'}, [1 2 4 8 16 32]);
  
  p = schema.prop(hThisClass, 'radioProp1', 'TestLevels');
  p = schema.prop(hThisClass, 'radioProp2', 'MyEnum');
  p = schema.prop(hThisClass, 'checkProp', 'bool');
  p = schema.prop(hThisClass, 'stringProp', 'string');
  p = schema.prop(hThisClass, 'intProp', 'int32');
  p = schema.prop(hThisClass, 'doubleProp', 'double');

  % Define public methods
  m = schema.method(hThisClass,'sampleMethod');
  m.signature.varargin = 'off';
  m.signature.inputTypes={'handle', 'int', 'string', 'bool'};