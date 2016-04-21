function c=csf_chart_loop(varargin)
% Stateflow Chart Loop
%
%    This component runs its subcomponents for each Stateflow chart in 
%    the list, which is constructed in one of the two ways:
%
%     1. automatic:  includes all charts under its parent, which must 
%        be a Simulink Model, System, Signal or Block loop component.
%        If none of the above components parents Chart Loop, report will
%        include all stateflow charts in memory.  Stateflow Chart Loop
%        cannot be parented by any Stateflow component.
%     2. manual: the list of charts is specified by the user.
%
%    It is possible to further refine the list by sorting and applying
%    restrictions in form of filters.
%
%    Note: Stateflow objects that were previously reported (perhaps in 
%    another loop) will not be reported for the second time.
%	  
%    See also CSF_HIER_LOOP, CSL_MDL_LOOP, CSL_SYS_LOOP, CSL_BLK_LOOP
%    


%   Copyright 1997-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2004/04/15 00:18:00 $

c=rptgenutil('EmptyComponentStructure','csf_chart_loop');
c=class(c,c.comp.Class,rptcomponent,zslmethods,zsfmethods);
c=buildcomponent(c,varargin{:});
