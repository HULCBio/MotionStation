function schema
% SCHEMA  
% Creates DiagnosticViewer class 
%  Copyright 1990-2004 The MathWorks, Inc.
  
%   $Revision: 1.1.6.2 $  $Date: 2004/04/15 00:30:44 $

  pkg = findpackage('DAStudio');
  cls = schema.class ( pkg, 'DiagnosticViewer');
  pkg.JavaPackage  = 'com.mathworks.toolbox.dastudio.diagView';
  cls.JavaInterfaces = {'com.mathworks.toolbox.dastudio.diagView.DiagnosticViewerInterface'}; 
 
  %Basic properties
  Title = schema.prop (cls, 'Title', 'string');
  nameP = schema.prop ( cls, 'Name', 'string' );
  %Model Associated with this Diagnostic Viewer
  hVisListener = schema.prop(cls,'modelH','NReals');
  hVisListener.AccessFlags.PublicSet = 'on';
  hVisListener.AccessFlags.PrivateSet = 'on';
  nags = schema.prop(cls,'Messages','handle vector');
  %Java Window associated with this object
  window = schema.prop(cls,'jDiagnosticViewerWindow','handle');
  %User Interaction properties make them private
  hVisListener = schema.prop(cls,'hVisListener','handle');
  hVisListener.AccessFlags.PublicSet = 'off';
  hVisListener.AccessFlags.PrivateSet = 'on';
  %Single Clicking Listener make it private
  hSingleClickListener =  schema.prop(cls,'hSingleClickListener','handle');
  hSingleClickListener.AccessFlags.PublicSet = 'off';
  hSingleClickListener.AccessFlags.PrivateSet = 'on';
  %Double Clicking Listener make it private
  hDoubleClickListener =  schema.prop(cls,'hDoubleClickListener','handle');
  hDoubleClickListener.AccessFlags.PublicSet = 'off';
  hDoubleClickListener.AccessFlags.PrivateSet = 'on';
  %Previously hilighted objects Make it private
  prevHilitObjs = schema.prop(cls,'prevHilitObjs','NReals');
  prevHilitObjs.AccessFlags.PublicSet = 'on';
  prevHilitObjs.AccessFlags.PrivateSet = 'off';
  %previously hilighted colors make it private
  prevHilitClrs = schema.prop(cls,'prevHilitClrs','string vector');
  prevHilitClrs.AccessFlags.PublicSet = 'on';
  prevHilitClrs.AccessFlags.PrivateSet = 'off';
  %Visible property is used by close button
  visible = schema.prop(cls,'Visible','bool');
  % This will determine whether we should do reverse sorting  
  reverseSort = schema.prop(cls,'ReverseSort','NReals');
  %This portion will show all the properties having to do with visibility of columns
  messageVisible  = schema.prop(cls,'messageVisible','bool');
  sourceVisible   = schema.prop(cls,'sourceVisible','bool'); 
  reportVisible   = schema.prop(cls,'reportVisible','bool');
  summaryVisible  = schema.prop(cls,'summaryVisible','bool');
  
  %This portion has to with all the listeners for visibility of columns
  %make them all private
  hMessageVisListener  =  schema.prop(cls,'hMessageVisListener','handle');
  hMessageVisListener.AccessFlags.PublicSet = 'off';
  hMessageVisListener.AccessFlags.PrivateSet = 'on';
  hSourceVisListener   =  schema.prop(cls,'hSourceVisListener','handle');
  hSourceVisListener.AccessFlags.PublicSet = 'off';
  hSourceVisListener.AccessFlags.PrivateSet = 'on';
  hReportedVisListener =  schema.prop(cls,'hReportedVisListener','handle');
  hReportedVisListener.AccessFlags.PublicSet = 'off';
  hReportedVisListener.AccessFlags.PrivateSet = 'on';
  hSummaryVisListener  =  schema.prop(cls,'hSummaryVisListener','handle');
  hSummaryVisListener.AccessFlags.PublicSet = 'off';
  hSummaryVisListener.AccessFlags.PrivateSet = 'on';
  %default font size
  defaultFontSize     =  schema.prop(cls,'defaultFontSize','int');
  
  % java allocated will determine whether there is a java window associated with DV
  javaAllocated = schema.prop(cls,'javaAllocated','bool');
  % java engaged is meant to be turned off for 
  % situations where you do not want to 
  % show or can not (due to platform reasons) show the window
  javaEngaged =  schema.prop(cls,'javaEngaged','bool');
  rowSelected = schema.prop(cls,'rowSelected','int');
  openRow = schema.prop(cls,'rowOpen','int');
  nameP.AccessFlags.PublicSet = 'on';

  % Define public methods
  m = schema.method(cls,'sortColumn');
  m.signature.varargin = 'off';
  m.signature.inputTypes={'handle','int'};
  
  m = schema.method(cls,'helpButton');
  m.signature.varargin = 'off';
  m.signature.inputTypes={'handle'};
  %
  m = schema.method(cls,'dehilitBlocks');
  m.signature.varargin = 'off';
  m.signature.inputTypes={'handle'};
  %
  m = schema.method(cls,'dehilitModelAncestors');
  m.signature.varargin = 'off';
  m.signature.inputTypes={'handle'};
  %
  m = schema.method(cls,'hypergate');
  m.signature.varargin = 'off';
  m.signature.inputTypes={'handle'};
  
  %m.signature.outputTypes={'handle vector'};
  %
  m = schema.method(cls,'isVisible');
  m.signature.varargin = 'off';
  m.signature.inputTypes={'handle'};
  m.signature.outputTypes={'bool'};





