function charts = get_charts_of (slsfObjs, varargin)
%
% this fcn returns the vector of charts that have the passed
% argument as their (not necessarily immediate) parent
% slsfObjs may be a name or a handle of a stateflow chart, 
% simulink system, model or block, or a any combination of the above
%

%   Vladimir Kolesnikov
%   Copyright 1995-2003 The MathWorks, Inc.
%   $Revision: 1.7.2.2 $  $Date: 2004/04/15 00:57:58 $

charts = [];
dispErrors = 0;
if nargin >1
   dispErrors = varargin{1};
end
if ischar( slsfObjs ), slsfObjs = {slsfObjs}; end

for i = 1:length( slsfObjs )
   if iscell( slsfObjs )
      curObj = slsfObjs{i};
   else
      curObj = slsfObjs(i);
   end
   objType = ml_type( curObj );
   switch objType
   case 'sf_handle',
      ISA = sf('get', curObj, '.isa');
      CHART = sf('get','default','chart.isa');
      STATE = sf('get', 'default','state.isa');
      switch ISA,
      case {CHART, STATE}, charts = [charts, curObj];
      otherwise, dispErrors
         disp( ['Warning: Passed Stateflow object is not a chart: ', sf_scalar2str(curObj)] );
      end;
   case {'sl_handle', 'string'},
      try
         slType = get_param( curObj, 'Type' );
      catch
         % unknown sl name
         if dispErrors
            disp( ['Warning: unknown Simulink object: ', sf_scalar2str(curObj)] );
         end
         slType = '';
      end
      
      switch slType,
      case 'block_diagram',
         % name passed is a model (machine) name
         modelH = get_param( curObj, 'Handle' );
         machineId = sf( 'find','all','machine.simulinkModel', modelH );
         instances = get_instances_in_machine( machineId );
         linkCharts = sf('get',instances,'.chart' );
         localCharts = sf('get', machineId, '.charts' );
         charts = [charts, localCharts, linkCharts];
      case 'block'
         try
            sfBlks = find_system( curObj, 'FollowLinks','on', ...
                  'LookUnderMasks', 'all', 'MaskType','Stateflow' );
            sfBlks = get_param( sfBlks, 'handle' );
            if iscell( sfBlks )
               sfBlks = [sfBlks{:} ];
               sfBlks = sfBlks(:);
            end
            localBlks = find_system( sfBlks, 'SearchDepth', 0, 'LinkStatus', 'none' );
            linkBlks = find_system( sfBlks, 'SearchDepth', 0, 'LinkStatus', 'resolved' );
            linkBlks = [linkBlks find_system( sfBlks, 'SearchDepth', 0, 'LinkStatus', 'implicit' )];
            localInstances = get_param( localBlks, 'UserData' );
            localCharts = sf( 'get', localInstances, '.chart' );
            if ~isempty( linkBlks )
               links = get_instances_in_machine([], linkBlks(:)' );
            else 
               links = [];
            end
            linkCharts = sf('get',links,'.chart' );
            charts = [charts, localCharts, linkCharts];
         catch
            if dispErrors
               disp( ['Warning: unable to process Simulink object: ', sf_scalar2str(curObj)] );
            end
         end
      case '',
         % do nothing, this happened because catch clause was executed
         % continue to the next iteration of the loop
      end
   otherwise
      if dispErrors
         disp( ['Warning: not a Stateflow or Simulink object: ', sf_scalar2str(curObj)] );
      end
   end
end

[temp index] = unique( charts );
charts = charts( index );
      
      