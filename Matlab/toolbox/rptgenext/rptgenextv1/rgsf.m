function varargout = rgsf( funCall, varargin )
%RGSF switch yard of commonly used functions in SF report generation

%   Copyright 1997-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2004/04/15 00:23:01 $



switch funCall
case 'type2num',
    varargout{1} = type2num( varargin{1} );
case 'num2type',
    varargout{1} = num2type( varargin{1} );
case 'whoami',
    varargout{1} = whoami( varargin{1} );
case 'get_states',
    varargout{1} = get_states( varargin{1} );
case 'get_functions',
    varargout{1} = get_functions( varargin{1} );
case 'get_groups',
    varargout{1} = get_groups( varargin{1} );
case 'get_trans_src_or_dest',
    varargout{1} = get_trans_src_or_dest( varargin{1} );
case 'assign_rg_tag',
    if nargin == 2,
        assign_rg_tag( varargin{1} );   
    elseif nargin == 3,
        assign_rg_tag( varargin{1}, varargin{2} );   
    end
case 'generate_all_ids',
    varargout{1} = generate_all_ids( varargin{1} );
case 'evaluate_object_property',
    varargout{1} = evaluate_object_property( varargin{1}, varargin{2} );
case 'get_property_cell',
    varargout{1} = get_property_cell( varargin{:} );
case 'get_property_list',
    varargout{1} = get_property_list( varargin{1} );
case 'get_filter_list',
    varargout{1} = get_filter_list;
case 'analyze_images',
    analyze_images( varargin{1} );
case 'get_data_scope',
    varargout{1} = get_data_scope( varargin{1} );
case 'get_event_scope',
    varargout{1} = get_event_scope( varargin{1} );
case 'get_event_trigger',
    varargout{1} = get_event_trigger( varargin{1} );
case 'get_data_type',
    varargout{1} = get_data_type( varargin{1} );
case 'get_sf_parent',
    varargout{1} = get_sf_parent( varargin{1} );
case 'get_slsf_parent',
    varargout{1} = get_slsf_parent( varargin{1} );
case 'get_sf_full_name',
    varargout{1} = get_sf_full_name( varargin{1},varargin{2},varargin{3} );
case 'get_parent_type',
    varargout{1} = get_parent_type( varargin{1} );
case 'get_parent_class',
    varargout{1} = get_parent_class( varargin{1} );
case 'get_sf_obj_name',
    varargout{1} = get_sf_obj_name( varargin{1} );
case 'can_have_children',
    varargout{1} = can_have_children( varargin{1} );
case 'can_have_picture',
    varargout{1} = can_have_picture( varargin{1} );
case 'is_parent_valid',
    if nargout == 1,
        varargout{1} = is_parent_valid( varargin{1} );
    else
        [varargout{1}, varargout{2}] = is_parent_valid( varargin{1} );
    end
otherwise
    error( sprintf('Unknown command: %s', funCall ));
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function res = type2num( type )

rptgenSF = zsfmethods;
typeTable = rptgenSF.typeTable;
for i = 1:length(typeTable)
    if strcmp( type, typeTable{i} )
        res = i-1;
        return;
    end
end
res = NaN;
%error( sprintf('type2num: unknown type: %s', type) );




%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function res = num2type( num )

rptgenSF = zsfmethods;
if num < 0 | num > length(rptgenSF.typeTable) - 1
    error( 'num2type: number is too large' );
end
res = rptgenSF.typeTable{ num + 1};



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function res = whoami( id )
% the function returns numeric value of the type of the
% object which id was passed
%
if id == 0
    res = 0;
    return;
end

res = sf( 'get', id, '.isa' );

if res ~= type2num('state')
    return;
else
    type = sf( 'get', id, '.type' );
    rptgenSF = zsfmethods;
    %if sf('get',id,'.superState') == 2 %2==SUBCHART
    %    res = type2num('subchart');
    if type == rptgenSF.stateTypes.sfGroupStateType
        if (sf('get',id,'.isNoteBox'))
            res = type2num('note');
        else
            res = type2num( 'box' );
        end
    elseif type == rptgenSF.stateTypes.sfFunctionStateType
        res = type2num('function');
    else % has to be a normal state 
        res = type2num('state');
    end
end



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function res = get_states( ids )
%  return the ids of 'real' states (not functions or groups)
states = sf( 'get', ids, 'state.id' );
rptgenSF = zsfmethods;
res = sf( 'find', states, '.type', rptgenSF.stateTypes.sfORStateStateType);
res = [res sf( 'find', states, '.type', rptgenSF.stateTypes.sfANDStateStateType)];


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function res = get_functions( ids )
%  return the ids of 'real' states (not functions or groups)
states = sf( 'get', ids, 'state.id' );
global sfFunctionStateType;
res = sf( 'find', states, '.type', sfFunctionStateType);


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function res = get_groups( ids )
%  return the ids of 'real' states (not functions or groups)
states = sf( 'get', ids, 'state.id' );
global sfGroupStateType;
res = sf( 'find', states, '.type', sfGroupStateType);

% this function returns the string that best describes the transition's
% source/destination (chooses between tag for junction or name for state)
function res = get_trans_src_or_dest( id )
type = whoami( id );
if isempty( type )
    res = [];
    return;
end

if type == type2num('junction'),
    res = sf('get', id, '.rgTag');
else 
    res = sf('get', id, '.name');
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function assign_rg_tag( id, varargin )
rptgenSF = zsfmethods; 
if isempty( sf('get', id, '.rgTag' ))
    if nargin == 2,
        me = varargin{1};
    else
        me = num2type( whoami( id ) );
    end
    % increment corresponding objCount
    eval( ['rptgenSF.objCount.' me '= rptgenSF.objCount.' me ' + 1;' ] );   
    % get the tag
    tag = eval( [ '[rptgenSF.objAbbr.' me ' rg_num2str( rptgenSF.objCount.' me ')]' ] );  
    sf( 'set', id, '.rgTag', tag );
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%  functions to compute the list of objects to be reported
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


function res = generate_all_ids( ids )
% the function takes the list of charts (assumed) and
% generates the list of all objects in the chart plus 
% the machine object and all the events, data and targets
% parented by that machine

% generate the list in hierarchical order and return
rptgenSF = zsfmethods; 
rptgenSF.temp.hierarchy = [];
rptgenSF.temp.dataList = [];
rptgenSF.temp.eventList = [];

res = compute_hierarchy( ids, 1 );

% and clear the fields
rptgenSF.temp.hierarchy = [];
rptgenSF.temp.dataList = [];
rptgenSF.temp.eventList = [];

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%  set the rg_tag to be obj_count followed by sf id. (unused fcn)
function idStr = create_rg_tag( objCount, sfId )

idStr = [rg_num2str(objCount), '_', rg_num2str(sf( 'get', sfId, '.id' )) ];



function hierarchy = compute_hierarchy( ids, level )
% ids are chart ids (assumed)
rptgenSF = zsfmethods;
machineIds = [];
for i = ids
    machine = sf( 'get', i, '.machine' );
    if sum( ismember( machineIds, machine ) ) == 0 
        machineIds = [machineIds machine];
        rptgenSF.temp.hierarchy( length( rptgenSF.temp.hierarchy(:) )/2 +1, 1:2 ) = ...
            [machine, level-1];
        assign_rg_tag( machine, 'machine' );
        targets = [sf( 'TargetsOf', machine) ];
        for j = 1:length( targets )
            rptgenSF.temp.hierarchy( length( rptgenSF.temp.hierarchy(:, 1) )+1, 1:2 ) = ...
                [targets(j), level];
            assign_rg_tag( targets(j), 'target' );   
        end
        put_events_and_data_in_the_hierarchy( machine, level );
    end
    put_in_the_hierarchy( i, level );  % pass chart id  
end

%now sort the events and data alphabetically
if ~isempty( rptgenSF.temp.eventList )
    eventNames = sf( 'get', rptgenSF.temp.eventList(:,1), '.name' );
    [sortedNames index] = sortrows( eventNames );
    rptgenSF.temp.hierarchy = [ rptgenSF.temp.hierarchy; rptgenSF.temp.eventList(index,:) ];
end
if ~isempty( rptgenSF.temp.dataList )
    dataNames = sf( 'get', rptgenSF.temp.dataList(:,1), '.name' );
    [sortedNames index] = sortrows( dataNames );
    rptgenSF.temp.hierarchy = [ rptgenSF.temp.hierarchy; rptgenSF.temp.dataList(index,:) ];
end

hierarchy = rptgenSF.temp.hierarchy;

% the function assumes chart or state ids only
function put_in_the_hierarchy( id, level )
rptgenSF = zsfmethods;

rptgenSF.temp.hierarchy( length( rptgenSF.temp.hierarchy(:,1) )+1, 1:2 ) = ...
    [sf( 'get', id, '.id' ), level]; 

% assign a tag to me, depending on who I am (chart, state, group or function)
% if I already dont have one
assign_rg_tag(id);
% recursively (depth first) print all the states
child = sf( 'get', id, '.treeNode.child' );
while child ~= 0
    put_in_the_hierarchy( child, level + 1 );
    child = sf( 'get', child, '.treeNode.next' );
end
% now print all the rest: junctions, transitions, data, events, 
junction = sf( 'get', id, '.firstJunction' );
while junction ~= 0
    rptgenSF.temp.hierarchy( length( rptgenSF.temp.hierarchy(:, 1) )+1, 1:2 ) = ...
        [junction, level+1];
    assign_rg_tag(junction, 'junction');
    junction = sf( 'get', junction, '.linkNode.next' );
end
transition = sf( 'get', id, '.firstTransition' );
while transition ~= 0
    rptgenSF.temp.hierarchy( length( rptgenSF.temp.hierarchy(:,1) )+1, 1:2 ) = ...
        [transition, level+1];
    assign_rg_tag(transition, 'transition');
    transition = sf( 'get', transition, '.linkNode.next' );
end
put_events_and_data_in_the_hierarchy( id, level+1);
rptgenSF.currentLoop.hierDepth = max( rptgenSF.currentLoop.hierDepth, level+1 );




%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function put_events_and_data_in_the_hierarchy( id, level )
rptgenSF = zsfmethods;

data = sf('get', id, '.firstData');
while data ~= 0
    rptgenSF.temp.dataList( length( rptgenSF.temp.dataList(:) )/2+1, 1:2 ) = [data, 0];
    assign_rg_tag(data, 'data');
    data = sf( 'get', data, '.linkNode.next' );
end

event = sf('get', id, '.firstEvent');
while event ~= 0
    rptgenSF.temp.eventList( length( rptgenSF.temp.eventList(:) )/2+1, 1:2 ) = [event, 0];
    assign_rg_tag(event, 'event');
    event = sf( 'get', event, '.linkNode.next' );
end



% quick way to do num2str
function res = rg_num2str( num )
res = '';
if ~isempty( num )
    if ceil( num ) ~= num
        res = sprintf( '%f', num );
    else
        res = sprintf( '%d', num );
    end
end



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function res = evaluate_object_property( att, c )

rptgenSF = zsfmethods;
if ~isstruct (c)
    % passed the object, so the currentobject is got from zsfmethods
    currentObject = rptgenSF.currentObject;
else
    currentObject = c;
end

res = [];
% set the variables
if ~isstruct( att )
    prop = rptgenSF.propTable( currentObject.type + 1 ).prop;
    for i = 1:length( prop )
        if strcmp( prop(i).propName, att )
            att = prop(i);
            break;
        end
    end
end
% Once we got here, att must be a structure, or else 
% we have an unknown property name
if ~isstruct( att )
    error( sprintf('Unknown %s property name: %s',currentObject.typeString ,att ));
end

sfName = att.evalString;
printName = att.printName;
valueRule = att.valueRule;
printRule = att.printRule;
important = att.important;
ignoreRule = att.ignoreRule;
isLink = att.isLink;
wildChar = att.wildChar;

value = sf( 'get', currentObject.id, sfName );

% apply the value rule if specified

if ~isempty( valueRule )
    value = eval( strrep( valueRule, wildChar, ['[' rg_num2str(value) ']'] ) );
end

% 2 cases: not a link, or a vector of links( may have length == 1, of course )
res.printName = printName;
res.printValue = {}; 
valueNotEmpty = 0;
if isLink == 0
    % single entry (not a link)
    if ~isempty( printRule )
        printValue = eval( strrep( printRule, wildChar,  ['[' rg_num2str(value ) ']'] ) );
    else 
        printValue = value;
    end
    res.printValue{1} = {printValue, ''};     
    if ~isempty( printValue )	valueNotEmpty = 1;	end    
else
    % link(s)
    for j = value
        if ~isempty( printRule )
            refPrint = eval( strrep( printRule, wildChar, rg_num2str(j) ) );
        else % default rule is the name of the link   
            refPrint = sf('get', j, '.name' );            
        end
        %if isempty( refPrint)
        %	refPrint = '?';
        %end
        
        len = length( res.printValue );
        ref = '';
        %if strcmp( res.printName, 'Charts' )
        %   1
        %end
        
        %if ismember( j, rptgenSF.reportList )
        ref = sf('get', j, '.rgTag');
        
        if isempty( ref )
            assign_rg_tag( j );
            ref = sf('get', j, '.rgTag');
        end 			
        %end
        res.printValue{ len + 1 } = { refPrint, ref };  
        if ~isempty( refPrint )	valueNotEmpty = 1;	end    
    end
end

if important == 1 & valueNotEmpty == 1
    hiddenContent = 1;
else
    hiddenContent = 0;
end

res.hiddenContent = hiddenContent;
res.valueNotEmpty = valueNotEmpty;

ignore = 0;		
if ~isempty (ignoreRule),
    % try applying the ignore rule
    ignore = eval( strrep( ignoreRule, wildChar, ['[' rg_num2str(value ) ']'] ) );
end
if ignore
    res = [];
end




%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function cellTxt = get_property_cell( curObjStruct, propname, c, setHiddenContent )

rptgenSF = zsfmethods;

cellTxt = [];
try
    cellContent = evaluate_object_property( propname, curObjStruct);
catch
    cellContent='N/A';
end

if isempty( cellContent ) | (ischar(cellContent) & strcmp(cellContent,'?'))
    cellTxt.name = '';
    cellTxt.value = '';
    return;
end

if ~cellContent.valueNotEmpty % value is empty
    cellTxt.name = {};
    cellTxt.value = {};
    return;
end

% cellContent is a structure with the fields printName, printValue and
% hiddenContent
if cellContent.hiddenContent & setHiddenContent
    rptgenSF.currentObject.hiddenContent = 1;
end
cellTxt.value={};
cellTxt.name = cellContent.printName;
linkComp = c.rptcomponent.comps.cfrlink;

for i = 1:length( cellContent.printValue );
    valueRefPair = cellContent.printValue{i};
    if ~isempty( valueRefPair{2} )
        linkComp.att.LinkType = 'Link';
        linkComp.att.LinkID = valueRefPair{2};
        linkComp.att.LinkText=valueRefPair{1};
        link=runcomponent(linkComp,0);
    else
        %if sum( valueRefPair{1} == 10 ) % exists a newline character
        %	textComp.att.Content = valueRefPair{1};
        %	textComp.att.isLiteral = 1;
        %   link=runcomponent(textComp,0);		
        %else
        link = valueRefPair{1};
        %end
    end
    
    cellTxt.value{ length( cellTxt.value )+1 } = link;
    
    %now that tables insert line breaks for cell arrays, don't need ', '
    %if i < length( cellContent.printValue )
    %	cellTxt.value{ length( cellTxt.value )+1 } = ', ';
    %end
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function propNames = get_property_list( filter )

rptgenSF = zsfmethods;
filter = lower(filter);
filterNum = type2num( filter );
props = rptgenSF.propTable( filterNum + 1 );
propNames = {};
for i = 1:length( props.prop )
    propNames{i} = props.prop(i).propName;
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function filters = get_filter_list
rptgenSF = zsfmethods;
filters = rptgenSF.typeTable;
reportable = rptgenSF.reportableObjectsIndex;
%remove extra entries
toRemove = [];
for i = 1:length( filters )
    if isempty( filters{i} ) ...
            | ~ismember( type2num( filters{i} ), reportable ),
        
        toRemove = [ toRemove, i ];
    end
end
filters(toRemove) = [];
%filters{ length( filters ) } = '?'


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function analyze_images( reportList )
% this function is a copy/paste/edit result of function 
% private/rg.generate_image_primitives
%
% Here we analyze the reportList's appearance on screen and
% save dependencies between objects ( such as font sizes, etc )
%
% Also it is planned to add image map capabilities, and part
% of the code of this function would contribute to that.
%
% original code is commented out (not deleted because most
% of it will be used for implementing image map capability

rptgenSF = zsfmethods;
legibleSize = rptgenSF.legibleSize;
%
% first get the information how to draw the picture from nice_shot.
%
drawInfo.data = [];
drawInfo.legibleIn = [];
drawInfo.numLegibleKids = zeros( 1, length( reportList ) );
drawInfo.context = zeros( 1, length( reportList ) );
drawInfo.map = sparse( 100000000, 1 );

sf( 'Private', 'nice_shot', 'initialize' );
global dData;

sf( 'Private', 'nice_shot', reportList, 'get_image_primitives', 'rptgen' );
% now dData contains all the info about drawing all objects
% save it into a file and maintain a structure containing the size info of objects

% Note that pics does NOT contain boxes and functions!
%
pics = dData.data;
for i = 1:length( pics )  % go through all the objects' descriptions
    pic = pics{i};
    % write the header for the definition
    id = pic{4};
    %fprintf( fid, ['/o' rg_num2str( id ) '{\n' ] ); 
    fontSize = Inf;
    for i = 1:length( pic{1} ) % go through all entries in an object's description
        cmd = pic{1}{i};
        type = cmd{1};
        switch type
        case 'text',
            % the x and y coordinates specify the upper left corner of the text
            x = cmd{2}(1);
            t = cmd{4};
            fs = cmd{3};	
            str = {};
            maxlength = 0;
            while ~isempty(t)
                [t1, t] = strtok( t, char(10) );
                str{length(str)+1} = t1;
                maxlength = max(maxlength, length( t1 ) );
            end
            if fs < 0 % no font size given. Set it.
                % determine the font size such that the text fits into the bounding rect
                w = cmd{2}(3);
                h = cmd{2}(4);
                fsw = w/maxlength / 0.65;
                fsh = h / length(str) / 1.2;
                fs = min( fsh, fsw );
            end
            y = -cmd{2}(2) - fs / 1.5;		% - (y pos of text + font size )
            %fprintf( fid,'%s\n',['cur1ptfont ' rg_num2str(fs) ' scalefont setfont' ] );
            %for j = 1:length(str)
            %	fprintf( fid, '%s\n', [rg_num2str(x) ' ' rg_num2str(y-fs*1.2*(j-1)) ' moveto'] );
            %	fprintf( fid,'%s\n',['(' ps_string(str{j}) ') show stroke ' ] );
            %end
            fontSize = min( fontSize, fs );
            
        case 'tag'
            %pos = cmd{2};
            %x = rg_num2str( pos(1) );
            %y = rg_num2str( -pos(2) );
            %fontSize = cmd{3};
            %t = ps_string( cmd{4} );
            %fprintf( fid, '%s\n', ['0.7 setgray ' x ' ' y ' moveto (' t ') show 0 setgray'] );
            
        case 'rrect',
            %rect = cmd{2};
            %x = rect(1);
            %y = -rect(2) - rect(4);
            %w = rect(3);
            %h = rect(4);
            %c = 0.18;
            
            %cx = 0.5*(max(w,h) *  c);
            %cx = 0.75*min(cx, min(w,h)/(3-c));
            %c = cx;
            
            %dash = cmd{3};
            %if dash ~= 0
            %	fprintf( fid, '%s\n', [ 'stroke [' rg_num2str( dash ) '] 0 setdash' ] );
            %end 
            %fprintf( fid, '%s\n', [ rg_num2str( x ) ' ' rg_num2str( y ) ' ' rg_num2str( w ) ' ' ...
            %		rg_num2str( h ) ' ' rg_num2str( c ) ' rrect' ] ); 
            %if dash ~= 0
            %	fprintf( fid, '%s\n', 'stroke [] 0 setdash' );
            %end
            
        case 'srect',
            %rect = cmd{2};
            %x = rect(1);
            %y = -rect(2) - rect(4);
            %w = rect(3);
            %h = rect(4);
            %c = min( w, h ) * 0.18;
            %fprintf( fid, '%s\n', [ rg_num2str( x ) ' ' rg_num2str( y ) ' ' rg_num2str( w ) ' ' ...
            %			rg_num2str( h ) ' rectstroke' ] ); 
            
        case 'circ',
            %c = cmd{2}; rad = cmd{3};
            %fprintf( fid, '%s\n', [rg_num2str( c(1) + rad ) ' ' rg_num2str(-c(2)) ...
            %	' moveto ' rg_num2str( c(1) ) ' ' rg_num2str( -c(2) ) ' ' ...
            %	rg_num2str( rad ) ' 0 360 arc' ] );
            
        case 'fcirc',
            %c = cmd{2}; rad = cmd{3};
            %fprintf( fid, '%s\n', ['stroke ' rg_num2str( c(1) + rad ) ' ' rg_num2str(-c(2)) ...
            %	' moveto ' rg_num2str( c(1) ) ' ' rg_num2str( -c(2) ) ' ' ...
            %	rg_num2str( rad ) ' 0 360 arc fill' ] );
            
        case 'spline',
            %dash = cmd{3};
            
            %if dash ~= 0
            %	fprintf( fid, '%s\n', [ 'stroke [' rg_num2str( dash ) '] 0 setdash' ] );
            %end
            
            %vec = cmd{2};
            %for j = 1:length(vec)
            %	fprintf( fid, '%s', [rg_num2str( vec(j) ) ' '] );
            %end
            %fprintf( fid, 'trans\n' );
            
            %if dash ~= 0
            %	fprintf( fid, '%s\n', 'stroke [] 0 setdash' );
            %end
            
        otherwise,
            error( [ 'Unknown draw command: ' cmd ] );
        end % switch
    end % for go through all entries in an object's description
    %fprintf( fid, '} def\n' );
    % put the fontSize and the list of objects I depend on into the drawInfo
    
    % define the scale factor for the image of this object depending on
    % the font sizes
    type = whoami( id );
    defStruct = rptgenSF.propTable( type + 1 );
    imageDescription = defStruct.image;
    dynamicSize = imageDescription.dynamicSize;
    viewRec = pic{3}; w = 0; h = 0; scale = 0;
    newFS = fontSize;
    maxScale = 0;
    if imageDescription.imagePresent
        
        w = imageDescription.imageSize(1);
        h = imageDescription.imageSize(2);
        xScale = w / max(viewRec(3),1);
        yScale = h / max(viewRec(4),1);
        maxScale = min( xScale, yScale );
        newFS  = fontSize * maxScale;
        if newFS > legibleSize & newFS ~= Inf & dynamicSize == 1
            scale = maxScale * legibleSize / newFS;
        else
            newFS = fontSize;
            scale = maxScale;
        end
    end
    pointRec = pic{5};
    parent = pic{6};
    drawInfo.data{ length( drawInfo.data ) + 1 } = ...
        {[id pic{2}], scale, viewRec, pointRec, parent, newFS, fontSize, maxScale };
    drawInfo.legibleIn(length(drawInfo.legibleIn)+1) = id;
    drawInfo.map(id) = length( drawInfo.data );
end % for go through all the objects' descriptions

imScale = zeros(1, length( drawInfo.data ) );
SFfSize = imScale;

for i = 1:length(drawInfo.data)
    child = drawInfo.data{i};
    SFfSize(i) = child{7};
    imScale(i) = child{2};
end
for i = 1:length(drawInfo.data)
    obj = drawInfo.data{i};
    children = obj{1};
    id = children(1);
    myType = sf( 'get', id, '.isa' );
    
    children = intersect( children, sf( 'ObjectsIn', id ) );
    if ~isempty(children)  % scale is not max => potentially makes sense to increase to draw children legibly
        childrenFS = SFfSize(drawInfo.map(children))*imScale(i);
        minFS = min( childrenFS );
        if minFS < legibleSize
            moreScale = min(legibleSize / minFS);
            scale = min( obj{8}, imScale(i) * moreScale );
            imScale(i) = scale;
            drawInfo.data{i}{2} = scale;
        end
        % let's see who of the children became legible at this object's picture
        legibleNow = children(SFfSize(drawInfo.map(children))*imScale(i) >= legibleSize - 0.05);
        prevLegibleParents = drawInfo.legibleIn( drawInfo.map( legibleNow  ) );
        kidsToFix = intersect( children, prevLegibleParents );
        fixedKids = intersect( legibleNow, kidsToFix );
        % set their legibleIn value
        drawInfo.legibleIn( drawInfo.map( fixedKids  ) ) = id;
        %remember how many kids I make legible
        drawInfo.numLegibleKids( i ) = length( fixedKids );
        drawInfo.legibleKids{ i } = fixedKids;		
        % fixedKids are not really fixed by this object.  Some of them may have fontSize = Inf (no text)
        % which means they should not appear in the list of object i claim I have fixed.
        if ~isempty( fixedKids )
            fixedKids( SFfSize(drawInfo.map(fixedKids)) == Inf	) = [];
            drawInfo.myFixedKids{i} = fixedKids;
        else
            drawInfo.myFixedKids{i} = [];
        end
    else
        drawInfo.legibleKids{ i } = [];
    end
end %for i = 1:length(drawInfo.data)
%set the indicator (pointer) information
for i = 1:length(drawInfo.data)
    obj = drawInfo.data{i};
    children = obj{1};
    id = children(1);
    myType = sf( 'get', id, '.isa' );
    children = intersect( children, sf( 'ObjectsIn', id ) );
    pointers = {};
    
    %Somewhere along the way, functions and boxes are not showing up as valid
    %pointedTo objects.  They are definitely in the "children" list, but are not making
    %the cut in the IF statement.  Aargh.
    for j = 1:length(children)
        if rptgenSF.pointedTo( whoami( children(j) ) + 1 ) == 1,
            parent = drawInfo.data{drawInfo.map( children(j) )}{5};
            while isempty( find( reportList == parent ) )
                parent = drawInfo.data{drawInfo.map( parent )}{5};
            end
            drawInfo.context( drawInfo.map( children(j) ) ) = parent;
            myFixedKids = drawInfo.myFixedKids{ drawInfo.map( id ) };
            
            if ( ~isempty( find( reportList == children(j) ) )) & ...
                    ( parent ==  id | ...
                    (length( myFixedKids ) > 0 & ~isempty( find( myFixedKids == children(j) ) ) ) ...
                    ) & SFfSize( drawInfo.map( children(j) ) ) < Inf
                pointRec = drawInfo.data{drawInfo.map( children(j) )}{4};
                pointers{ length( pointers ) + 1 } = { children(j), pointRec };
                drawInfo.context( drawInfo.map( children(j) ) ) = parent;
            end
        end % if
    end % for
    drawInfo.pointers{ drawInfo.map( id ) } = pointers;
end %for i = 1:length(drawInfo.data)
rptgenSF.currentLoop.drawInfo = drawInfo;
% now we can free the dData variable
clear global dData;




%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function res = isLabelLegible( id )
rptgenSF = zsfmethods;
drawInfo = rptgenSF.currentLoop.drawInfo;
legibleSize = rptgenSF.legibleSize;

d  = drawInfo.data{ drawInfo.map( id ) };
scale = d{2};
SFFontSize = d{7};
res = scale * SFFontSize >= legibleSize - 0.05;


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function res = get_data_scope( id )
rptgenSF = zsfmethods;
if isempty( rptgenSF.dataScopeTable )
    % construct the table
    [prop,scopes]=sf('subproperty','data.scope');
    for i=1:length(scopes{1})
        pos = find( scopes{1}{i} == '_' );
        scopes{1}{i} = scopes{1}{i}(1:pos(1)-1);
    end
    rptgenSF.dataScopeTable = scopes{1};
end
res = rptgenSF.dataScopeTable{ sf( 'get', id, '.scope' ) + 1 };

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function res = get_event_scope( id )
rptgenSF = zsfmethods;
if isempty( rptgenSF.eventScopeTable )
    % construct the table
    [prop,scopes]=sf('subproperty','event.scope');
    for i=1:length(scopes{1})
        pos = find( scopes{1}{i} == '_' );
        scopes{1}{i} = scopes{1}{i}(1:pos(1)-1);
    end
    rptgenSF.eventScopeTable = scopes{1};
end
res = rptgenSF.eventScopeTable{ sf( 'get', id, '.scope' ) + 1 };

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function res = get_event_trigger( id )
rptgenSF = zsfmethods;
if isempty( rptgenSF.eventTriggerTable )
    % construct the table
    [prop,scopes]=sf('subproperty','event.trigger');
    for i=1:length(scopes{1})
        pos = find( scopes{1}{i} == '_' );
        scopes{1}{i} = scopes{1}{i}(1:pos(2)-1);
    end
    rptgenSF.eventTriggerTable = scopes{1};
end
res = rptgenSF.eventTriggerTable{ sf( 'get', id, '.trigger' ) + 1 };



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function res = get_data_type( id )
res = sf( 'get', id, '.dataType' );
if isempty( res )
    res = 'Real(double)';
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function parent = get_sf_parent( comp );
[parentClass, parent] = getparentloop( comp, {'csf',''} );




%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function parent = get_slsf_parent( comp );
[parentClass, parent] = getparentloop( comp, ...
    {'csf',          ''; ...
        'csl_mdl_loop', ''; ...
        'csl_blk_loop', ''; ...
        'csl_sys_loop', ''; ...
        'csl_sig_loop', '' });


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function parentType = get_parent_type( comp )
parent = get_sf_parent(comp);
parentType = '';
parentClass = parent.comp.Class;
if strcmp( parentClass, 'csf_obj_report' )
    parentType = capitalize1( parent.att.typeString);
elseif strcmp( parentClass, 'csf_hier_loop' )
    parentType = 'Object';
elseif strcmp( parentClass, 'csf_chart_loop' )
    parentType = 'Chart';
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function parentClass = get_parent_class( comp )
parent = get_sf_parent(comp);
parentType = '';
parentClass = parent.comp.Class;


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function str = get_sf_obj_name( id )

myType = whoami( id );
if myType == type2num( 'transition' ) | ...
        myType == type2num( 'junction' ) | ...
        myType == type2num( 'note' )
    str = [sf( 'get', id, '.rgTag' )];
else
    str = sf( 'get', id, '.name' );
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function res = can_have_children( typeString )
rptgenSF = zsfmethods;
res = rptgenSF.canHaveChildren( type2num( typeString ) + 1);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function res = can_have_picture( typeString )
rptgenSF = zsfmethods;
res = rptgenSF.propTable(type2num( typeString)+1).image.imagePresent;



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [res, varargout] = is_parent_valid( c )

% c here is one of the stateflow components

n = nargout;
if n == 2
    varargout{1} = '';
end
% first, get the parent type
myClass = c.comp.Class;

slParentCompClass = getparentloop(c);
[sfParentCompClass, sfParentComp] = getparentloop(c, {'csf',''});
slsfParentComp = get_slsf_parent( c );
if ~isempty( slsfParentComp )
    slsfParentCompClass = slsfParentComp.comp.Class;
else
    slsfParentCompClass = '';
end

% Now see id my parent class is what i expected
res = 0;
switch myClass,
case 'csf_hier_loop',
    if n==2,
        varargout{1} = 'expects Chart Loop or Simulink Model, System, Signal or Block loop component as parent.';
    end
    switch slsfParentCompClass,
    case {'csl_mdl_loop', 'csl_sys_loop', 'csl_blk_loop', 'csl_sig_loop', 'csf_chart_loop' }
        res = 1;
        if n == 2, 	varargout{1} = ''; end
    end
case 'csf_chart_loop',
    % may be parented by anything but sf loop or chart loop
    if n==2,
        varargout{1} = 'cannot be parented by Stateflow looping components.';
    end
    % user should never be able to put chart Loop as a child of summ_table.
    % however, Karl does that temporarily for summ_table processing.
    % thus, we should ignore that summ_table parent.  
    if isempty( sfParentCompClass ) | strcmp( sfParentCompClass, 'csf_summ_table' ),
        res = 1;
    end
case 'csf_summ_table',
    if n==2,
        varargout{1} = 'cannot be parented by Stateflow components except Chart Loop.';
    end
    if isempty( sfParentCompClass ) | strcmp( sfParentCompClass, 'csf_chart_loop' )
        res = 1;
        if n == 2, 	varargout{1} = '';
        end
    end
case 'csf_snapshot',
    if n==2,
        varargout{1} = 'expects Stateflow Object (with graphical representation) Report component as parent.';
    end
    if strcmp( sfParentCompClass, 'csf_obj_report' ) & ...
            can_have_picture( sfParentComp.att.typeString )
        res = 1;
        if n == 2, 	varargout{1} = ''; end
    end
case 'csf_obj_report',
    if n == 2,
        varargout{1} = 'expects Stateflow Loop component as parent.';
    end
    if strcmp( sfParentCompClass, 'csf_hier_loop' )
        res = 1;
        if n == 2, 	varargout{1} = ''; end
    end
case 'csf_prop_table',
    if n == 2,
        varargout{1} = 'expects Stateflow Object Report component as parent.';
    end
    if strcmp( sfParentCompClass, 'csf_obj_report' )
        res = 1;
        if n == 2, 	varargout{1} = ''; end
    end
case {'csfobjname','csflinktarget'}
    if n == 2,
        varargout{1} = 'expects Object Report, Chart Loop or Stateflow Loop component as parent.';
    end
    if strcmp( sfParentCompClass, 'csf_obj_report' ) | ... 
            strcmp( sfParentCompClass, 'csf_hier_loop' ) | ... 
            strcmp( sfParentCompClass, 'csf_chart_loop' )
        res = 1;
        if n == 2, 	varargout{1} = ''; end
    end
end		
if n == 2 & isempty( varargout{1} )
    varargout{1} = 'this component has a valid parent'; 
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function str = get_sf_full_name( id, pathSep, overrideName )
if ~isempty( overrideName )
    path = sf('Private', 'get_stateflow_path_to_parent', id, pathSep );
    str = [path, pathSep, overrideName ];
else
    [path, name] = sf('Private', 'get_stateflow_path_to_parent', id, pathSep );
    str = [ path pathSep name ];
end
if isempty(path) & length(pathSep) == 1
    % get rid of leading pathSep
    str(1) = [];
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function str = capitalize1( str )
if ~isempty(str)
    str(1) = upper( str(1) );
end
