function S = set(S,varargin)
% SET  Set Node properties and register values
%   S = SET(S,STR) - Returns a new SBS 25x0 node object which has its
%    properties overwritten by the passed structure: STR. This structure must
%    have fields that correspond to the properties of the SBS 25x0 node 
%    object.  Incomplete structures as allowed (the undefined properties
%    are taken from the incoming S object).
%      
%   S = SET(S,'Prop','Val','Prop2','Val2',...) - Same as above, except new
%   properties as specified as Property, Value pairs.  For Example:
%     > S = set(S,'RXEnable','off') 
%   will disable the board's receiver (for write-only broadcast memory).

%   Copyright 2004 The MathWorks, Inc. 
%   $Revision: 1.1.6.2 $  $Date: 2004/02/06 00:32:06 $
if nargin == 2 
    defstruct = varargin{1};
    if isstruct(defstruct),
        for sfields = fieldnames(defstruct)',
            S = set(S,sfields{1},defstruct.(sfields{1}));
        end
    elseif isa(defstruct,'smnodesbs25x0'),
            S = defstruct;
    else
        error('SET requires Property/Value pairs or Configuration Structure');
    end
end
while length(varargin) >= 2,
    prop = varargin{1};
    val = varargin{2};
    varargin = varargin(3:end);
    switch prop
    case {'TargetAbortEnable','LoopbackEnable','RXEnable','TXEnable','WITEnable','IRQ_ErrorEnable','IRQ_WITEnable'}  % On/Off properties
        if isempty(val), % defaults
           S.(prop) = 'off';
        elseif ischar(val) && any(strcmp(val,{'on','off'})),
            S.(prop) = val;
        else
            error(['Property ' prop ' must be to either ''on'' or ''off''']);
        end
    case 'Partition'
        if isempty(val),
            S.(prop) = val;
        elseif isstruct(val) || isa(val,'smpartsbs25x0') || isa(val,'smpartition')
            S.(prop) = smpartsbs25x0(val);
        else
           error('Unexpected value for Partition property (expected smpart25x10 object)');
        end
    case 'MemorySize'       
        if any(strcmp(val,{'any','256kByte','512kByte','1MByte','2MByte','4MByte','8MByte'})),
            S.(prop) = val;         
        else
           error('Unexpected value for MemorySize (minimum) property ');
        end
        val = round(val);      
    otherwise
        val = eval(['S.' prop_name]);
    end
end



