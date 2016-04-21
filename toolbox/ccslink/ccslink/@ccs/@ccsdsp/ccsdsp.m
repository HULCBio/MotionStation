function cc = ccsdsp(varargin)
%CCSDSP create a link to the Texas Instruments Code Composer(R) IDE.
%   CC = CCSDSP('PropertyName',PropertyValue,...) returns an object which
%   is used to communicate with a DSP target processor.  This handle can be
%   used to access memory and control the execution of  the target DSP
%   processor. CCSDSP can also be used to create an array of objects for a
%   multiprocessor board. If CC is an array, any method called by CC is
%   sequentially broadcasted to all processors connected to the CCSDSP
%   object. All communication is handled by the Code Composer Studio(R) IDE
%   application.   
%   
%   All passed parameters are interpreted as object property definitions.
%   Each property definition consists of a property name followed by the
%   desired property value.  Although any CC object property can be defined
%   during this initialization, there are several important properties that
%   MUST be provided during the initial call.  Therefore, these must be
%   properly delineated when the object is created.  After the object is
%   built, these values can be retrieved with GET, but never modified. 
%
%   'boardnum' - The index of the desired DSP board.  The resulting object
%   CC refers to a DSP processor on this board.  Use the CCSBOARDINFO
%   utility to determine the number for the desired DSP board.  If the
%   user's Code Composer is defined to support only a single board, this
%   property definition can be skipped.  If the property is not passed by
%   the user, the object will default to boardnum 0 (zero-based).  
%
%   'procnum' - The index of the desired DSP processor on the DSP board 
%   selected with the 'boardnum' property. The property can also be an
%   array of processor indices in a multiprocessor board.  This will result
%   to CC being an array of objects that correspond to the specified
%   processors. Use the CCSBOARDINFO utility to determine the number for
%   the desired DSP processor(s).  If the user's Code Composer is defined
%   to support only a single processor on the board, this property
%   definition can be skipped.  In a single-processor board, if the
%   property is not passed by the user, the object will default to procnum
%   0 (zero-based). In a multiprocessor board, if the property is not
%   passed by the user, 'procnum' will default to [0,...,N-1], where N is
%   the number of processors in the board. 
%
%   Example: 
%   target = ccsdsp('boardnum',1,'procnum',0); 
%   - will return a handle to the first DSP processor on the second DSP board.
%
%   target = ccsdsp('boardnum',0,'procnum',[0 1]); 
%   - will return a 1x2 array of handles to the first and second DSP processor
%   on the first DSP board.
%   target(1) <-- handle for first processor (0)   
%   target(2) <-- handle for second processor (1)   
%
%   CCSDSP without any passed arguments will construct the object with the 
%   default property values.
%
%   Example: Single-processor board (one processor in board 0)
%   target = ccsdsp('boardnum',0); 
%   - will return a handle to the first DSP processor on the first DSP board.
%
%   Example: Multi-processor board (three processors in board 0)
%   target = ccsdsp('boardnum',0); 
%   - will return an array of handles, i.e., target(1), target(2), target(3), 
%   where each handle corresponds to a DSP processor in the first board.
%   
%   See also CCSBOARDINFO, RTDX, GET, SET.

%   Copyright 2001-2004 The MathWorks, Inc.
%   $Revision: 1.49.6.5 $ $Date: 2004/04/06 01:04:40 $

focusstate = p_getCmdWndFocus;

% Construct the actual object instance    
cc = ccs.ccsdsp;
cc = initialize_object(cc, nargin,varargin);

% Constructor
try     
    cc.ccsversion = p_createCCSVersionObj(cc.apiversion,'warn');
    callSwitchyard(cc.ccsversion,[0,cc.boardnum,cc.procnum,0,0]);
catch
    if strfind(lasterr,'CCSDSP:Class not registered'),
        error(generateccsmsgid('CannotConnectToCCS'),...
            'Proper installation of Code Composer Studio(R) is required');
    elseif strfind(lasterr,'CCSDSP:Server execution failed')
        error(generateccsmsgid('CannotConnectToCCS'),...
            'Unable to attach to Code Composer Studio COM interface: The board may not be properly connected.');
    else
        error(generateccsmsgid('CannotConnectToCCS'),lasterr);
    end
end
cc.rtdx = rtdx([cc.boardnum,cc.procnum],cc.ccsversion.apiversion);
cc.type = ccsdatatype('boardproc',[cc.boardnum,cc.procnum],'apiversion',cc.ccsversion.apiversion);
cc.stack = ccsstack([cc.boardnum,cc.procnum]);

cc.cd(pwd);
cc.apiversion = callSwitchyard(cc.ccsversion,[37,cc.boardnum,cc.procnum,0,0]);
cc.ccsappexe = callSwitchyard(cc.ccsversion,[63,cc.boardnum,cc.procnum,0,0]);

ccinfo = info(cc);
cc.family = ccinfo.family;
cc.subfamily = ccinfo.subfamily;
cc.revfamily = ccinfo.revfamily;

if (cc.subfamily >= 80 && cc.subfamily <= 95) % c54x
    cc.page = 1;
end

p_grabCmdWndFocus(focusstate);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function cc = initialize_object(cc, nargs, args)
%
% Defaults
cc.boardnum = 0;    % Important info for MEX-file
cc.procnum  = 0;    % Important info for MEX-file
cc.timeout = 10.0;  % Default = 10 seconds
cc.page = 0;
cc.eventwaitms = 20;  % Default = 20 msec

% Process constructors input arguments if any
if nargs <= 1
    return;      % Use defaults
else
    
    if(mod(nargs,2)~=0)
        error(['CCSDSP constructor requires property and value ', ...
                'arguments to be specified in pairs.']);
    end
    
    % Get property / value pairs from argument list
    for i = 1:2:nargs
        
        prop = lower(args{i});
        val  = args{i+1};
        
        % Argument checking
        switch prop
            
        case 'boardnum'
            if length(val) ~=1, error('Property ''boardnum'' must be a scalar value.');end
            if ~isnumeric(val), error('Property ''boardnum'' must be numeric.'); end
            if val<0, error('''boardnum'' must be a positive integer.'); end
            cc.boardnum = double(val);
            
        case 'procnum'
            if ~isnumeric(val), error('Property ''procnum'' must be numeric.'); end
            if val<0, error('''procnum'' must be a positive integer.'); end
            cc.procnum = double(val);
            
        case 'boardname'
            if ~ischar(val), error('Property ''boardname'' must be a string.');end
            cc.boardnum = double(val);
            
        case 'procname'
           if ~ischar(val), error('Property ''procname'' must be a string.');end
            cc.procnum = double(val);
            
        case 'timeout'
            if ~isnumeric(val), error('Property ''timeout'' must be numeric.'); end
            if val<0, error('''timeout'' must be a positive integer.'); end
            cc.timeout = double(val);
            
        case 'eventwaitms'
            if ~isnumeric(val), error('Property ''timeout'' must be numeric.'); end
            if val<0, error('''eventwaitms'' must be a positive integer.'); end
            cc.eventwaitms = double(val);
            
        case 'page'
            if ~isnumeric(val), error('Property ''page'' must be numeric.'); end
            if val<0, error('''page'' must be a positive integer.'); end
            cc.page = double(val);
            
        case 'ccsappexe'
            if ~char(val), error('Property ''ccsappexe'' must be a char array.'); end
            if exist(val,'file') ~= 2, error(['Executable: ''' val '''provided for Code Composer does not exist']); end
            cc.ccsappexe = val;   

        case 'apiversion'
            if ~isnumeric(val), error('Property ''apiversion'' must be a 2-element numeric array.'); end
            cc.apiversion = val; % val can be empty -> isnumeric([])=1

        otherwise
            error('Unknown property specified for CCSDSP object.')
        end
    end
end

% [EOF] ccsdsp.m
