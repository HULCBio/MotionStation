function [isSFError, sfIds, sfBlockPath, errType, strippedMsg, errorMsg, openFcn,relevantSlHandle,hyperlinkSlHandle] = parse_error_msg( origStr , blkHandle)
%[SFIDS,SFBLOCKPATH,ERRORTYPE,STRIPPEDMSG,ERRORMSG,OPENFCN] = PARSE_ERROR_MSG(RAWERRORSTR,BLKHANDLE)
%Parses an error message and figures out relavant information if it is constructed by
%construct_error() function. Note that blkHandle input is used only if this is not a SF generated error message
%and it is relevant to an SF chart (i.e., unresolved chart workspace data)
%

%   Vladimir Kolesnikov
%  Copyright 1995-2004 The MathWorks, Inc.
%  $Revision: 1.19.2.6 $  $Date: 2004/04/15 00:58:57 $

% All SF error msgs constructed by construct_error() will have the following format:
% Stateflow <errType> Error (#<id>): <error message>
% sfIds set to 0 notifies an error (non-SF error msg).
% Empty sfIds means that no SF id is connected with the error msg

rawStr = clean_error_msg( origStr );
isSFError = 0;
sfIds = 0;
sfBlockPath = '';
errType = '';
strippedMsg = '';
errorMsg = rawStr;
openFcn = '';
relevantSlHandle = [];
hyperlinkSlHandle = [];
isEml = 0;
chartId = [];

%set defaults for non-sf error msg

%%%

% see if the error msg looks like SF error
% this used to get rid of whatever crap prepends real sf error msg (such as SL message)
[isSfError,isSfWarning,rawStr] = check_if_sf_generated(rawStr);
if(~isSfError & ~isSfWarning)
    [isSfError, isSfWarning, rawStr,hyperlinkSlHandle,isEml,chartId] = preprocess_sl_error(rawStr,blkHandle);
end
if(~isSfError & ~isSfWarning)
    return;
end

% first word must be 'Stateflow'
[token, rawStr] = strtok( rawStr );
if strcmpi( token, 'embedded' ) || strcmpi(token, '-->embedded')
    % eat MATLAB as well
    [token, rawStr] = strtok( rawStr );
end
    
if ~strcmpi( token, 'stateflow' ) & ~strcmpi(token, '-->Stateflow')...
   & ~strcmpi( token, 'MATLAB' ),
    return;
end

% second word is the stateflow error type
[errorStart, errorEnd] = regexp( lower( rawStr ), '\<error\>+' , 'once');
if isempty(errorStart)
    return;
end

% wish: use find to strip the spaces.
errType = fliplr( deblank (rawStr(1:(errorStart-1) ) ) );
errType = fliplr( deblank( errType ) ); % got rid of leading and trailing spaces in errType

% third word must be 'error'
% but we checked this above with regexp, so continue parsing from errorEnd
rawStr = rawStr( (errorEnd+1): end );

% Next thing is either a pair of parenthesis with SF ids inside or a colon:
colonPos = find( rawStr == ':' );
% we know that there is a colon, because we ran regexp above.
colonPos = colonPos(1);

%see if there is a list of SF ids in parenthesis
idsStr = rawStr( 1:colonPos );
leftParenPos = find( idsStr == '(' );
rightParenPos = find( idsStr == ')' );
if length( leftParenPos ) ~= length( rightParenPos ) | length( leftParenPos ) > 1
    warn_about_bad_msg( origStr );
    return;
end
isSFError = 1;
sfIds = [];
if ~isempty( leftParenPos )
    % we have some relevant sf ids
    inParenStr = ...
        [ idsStr( leftParenPos+1:rightParenPos-1 ), ' ' ]; % add a whitespace for easier parsing

    % look for #<number>
    [begPos, endPos] = regexp( inParenStr, '#\d+[,\s]' );
    for i = 1:length( begPos )
        sfIds = [sfIds str2num( inParenStr( begPos(i)+1:endPos(i)-1 ) ) ];
    end
    if(isempty(begPos))
        if(~isempty(findstr(lower(inParenStr),'chart')))
            hyperlinkSlHandle = map_blk_to_sf_blk(blkHandle);
            chartId = block2chart(hyperlinkSlHandle);
            isEmlChart = is_eml_chart(chartId);
        elseif(~isempty(findstr(lower(inParenStr),'machine')))
            hyperlinkSlHandle = bdroot(blkHandle);
        end
    end
end

sfIds = [chartId,sfIds];
sfIds( find( ~sf( 'ishandle', sfIds ) ) ) = []; % ignore non-SF handles

% whatever is after the colon is stripped error msg
strippedMsg = rawStr( (colonPos+1):end );

if(isEml)
   compName = 'Embedded MATLAB';
else
   compName = 'Stateflow';
end
if(isSfError)
    errorMsg = [ compName ' ' errType ' Error: ' strippedMsg ];
else
    errorMsg = [ compName ' ' errType ' Warning: ' strippedMsg ];
end

if(~isempty(hyperlinkSlHandle))
    %%% this must have been returned by preprocess_sl_error. hence we use thisfor blockpath
    sfBlockPath = getfullname(hyperlinkSlHandle);
    relevantSlHandle = hyperlinkSlHandle;
else
    [sfBlockPath,relevantSlHandle] = get_sf_block_path(sfIds);
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function sfBlkHandle = map_blk_to_sf_blk(blkHandle)
sfBlkHandle = [];
try,
    if(strcmp(get_param(blkHandle,'MaskType'),'Stateflow'))
        %% is itself a SF block
        sfBlkHandle = blkHandle;
        return;
    end
catch,
    return;
end

try,
    blkParent = get_param(blkHandle,'Parent');
    if(isempty(blkParent)...
            | ~strcmp(get_param(blkParent,'Type'),'block')...
            | ~strcmp(get_param(blkParent,'MaskType'),'Stateflow'))
        %%% not SF hidden block. just return
        return;
    end
    sfBlkHandle= get_param(blkParent,'handle');
catch,
    return;
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [isSfError,isSfWarning,rawStr] = check_if_sf_generated(rawStr)

isSfError = 0;
isSfWarning = 0;
testRawStr = lower( rawStr );
[errorStart, errorEnd] = regexp( testRawStr, 'stateflow.*?error\s*[:(]', 'once');
if ~isempty(errorStart)
    isSfError = 1;
    rawStr = rawStr( errorStart:end );
else
    [errorStart, errorEnd] = regexp( testRawStr, 'stateflow.*?warning\s*[:(]', 'once');
    if ~isempty(errorStart)
        isSfWarning = 1;
        rawStr = rawStr( errorStart:end );
    else
        return;
    end
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% this function warns the user that that is probably an SF error
% msg, but it doesn't quite comply with the format.
% this function gets called only in the event of high likelihood
% of rawStr being SF error msg
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function warn_about_bad_msg( rawStr )
warning( [ '''' rawStr ''' does not comply with SF error message syntax.' ]  );


function [pathStr, relevantSlHandle] = get_sf_block_path( ids )
pathStr = 'Stateflow';
relevantSlHandle = [];
if isempty( ids )
    return;
end
chartISA = sf( 'get', 'default', 'chart.isa' );
machineISA = sf( 'get', 'default', 'machine.isa' );

parents = unique( get_chart_or_machine_parent( ids ));
charts = unique( sf( 'find', parents, '.isa', chartISA ) );
machines = unique( [ sf( 'find', parents, '.isa', machineISA ), ...
        sf( 'get', charts, '.machine' ) ] );

if length( machines ) > 1
    return;
end
pathStr = sf( 'get', machines, '.name' );


switch length( charts )
case 1,
    instanceId = sf( 'get', charts, '.instance' );
    blockH = sf( 'get', instanceId, '.simulinkBlock' );
    pathStr = getfullname( blockH );
    relevantSlHandle = blockH;
otherwise,
end


function parent = get_chart_or_machine_parent( ids )
machineISA = sf( 'get', 'default', 'machine.isa' );
chartISA = sf( 'get', 'default', 'chart.isa' );

for i = 1:length( ids )
    parent(i) = ids(i);
    parentISA = sf( 'get', parent(i), '.isa' );
    while  parentISA~= chartISA & parentISA ~= machineISA
        parent(i) = sf( 'ParentOf', parent(i) );
        parentISA = sf( 'get', parent(i), '.isa' );
    end
end

function [isSfError,isSfWarning, cookedString,hyperlinkSlHandle,isEml,chartId] = preprocess_sl_error(rawString,blkHandle)

%%% now we check if this is an error pertaining to an SF block. In which case
%%% we might want to process it and own it. One example is unresolved chart
%%% workspace data where the blkHandle is of the Sfunction underneath SF block.
%%% other examples will be discovered shortly
cookedString = rawString;
hyperlinkSlHandle = [];
isSfError = 0;
isSfWarning = 0;
isEml = 0;
chartId = [];

if(blkHandle==0.0)
    return;
end

%% in the following, we are trying to deal with the
%% SL block pathnames. SL allows block-path names to contain
%% all sorts of unparsable strings that dont work with get_param()
%% hence, if SL cant handle this, just bail.
try,
    isSfError = 0;
    for i=1:length(blkHandle)
        blkParent = get_param(blkHandle(i),'Parent');
        if(~isempty(blkParent)...
                & strcmp(get_param(blkParent,'Type'),'block')...
                & strcmp(get_param(blkParent,'MaskType'),'Stateflow'))
            %%% is a SL/SF error
            isSfError = 1;
            break;
        end
    end
    if(~isSfError)
        return;
    end
    blkParentHandle = get_param(blkParent,'handle');
catch,
    return;
end

% translate IO size mismatch errors
[instanceId, chartId] = sf_block_object_ids(blkParentHandle);
[isHandledHere,rawString] = translate_io_size_mismatch_error(rawString,instanceId, chartId);
    

%%% we assume that the error message must look like the following
%%% Error evaluating parameter 'Parameter 1' in block 'untitled/Chart/ SFunction ': Undefined function or variable 'x'.
%%% we must have a test to guard against SL breaking us by changing the error format

errorPrefix = 'Error evaluating parameter';
if(strncmp(rawString,errorPrefix,length(errorPrefix)))


    %
    % Handle kanji case too.
    %
    % WUENSCH: revisit this code and make it truly language independent
    % rather than explicitly handling kanji and non-kanji cases.
    % JRT, RH
    %
    lang = get(0,'language');
    if length(lang) >= 2 & strcmp(lower(lang(1:2)),'ja')   % if this is japanese
        jaSearchString=xlate('Undefined function or variable ''%s''');
        jaSearchString=jaSearchString(end-14:end);
        if ~isempty(findstr(jaSearchString,rawString)),
            aQuote = '''';
            quotes=findstr(rawString, aQuote);
            if ~isempty(quotes), dataName=rawString((quotes(end-1)+1):(quotes(end)-1));
            else, dataName = '';
            end;
        else
            % doesnt start with our prefix. do nothing
            return;
        end

    else  % non-japanese
        [s, e] = regexp(rawString,'Undefined[\s]+function[\s]+or[\s]+variable[\s]+', 'once');
        if(isempty(s))
            % doesnt start with our prefix. do nothing
            return;
        end


        %%% starts with the prefix we are looking for.
        %%% this must be an undefined chart workspace data error. extract data
        %%% name and then get dataId
        dataName = rawString(e+2:end-1);
    end;

    isEml = is_eml_chart(chartId);
    if(isEml)
       compName = 'Embedded MATLAB';
    else
       compName = 'Stateflow';
    end
    allChartData = sf('DataOf',chartId);
    dataId = sf('find',allChartData,'data.name',dataName);
    %%% at this point we have the ID of the undefined data. construct an error message in the SF standard format
    %%% we return this newly constructed error message back in effect highjacking SL's error message
    %%% and morphing it into ours so that users know exactly what is needed to be done with workspace data.
    throwFlag = -1; %%just constructs and doesnt throw and doesnt touch lasterr
    errorMsg = sprintf('Error evaluating %s parameter data ''%s'' (#%d) in its parent workspace.',compName,...
                      dataName,dataId);
    cookedString = construct_error( dataId,'Runtime', errorMsg, throwFlag );
    isSfError = 1;
else
    %%% we know that the error originated on one of the hidden blocks of SF masked block.
    %%% we take ownership of it. this ensures that the hyperlink wont open up SF mask block
    %%% and wreak havoc


    throwFlag = -1; %%just constructs and doesnt throw and doesnt touch lasterr
    errorMsg = check_for_sl_interface_data_type_mismatch_errors(rawString,blkParentHandle);
    chartId =  block2chart(blkParentHandle);
    cookedString = construct_error(chartId, 'Interface', errorMsg, throwFlag);
    isSfError = 1;
    isEml = is_eml_chart(chartId);
end

hyperlinkSlHandle = blkParentHandle;



function [instanceId, chartId] = sf_block_object_ids(blkParentHandle);
    instanceId = sf('find','all','instance.simulinkBlock',blkParentHandle);
    if(isempty(instanceId))
        %% this is a library chart. an open_system will automatically load
        %% the library model if necessary and sets the active instance properly
        open_system(blkParentHandle);
        chartId = sf('find','all','chart.activeInstance',blkParentHandle);
    else
        chartId = sf('get',instanceId,'instance.chart');
    end

function errorMsg = check_for_sl_interface_data_type_mismatch_errors(errorMsg, blkParentHandle)
    [prevErrMsg, prevErrId] = lasterr;
    try
        errorPrefix = 'Data type mismatch.';
        % Now there are two possibilities
        % 1- The Chart is weakly typed but Simulink wants to use Strong Data Typing on I/O
        % 2- The Chart is set to use Strong Data Typing with Simulink and there is a type mismatch
        if ~(strncmp(errorMsg,errorPrefix,length(errorPrefix)))
            return;
        end
        errorMsg = strrep(errorMsg,'/ SFunction ','');
        [instanceId, chartId] = sf_block_object_ids(blkParentHandle);
        if(is_eml_chart(chartId))
            errorMsg = sprintf('%s\n\n%s',errorMsg,...
             ['This problem may be resolved by using Simulink Data Type Conversion block(s)']);
        else
            errorMsg = sprintf('%s\n\n%s',errorMsg,...
             ['This problem may be resolved by using Simulink Type Conversion block(s) and by',...
              ' setting the Strong Data Typing option in the Stateflow chart (#',num2str(chartId),...
              ') properties dialog.']);
        end
    catch
        % defensive coding
        lasterr(prevErrMsg, prevErrId);
    end
