function fix_corrupted_subgroups(machineId)
%   Copyright 1995-2002 The MathWorks, Inc.
%   $Revision: 1.3.2.1 $  $Date: 2004/04/15 00:57:50 $

sf('flag','state.subgrouped','write/show/save');
charts = sf('get',machineId,'machine.charts');

for i=1:length(charts)
   states = sf('get',charts(i),'chart.states');
   states = sf('find',states,'state.superState','SUBCHART');  
   for j=1:length(states)
      state = states(j);
      objs = [sf('get',state,'state.firstTransition'),...
              sf('get',state,'state.firstJunction'),...
              sf('get',state,'state.treeNode.child')];
      if(sf('get',state,'state.subgrouped')==0 &...
         any(sf('get',objs,'.isGrouped')))
         sf('set',state,'state.subgrouped',1);
         disp(sprintf('Repaired grouped subchart state %s in chart %s',...
              sf('get',state,'state.name'),...
              sf('get',charts(i),'chart.name'))); 
      else
         sf('set',state,'state.subgrouped',0);
      end
   end
end
sf('flag','state.subgrouped','save/show');

