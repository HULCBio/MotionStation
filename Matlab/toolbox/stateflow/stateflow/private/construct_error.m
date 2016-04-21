function varargout = construct_error( ids, errorType, errorMsg, throwFlag, openFcn)
%CONSTRUCT_ERROR(IDS,ERRORTYPE,ERRORMSG,THROWFLAG)  
%Centralized error message generation function for SF.
%All SF modules must call construct_error instead of error() directly.
%IDS must be an array of data-dictionary ids relevant to the error
%message. IDS can be an empty vector.
%ERRORTYPE is a string that represents the module generating the error
%examples of ERRORTYPE = 'Coder','Parser','Make','Runtime'
%ERRORMSG is the raw error message.
%THROWFLAG = 0 merely returns the constructed error message as an output
%THROWFLAG = 1 constructs the message and calls error() with it.


%   Vladimir Kolesnikov
%   Copyright 1995-2004 The MathWorks, Inc.
%   $Revision: 1.18.2.5 $  $Date: 2004/04/15 00:56:24 $

    SLSFERRORCODE = slsfnagctlr('NagToken');

    if nargin < 5,  openFcn = []; end
    if nargin < 4,  throwFlag = 1; end
    if nargin < 3 | isempty(errorMsg),     errorMsg  = 'unknown error'; end
    if nargin < 2 | isempty( errorType ),  errorType = 'general';       end
    if nargin < 1,  ids = []; end

    idsLen = length( ids );

    if length(ids) > 0, id = ids(1);  else, id = []; end;

    nag             = slsfnagctlr('NagTemplate');
    if throwFlag==-2
       nag.type        = 'Warning';
    else
       nag.type        = 'Error';
    end
    nag.msg.details = errorMsg;
    nag.msg.type    = errorType;
    nag.msg.summary = errorMsg;
    if is_eml_chart(id)
        % eML block
        nag.component = 'Embedded MATLAB';
        nag.sourceName = sf('get', id, 'chart.name');
    elseif is_eml_script(id)
        % eML script
        nag.component = 'Embedded MATLAB';
        nag.sourceName = sf('get', id, 'script.filePath');
    else
        nag.component = 'Stateflow';
    end
    nag.sourceHId   = id;
    nag.ids         = ids;
    nag.blkHandles  = get_chart_block_handle_from_id_l(id);
    if ~isempty(openFcn)
        nag.openFcn = openFcn;
    end


    slsfnagctlr('Naglog', 'push', nag);

    if throwFlag ~= -1,
        
        %
        % insure nice formating of displayed text by truncating the summary rows to maxWidth
        %
        maxWidth = 60;
        len = length(nag.msg.summary);
        if len >= maxWidth, 
            crnl = find(nag.msg.summary==10 | nag.msg.summary==13);
          
            if isempty(crnl), summary = [nag.msg.summary(1:maxWidth),'...'];
            else,
                ind = crnl;
                if (ind(1) ~= 1),     ind = [1, ind];   end;
                if (ind(end) ~= len), ind = [ind, len]; end;
                summary = [];
                for i=2:length(ind),
                    ind1 = ind(i-1);
                    ind2 = ind(i);
                    w = ind2-ind1;
                   
                    if w > maxWidth, summary = [summary, nag.msg.summary(ind1:(ind1+maxWidth)), '...'];
                    else, summary = [summary, nag.msg.summary(ind1:(ind2-1))];
                    end;
                end;
            end;
        else, summary = nag.msg.summary;
        end;
    
        if ~isempty(summary) & ~strncmpi(nag.msg.type, 'Lex', 3),
            summary(summary==10) = [];
            summary(summary==13) = [];
        end;
        
        % Note: the SLSFERRORCODE token MUST come before the summary as the summary may contain multibyte chars
        % which get randomly truncated by Simulink via lasterr.  If trunctaion occurs, the token is
        % munged and the NAG-Controller can't resolve the error message.
        displayTxt = ['-->',nag.component,setstr(32),nag.msg.type,setstr(32),nag.type,' :',SLSFERRORCODE, summary];   
    else,
        displayTxt = ['-->',nag.component,setstr(32),nag.msg.type,setstr(32),nag.type,' :', nag.msg.summary];
    end;
    
    % Throw error if requested
    switch (throwFlag),
        case 1,
            slsfnagctlr('ViewNaglog'); 
            error(displayTxt); % throw the error

        case 0,
            lasterr(displayTxt);
        case -2,
            lastwarn(displayTxt)
        case -1,
          %%% this is needed so that we dont pollute lasterr when we are merely
          %%% using this function to construct a message in our format.
    end

    varargout{1} = displayTxt;


%-------------------------------------------------------------------------------------
function blockH = get_chart_block_handle_from_id_l(id)
%
%
%
    blockH = [];
    if ~isequal(sf('ishandle',id), 1), return; end;
    
    MACHINE     = sf('get', 'default', 'machine.isa');
    CHART       = sf('get', 'default', 'chart.isa');
    STATE       = sf('get', 'default', 'state.isa');
    JUNCTION    = sf('get', 'default', 'junction.isa');
    TRANSITION  = sf('get', 'default', 'transition.isa');
    EVENT       = sf('get', 'default', 'event.isa');
    DATA        = sf('get', 'default', 'data.isa');
    TARGET      = sf('get', 'default', 'target.isa');
    SCRIPT      = sf('get', 'default', 'script.isa');

    chartId = [];
    switch sf('get', id, '.isa'),
        case {MACHINE, TARGET, SCRIPT},              % nothing
        case CHART,                          chartId = id;
        case {STATE, TRANSITION, JUNCTION},  chartId = sf('get', id, '.chart');
        case {EVENT, DATA},
            parent = sf('get', id, '.linkNode.parent');
            switch sf('get', parent, '.isa'),
                case STATE, chartId = sf('get', parent, '.chart');
                case CHART, chartId = parent;
            end;
        otherwise, error('bad type.');
    end;

    if isempty(chartId), return; end;

    %
    % chartId is now valid, so just get the instance block handle
    %
    instanceId = sf('get', chartId,'.instance');
    blockH = sf('get', instanceId, '.simulinkBlock'); 
