function out=rgstoredata(z, in, action)
%RGSTOREDATA saves persistent data

%   Copyright 1997-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2004/04/15 00:22:23 $

persistent rptgenSF;

if nargin == 2 | (nargin==3 & strcmp( action, 'set' ))
  	rptgenSF=in;
	out=rptgenSF;
	return
end

if (nargin <2 | (nargin > 2 & ~strcmp( action, 'initialize' ))) ... & ~isempty( rptgenSF )
	out=rptgenSF;
	return;
end
mlock;

%INITIALIZE

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% fields of the structure:
% 
% typeTable:			mapping of object type names to numbers
% reportableObjectsIndex: array of types that are reportable.
% pointedTo:			an array of bool that mean that that type of object may be pointed
% 							to on an image
% canHaveChildren:   an array of bool that mean that that type of object may have 
% 							children
% stateTypes:			state decompositions
% reportList:			the list of all sf objects decided to be reported so far
%								(updated by sf_chart_loop and sf_obj_report)
% linkTargetCreated: list of objects that had their linktargets created.
% objAbbr:				object tags intial chars, meaning the type
% objCount:				number of tagged objects of each type
% legibleSize:			minimal font size considered legible for the user
% currentObject:		structure describing the status of the current obj reported.
% 		id:				id of the object being reported
%		type:				the type of the object reported
%		typeString:		the name of the object type (ex. 'chart')
%		hiddenContent:	determines if this object has information which has
%								not been previously revealed (and thus should be reported)
% chartLoop:			structure containing information about the current chart loop
%		id:				the id of the current chart
%		charts:			the vector of charts in the current chart loop
% currentLoop:			structure containing information about the current hier_loop
%		reportList:		the list of sf objects to be reported (set by sf_hier_loop)
%		hierDepth:		the depth of the hierarchy of the current loop
%		drawInfo:		contains info on drawing sf objects
%							all fields except context are initialized during the execution of
%							sf_hier_loop component (call to rgsf('analyze_images') )
%			data:			cellarray = {[ id, children_ids], scale factor (sf -> image),
%								veiwRectangle, pointRectangle, parent, newFontSize, 
%								fontSize, maxScale }
%			map:			sparse matrix that provides mapping between an object id and
%								entry in data, legibleIn, and other fields of the drawInfo
%			legibleIn:	gives the id of the object highest in the hierarchy, which
%								picture displays this object readably
%			numLegibleKids:  number of children that this object makes legible on its picture
%			legibleKids: the list of children that this object makes legible on its picture
%			context:		id of an object that is reported and has a picture where this object
%								is legible (difference from legibleIn: context must be reported)
%
% temp					temp structure will contain temporary, non-persistent info
% propTable:			array of structures that contains the information on all the 
%							possible properties of objects
%		prop:				array of structures that contain info on every property
%			propName:	name of the property
%			printName:	name of the property as it appears in report
%			isLink:		boolean defining whether this property value is a link(s)
%			evalString:	m-code expression to be evaluated to get the value
%			valueRule:	m-code expression to be evaluated to update the value
%			printRule:	m-code expression to be evaluated to print the value
%			ignoreRule:	m-code expression to determine if this property should be reported
%			important:	boolean value that defines whether this property is important
%								for the user (ex. to determine whether to report an object)
%			wildChar:	the char that gets substituted by the value of the property
%								in ...Rule's (valueRule, etc.)
%
%		image
%			imagePresent: boolean variable defining if the image is present for that type of object
%			imageSize:	a 1x2 vector [w h] of the image
%			dynamicSize: a boolean defining if smarts are applied to determine the best pic size
%
%		preset			array of structures that contain preset tables info
%			names:		cell array of cell contents
%			description:what the user sees in the puul-down menu
%			title:		table title
%			colWid:		relative column widths
%			render:		the render value (ex. 1:'value', 2:'property:value', 
%									3:'PROPERTY:value')
%			align:		{'l','c',r'}
%			border:   	defines the table's border.
%			SingleValueMode: 1 if the table is a split prop/value table, 0 otherwise
%
% dataScopeTable:		the mapping table between the data scope numeric and string value
% eventScopeTable:	the mapping table between the event scope numeric and string value
% eventTriggerTable:	the mapping table between the event trigger numeric and string value
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% sf types:
types = {
    'chart'
    'data'
    'event'
    'instance'
    'junction'
    'linkchart'
    'machine'
    'note'
    'portal'
    'state'
    'target'
    'transition'
%    'undo'
    'wormhole'
};

for i = 1:length(types)
	curType = sf( 'get', 'default', [ types{i} '.isa' ]);
	typeTable{curType+1} = types{i};
end
% and our special case:
typeTable{end+1} = 'function';
typeTable{end+1} = 'box';
typeTable{end+1} = 'note';
typeTable{end+1} = 'index';
%typeTable{end+1} = 'subchart';
typeTable{end+1} = '?';
rptgenSF.typeTable = typeTable; 

reportableTypes = {
    'machine'
    'chart' %'subchart'
    'target'
    'state'
    'transition'
    'junction'
    'event'
    'data'
    'box'
    'function'
    'note'
};
reportableIndex = [];
for i = 1:length( reportableTypes )
	reportableIndex = [ reportableIndex, rgsf( 'type2num', reportableTypes{i} ) ];
end
rptgenSF.reportableObjectsIndex = reportableIndex;

taggedTypes = {'machine', 'chart', 'target', 'state', 'transition', ...
				'junction', 'event', 'data', ...
         };
     %don't need function, note, box, or subchart here because they are  subclasses of state
      
canHaveChildrenTypes = { 'state','box','function'}; %,'subchart'};
canHaveChildrenIndex = zeros(1, length( typeTable ) );
for i = 1:length( canHaveChildrenTypes )
	canHaveChildrenIndex ( rgsf( 'type2num', canHaveChildrenTypes{i} ) + 1 ) = 1;
end
rptgenSF.canHaveChildren = canHaveChildrenIndex;

pointedToList = {'state','transition','box','function','note'};
rptgenSF.pointedTo( length(typeTable) + 1) = 0;
for i = 1:length( pointedToList )
	rptgenSF.pointedTo( rgsf('type2num', pointedToList{i} ) + 1 ) = 1;
end


[tt,vv] = sf('subproperty', 'state.type' );
rptgenSF.stateTypes.sfORStateStateType = find( strcmp( 'OR_STATE', vv{:} ) ) -1;
rptgenSF.stateTypes.sfANDStateStateType = find( strcmp( 'AND_STATE', vv{:} ) ) -1;
rptgenSF.stateTypes.sfFunctionStateType = find( strcmp( 'FUNC_STATE', vv{:} ) ) -1;
rptgenSF.stateTypes.sfGroupStateType = find( strcmp( 'GROUP_STATE', vv{:} ) ) -1;
clear tt, vv;

objAbbr.machine = 'M';
objAbbr.chart = 'C';
%objAbbr.subchart='Subchart-';
objAbbr.target = 'Trgt-';
objAbbr.instance = 'I';
objAbbr.state = 'S';
objAbbr.transition = 'T';
objAbbr.junction = 'J';
objAbbr.event = 'E';
objAbbr.data = 'D';
objAbbr.function = 'F';
objAbbr.box = 'B';
objAbbr.note = 'N';
% objAbbr and objCount are the only two names that have an update
% for SF 'frame' -> 'box' renaming because they are used in eval.
rptgenSF.objAbbr = objAbbr;

objCount.machine = 0;
objCount.chart = 0;
%objCount.subchart=0;
objCount.target = 0;
objCount.instance = 0;
objCount.state = 0;
objCount.transition = 0;
objCount.junction = 0;
objCount.event = 0;
objCount.data = 0;
objCount.function = 0;
objCount.box = 0;
objCount.note=0;

% objAbbr and objCount are the only two names that have an update
% for SF 'frame' -> 'box' renaming because they are used in eval.

rptgenSF.objCount = objCount;

rptgenSF.legibleSize = 8;
rptgenSF.reportList = [];

chartLoop.id = [];
chartLoop.charts = [];
rptgenSF.chartLoop = chartLoop;

currentObject.id = 0;
currentObject.type = -1;
currentObject.typeString = '';
currentObject.hiddenContent = 0;
rptgenSF.currentObject = currentObject;
rptgenSF.linkTargetCreated = [];

currentLoop.reportList = [];
currentLoop.hierDepth = 0;
rptgenSF.currentLoop = currentLoop;

rptgenSF.temp = [];

wc = '$';
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% set reportable properties for the machine
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
i = 0;

i = i + 1;
p(i).propName = 'Name';
p(i).printName = 'Machine';
p(i).isLink = 0;
p(i).evalString = 'machine.id';
p(i).valueRule = '';
p(i).printRule = ['sf(''get'',' wc ',''.name'')' ];
p(i).ignoreRule = '';
p(i).important = 1;
p(i).wildChar = wc;

i = i + 1;
p(i).propName = 'FullPath+Name';
p(i).printName = 'Machine';
p(i).isLink = 0;
p(i).evalString = 'machine.id';
p(i).valueRule = '';
p(i).printRule = ['sf(''FullNameOf'',' wc ',''/'')' ];
p(i).ignoreRule = '';
p(i).important = 1;
p(i).wildChar = wc;

i = i + 1;
p(i).propName = 'SFPath+Name';
p(i).printName = 'Machine';
p(i).isLink = 0;
p(i).evalString = 'machine.id';
p(i).valueRule = '';
p(i).printRule = ['rgsf(''get_sf_full_name'',' wc ',''/'', '''')' ];
p(i).ignoreRule = '';
p(i).important = 1;
p(i).wildChar = wc;

i = i + 1;
p(i).propName = 'Charts';
p(i).printName = 'Charts';
p(i).isLink = 1;
p(i).evalString = 'machine.charts';
p(i).valueRule = '';
p(i).printRule = ['sf(''get'',' wc ',''.name'')' ];
p(i).ignoreRule = '';
p(i).important = 1;
p(i).wildChar = wc;

i = i + 1;
p(i).propName = 'Linkcharts';
p(i).printName = 'Linkcharts';
p(i).isLink = 1;
p(i).evalString = 'machine.sfLinks';
p(i).valueRule = ' (get_param( q, ''Referenceblock'' ))'' ';
p(i).printRule = ['sf(''get'',' wc ',''.name'')' ];
p(i).ignoreRule = '';
p(i).important = 1;
p(i).wildChar = wc;

i = i + 1;
p(i).propName = 'Description';
p(i).printName = 'Description';
p(i).isLink = 0;
p(i).evalString = 'machine.description';
p(i).valueRule = '';
p(i).printRule = '';
p(i).ignoreRule = '';
p(i).important = 1;
p(i).wildChar = wc;


i = i + 1;
p(i).propName = 'Document';
p(i).printName = 'Document';
p(i).isLink = 0;
p(i).evalString = 'machine.id';
p(i).valueRule = '';
p(i).printRule = ['sf(''get'',' wc ',''.document'')' ];
p(i).ignoreRule = '';
p(i).important = 1;
p(i).wildChar = wc;


i = i + 1;
p(i).propName = 'Creation Date';
p(i).printName = 'Created';
p(i).isLink = 0;
p(i).evalString = 'machine.created';
p(i).valueRule = '';
p(i).printRule = '';
p(i).ignoreRule = '';
p(i).important = 1;
p(i).wildChar = wc;

i = i + 1;
p(i).propName = 'Created By';
p(i).printName = 'Created By';
p(i).isLink = 0;
p(i).evalString = 'machine.creator';
p(i).valueRule = '';
p(i).printRule = '';
p(i).ignoreRule = '';
p(i).important = 1;
p(i).wildChar = wc;

i = i + 1;
p(i).propName = 'Version';
p(i).printName = 'Version';
p(i).isLink = 0;
p(i).evalString = 'machine.version';
p(i).valueRule = '';
p(i).printRule = '';
p(i).ignoreRule = '';
p(i).important = 1;
p(i).wildChar = wc;

i = i + 1;
p(i).propName = 'Data';
p(i).printName = 'Data';
p(i).isLink = 1;
p(i).evalString = 'machine.id';
p(i).valueRule = ['sf(''DataOf'', ' wc ')'];
p(i).printRule = ['sf(''get'', ' wc ', ''.name'')'];
p(i).ignoreRule = '';
p(i).important = 1;
p(i).wildChar = wc;

i = i + 1;
p(i).propName = 'Events';
p(i).printName = 'Events';
p(i).isLink = 1;
p(i).evalString = 'machine.id';
p(i).valueRule = ['sf(''EventsOf'', ' wc ')'];
p(i).printRule = ['sf(''get'', ' wc ', ''.name'')'];
p(i).ignoreRule = '';
p(i).important = 1;
p(i).wildChar = wc;

i = i + 1;
p(i).propName = 'SF ID';
p(i).printName = 'Id';
p(i).isLink = 0;
p(i).evalString = 'machine.id';
p(i).valueRule = '';
p(i).printRule = ['num2str(' wc ')'];
p(i).ignoreRule = '';
p(i).important = 0;
p(i).wildChar = wc;

i = i + 1;
p(i).propName = 'Modified';
p(i).printName = 'Modified';
p(i).isLink = 0;
p(i).evalString = 'machine.id';
p(i).valueRule = '';
p(i).printRule = ['sf(''get'', ' wc ', ''.modified'')'];
p(i).ignoreRule = '';
p(i).important = 0;
p(i).wildChar = wc;

i = i + 1;
p(i).propName = 'Full File Name';
p(i).printName = 'Full File Name';
p(i).isLink = 0;
p(i).evalString = 'machine.id';
p(i).valueRule = '';
p(i).printRule = ['sf(''get'', ' wc ', ''.fullFileName'')'];
p(i).ignoreRule = '';
p(i).important = 0;
p(i).wildChar = wc;

% define the image for this type of object
image.imagePresent = 0;
image.imageSize = [0 0];
image.dynamicSize = 1;

% define preset tables here
i = 0;
i = i + 1;
preset(i).names = {
		'%<Name>' ...
};
preset(i).description = 'Machine Header';
preset(i).title = '';
preset(i).colWid = [1];
preset(i).render = 'P v';
preset(i).align = 'j';
preset(i).border = logical(1);
preset(i).SingleValueMode = logical(1);


i = i + 1;
preset(i).names = {
      '%<Charts>';
      '%<Description>';
		'%<Document>';
      '%<Creation Date>';
      '%<Created By>';
      '%<Version>';
      '%<Data>';
      '%<Events>' ...
};
preset(i).description = 'Machine Body';
preset(i).title = '';
preset(i).colWid = [1];
preset(i).render = 'P v';
preset(i).align = 'l';
preset(i).border = logical(0);
preset(i).SingleValueMode = logical(1);


rptgenSF.propTable( rgsf( 'type2num', 'machine' ) + 1 ).prop = p;
clear p;
rptgenSF.propTable( rgsf( 'type2num', 'machine' ) + 1 ).image = image;
clear image;
rptgenSF.propTable( rgsf( 'type2num', 'machine' ) + 1 ).preset = preset;
clear preset;



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% set reportable properties for the chart
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
i = 0;

i = i + 1;
p(i).propName = 'Name';
p(i).printName = 'Chart';
p(i).isLink = 0;
p(i).evalString = 'chart.id';
p(i).valueRule = '';
p(i).printRule = ['sf(''get'',' wc ',''.name'')' ];
p(i).ignoreRule = '';
p(i).important = 1;
p(i).wildChar = wc;

i = i + 1;
p(i).propName = 'FullPath+Name';
p(i).printName = 'Chart';
p(i).isLink = 0;
p(i).evalString = 'chart.id';
p(i).valueRule = '';
p(i).printRule = ['sf(''FullNameOf'',' wc ',''/'')' ];
p(i).ignoreRule = '';
p(i).important = 1;
p(i).wildChar = wc;

i = i + 1;
p(i).propName = 'SFPath+Name';
p(i).printName = 'Chart';
p(i).isLink = 0;
p(i).evalString = 'chart.id';
p(i).valueRule = '';
p(i).printRule = ['rgsf(''get_sf_full_name'',' wc ',''/'', '''')' ];
p(i).ignoreRule = '';
p(i).important = 1;
p(i).wildChar = wc;

i = i + 1;
p(i).propName = 'Machine';
p(i).printName = 'Machine';
p(i).isLink = 1;
p(i).evalString = 'chart.machine';
p(i).valueRule = '';
p(i).printRule = ['sf(''get'',' wc ',''.name'')' ];
p(i).ignoreRule = '';
p(i).important = 0;
p(i).wildChar = wc;

i = i + 1;
p(i).propName = 'Description';
p(i).printName = 'Description';
p(i).isLink = 0;
p(i).evalString = 'chart.description';
p(i).valueRule = '';
p(i).printRule = '';
p(i).ignoreRule = '';
p(i).important = 1;
p(i).wildChar = wc;

i = i + 1;
p(i).propName = 'Document';
p(i).printName = 'Document';
p(i).isLink = 0;
p(i).evalString = 'chart.id';
p(i).valueRule = '';
p(i).printRule = ['sf(''get'',' wc ',''.document'')' ];
p(i).ignoreRule = '';
p(i).important = 1;
p(i).wildChar = wc;


i = i + 1;
p(i).propName = 'Data';
p(i).printName = 'Data';
p(i).isLink = 1;
p(i).evalString = 'chart.id';
p(i).valueRule = ['sf(''DataOf'',' wc ')' ];
p(i).printRule = ['sf(''get'',' wc ',''.name'')' ];
p(i).ignoreRule = '';
p(i).important = 1;
p(i).wildChar = wc;

i = i + 1;
p(i).propName = 'Events';
p(i).printName = 'Events';
p(i).isLink = 1;
p(i).evalString = 'chart.id';
p(i).valueRule = ['sf(''EventsOf'',' wc ')' ];
p(i).printRule = ['sf(''get'',' wc ',''.name'')' ];
p(i).ignoreRule = '';
p(i).important = 1;
p(i).wildChar = wc;


i = i + 1;
p(i).propName = 'States';
p(i).printName = 'States';
p(i).isLink = 1;
p(i).evalString = 'chart.id';
p(i).valueRule = [' sf(''find'', rgsf( ''get_states'', sf(''get'',' wc ', ''.states'') ), ' ...
		'''.treeNode.parent'',' wc ')'];
p(i).printRule = ['sf(''get'',' wc ',''.name'')' ];
p(i).ignoreRule = '';
p(i).important = 1;
p(i).wildChar = wc;


%i = i + 1;
%p(i).propName = 'Image';
%p(i).printName = '';
%p(i).isLink = 0;
%p(i).evalString = '.id';
%p(i).valueRule = '';
%p(i).printRule = 'runsubcomponent( csf_snapshot, 0 )';
%p(i).ignoreRule = '';
%p(i).important = 0;
%p(i).wildChar = wc;

i = i + 1;
p(i).propName = 'SF ID';
p(i).printName = 'Id';
p(i).isLink = 0;
p(i).evalString = 'chart.id';
p(i).valueRule = '';
p(i).printRule = ['num2str(' wc ')'];
p(i).ignoreRule = '';
p(i).important = 0;
p(i).wildChar = wc;

i = i + 1;
p(i).propName = 'Transitions';
p(i).printName = 'Transitions';
p(i).isLink = 1;
p(i).evalString = 'chart.id';
p(i).valueRule = ['sf(''get'',' wc ', ''.transitions'')'];
p(i).printRule = ['sf(''get'',' wc ',''.rgTag'')' ];
p(i).ignoreRule = '';
p(i).important = 0;
p(i).wildChar = wc;


rptgenSF.propTable( rgsf( 'type2num', 'chart' ) + 1 ).prop = p;
clear p;

% define the image for this type of object
image.imagePresent = 1;
image.imageSize = [500 500];
image.dynamicSize = 1;
rptgenSF.propTable( rgsf( 'type2num', 'chart' ) + 1 ).image = image;
clear image;

% define preset tables here
i = 0;
i = i + 1;
preset(i).names = {
		'%<Name>';
};
preset(i).description = 'Chart Header';
preset(i).title = '';
preset(i).colWid = [1];
preset(i).render = 'P v';
preset(i).align = 'j';
preset(i).border = logical(1);
preset(i).SingleValueMode = logical(1);

i = i + 1;
preset(i).names = {
		'%<Machine>';
		'%<Description>';
		'%<Document>';
};
preset(i).description = 'Chart Top';
preset(i).title = '';
preset(i).colWid = [1];
preset(i).render = 'P v';
preset(i).align = 'l';
preset(i).border = logical(0);
preset(i).SingleValueMode = logical(1);

i = i + 1;
preset(i).names = {
		'%<Data>';
		'%<Events>';
		'%<States>' ...
};
preset(i).description = 'Chart Bottom';
preset(i).title = '';
preset(i).colWid = [1];
preset(i).render = 'P v';
preset(i).align = 'l';
preset(i).border = logical(0);
preset(i).SingleValueMode = logical(1);


rptgenSF.propTable( rgsf( 'type2num', 'chart' ) + 1 ).preset = preset;
clear preset;




%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% set reportable properties for the state
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
i = 0;

i = i + 1;
p(i).propName = 'Name';
p(i).printName = 'State';
p(i).isLink = 0;
p(i).evalString = 'state.id';
p(i).valueRule = '';
p(i).printRule = ['sf(''get'',' wc ',''.name'')' ];
p(i).ignoreRule = '';
p(i).important = 0;
p(i).wildChar = wc;

i = i + 1;
p(i).propName = 'FullPath+Name';
p(i).printName = 'State';
p(i).isLink = 0;
p(i).evalString = 'state.id';
p(i).valueRule = '';
p(i).printRule = ['sf(''FullNameOf'',' wc ',''/'')' ];
p(i).ignoreRule = '';
p(i).important = 0;
p(i).wildChar = wc;

i = i + 1;
p(i).propName = 'SFPath+Name';
p(i).printName = 'State';
p(i).isLink = 0;
p(i).evalString = 'state.id';
p(i).valueRule = '';
p(i).printRule = ['rgsf(''get_sf_full_name'',' wc ',''/'', '''')' ];
p(i).ignoreRule = '';
p(i).important = 1;
p(i).wildChar = wc;

i = i + 1;
p(i).propName = 'Parent';
p(i).printName = 'Parent';
p(i).isLink = 1;
p(i).evalString = 'state.treeNode.parent';
p(i).valueRule = '';
p(i).printRule = ['sf(''get'',' wc ',''.name'')' ];
p(i).ignoreRule = '';
p(i).important = 0;
p(i).wildChar = wc;

i = i + 1;
p(i).propName = 'Label';
p(i).printName = 'Label';
p(i).isLink = 0;
p(i).evalString = 'state.id';
p(i).valueRule = '';
p(i).printRule = ['sf(''get'',' wc ',''.labelString'')' ];
p(i).ignoreRule = '';
p(i).important = 0;
p(i).wildChar = wc;

i = i + 1;
p(i).propName = 'Description';
p(i).printName = 'Description';
p(i).isLink = 0;
p(i).evalString = 'state.description';
p(i).valueRule = '';
p(i).printRule = '';
p(i).ignoreRule = '';
p(i).important = 1;
p(i).wildChar = wc;

i = i + 1;
p(i).propName = 'Data';
p(i).printName = 'Data';
p(i).isLink = 1;
p(i).evalString = 'state.id';
p(i).valueRule = ['sf(''DataOf'',' wc ')' ];
p(i).printRule = ['sf(''get'',' wc ',''.name'')' ];
p(i).ignoreRule = '';
p(i).important = 1;
p(i).wildChar = wc;

i = i + 1;
p(i).propName = 'Events';
p(i).printName = 'Events';
p(i).isLink = 1;
p(i).evalString = 'state.id';
p(i).valueRule = ['sf(''EventsOf'',' wc ')' ];
p(i).printRule = ['sf(''get'',' wc ',''.name'')' ];
p(i).ignoreRule = '';
p(i).important = 1;
p(i).wildChar = wc;


i = i + 1;
p(i).propName = 'Substates';
p(i).printName = 'Substates';
p(i).isLink = 1;
p(i).evalString = 'state.id';
p(i).valueRule = ['rgsf( ''get_states'', sf(''AllSubstatesOf'',' wc ') )'];
p(i).printRule = ['sf(''get'',' wc ',''.name'')' ];
p(i).ignoreRule = '';
p(i).important = 0;
p(i).wildChar = wc;

i = i + 1;
p(i).propName = 'Source Transitions';
p(i).printName = 'Source Transitions';
p(i).isLink = 1;
p(i).evalString = 'state.srcTransitions';
p(i).valueRule = '';
p(i).printRule = ['sf(''get'',' wc ',''.rgTag'')' ];
p(i).ignoreRule = '';
p(i).important = 0;
p(i).wildChar = wc;

i = i + 1;
p(i).propName = 'Dest Transitions';
p(i).printName = 'Dest Transitions';
p(i).isLink = 1;
p(i).evalString = 'state.dstTransitions';
p(i).valueRule = '';
p(i).printRule = ['sf(''get'',' wc ',''.rgTag'')' ];
p(i).ignoreRule = '';
p(i).important = 0;
p(i).wildChar = wc;

%i = i + 1;
%p(i).propName = 'Image';
%p(i).printName = '';
%p(i).isLink = 0;
%p(i).evalString = '.id';
%p(i).valueRule = '';
%p(i).printRule = 'runsubcomponent( csf_snapshot, 0 )';
%p(i).ignoreRule = '';
%p(i).important = 0;
%p(i).wildChar = wc;

i = i + 1;
p(i).propName = 'Output Data';
p(i).printName = 'Output Data';
p(i).isLink = 1;
p(i).evalString = 'state.outputData';
p(i).valueRule = '';
p(i).printRule = ['sf(''get'',' wc ',''.name'')' ];
p(i).ignoreRule = '';
p(i).important = 0;
p(i).wildChar = wc;

i = i + 1;
p(i).propName = 'Document';
p(i).printName = 'Document';
p(i).isLink = 0;
p(i).evalString = 'state.id';
p(i).valueRule = '';
p(i).printRule = ['sf(''get'',' wc ',''.document'')' ];
p(i).ignoreRule = '';
p(i).important = 1;
p(i).wildChar = wc;



rptgenSF.propTable( rgsf( 'type2num', 'state' ) + 1 ).prop = p;
clear p;

% define the image for this type of object
image.imagePresent = 1;
image.imageSize = [500 500];
image.dynamicSize = 1;
rptgenSF.propTable( rgsf( 'type2num', 'state' ) + 1 ).image = image;
clear image;

% define preset tables here
i = 0;
i = i + 1;
preset(i).names = {
		'%<Name>';
};
preset(i).description = 'State Header';
preset(i).title = '';
preset(i).colWid = [1];
preset(i).render = 'P v';
preset(i).align = 'j';
preset(i).border = logical(1);
preset(i).SingleValueMode = logical(1);


i = i + 1;
preset(i).names = {
		'%<Parent>';
		'%<Label>';
		'%<Description>';
		'%<Document>' ...
};
preset(i).description = 'State Top';
preset(i).title = '';
preset(i).colWid = [1];
preset(i).render = 'P v';
preset(i).align = 'l';
preset(i).border = logical(0);
preset(i).SingleValueMode = logical(1);

i = i + 1;
preset(i).names = {
		'%<Substates>';
		'%<Data>';
		'%<Events>';
		'%<Output Data>' ...
};
preset(i).description = 'State Bottom';
preset(i).title = '';
preset(i).colWid = [1];
preset(i).render = 'P v';
preset(i).align = 'l';
preset(i).border = logical(0);
preset(i).SingleValueMode = logical(1);


rptgenSF.propTable( rgsf( 'type2num', 'state' ) + 1 ).preset = preset;
clear preset;

% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% % set reportable properties for subchart
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% i = 0;
% 
% i = i + 1;
% p(i).propName = 'Name';
% p(i).printName = 'Subchart';
% p(i).isLink = 0;
% p(i).evalString = 'subchart.id';
% p(i).valueRule = '';
% p(i).printRule = ['sf(''get'',' wc ',''.name'')' ];
% p(i).ignoreRule = '';
% p(i).important = 0;
% p(i).wildChar = wc;
% 
% i = i + 1;
% p(i).propName = 'FullPath+Name';
% p(i).printName = 'Subchart';
% p(i).isLink = 0;
% p(i).evalString = 'subchart.id';
% p(i).valueRule = '';
% p(i).printRule = ['sf(''FullNameOf'',' wc ',''/'')' ];
% p(i).ignoreRule = '';
% p(i).important = 0;
% p(i).wildChar = wc;
% 
% i = i + 1;
% p(i).propName = 'SFPath+Name';
% p(i).printName = 'Subchart';
% p(i).isLink = 0;
% p(i).evalString = 'subchart.id';
% p(i).valueRule = '';
% p(i).printRule = ['rgsf(''get_sf_full_name'',' wc ',''/'', '''')' ];
% p(i).ignoreRule = '';
% p(i).important = 1;
% p(i).wildChar = wc;
% 
% i = i + 1;
% p(i).propName = 'Parent';
% p(i).printName = 'Parent';
% p(i).isLink = 1;
% p(i).evalString = 'subchart.treeNode.parent';
% p(i).valueRule = '';
% p(i).printRule = ['sf(''get'',' wc ',''.name'')' ];
% p(i).ignoreRule = '';
% p(i).important = 0;
% p(i).wildChar = wc;
% 
% i = i + 1;
% p(i).propName = 'Label';
% p(i).printName = 'Label';
% p(i).isLink = 0;
% p(i).evalString = 'subchart.id';
% p(i).valueRule = '';
% p(i).printRule = ['sf(''get'',' wc ',''.labelString'')' ];
% p(i).ignoreRule = '';
% p(i).important = 0;
% p(i).wildChar = wc;
% 
% i = i + 1;
% p(i).propName = 'Description';
% p(i).printName = 'Description';
% p(i).isLink = 0;
% p(i).evalString = 'subchart.description';
% p(i).valueRule = '';
% p(i).printRule = '';
% p(i).ignoreRule = '';
% p(i).important = 1;
% p(i).wildChar = wc;
% 
% i = i + 1;
% p(i).propName = 'Data';
% p(i).printName = 'Data';
% p(i).isLink = 1;
% p(i).evalString = 'subchart.id';
% p(i).valueRule = ['sf(''DataOf'',' wc ')' ];
% p(i).printRule = ['sf(''get'',' wc ',''.name'')' ];
% p(i).ignoreRule = '';
% p(i).important = 1;
% p(i).wildChar = wc;
% 
% i = i + 1;
% p(i).propName = 'Events';
% p(i).printName = 'Events';
% p(i).isLink = 1;
% p(i).evalString = 'subchart.id';
% p(i).valueRule = ['sf(''EventsOf'',' wc ')' ];
% p(i).printRule = ['sf(''get'',' wc ',''.name'')' ];
% p(i).ignoreRule = '';
% p(i).important = 1;
% p(i).wildChar = wc;
% 
% 
% i = i + 1;
% p(i).propName = 'Substates';
% p(i).printName = 'Substates';
% p(i).isLink = 1;
% p(i).evalString = 'subchart.id';
% p(i).valueRule = ['rgsf( ''get_states'', sf(''AllSubstatesOf'',' wc ') )'];
% p(i).printRule = ['sf(''get'',' wc ',''.name'')' ];
% p(i).ignoreRule = '';
% p(i).important = 0;
% p(i).wildChar = wc;
% 
% i = i + 1;
% p(i).propName = 'Source Transitions';
% p(i).printName = 'Source Transitions';
% p(i).isLink = 1;
% p(i).evalString = 'subchart.srcTransitions';
% p(i).valueRule = '';
% p(i).printRule = ['sf(''get'',' wc ',''.rgTag'')' ];
% p(i).ignoreRule = '';
% p(i).important = 0;
% p(i).wildChar = wc;
% 
% i = i + 1;
% p(i).propName = 'Dest Transitions';
% p(i).printName = 'Dest Transitions';
% p(i).isLink = 1;
% p(i).evalString = 'subchart.dstTransitions';
% p(i).valueRule = '';
% p(i).printRule = ['sf(''get'',' wc ',''.rgTag'')' ];
% p(i).ignoreRule = '';
% p(i).important = 0;
% p(i).wildChar = wc;
% 
% %i = i + 1;
% %p(i).propName = 'Image';
% %p(i).printName = '';
% %p(i).isLink = 0;
% %p(i).evalString = '.id';
% %p(i).valueRule = '';
% %p(i).printRule = 'runsubcomponent( csf_snapshot, 0 )';
% %p(i).ignoreRule = '';
% %p(i).important = 0;
% %p(i).wildChar = wc;
% 
% i = i + 1;
% p(i).propName = 'Output Data';
% p(i).printName = 'Output Data';
% p(i).isLink = 1;
% p(i).evalString = 'subchart.outputData';
% p(i).valueRule = '';
% p(i).printRule = ['sf(''get'',' wc ',''.name'')' ];
% p(i).ignoreRule = '';
% p(i).important = 0;
% p(i).wildChar = wc;
% 
% i = i + 1;
% p(i).propName = 'Document';
% p(i).printName = 'Document';
% p(i).isLink = 0;
% p(i).evalString = 'subchart.id';
% p(i).valueRule = '';
% p(i).printRule = ['sf(''get'',' wc ',''.document'')' ];
% p(i).ignoreRule = '';
% p(i).important = 1;
% p(i).wildChar = wc;
% 
% rptgenSF.propTable( rgsf( 'type2num', 'subchart' ) + 1 ).prop = p;
% clear p;
% 
% % define the image for this type of object
% image.imagePresent = 1;
% image.imageSize = [500 500];
% image.dynamicSize = 1;
% rptgenSF.propTable( rgsf( 'type2num', 'subchart' ) + 1 ).image = image;
% clear image;
% 
% % define preset tables here
% i = 0;
% i = i + 1;
% preset(i).names = {
% 		'%<Name>';
% };
% preset(i).description = 'Subchart Header';
% preset(i).title = '';
% preset(i).colWid = [1];
% preset(i).render = 'P v';
% preset(i).align = 'j';
% preset(i).border = logical(1);
% preset(i).SingleValueMode = logical(1);
% 
% 
% i = i + 1;
% preset(i).names = {
% 		'%<Parent>';
% 		'%<Label>';
% 		'%<Description>';
% 		'%<Document>' ...
% };
% preset(i).description = 'Subchart Top';
% preset(i).title = '';
% preset(i).colWid = [1];
% preset(i).render = 'P v';
% preset(i).align = 'l';
% preset(i).border = logical(0);
% preset(i).SingleValueMode = logical(1);
% 
% i = i + 1;
% preset(i).names = {
% 		'%<Substates>';
% 		'%<Data>';
% 		'%<Events>';
% 		'%<Output Data>' ...
% };
% preset(i).description = 'Subchart Bottom';
% preset(i).title = '';
% preset(i).colWid = [1];
% preset(i).render = 'P v';
% preset(i).align = 'l';
% preset(i).border = logical(0);
% preset(i).SingleValueMode = logical(1);
% 
% 
% rptgenSF.propTable( rgsf( 'type2num', 'subchart' ) + 1 ).preset = preset;
% clear preset;
% 

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% set reportable properties for the function object
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
i = 0;

i = i + 1;
p(i).propName = 'Name';
p(i).printName = 'Function';
p(i).isLink = 0;
p(i).evalString = 'state.id';
p(i).valueRule = '';
p(i).printRule = ['sf(''get'',' wc ',''.name'')' ];
p(i).ignoreRule = '';
p(i).important = 0;
p(i).wildChar = wc;


i = i + 1;
p(i).propName = 'FullPath+Name';
p(i).printName = 'Function';
p(i).isLink = 0;
p(i).evalString = 'state.id';
p(i).valueRule = '';
p(i).printRule = ['sf(''FullNameOf'',' wc ',''/'')' ];
p(i).ignoreRule = '';
p(i).important = 0;
p(i).wildChar = wc;

i = i + 1;
p(i).propName = 'SFPath+Name';
p(i).printName = 'Function';
p(i).isLink = 0;
p(i).evalString = 'state.id';
p(i).valueRule = '';
p(i).printRule = ['rgsf(''get_sf_full_name'',' wc ',''/'', '''')' ];
p(i).ignoreRule = '';
p(i).important = 1;
p(i).wildChar = wc;

i = i + 1;
p(i).propName = 'Label';
p(i).printName = 'Label';
p(i).isLink = 0;
p(i).evalString = 'state.id';
p(i).valueRule = '';
p(i).printRule = ['sf(''get'',' wc ',''.labelString'')' ];
p(i).ignoreRule = '';
p(i).important = 0;
p(i).wildChar = wc;

i = i + 1;
p(i).propName = 'Parent';
p(i).printName = 'Parent';
p(i).isLink = 1;
p(i).evalString = 'state.treeNode.parent';
p(i).valueRule = '';
p(i).printRule = ['sf(''get'',' wc ',''.name'')' ];
p(i).ignoreRule = '';
p(i).important = 0;
p(i).wildChar = wc;

i = i + 1;
p(i).propName = 'Description';
p(i).printName = 'Description';
p(i).isLink = 0;
p(i).evalString = 'state.description';
p(i).valueRule = '';
p(i).printRule = '';
p(i).ignoreRule = '';
p(i).important = 1;
p(i).wildChar = wc;

i = i + 1;
p(i).propName = 'Document';
p(i).printName = 'Document';
p(i).isLink = 0;
p(i).evalString = 'state.id';
p(i).valueRule = '';
p(i).printRule = ['sf(''get'',' wc ',''.document'')' ];
p(i).ignoreRule = '';
p(i).important = 1;
p(i).wildChar = wc;


i = i + 1;
p(i).propName = 'Data';
p(i).printName = 'Data';
p(i).isLink = 1;
p(i).evalString = 'state.id';
p(i).valueRule = ['sf(''DataOf'',' wc ')' ];
p(i).printRule = ['sf(''get'',' wc ',''.name'')' ];
p(i).ignoreRule = '';
p(i).important = 1;
p(i).wildChar = wc;

rptgenSF.propTable( rgsf( 'type2num', 'function' ) + 1 ).prop = p;
clear p;

% define the image for this type of object
image.imagePresent = 1;
image.imageSize = [500 500];
image.dynamicSize = 1;
rptgenSF.propTable( rgsf( 'type2num', 'function' ) + 1 ).image = image;
clear image;

% define preset tables here
i = 0;
i = i + 1;
preset(i).names = {
		'%<Name>';
};
preset(i).description = 'Function Header';
preset(i).title = '';
preset(i).colWid = [1];
preset(i).render = 'P v';
preset(i).align = 'j';
preset(i).border = logical(1);
preset(i).SingleValueMode = logical(1);

i = i + 1;
preset(i).names = {
		'%<Parent>'
		'%<Label>'
		'%<Description>'
		'%<Document>'
        '%<Data>'
};
preset(i).description = 'Function Top';
preset(i).title = '';
preset(i).colWid = [1];
preset(i).render = 'P v';
preset(i).align = 'l';
preset(i).border = logical(0);
preset(i).SingleValueMode = logical(1);

rptgenSF.propTable( rgsf( 'type2num', 'function' ) + 1 ).preset = preset;
clear preset;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% set reportable properties for the group (called box)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
i = 0;

i = i + 1;
p(i).propName = 'Name';
p(i).printName = 'Box';
p(i).isLink = 0;
p(i).evalString = 'state.id';
p(i).valueRule = '';
p(i).printRule = ['sf(''get'',' wc ',''.name'')' ];
p(i).ignoreRule = '';
p(i).important = 0;
p(i).wildChar = wc;


i = i + 1;
p(i).propName = 'FullPath+Name';
p(i).printName = 'Box';
p(i).isLink = 0;
p(i).evalString = 'state.id';
p(i).valueRule = '';
p(i).printRule = ['sf(''FullNameOf'',' wc ',''/'')' ];
p(i).ignoreRule = '';
p(i).important = 0;
p(i).wildChar = wc;

i = i + 1;
p(i).propName = 'SFPath+Name';
p(i).printName = 'Box';
p(i).isLink = 0;
p(i).evalString = 'state.id';
p(i).valueRule = '';
p(i).printRule = ['rgsf(''get_sf_full_name'',' wc ',''/'', '''')' ];
p(i).ignoreRule = '';
p(i).important = 1;
p(i).wildChar = wc;

i = i + 1;
p(i).propName = 'Label';
p(i).printName = 'Label';
p(i).isLink = 0;
p(i).evalString = 'state.id';
p(i).valueRule = '';
p(i).printRule = ['sf(''get'',' wc ',''.labelString'')' ];
p(i).ignoreRule = '';
p(i).important = 0;
p(i).wildChar = wc;

i = i + 1;
p(i).propName = 'Parent';
p(i).printName = 'Parent';
p(i).isLink = 1;
p(i).evalString = 'state.treeNode.parent';
p(i).valueRule = '';
p(i).printRule = ['sf(''get'',' wc ',''.name'')' ];
p(i).ignoreRule = '';
p(i).important = 0;
p(i).wildChar = wc;

i = i + 1;
p(i).propName = 'Description';
p(i).printName = 'Description';
p(i).isLink = 0;
p(i).evalString = 'state.description';
p(i).valueRule = '';
p(i).printRule = '';
p(i).ignoreRule = '';
p(i).important = 1;
p(i).wildChar = wc;


%i = i + 1;
%p(i).propName = 'Image';
%p(i).printName = '';
%p(i).isLink = 0;
%p(i).evalString = '.id';
%p(i).valueRule = '';
%p(i).printRule = 'runsubcomponent( csf_snapshot, 0 )';
%p(i).ignoreRule = '';
%p(i).important = 0;
%p(i).wildChar = wc;

i = i + 1;
p(i).propName = 'Document';
p(i).printName = 'Document';
p(i).isLink = 0;
p(i).evalString = 'state.id';
p(i).valueRule = '';
p(i).printRule = ['sf(''get'',' wc ',''.document'')' ];
p(i).ignoreRule = '';
p(i).important = 1;
p(i).wildChar = wc;


i = i + 1;
p(i).propName = 'Data';
p(i).printName = 'Data';
p(i).isLink = 1;
p(i).evalString = 'state.id';
p(i).valueRule = ['sf(''DataOf'',' wc ')' ];
p(i).printRule = ['sf(''get'',' wc ',''.name'')' ];
p(i).ignoreRule = '';
p(i).important = 1;
p(i).wildChar = wc;

i = i + 1;
p(i).propName = 'Events';
p(i).printName = 'Events';
p(i).isLink = 1;
p(i).evalString = 'state.id';
p(i).valueRule = ['sf(''EventsOf'',' wc ')' ];
p(i).printRule = ['sf(''get'',' wc ',''.name'')' ];
p(i).ignoreRule = '';
p(i).important = 1;
p(i).wildChar = wc;


i = i + 1;
p(i).propName = 'Substates';
p(i).printName = 'Substates';
p(i).isLink = 1;
p(i).evalString = 'state.id';
p(i).valueRule = ['rgsf( ''get_states'', sf(''AllSubstatesOf'',' wc ') )'];
p(i).printRule = ['sf(''get'',' wc ',''.name'')' ];
p(i).ignoreRule = '';
p(i).important = 0;
p(i).wildChar = wc;



rptgenSF.propTable( rgsf( 'type2num', 'box' ) + 1 ).prop = p;
clear p;

% define the image for this type of object
image.imagePresent = 1;
image.imageSize = [500 500];
image.dynamicSize = 1;
rptgenSF.propTable( rgsf( 'type2num', 'box' ) + 1 ).image = image;
clear image;

% define preset tables here
i = 0;
i = i + 1;
preset(i).names = {
		'%<Name>';
};
preset(i).description = 'Box Header';
preset(i).title = '';
preset(i).colWid = [1];
preset(i).render = 'P v';
preset(i).align = 'j';
preset(i).border = logical(1);
preset(i).SingleValueMode = logical(1);

i = i + 1;
preset(i).names = {
		'%<Parent>'
		'%<Label>'
		'%<Description>'
		'%<Document>'
};
preset(i).description = 'Box Top';
preset(i).title = '';
preset(i).colWid = [1];
preset(i).render = 'P v';
preset(i).align = 'l';
preset(i).border = logical(0);
preset(i).SingleValueMode = logical(1);

i = i + 1;
preset(i).names = {
		'%<Data>'
		'%<Events>'
		'%<Substates>'
};
preset(i).description = 'Box Bottom';
preset(i).title = '';
preset(i).colWid = [1];
preset(i).render = 'P v';
preset(i).align = 'l';
preset(i).border = logical(0);
preset(i).SingleValueMode = logical(1);



rptgenSF.propTable( rgsf( 'type2num', 'box' ) + 1 ).preset = preset;
clear preset;


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% set reportable properties for the transition
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
i = 0;

i = i + 1;
p(i).propName = 'Name';
p(i).printName = 'Transition';
p(i).isLink = 0;
p(i).evalString = 'transition.id';
p(i).valueRule = '';
p(i).printRule = ['sf(''get'',' wc ',''.rgTag'')' ];
p(i).ignoreRule = '';
p(i).important = 0;
p(i).wildChar = wc;

i = i + 1;
p(i).propName = 'FullPath+Name';
p(i).printName = 'Transition';
p(i).isLink = 0;
p(i).evalString = 'transition.id';
p(i).valueRule = '';
p(i).printRule = [ '[ sf(''FullNameOf'', sf(''ParentOf'',' wc '), ''/''), ''/'', sf(''get'',' wc ',''.rgTag'') ]' ];
p(i).ignoreRule = '';
p(i).important = 0;
p(i).wildChar = wc;


i = i + 1;
p(i).propName = 'SFPath+Name';
p(i).printName = 'Transition';
p(i).isLink = 0;
p(i).evalString = 'transition.id';
p(i).valueRule = '';
p(i).printRule = ['rgsf(''get_sf_full_name'',' wc ',''/'', sf(''get'',' wc ',''.rgTag'') )' ];
p(i).ignoreRule = '';
p(i).important = 1;
p(i).wildChar = wc;

i = i + 1;
p(i).propName = 'Label';
p(i).printName = 'Label';
p(i).isLink = 0;
p(i).evalString = 'transition.id';
p(i).valueRule = '';
p(i).printRule = ['sf(''get'',' wc ',''.labelString'')' ];
p(i).ignoreRule = '';
p(i).important = 0;
p(i).wildChar = wc;

i = i + 1;
p(i).propName = 'Parent';
p(i).printName = 'Parent';
p(i).isLink = 1;
p(i).evalString = 'transition.linkNode.parent';
p(i).valueRule = '';
p(i).printRule = ['sf(''get'',' wc ',''.name'')' ];
p(i).ignoreRule = '';
p(i).important = 0;
p(i).wildChar = wc;

i = i + 1;
p(i).propName = 'Description';
p(i).printName = 'Description';
p(i).isLink = 0;
p(i).evalString = 'transition.description';
p(i).valueRule = '';
p(i).printRule = '';
p(i).ignoreRule = '';
p(i).important = 1;
p(i).wildChar = wc;

i = i + 1;
p(i).propName = 'Source';
p(i).printName = 'Source';
p(i).isLink = 1;
p(i).evalString = 'transition.src.id';
p(i).valueRule = '';
p(i).printRule = ['rgsf( ''get_trans_src_or_dest'',' wc ')'];
p(i).ignoreRule = '';
p(i).important = 0;
p(i).wildChar = wc;

i = i + 1;
p(i).propName = 'Destination';
p(i).printName = 'Dest';
p(i).isLink = 1;
p(i).evalString = 'transition.dst.id';
p(i).valueRule = '';
p(i).printRule = ['rgsf( ''get_trans_src_or_dest'',' wc ')'];
p(i).ignoreRule = '';
p(i).important = 0;
p(i).wildChar = wc;

%i = i + 1;
%p(i).propName = 'Image';
%p(i).printName = '';
%p(i).isLink = 0;
%p(i).evalString = '.id';
%p(i).valueRule = '';
%p(i).printRule = 'runsubcomponent( csf_snapshot, 0 )';
%p(i).ignoreRule = '';
%p(i).important = 0;
%p(i).wildChar = wc;

i = i + 1;
p(i).propName = 'Chart';
p(i).printName = 'Chart';
p(i).isLink = 1;
p(i).evalString = 'transition.chart';
p(i).valueRule = '';
p(i).printRule = ['sf(''get'',' wc ',''.name'')' ];
p(i).ignoreRule = '';
p(i).important = 0;
p(i).wildChar = wc;

i = i + 1;
p(i).propName = 'Is Default';
p(i).printName = 'Is Default';
p(i).isLink = 1;
p(i).evalString = 'transition.isDefault';
p(i).valueRule = '';
p(i).printRule = ['rg_num2str(' wc ')' ];
p(i).ignoreRule = [ wc ' == 0' ];
p(i).important = 0;
p(i).wildChar = wc;

i = i + 1;
p(i).propName = 'Document';
p(i).printName = 'Document';
p(i).isLink = 0;
p(i).evalString = 'transition.id';
p(i).valueRule = '';
p(i).printRule = ['sf(''get'',' wc ',''.document'')' ];
p(i).ignoreRule = '';
p(i).important = 1;
p(i).wildChar = wc;



rptgenSF.propTable( rgsf( 'type2num', 'transition' ) + 1 ).prop = p;
clear p;

% define the image for this type of object
image.imagePresent = 1;
image.imageSize = [500 400];
image.dynamicSize = 1;
rptgenSF.propTable( rgsf( 'type2num', 'transition' ) + 1 ).image = image;
clear image;

% define preset tables here
i = 0;
i = i + 1;
preset(i).names = {
		'%<Name>';
};
preset(i).description = 'Transition Header';
preset(i).title = '';
preset(i).colWid = [1];
preset(i).render = 'P v';
preset(i).align = 'j';
preset(i).border = logical(1);
preset(i).SingleValueMode = logical(1);

i = i + 1;
preset(i).names = {
		'%<Parent>';
		'%<Label>';
		'%<Description>';
		'%<Document>';
};
preset(i).description = 'Transition Top';
preset(i).title = '';
preset(i).colWid = [1];
preset(i).render = 'P v';
preset(i).align = 'l';
preset(i).border = logical(0);
preset(i).SingleValueMode = logical(1);

i = i + 1;
preset(i).names = {
		'%<Source>';
		'%<Destination>';
		'%<Chart>';
		'%<Is Default>';
};
preset(i).description = 'Transition Bottom';
preset(i).title = '';
preset(i).colWid = [1];
preset(i).render = 'P v';
preset(i).align = 'l';
preset(i).border = logical(0);
preset(i).SingleValueMode = logical(1);



rptgenSF.propTable( rgsf( 'type2num', 'transition' ) + 1 ).preset = preset;
clear preset;



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% set reportable properties for the target
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
i = 0;

i = i + 1;
p(i).propName = 'Name';
p(i).printName = 'Target';
p(i).isLink = 0;
p(i).evalString = 'target.id';
p(i).valueRule = '';
p(i).printRule = ['sf(''get'',' wc ',''.name'')' ];
p(i).ignoreRule = '';
p(i).important = 1;
p(i).wildChar = wc;

i = i + 1;
p(i).propName = 'FullPath+Name';
p(i).printName = 'Target';
p(i).isLink = 0;
p(i).evalString = 'target.id';
p(i).valueRule = '';
p(i).printRule = ['sf(''FullNameOf'',' wc ',''/'')' ];
p(i).ignoreRule = '';
p(i).important = 1;
p(i).wildChar = wc;


i = i + 1;
p(i).propName = 'SFPath+Name';
p(i).printName = 'Target';
p(i).isLink = 0;
p(i).evalString = 'target.id';
p(i).valueRule = '';
p(i).printRule = ['rgsf(''get_sf_full_name'',' wc ',''/'', '''')' ];
p(i).ignoreRule = '';
p(i).important = 1;
p(i).wildChar = wc;

i = i + 1;
p(i).propName = 'Machine';
p(i).printName = 'Machine';
p(i).isLink = 1;
p(i).evalString = 'target.machine';
p(i).valueRule = '';
p(i).printRule = ['sf(''get'',' wc ',''.name'')' ];
p(i).ignoreRule = '';
p(i).important = 0;
p(i).wildChar = wc;

i = i + 1;
p(i).propName = 'Description';
p(i).printName = 'Description';
p(i).isLink = 0;
p(i).evalString = 'target.id';
p(i).valueRule = '';
p(i).printRule = ['sf(''get'',' wc ',''.description'')' ];
p(i).ignoreRule = '';
p(i).important = 1;
p(i).wildChar = wc;

i = i + 1;
p(i).propName = 'Custom Code';
p(i).printName = 'Custom Code';
p(i).isLink = 0;
p(i).evalString = 'target.id';
p(i).valueRule = '';
p(i).printRule = ['sf(''get'',' wc ',''.customCode'')' ];
p(i).ignoreRule = '';
p(i).important = 1;
p(i).wildChar = wc;

i = i + 1;
p(i).propName = 'Code Flags';
p(i).printName = 'Code Flags';
p(i).isLink = 0;
p(i).evalString = 'target.id';
p(i).valueRule = '';
p(i).printRule = ['sf(''get'',' wc ',''.codeFlags'')' ];
p(i).ignoreRule = '';
p(i).important = 1;
p(i).wildChar = wc;

i = i + 1;
p(i).propName = 'Document';
p(i).printName = 'Document';
p(i).isLink = 0;
p(i).evalString = 'target.id';
p(i).valueRule = '';
p(i).printRule = ['sf(''get'',' wc ',''.document'')' ];
p(i).ignoreRule = '';
p(i).important = 1;
p(i).wildChar = wc;

i = i + 1;
p(i).propName = 'User Sources';
p(i).printName = 'User Sources';
p(i).isLink = 0;
p(i).evalString = 'target.id';
p(i).valueRule = '';
p(i).printRule = ['sf(''get'',' wc ',''.userSources'')' ];
p(i).ignoreRule = '';
p(i).important = 1;
p(i).wildChar = wc;

i = i + 1;
p(i).propName = 'User Include Directories';
p(i).printName = 'User Include Directories';
p(i).isLink = 0;
p(i).evalString = 'target.id';
p(i).valueRule = '';
p(i).printRule = ['sf(''get'',' wc ',''.userIncludeDirs'')' ];
p(i).ignoreRule = '';
p(i).important = 1;
p(i).wildChar = wc;

i = i + 1;
p(i).propName = 'User Libraries';
p(i).printName = 'User Libraries';
p(i).isLink = 0;
p(i).evalString = 'target.id';
p(i).valueRule = '';
p(i).printRule = ['sf(''get'',' wc ',''.userLibraries'')' ];
p(i).ignoreRule = '';
p(i).important = 1;
p(i).wildChar = wc;

i = i + 1;
p(i).propName = 'User Makefiles';
p(i).printName = 'User Makefiles';
p(i).isLink = 0;
p(i).evalString = 'target.id';
p(i).valueRule = '';
p(i).printRule = ['sf(''get'',' wc ',''.userMakefiles'')' ];
p(i).ignoreRule = '';
p(i).important = 1;
p(i).wildChar = wc;

i = i + 1;
p(i).propName = 'Mex File Name';
p(i).printName = 'Mex File Name';
p(i).isLink = 0;
p(i).evalString = 'target.id';
p(i).valueRule = '';
p(i).printRule = ['sf(''get'',' wc ',''.mexFileName'')' ];
p(i).ignoreRule = '';
p(i).important = 1;
p(i).wildChar = wc;



rptgenSF.propTable( rgsf( 'type2num', 'target' ) + 1 ).prop = p;
clear p;

% define the image for this type of object
image.imagePresent = 0;
image.imageSize = [0 0];
image.dynamicSize = 1;
rptgenSF.propTable( rgsf( 'type2num', 'target' ) + 1 ).image = image;
clear image;


% define preset tables here
i = 0;
i = i + 1;
preset(i).names = {
		'%<Name>';
};
preset(i).description = 'Target Header';
preset(i).title = '';
preset(i).colWid = [1];
preset(i).render = 'P v';
preset(i).align = 'j';
preset(i).border = logical(1);
preset(i).SingleValueMode = logical(1);

i = i + 1;
preset(i).names = {
		'%<Machine>';
		'%<Description>';
		'%<Document>';
		'%<Custom Code>';
		'%<Code Flags>';
		'%<User Sources>';
		'%<User Include Directories>';
		'%<User Libraries>';
		'%<User Makefiles>';
		'%<Mex File Name>' ...
};
preset(i).description = 'Target Top';
preset(i).title = '';
preset(i).colWid = [1];
preset(i).render = 'P v';
preset(i).align = 'l';
preset(i).border = logical(0);
preset(i).SingleValueMode = logical(1);

rptgenSF.propTable( rgsf( 'type2num', 'target' ) + 1 ).preset = preset;
clear preset;



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% set reportable properties for the junction
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
i = 0;

i = i + 1;
p(i).propName = 'Name';
p(i).printName = 'Junction';
p(i).isLink = 0;
p(i).evalString = 'junction.rgTag';
p(i).valueRule = '';
p(i).printRule = '';
p(i).ignoreRule = '';
p(i).important = 0;
p(i).wildChar = wc;

i = i + 1;
p(i).propName = 'FullPath+Name';
p(i).printName = 'Junction';
p(i).isLink = 0;
p(i).evalString = 'junction.id';
p(i).valueRule = '';
p(i).printRule = [ '[ sf(''FullNameOf'', sf(''ParentOf'',' wc '), ''/''), ''/'', sf(''get'',' wc ',''.rgTag'') ]' ];
p(i).ignoreRule = '';
p(i).important = 0;
p(i).wildChar = wc;

i = i + 1;
p(i).propName = 'SFPath+Name';
p(i).printName = 'Junction';
p(i).isLink = 0;
p(i).evalString = 'junction.id';
p(i).valueRule = '';
p(i).printRule = ['rgsf(''get_sf_full_name'',' wc ',''/'', sf(''get'',' wc ',''.rgTag'') )' ];
p(i).ignoreRule = '';
p(i).important = 1;
p(i).wildChar = wc;

i = i + 1;
p(i).propName = 'Label';
p(i).printName = 'Label';
p(i).isLink = 0;
p(i).evalString = 'junction.labelString';
p(i).valueRule = '';
p(i).printRule = '';
p(i).ignoreRule = '';
p(i).important = 0;
p(i).wildChar = wc;

i = i + 1;
p(i).propName = 'Description';
p(i).printName = 'Description';
p(i).isLink = 0;
p(i).evalString = 'junction.id';
p(i).valueRule = '';
p(i).printRule = ['sf(''get'',' wc ',''.description'')' ];
p(i).ignoreRule = '';
p(i).important = 1;
p(i).wildChar = wc;

i = i + 1;
p(i).propName = 'Document';
p(i).printName = 'Document';
p(i).isLink = 0;
p(i).evalString = 'junction.id';
p(i).valueRule = '';
p(i).printRule = ['sf(''get'',' wc ',''.document'')' ];
p(i).ignoreRule = '';
p(i).important = 1;
p(i).wildChar = wc;

i = i + 1;
p(i).propName = 'Chart';
p(i).printName = 'Chart';
p(i).isLink = 1;
p(i).evalString = 'junction.id';
p(i).valueRule = '';
p(i).printRule = ['sf(''get'',' wc ',''.chart'')' ];
p(i).ignoreRule = '';
p(i).important = 0;
p(i).wildChar = wc;

i = i + 1;
p(i).propName = 'Parent';
p(i).printName = 'Parent';
p(i).isLink = 1;
p(i).evalString = 'junction.linkNode.parent';
p(i).valueRule = '';
p(i).printRule = ['sf(''get'',' wc ',''.name'')' ];
p(i).ignoreRule = '';
p(i).important = 0;
p(i).wildChar = wc;


i = i + 1;
p(i).propName = 'Source Transitions';
p(i).printName = 'Source Transitions';
p(i).isLink = 1;
p(i).evalString = 'junction.srcTransitions';
p(i).valueRule = '';
p(i).printRule = ['sf(''get'',' wc ',''.rgTag'')' ];
p(i).ignoreRule = '';
p(i).important = 0;
p(i).wildChar = wc;

i = i + 1;
p(i).propName = 'Dest Transitions';
p(i).printName = 'Dest Transitions';
p(i).isLink = 1;
p(i).evalString = 'junction.dstTransitions';
p(i).valueRule = '';
p(i).printRule = ['sf(''get'',' wc ',''.rgTag'')' ];
p(i).ignoreRule = '';
p(i).important = 0;
p(i).wildChar = wc;



rptgenSF.propTable( rgsf( 'type2num', 'junction' ) + 1 ).prop = p;
clear p;

% define the image for this type of object
image.imagePresent = 0;
image.imageSize = [0 0];
image.dynamicSize = 1;
rptgenSF.propTable( rgsf( 'type2num', 'junction' ) + 1 ).image = image;
clear image;


% define preset tables here
i = 0;
i = i + 1;
preset(i).names = {
		'%<Name>';
};
preset(i).description = 'Junction Header';
preset(i).title = '';
preset(i).colWid = [1];
preset(i).render = 'P v';
preset(i).align = 'j';
preset(i).border = logical(1);
preset(i).SingleValueMode = logical(1);

i = i + 1;
preset(i).names = {
		'%<Parent>';
		'%<Label>';
		'%<Description>';
		'%<Document>';
		'%<Chart>';
		'%<Source Transitions>';
		'%<Dest Transitions>' ...
};
preset(i).description = 'Junction';
preset(i).title = '';
preset(i).colWid = [1];
preset(i).render = 'P v';
preset(i).align = 'l';
preset(i).border = logical(0);
preset(i).SingleValueMode = logical(1);


rptgenSF.propTable( rgsf( 'type2num', 'junction' ) + 1 ).preset = preset;
clear preset;



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% set reportable properties for the data
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
i = 0;

i = i + 1;
p(i).propName = 'Name';
p(i).printName = 'Data';
p(i).isLink = 0;
p(i).evalString = 'data.name';
p(i).valueRule = '';
p(i).printRule = '';
p(i).ignoreRule = '';
p(i).important = 1;
p(i).wildChar = wc;

i = i + 1;
p(i).propName = 'FullPath+Name';
p(i).printName = 'Data';
p(i).isLink = 0;
p(i).evalString = 'data.id';
p(i).valueRule = '';
p(i).printRule = ['sf(''FullNameOf'',' wc ',''/'')' ];
p(i).ignoreRule = '';
p(i).important = 1;
p(i).wildChar = wc;

i = i + 1;
p(i).propName = 'SFPath+Name';
p(i).printName = 'Data';
p(i).isLink = 0;
p(i).evalString = 'data.id';
p(i).valueRule = '';
p(i).printRule = ['rgsf(''get_sf_full_name'',' wc ',''/'', '''')' ];
p(i).ignoreRule = '';
p(i).important = 1;
p(i).wildChar = wc;

i = i + 1;
p(i).propName = 'Description';
p(i).printName = 'Description';
p(i).isLink = 0;
p(i).evalString = 'data.description';
p(i).valueRule = '';
p(i).printRule = '';
p(i).ignoreRule = '';
p(i).important = 1;
p(i).wildChar = wc;

i = i + 1;
p(i).propName = 'Parent';
p(i).printName = 'Parent';
p(i).isLink = 1;
p(i).evalString = 'data.linkNode.parent';
p(i).valueRule = '';
p(i).printRule = ['sf(''get'',' wc ',''.name'')' ];
p(i).ignoreRule = '';
p(i).important = 0;
p(i).wildChar = wc;

i = i + 1;
p(i).propName = 'Scope';
p(i).printName = 'Scope';
p(i).isLink = 0;
p(i).evalString = 'data.id';
p(i).valueRule = '';
p(i).printRule = ['rgsf( ''get_data_scope'', ' wc ')'];
p(i).ignoreRule = '';
p(i).important = 1;
p(i).wildChar = wc;

i = i + 1;
p(i).propName = 'Machine';
p(i).printName = 'Machine';
p(i).isLink = 1;
p(i).evalString = 'data.machine';
p(i).valueRule = '';
p(i).printRule = ['sf(''get'',' wc ',''.name'')' ];
p(i).ignoreRule = '';
p(i).important = 0;
p(i).wildChar = wc;

i = i + 1;
p(i).propName = 'Data Type';
p(i).printName = 'Data Type';
p(i).isLink = 0;
p(i).evalString = 'data.id';
p(i).valueRule = '';
p(i).printRule = ['rgsf( ''get_data_type'', ' wc ')'];
p(i).ignoreRule = '';
p(i).important = 0;
p(i).wildChar = wc;

i = i + 1;
p(i).propName = 'Units';
p(i).printName = 'Units';
p(i).isLink = 0;
p(i).evalString = 'data.units';
p(i).valueRule = '';
p(i).printRule = '';
p(i).ignoreRule = '';
p(i).important = 0;
p(i).wildChar = wc;

i = i + 1;
p(i).propName = 'Range';
p(i).printName = 'Range';
p(i).isLink = 0;
p(i).evalString = 'data.id';
p(i).valueRule = '';
p(i).printRule = [ '[sf(''get'',' wc ',''.props.range.minimum'') ''...''  sf(''get'',' wc ',''.props.range.maximum'')]' ];
p(i).ignoreRule = ['sf (''get'',' wc ', ''.parsedInfo.range.minimum'') == -inf & sf (''get'',' wc ', ''.parsedInfo.range.maximum'') == inf'];
p(i).important = 0;
p(i).wildChar = wc;

i = i + 1;
p(i).propName = 'Init Value';
p(i).printName = 'Init Value';
p(i).isLink = 0;
p(i).evalString = 'data.id';
p(i).valueRule = '';
p(i).printRule = [ 'sf( ''get'',' wc ',''.props.initialValue'')' ];
p(i).ignoreRule = [ 'sf(''get'',' wc ',''.parsedInfo.initialValue'') == 0' ];
p(i).important = 0;
p(i).wildChar = wc;

i = i + 1;
p(i).propName = 'Document';
p(i).printName = 'Document';
p(i).isLink = 0;
p(i).evalString = 'data.id';
p(i).valueRule = '';
p(i).printRule = ['sf(''get'',' wc ',''.document'')' ];
p(i).ignoreRule = '';
p(i).important = 1;
p(i).wildChar = wc;


rptgenSF.propTable( rgsf( 'type2num', 'data' ) + 1 ).prop = p;
clear p;

% define the image for this type of object
image.imagePresent = 0;
image.imageSize = [0 0];
image.dynamicSize = 1;
rptgenSF.propTable( rgsf( 'type2num', 'data' ) + 1 ).image = image;
clear image;

% define preset tables here
i = 0;
i = i + 1;
preset(i).names = {
		'%<Name>';
};
preset(i).description = 'Data Header';
preset(i).title = '';
preset(i).colWid = [1];
preset(i).render = 'P v';
preset(i).align = 'j';
preset(i).border = logical(1);
preset(i).SingleValueMode = logical(1);

i = i + 1;
preset(i).names = {
		'%<Parent>';
		'%<Description>';
		'%<Document>';
		'%<Scope>';
		'%<Data Type>';
		'%<Units>';
		'%<Range>';
		'%<Init Value>'...
};
preset(i).description = 'Data';
preset(i).title = '';
preset(i).colWid = [1];
preset(i).render = 'P v';
preset(i).align = 'l';
preset(i).border = logical(0);
preset(i).SingleValueMode = logical(1);



rptgenSF.propTable( rgsf( 'type2num', 'data' ) + 1 ).preset = preset;
clear preset;


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% set reportable properties for the event
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
i = 0;

i = i + 1;
p(i).propName = 'Name';
p(i).printName = 'Event';
p(i).isLink = 0;
p(i).evalString = 'event.name';
p(i).valueRule = '';
p(i).printRule = '';
p(i).ignoreRule = '';
p(i).important = 1;
p(i).wildChar = wc;

i = i + 1;
p(i).propName = 'FullPath+Name';
p(i).printName = 'Event';
p(i).isLink = 0;
p(i).evalString = 'event.id';
p(i).valueRule = '';
p(i).printRule = ['sf(''FullNameOf'',' wc ',''/'')' ];
p(i).ignoreRule = '';
p(i).important = 1;
p(i).wildChar = wc;

i = i + 1;
p(i).propName = 'SFPath+Name';
p(i).printName = 'Event';
p(i).isLink = 0;
p(i).evalString = 'event.id';
p(i).valueRule = '';
p(i).printRule = ['rgsf(''get_sf_full_name'',' wc ',''/'', '''')' ];
p(i).ignoreRule = '';
p(i).important = 1;
p(i).wildChar = wc;

i = i + 1;
p(i).propName = 'Description';
p(i).printName = 'Description';
p(i).isLink = 0;
p(i).evalString = 'event.description';
p(i).valueRule = '';
p(i).printRule = '';
p(i).ignoreRule = '';
p(i).important = 1;
p(i).wildChar = wc;

i = i + 1;
p(i).propName = 'Parent';
p(i).printName = 'Parent';
p(i).isLink = 1;
p(i).evalString = 'event.linkNode.parent';
p(i).valueRule = '';
p(i).printRule = ['sf(''get'',' wc ',''.name'')' ];
p(i).ignoreRule = '';
p(i).important = 0;
p(i).wildChar = wc;

i = i + 1;
p(i).propName = 'Scope';
p(i).printName = 'Scope';
p(i).isLink = 0;
p(i).evalString = 'event.id';
p(i).valueRule = '';
p(i).printRule = ['rgsf( ''get_event_scope'', ' wc ')'];
p(i).ignoreRule = '';
p(i).important = 0;
p(i).wildChar = wc;


i = i + 1;
p(i).propName = 'Document';
p(i).printName = 'Document';
p(i).isLink = 0;
p(i).evalString = 'event.id';
p(i).valueRule = '';
p(i).printRule = ['sf(''get'',' wc ',''.document'')' ];
p(i).ignoreRule = '';
p(i).important = 1;
p(i).wildChar = wc;


i = i + 1;
p(i).propName = 'Machine';
p(i).printName = 'Machine';
p(i).isLink = 1;
p(i).evalString = 'event.machine';
p(i).valueRule = '';
p(i).printRule = ['sf(''get'',' wc ',''.name'')' ];
p(i).ignoreRule = '';
p(i).important = 0;
p(i).wildChar = wc;

i = i + 1;
p(i).propName = 'Trigger';
p(i).printName = 'Trigger';
p(i).isLink = 0;
p(i).evalString = 'event.id';
p(i).valueRule = '';
p(i).printRule = ['rgsf( ''get_event_trigger'', ' wc ')'];
p(i).ignoreRule = '';
p(i).important = 0;
p(i).wildChar = wc;


rptgenSF.propTable( rgsf( 'type2num', 'event' ) + 1 ).prop = p;
clear p;

% define the image for this type of object
image.imagePresent = 0;
image.imageSize = [0 0];
image.dynamicSize = 1;
rptgenSF.propTable( rgsf( 'type2num', 'event' ) + 1 ).image = image;
clear image;

% define preset tables here
i = 0;
i = i + 1;
preset(i).names = {
		'%<Name>';
};
preset(i).description = 'Event Header';
preset(i).title = '';
preset(i).colWid = [1];
preset(i).render = 'P v';
preset(i).align = 'j';
preset(i).border = logical(1);
preset(i).SingleValueMode = logical(1);

i = i + 1;
preset(i).names = {
		'%<Parent>';
		'%<Description>';
		'%<Document>';
		'%<Scope>';
		'%<Trigger>'...
};
preset(i).description = 'Event';
preset(i).title = '';
preset(i).colWid = [1];
preset(i).render = 'P v';
preset(i).align = 'l';
preset(i).border = logical(0);
preset(i).SingleValueMode = logical(1);


rptgenSF.propTable( rgsf( 'type2num', 'event' ) + 1 ).preset = preset;
clear preset;



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% set reportable properties for the instance
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
i = 0;

i = i + 1;
p = [];

p(i).propName = 'Name';
p(i).printName = 'Instance';
p(i).isLink = 0;
p(i).evalString = 'instance.name';
p(i).valueRule = '';
p(i).printRule = '';
p(i).ignoreRule = '';
p(i).important = 1;
p(i).wildChar = wc;
i = i+1;

p(i).propName = 'FullPath+Name';
p(i).printName = 'Instance';
p(i).isLink = 0;
p(i).evalString = 'instance.simulinkBlock';
p(i).valueRule = '';
p(i).printRule = ['getfullname(' wc ')' ];
p(i).ignoreRule = '';
p(i).important = 1;
p(i).wildChar = wc;
i = i+1;

i = i + 1;
p(i).propName = 'SFPath+Name';
p(i).printName = 'Instance';
p(i).isLink = 0;
p(i).evalString = 'instance.id';
p(i).valueRule = '';
p(i).printRule = ['rgsf(''get_sf_full_name'',' wc ',''/'', '''')' ];
p(i).ignoreRule = '';
p(i).important = 1;
p(i).wildChar = wc;

p(i).propName = 'Machine';
p(i).printName = 'Machine';
p(i).isLink = 1;
p(i).evalString = 'instance.machine';
p(i).valueRule = '';
p(i).printRule = '';
p(i).ignoreRule = '';
p(i).important = 0;
p(i).wildChar = wc;
i = i+1;

p(i).propName = 'Chart';
p(i).printName = 'Chart';
p(i).isLink = 1;
p(i).evalString = 'instance.chart';
p(i).valueRule = '';
p(i).printRule = '';
p(i).ignoreRule = '';
p(i).important = 0;
p(i).wildChar = wc;
i = i+1;

rptgenSF.propTable( rgsf( 'type2num', 'instance' ) + 1 ).prop = p;
clear p;

% define the image for this type of object
image.imagePresent = 0;
image.imageSize = [0 0];
image.dynamicSize = 1;
rptgenSF.propTable( rgsf( 'type2num', 'instance' ) + 1 ).image = image;
clear image;

% define preset tables here
i = 0;
i = i + 1;
preset(i).names = {
		'%<Path+Name>';
};
preset(i).description = 'Instance Header';
preset(i).title = '';
preset(i).colWid = [1];
preset(i).render = 'P v';
preset(i).align = 'j';
preset(i).border = logical(1);
preset(i).SingleValueMode = logical(1);

rptgenSF.propTable( rgsf( 'type2num', 'instance' ) + 1 ).preset = preset;
clear preset;


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% set reportable properties for the index
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
i = 0;

i = i + 1;
p = [];

rptgenSF.propTable( rgsf( 'type2num', 'index' ) + 1 ).prop = p;
clear p;

% define the image for this type of object
image.imagePresent = 0;
image.imageSize = [0 0];
image.dynamicSize = 1;
rptgenSF.propTable( rgsf( 'type2num', 'index' ) + 1 ).image = image;
clear image;

% define preset tables here
i = 0;
i = i + 1;
preset(i).names = {
		'%<Name>';
};
preset(i).description = 'Index Header';
preset(i).title = '';
preset(i).colWid = [1];
preset(i).render = 'P v';
preset(i).align = 'j';
preset(i).border = logical(1);
preset(i).SingleValueMode = logical(1);

rptgenSF.propTable( rgsf( 'type2num', 'index' ) + 1 ).preset = preset;
clear preset;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% set reportable properties for the note
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
i = 0;

i = i + 1;
p(i).propName = 'Name';
p(i).printName = 'Note';
p(i).isLink = 0;
p(i).evalString = 'state.id';
p(i).valueRule = '';
p(i).printRule = ['sf(''get'',' wc ',''.rgTag'')' ];
p(i).ignoreRule = '';
p(i).important = 0;
p(i).wildChar = wc;


i = i + 1;
p(i).propName = 'FullPath+Name';
p(i).printName = 'Note';
p(i).isLink = 0;
p(i).evalString = 'state.id';
p(i).valueRule = '';
p(i).printRule = [ '[ sf(''FullNameOf'', sf(''ParentOf'',' wc '), ''/''), ''/'', sf(''get'',' wc ',''.rgTag'') ]' ];
p(i).ignoreRule = '';
p(i).important = 0;
p(i).wildChar = wc;

i = i + 1;
p(i).propName = 'SFPath+Name';
p(i).printName = 'Note';
p(i).isLink = 0;
p(i).evalString = 'state.id';
p(i).valueRule = '';
p(i).printRule = ['rgsf(''get_sf_full_name'',' wc ',''/'', sf(''get'',' wc ',''.rgTag'') )' ];
p(i).ignoreRule = '';
p(i).important = 1;
p(i).wildChar = wc;

i = i + 1;
p(i).propName = 'Label';
p(i).printName = 'Label';
p(i).isLink = 0;
p(i).evalString = 'state.id';
p(i).valueRule = '';
p(i).printRule = ['sf(''get'',' wc ',''.labelString'')' ];
p(i).ignoreRule = '';
p(i).important = 0;
p(i).wildChar = wc;

i = i + 1;
p(i).propName = 'Parent';
p(i).printName = 'Parent';
p(i).isLink = 1;
p(i).evalString = 'state.treeNode.parent';
p(i).valueRule = '';
p(i).printRule = ['sf(''get'',' wc ',''.name'')' ];
p(i).ignoreRule = '';
p(i).important = 0;
p(i).wildChar = wc;

i = i + 1;
p(i).propName = 'Description';
p(i).printName = 'Description';
p(i).isLink = 0;
p(i).evalString = 'state.description';
p(i).valueRule = '';
p(i).printRule = '';
p(i).ignoreRule = '';
p(i).important = 1;
p(i).wildChar = wc;


%i = i + 1;
%p(i).propName = 'Image';
%p(i).printName = '';
%p(i).isLink = 0;
%p(i).evalString = '.id';
%p(i).valueRule = '';
%p(i).printRule = 'runsubcomponent( csf_snapshot, 0 )';
%p(i).ignoreRule = '';
%p(i).important = 0;
%p(i).wildChar = wc;

i = i + 1;
p(i).propName = 'Document';
p(i).printName = 'Document';
p(i).isLink = 0;
p(i).evalString = 'state.id';
p(i).valueRule = '';
p(i).printRule = ['sf(''get'',' wc ',''.document'')' ];
p(i).ignoreRule = '';
p(i).important = 1;
p(i).wildChar = wc;


rptgenSF.propTable( rgsf( 'type2num', 'note' ) + 1 ).prop = p;
clear p;

% define the image for this type of object
image.imagePresent = 1;
image.imageSize = [500 500];
image.dynamicSize = 0;
rptgenSF.propTable( rgsf( 'type2num', 'note' ) + 1 ).image = image;
clear image;

% define preset tables here
i = 0;
i = i + 1;
preset(i).names = {
		'%<Name>';
};
preset(i).description = 'Note Header';
preset(i).title = '';
preset(i).colWid = [1];
preset(i).render = 'P v';
preset(i).align = 'j';
preset(i).border = logical(1);
preset(i).SingleValueMode = logical(1);

i = i + 1;
preset(i).names = {
		'%<Label>'
		'%<Parent>'
		'%<Description>'
		'%<Document>'
};
preset(i).description = 'Note Body';
preset(i).title = '';
preset(i).colWid = [1];
preset(i).render = 'P v';
preset(i).align = 'l';
preset(i).border = logical(0);
preset(i).SingleValueMode = logical(1);

rptgenSF.propTable( rgsf( 'type2num', 'note' ) + 1 ).preset = preset;
clear preset;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% set reportable properties for the ? (nothing selected)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
i = 0;

i = i + 1;
p = [];

rptgenSF.propTable( rgsf( 'type2num', '?' ) + 1 ).prop = p;
clear p;

% define the image for this type of object
image.imagePresent = 0;
image.imageSize = [0 0];
image.dynamicSize = 1;
rptgenSF.propTable( rgsf( 'type2num', '?' ) + 1 ).image = image;
clear image;

rptgenSF.propTable( rgsf( 'type2num', 'index' ) + 1 ).preset = [];

rptgenSF.dataScopeTable = []; % defined as necessary
rptgenSF.eventScopeTable = [];%
rptgenSF.eventTriggerTable = [];


rptgenSF.sfportal=locPortal;

% clear all rgTags on charts
for i = 1:length(taggedTypes)
   eval( ['sf(''set'',''all'', ''',taggedTypes{i}, '.rgTag'','''')'] );
end

rptgenSF.initialized=logical(0);

out=rptgenSF;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function rgPortal=locPortal
%looks for the canonical Report Generator portal.
%if one does not exist, create it.

rgPortal=[];
rgTag='SF_RG_Portal';

try
    allPortals=sf('get','all','portal.id');
    if ~isempty(allPortals)
        i=1;
        while isempty(rgPortal) & i<=length(allPortals)
            if isappdata(sf('get',allPortals(i),'.figH'),rgTag)
                rgPortal=allPortals(i);
            else
                i=i+1;
            end
        end
    end
end

if isempty(rgPortal)
    rgPortal=sf('new','portal');
    rgPortalHandle=sf('get',rgPortal,'.figH');
    setappdata(rgPortalHandle,rgTag,logical(1));
end

