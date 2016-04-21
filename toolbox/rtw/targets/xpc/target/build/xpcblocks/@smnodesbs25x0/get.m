function val = get(S,prop_name)
% GET  Retrieve Node properties and register values
%   GET(S,'Interrupt') Returns Interrupt structure
%   GET(S,'BT_REG_CTRL_ARG') Returns cell array of alignments
%
%   GET(S,'all') Returns all parameters in a structure
% 
% See also SMPARTITION

%   Copyright 2004 The MathWorks, Inc. 
%   $Revision: 1.1.6.1 $  $Date: 2004/01/22 18:34:52 $
if nargin == 1,
    prop_name = 'all';
end
    switch prop_name
    case 'BT_REG_CTRL_ARG'  % Numeric version of address
        % Compute BT_REG_CTRL_ARG from fields
        val = 0;
        if strcmp(S.TargetAbortEnable,'on'),
            val = val + 2^6;
        end
        if strcmp(S.LoopbackEnable,'on'),
           val = val + 2^5;
        end
        if strcmp(S.IRQ_WITEnable,'on'),
           val = val + 2^3;
        end        
        if strcmp(S.IRQ_ErrorEnable,'on'),
           val = val + 2^2;
        end    
        if  strcmp(S.RXEnable,'on'),
           val = val + 2^1;
        end         
        if strcmp(S.TXEnable,'on'),
           val = val + 2^0;
        end
        val = round(val);
    case 'BT_REG_MEM_ARG'
        switch S.MemorySize 
        case {'256kByte','any'},
            val = 2^0;
        case '512kByte',
            val = 2^1;                
        case '1MByte',
            val = 2^2;             
        case '2MByte',
            val = 2^3;             
        case '4MByte',
            val = 2^4;             
        case '8MByte',
            val = 2^5;             
        otherwise
           error('Unexpected value for Mode.MemorySize');
        end
        val = round(val);
    case 'WIT',
        if ~isempty(S.Partition),
            val = getwit(S.Partition);
        else
            val = [];
        end
    case 'all',
        val = struct(S);
    otherwise
        val = eval(['S.' prop_name]);
    end
end



