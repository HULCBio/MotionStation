function out=tableref(c,action,varargin)
%TABLEREF required information for property table

%   Copyright 1997-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2004/04/15 00:18:28 $

%GetPropList

%GetFilterList

%GetFormatList

%GetPropCell

%GetPresetList

%GetPresetTable

switch action
case {'GetPropList' 'GetFilterList' 'GetPropCell' 'GetPresetList' 'GetPresetTable'}
   out=feval(action,c,varargin{:});
otherwise
   out=feval(action,varargin{:});
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function errorMsg=CheckContinue
%
% function added for Karl (at least at this point).  The purpose
% of the function is to let the executing thread know if continuing
% execution of the table makes sense. In this case, simply return
% a non-empty error message
%
errorMsg = '';



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function  propList=GetPropList(c,filter)
propList = rgsf( 'get_property_list', filter );

%propList=slsysprops(c,'all');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function  filterList=GetFilterList(c)
parent = rgsf('get_sf_parent', c);
typeStr = '';
if ~isempty(parent) & strcmp( parent.comp.Class, 'csf_obj_report' )
	typeStr = parent.att.typeString;
end


list=rgsf( 'get_filter_list')';
% now eliminate entries that have no properties from the list
toRemove = [];
for i = 1:length(list)
	if isempty( GetPropList( c, list( i ) ) )
		toRemove = [toRemove i];
	end
end
list( toRemove ) = [];

index = 0;
for i = 1:length( list )
	if strcmp( list{i}, typeStr )
		index = i;
		break
	end
end
if index == 0;
	list{ length( list ) +1 } = '?'; index = length( list );
end
filterList.list = list;
filterList.index = index;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function   cellTxt=GetPropCell(c,propname)
rptgenSF = zsfmethods;
cellTxt = rgsf( 'get_property_cell', rptgenSF.currentObject, propname, c, 1);


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function list=GetPresetList(c)

%list={'Blank 4x4'
%   'Report on SF Machine'
%   'Report on SF State'
%   'RTW Information'
%   'Mask Properties'};
rptgenSF = zsfmethods;
parent = rgsf('get_sf_parent', c);
list = {};
% parent must be csf_obj_report
if ~isempty(parent) & strcmp( parent.comp.Class, 'csf_obj_report' ) ...
		& ~isempty(parent.att.typeString)
	typeNum = rgsf('type2num', parent.att.typeString );
	table = rptgenSF.propTable( typeNum + 1 );
	for i=1:length(table.preset)
		list{length(list)+1} = table.preset(i).description;
	end
%else
%	list = {'This component must be parented by csf_obj_report'};
%	list = {};
end

list{end+1}='Default';

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function out=GetPresetTable(c, tablename)

if ~strcmp(tablename,'Default')
   
   rptgenSF = zsfmethods;
   parent = rgsf('get_sf_parent', c);
   
   % parent must be csf_obj_report
   out = [];;
   if ~isempty(parent) & strcmp( parent.comp.Class, 'csf_obj_report' )
      typeNum = rgsf('type2num', parent.att.typeString );
      table = rptgenSF.propTable( typeNum + 1 );
      for i=1:length(table.preset)
         if strcmp( table.preset(i).description, tablename )
            break;
         end
      end
   else
      return;
   end
   table = table.preset(i);

else
   table.names={'%<Name>';'%<Description>'};
   table.description='Default';
   table.title='Stateflow Property Table';
   table.colWid=[.2 .8];
   table.render='P v';
   table.align='c';
   table.border=3;
   table.SingleValueMode=logical(1);
end

   
content = struct( ...
	'text', table.names, ...
	'align', table.align, ...
	'render', table.render, ...
	'border', table.border ...
	);
out = struct( ...
	'TableTitle', table.title, ...
	'ColWidths', table.colWid, ...
	'TableContent', content, ...
	'isBorder', table.border, ...
	'SingleValueMode', table.SingleValueMode ...
	);



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function out=LocMakeTable(propNames,title,widths)

content=struct('align','l',...
   'text',propNames,...
   'render',1);

out=struct('TableTitle',title,...
   'ColWidths',widths,...
   'TableContent',content);