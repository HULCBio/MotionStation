function c=csf_summ_table(varargin)
%Summary Table
%   This component inserts a table which lists several
%   Stateflow objects and their properties.
%

%   Copyright 1997-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2004/04/15 00:18:37 $

z=zslmethods;
zsf = zsfmethods;
r=rpt_summ_table;

%filters = propsf(zsf,'GetFilterList', 'get_all');
%we have to hardcode the list of object types in order to
%prevent stateflow from loading when instantiating the object

filters={
    'Machine'       'Machine properties' 
    'Chart'         'Chart properties'   
    'Target'        'Target properties'  
    'State'         'State properties'   
    'Transition'    'Transition properties'
    'Junction'      'Junction properties'
    'Event'         'Event properties'   
    'Data'          'Data properties'    
    'Box'           'Box properties'
    'Function'      'Function properties'
    'Note'          'Note properties'
};     

%    'Subchart'      'Subchart properties'

for i = 1:size(filters,1)
   r=set_table(r,...
   filters{ i, 1 },...
   {'csf_chart_loop','ObjectType',filters{i,1}},...
   'propsf',...
   {'Name'},...
   '',...
   []);
end


c=rptgenutil('EmptyComponentStructure','csf_summ_table');
c=class(c,c.comp.Class,rptcomponent,zsf,z,r);
c=buildcomponent(c,varargin{:});

if ~isempty(varargin)
   c=refresh_loop_comps(c.rpt_summ_table,c);
end
