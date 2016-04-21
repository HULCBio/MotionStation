function schema
% SCHEMA  
% Creates ArrayEditor class 
%  Copyright 1990-2004 The MathWorks, Inc.
  

  pkg = findpackage('DAStudio');
  cls = schema.class ( pkg, 'ArrayEditor');
  pkg.JavaPackage  = 'com.mathworks.toolbox.dastudio.arrayEditor';
  cls.JavaInterfaces = {'com.mathworks.toolbox.dastudio.arrayEditor.DAArrayEditorInterface'}; 
 
  %Basic properties
  Title = schema.prop (cls, 'Title', 'string');
  nameP = schema.prop ( cls, 'Name', 'string' );
  %Model Associated with this Diagnostic Viewer
  hVisListener = schema.prop(cls,'modelH','NReals');
  hVisListener.AccessFlags.PublicSet = 'on';
  hVisListener.AccessFlags.PrivateSet = 'on';
  nags = schema.prop(cls,'Messages','handle vector');
  %Java Window associated with this object
  window = schema.prop(cls,'jArrayEditorWindow','handle');
  %MxArray associated with this object
  value =  schema.prop(cls,'value','MATLAB array');
  %User Interaction properties make them private
  hVisListener = schema.prop(cls,'hVisListener','handle');
  hVisListener.AccessFlags.PublicSet = 'off';
  hVisListener.AccessFlags.PrivateSet = 'on';
  %Visible property is used by close button
  visible = schema.prop(cls,'Visible','bool');
  % java allocated will determine whether there is a java window associated with Array Editor
  javaAllocated = schema.prop(cls,'javaAllocated','bool');
  % java engaged is meant to be turned off for 
  % situations where you do not want to 
  % show or can not (due to platform reasons) show the window
  javaEngaged =  schema.prop(cls,'javaEngaged','bool');

  % Define public methods
  m = schema.method(cls,'saveTableValues');
  m.signature.varargin = 'off';
  m.signature.inputTypes={'handle', 'java.lang.Object'};

  






