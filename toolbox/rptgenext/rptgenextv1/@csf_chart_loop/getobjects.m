function [resultIds, badList]=getobjects(c, varargin)
%GETOBJECTS returns a list of objects to include in report
%   OBJLIST=GETOBJECTS(C)

%   Copyright 1997-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2004/04/15 00:18:03 $

% Call csl_blk_loop.getobjects to get the list of objects
if strcmp( c.att.LoopType, '$list' )
   q = unpoint(csl_blk_loop);
   q.att.LoopType = c.att.LoopType;
   q.att.isFilterList = c.att.isSLFilterList;
   q.att.isSortList = c.att.isSortList;
   q.att.SortBy = c.att.SortBy;
   q.att.ObjectList = c.att.ObjectList;
   q.att.FilterTerms = {'MaskType', 'Stateflow', c.att.FilterTerms{2}{:} };
   
   [oList, badList] = getobjects( q );
elseif strcmp( c.att.LoopType, '$auto' )
   if c.att.isSLFilterList,
      filterTerms = {'MaskType', 'Stateflow', c.att.FilterTerms{2}{:}};
   else
      filterTerms = {'MaskType', 'Stateflow'};
   end
   
   [oList, badList]=loopblock(c,...
      c.att.SortBy,...
      getparentloop(c),...
      filterTerms);
else
   error( sprintf('Unknown Loop type: %s', c.att.LoopType ) );
end

resultIds = get_chart_ids(c, oList );

if isfield( c.att, 'ObjectType' )
   % we are constructing list for the summary table
   sfParent = rgsf( 'get_sf_parent', c );
   if ~isempty(sfParent) & strcmp( sfParent.comp.Class, 'csf_chart_loop' )
      % do only the children of the current chart.
      rptgenSF = zsfmethods;
      resultIds = rptgenSF.chartLoop.id;
   end
   allIds = rgsf( 'generate_all_ids', resultIds' );
   if ~isempty( allIds )
      allIds = allIds( :, 1 );
   end
   
   objType=lower(c.att.ObjectType);
   if any(strcmp({'function','box','state','note'},objType))
       stateType=objType;
       objType='state';
   else
       stateType='';
   end
   
   resultIds = sf( 'get', allIds, [lower( objType) '.id'] );
   resultIds = resultIds';

   switch stateType
   case 'function'
       type = sf( 'get', resultIds, '.type' );
       idx=find(type==c.zsfmethods.stateTypes.sfFunctionStateType);
       resultIds=resultIds(idx);
   case 'box'
       type = sf( 'get', resultIds, '.type' );
       nb   = sf( 'get', resultIds, '.isNoteBox');
       idx=find(type==c.zsfmethods.stateTypes.sfGroupStateType & ...
          nb == 0);
       resultIds=resultIds(idx);
   case 'state'
       type = sf( 'get', resultIds, '.type' );
       idx=find(type~=c.zsfmethods.stateTypes.sfGroupStateType & ...
           type~=c.zsfmethods.stateTypes.sfFunctionStateType);
       resultIds=resultIds(idx);
   case 'note'
       type = sf( 'get', resultIds, '.type' );
       nb   = sf( 'get', resultIds, '.isNoteBox');
       idx=find(type==c.zsfmethods.stateTypes.sfGroupStateType & ...
          nb == 1);
       resultIds=resultIds(idx);
   end
end


% if necessary, SF filter the list:
if c.att.isSFFilterList
	resultIds = filter_charts( c, resultIds );
end



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function chartIds = get_chart_ids(c, objList)
idList = [];
for i = 1:length( objList )
   name = objList{i};
   if isempty( name ),
      continue;
   end
   id = [];
   try
      id = find_system(name, 'findall', 'off', 'MaskType', 'Stateflow');
   catch
      % post a warning and attempt to load the system
      status(c,sprintf('Block %s is not loaded, attempting to load...' ,name),2);
      try
         slashPos = find( name == '/' );
         machName = name( 1:slashPos-1 );
         load_system( machName );
         id = find_system(name, 'findall', 'off', 'MaskType', 'Stateflow');
      catch
         % post error msg and continue with the loop
         status(c,sprintf('Could not load %s', name ),1);
         continue;
      end
   end
   if isempty(id)
      % post error msg and continue with the loop
      status(c,sprintf('Could not find chart: %s', name ),1);
      continue;
   end
   idList = [idList; id ];
end
[sortedIdList, i1, i2] = unique( idList );
idList = idList(sort(i1));
% generate the list of sf charts corresponding to the list of SL ids
chartIds = get_chart_ids_from_block_names(c, idList );



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function chartIds = get_chart_ids_from_block_names(c, objList )
rptgenSF = c.zsfmethods;
%loadedLibraries = {};

allInstanceID = propblock(c,'GetPropValue',objList,'UserData');
%instanceId = cat( 1, instanceId{:} );

instanceID=[];
for i = 1:length( objList )
   if iscell( objList )
      curObj = objList{i};
   else
      curObj = objList(i);
   end
   
	%thisInstanceId = propblock(c,'GetPropValue',curObj,'UserData');
	% if this block is a link then find it's instance id the jay's way.
	if ~isempty(get_param(curObj, 'ReferenceBlock'))
		% it is a stateflow link
		open_system( curObj );
		ref = get_param(curObj, 'ReferenceBlock');
		%loadedLibraries = {loadedLibraries{:}, bdroot( ref ) }; % may have duplicates. take care later
		refH = get_param(ref, 'handle');
      thisInstanceID = sf('find','all','instance.simulinkBlock',refH);
   else
      thisInstanceID = allInstanceID{i};
	end
	instanceID = [instanceID; thisInstanceID];
end

chartIds=sf('get',instanceID,'.chart');
% uniqueify the vector of chart ids
[sortedchartIds, i1, i2] = unique( chartIds );
chartIds = chartIds( sort( i1 ) );


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function chartIds = filter_charts( c, chartIds ) 
rptgenSF = c.zsfmethods;
terms = c.att.FilterTerms{1};
if ~isempty( terms{1} )
   if ~isempty( str2num (terms{2})), terms{2} = str2num(terms{2}); end
   try
      chartIds = sf('regexp',chartIds, ['.' terms{1}], terms{2} );
   catch
      status(c, 'error evaluating Stateflow property name/value search' ,1);
   end
end
