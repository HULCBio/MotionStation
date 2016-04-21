function c=csf_hier_loop(varargin)
% Stateflow Loop
%
%    This component creates the list of Stateflow objects to
%    be reported according to its parent which must be a Stateflow
%    Chart Loop or Simulink Model, System, Signal or Block loop 
%    component.
%
%    Thus, if it is parented by a block loop, only objects in the
%    corresponding Stateflow chart will be reported. Similarly,
%    if it is parented by a model/system loop, all of the charts 
%    in the model/system will be included in the report. If it is 
%    parented by Stateflow Chart Loop, it will report on charts
%    determined by the Chart Loop.
%
%    Attribute page parameter:
%        minimal readable/legible font size to be used in generated images
%    
%    This page also displays the list of Stateflow object types 
%    that are reported in the loop.

%   Copyright 1997-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2004/04/15 00:18:08 $

c=rptgenutil('EmptyComponentStructure','csf_hier_loop');
c=class(c,c.comp.Class,rptcomponent,zslmethods,zsfmethods);
c=buildcomponent(c,varargin{:});
