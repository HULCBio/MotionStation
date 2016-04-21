function schema
% Creates the DiagnosticMsg class 
% Copyright 1990-2004 The MathWorks, Inc.
  
%   $Revision: 1.1.6.2 $  $Date: 2004/04/15 00:30:22 $
  
  
  pkg              = findpackage('DAStudio');
  c                = schema.class ( pkg, 'DiagnosticMsg');
  pkg.JavaPackage  = 'com.mathworks.toolbox.dastudio.diagView';
  c.JavaInterfaces = {'com.mathworks.toolbox.dastudio.diagView.DiagnosticMsgInterface'};  
		      

% Define public properties
  schema.prop(c,'Type','string');
  schema.prop(c,'Contents','handle');
  schema.prop(c,'SourceFullName','string');
  schema.prop(c,'SourceName','string');
  schema.prop(c,'Component','string');
  schema.prop(c,'AssocObjectHandles','NReals');
  schema.prop(c,'AssocObjectNames','string vector');
  schema.prop(c,'SourceObject','NReals');
  schema.prop(c,'OpenFcn','string');
   % this property is meant to find the directory for a hyperlink
  schema.prop(c,'HyperRefDir','string');
% Create DiagnosticMsg.Contents class
  cContents         = schema.class ( pkg, 'DiagnosticMsgContents');
  cContents.JavaInterfaces = {'com.mathworks.toolbox.dastudio.diagView.DiagnosticMsgContentsInterface'};
% Define public properties for DiagnosticMsgContents class
  schema.prop(cContents,'Type','string');
  schema.prop(cContents,'Details','string');
  schema.prop(cContents,'Summary','string');
  schema.prop(cContents,'HyperSearched','bool');
 
  % Access and defaults

  % Define private properties

  % Events

  % Create class instance
