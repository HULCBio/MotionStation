function out=execute(c)
%EXECUTE returns a string during generation

%   Copyright 1997-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2004/04/15 00:18:09 $

out=sgmltag;
if ~rgsf( 'is_parent_valid', c )
		[validity, errMsg] = rgsf( 'is_parent_valid', c );
		compInfo = getinfo( c );
		status(c, sprintf('%s error: this component %s',compInfo.Name, errMsg) ,1);
	return;
end

% ok, we have a valid parent.
% it is either a sl blk, system, or model, or stateflow chart loop

rptgenSF = c.zsfmethods;

%generate the vector of object ids to be reported

if ~isempty( getparentloop( c, {'csf', ''} ))
   chartIds = rptgenSF.chartLoop.id;   
else  % we are working with a SL loop
   
   %objList is a vector of system handles which
   %represent Stateflow blocks
   
   objList=searchblocktype(c.zslmethods,...
      {'MaskType','Stateflow'},...
      getparentloop(c));
   
   if isempty(objList)
      out='';
      return
   end
   
   
   %objList=propblock(c,'GetPropValue',objList,'handle');
   instanceID=getparam(c,objList,'UserData');
   
   loadedLibraries = {};
   instanceID = [];
   for i = 1:length( objList )
      curObj = objList{i};
      thisInstanceId = propblock(c,'GetPropValue',curObj,'UserData');
      % if this block is a link then find it's instance id the jay's way.
      if ~isempty(get_param(curObj, 'ReferenceBlock'))
         % it is a stateflow link
         open_system( curObj );
         ref = get_param(curObj, 'ReferenceBlock');
         loadedLibraries = {loadedLibraries{:}, bdroot( ref ) }; % may have duplicates. take care later
         refH = get_param(ref, 'handle');
         thisInstanceId = sf('find','all','instance.simulinkBlock',refH);
      end
      if iscell( thisInstanceId )
         thisInstanceId = cat( 1, thisInstanceId{:} );
      end
      instanceID = [instanceID; thisInstanceId];
   end
   
   chartIds=sf('get',instanceID,'.chart');
end

% do all the charts for SL loops
rptgenSF.legibleSize = c.att.legibleFontSize;
hierRepList = rgsf( 'generate_all_ids', chartIds' );
rptgenSF.currentLoop.reportList = hierRepList(:,1);
if isempty( rptgenSF.currentLoop.reportList )
	compInfo = getinfo( c );
	status(c, sprintf('Warning (%s): report list is empty',compInfo.Name ) ,2);
	return;
end
% remove from the report list objects that are already on the full report list
% because they are already reported.
if ~isempty( rptgenSF.reportList)
	commonObjs = ismember( rptgenSF.currentLoop.reportList, rptgenSF.reportList );
	rptgenSF.currentLoop.reportList( commonObjs ) = [];
end

%We don't add to the .reportList here anymore - objects are added
%one at a time in the Object Report
%fullReportList = [rptgenSF.reportList; rptgenSF.currentLoop.reportList];
%rptgenSF.reportList = fullReportList;


currentLoopRepList = rptgenSF.currentLoop.reportList';
% traverse the rptgen comp hierarchy to set image sizes
comps = get_snapshot_comps(c);
for i = 1:length( comps )
   %parent = rgsf( 'get_sf_parent', comps(i) );
   [parentClass, parent] = getparentloop(c, {'csf',''} );
	if ~isempty(parent) & strcmp( parentClass, 'csf_obj_report' )
		typeNum = rgsf('type2num', parent.att.typeString );
		rptgenSF.propTable(typeNum+1).image.imageSize = comps(i).att.PrintSizePoints;
	end
end


% set the rptgenSF.currentLoop.drawInfo
if ~isempty( currentLoopRepList)
   rgsf( 'analyze_images', currentLoopRepList );
end

myChildren=children(c);

for i = 1:length( currentLoopRepList )
   if c.rptcomponent.HaltGenerate
      status(c,'Stateflow Loop execution halted',2);
      break
   end
   
   rptgenSF.currentObject.id = currentLoopRepList(i);
	rptgenSF.currentObject.type = ...
      rgsf( 'whoami', rptgenSF.currentObject.id );
   objTypeString =  ...
		rgsf( 'num2type', rptgenSF.currentObject.type );
   
   rptgenSF.currentObject.typeString = objTypeString;
   %Post a status message
   objName=rgsf('get_sf_obj_name',currentLoopRepList(i));
   objName=strrep(singlelinetext(c,objName,' '),sprintf('\n'),' ');
   status(c,sprintf('Looping on Stateflow %s %s', objTypeString , objName),3);
   
   out=[out;runcomponent(myChildren)];
end

%cleanup
rptgenSF.currentLoop.reportList = [];


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function comps = get_snapshot_comps(c)
comps = [];
myChildren = children(c);
for i = 1:length( myChildren )
	child = myChildren(i);
	if strcmp( child.comp.Class, 'csf_snapshot' )
		comps = [ comps; child ];
	end
	comps = [comps get_snapshot_comps(child) ];
end

