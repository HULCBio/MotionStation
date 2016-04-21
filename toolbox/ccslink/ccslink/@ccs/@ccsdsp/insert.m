function insert(cc,fileadd,linetype,type)
%INSERT Adds a debug point into Code Composer Studio(R)
%   INSERT(CC,ADDR,TYPE) places a debug point at the provided address
%   of the DSP.  The CC handle defines the DSP target that will 
%   receive the new debug point. The debug point location is 
%   defined by ADDR, the desired memory address.  Code Composer 
%   provides several types of debug points. Refer to the Code 
%   Composer help documentation for information on their respective 
%   behavior. The following debug TYPE options are supported:
%    'break' or '' - Breakpoint (default)
%    'probe'  - Probe Point
%    'profile' - Profile Point
%
%   INSERT(CC,ADDR) same as above, except the debug point defaults to
%   a breakpoint.
%
%   INSERT(CC,FILE,LINE,TYPE) places a debug point at the specified line
%   in a source file of Code Composer.  The FILE parameter gives the
%   name of the source file, while LINE defines the line number to
%   receive the breakpoint.   Code Composer provides several
%   types of debug points.  Refer to Code Composer documentation for
%   information on their respective behavior. Refer to the previous list
%   of supported point types.
%
%   INSERT(CC,FILE,LINE) same as above, except the debug point defaults to
%   a breakpoint.
%
%   See also DELETE, ADDRESS, RUN.

% Copyright 2001-2004 The MathWorks, Inc.
% $Revision: 1.2.4.3 $ $Date: 2004/04/01 16:02:19 $

error(nargchk(2,4,nargin));
p_errorif_ccarray(cc);

if ~ishandle(cc),
    error('First Parameter must be a CCSDSP Handle.');
end

if nargin>=3 & isnumeric(linetype),   % File, Line form
    if nargin == 2,
        error('Requires both a filename and a line number');
    elseif ~isnumeric(linetype) | linetype < 0,
        error('Line number must be a positive numeric value');
    end
    if nargin < 4 | isempty(type),
        action = 27;
    else
        if ~ischar(type), 
            error('TYPE must be either: ''break'', ''probe'' or ''profile''');
        end
        idx = strmatch(type,{'break','probe','profile'});
        if idx == 1,
            action = 27;
        elseif idx == 2,
            action = 33;
        elseif idx == 3,
            action = 35;
        else
            error(['Point TYPE: ''' type ''' Not supported']);
        end
    end
    callSwitchyard(cc.ccsversion,[action,cc.boardnum,cc.procnum,0,0],fileadd,linetype);
elseif isnumeric(fileadd) | ischar(fileadd),    % Address form (numeric or hex string)
    if nargin == 4,
        error('Syntax error - too many inputs for ADDR mode');
    elseif isempty(fileadd),
        error('ADDR (address) must be a positive numeric value');
    end
    if nargin == 2 | isempty(linetype),
        action = 27;
    else
        if ~ischar(linetype), 
            error('TYPE must be either: ''break'', ''probe'' or ''profile''');
        end
        idx = strmatch(linetype,{'break','probe','profile'});
        if idx == 1,
            action = 27;
        elseif idx == 2,
            action = 33;
        elseif idx == 3,
            action = 35;
        else
            error(['Point TYPE: ''' linetype ''' Not supported']);
        end
    end       
    callSwitchyard(cc.ccsversion,[action,cc.boardnum,cc.procnum,0,0],fileadd);
else
    error('Syntax error - First parameter must be an address or filename');    
end   

% [EOF] insert.m
