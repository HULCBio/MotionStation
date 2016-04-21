function val = get(S,prop_name)
% GET  Retrieve raw parition parameters
%   ADDR = GET(S,'Address') Returns Cell array of Addresses
%   ALIGN= GET(S,'Alignment') Returns Cell array of Alignment
%   DTYPE= GET(S,'Type')  Returns 
%   SIZE = GET(S,'Size')
%   STR  = GET(S,'all') or GET(S) Returns all parameters in a structure

% See also SMPARTITION

%   Copyright 2004 The MathWorks, Inc. 
%   $Revision: 1.1.6.1 $  $Date: 2004/01/22 18:34:40 $
if nargin == 1,
    prop_name = 'all';
end
ns = numel(S);
if ns == 1,
    switch prop_name
    case 'IAddress'  % Numeric version of address
        val = S.Address;
    case 'Address'     
        val = {};
        for taddr = S.Address
            val = horzcat(val,{['0x' dec2hex(taddr)]});
        end
    case 'IAlignment'
        val = S.Alignment;        
    case 'Alignment'
        val = {};
        for talign = S.Alignment
            val = horzcat(val,{num2str(talign)});
        end
    case 'ISize'   % 
        val = S.Size;      
    case 'Size'
        val = {};        
        for tsize = S.Size,
            if tsize(2) == 0,
                val = horzcat(val,{['[ ' num2str(tsize(1)) ' ]']});
            else
                val = horzcat(val,{['[ ' num2str(tsize') ' ]']});                
            end
        end
    case 'Type'
        val = {};        
        for ttype = S.Type,        
            val = horzcat(val,{typeconvert(S,ttype)});
        end
    case 'IType'
        val = S.Type;
    case {'ALL','all','All'}
        val = getstruct(S);
    otherwise
        val = eval(['S.' prop_name]);  % Might fail
    end
elseif ns >= 2,
    switch prop_name    
    case 'IAddress'
        for inxS = 1:numel(S),
            val{inxS} = S(inxS).Address;
        end
    case 'Address'
        val = {};
        for inxS = 1:numel(S),
            val_t = {};          
            for taddr = S(inxS).Address
                val_t =  horzcat(val_t,{['[ ' num2str(taddr) ' ]']});;
            end
            val{inxS} = val_t;
        end
    case 'IAlignment'   
        for inxS = 1:numel(S),        
            val{inxS} = S(inxS).Alignment;
        end       
    case 'Alignment'
        for inxS = 1:numel(S),        
            val_t = {};
            for talign = S(inxS).Alignment,
                val_t = horzcat(val_t,{num2str(talign)});
            end
           val{inxS} = val_t;            
        end
    case 'ISize'
        for inxS = 1:numel(S),
            val{inxS} = S(inxS).Size;
        end        
    case 'Size'
        for inxS = 1:numel(S),        
            val_t = {};          
            for tsize = S(inxS).Size,
                if tsize(2) == 0,
                    val_t = horzcat(val_t,{['[ ' num2str(tsize(1)) ' ]']});
                else
                    val_t = horzcat(val_t,{['[ ' num2str(tsize') ' ]']});                
                end                
            end
            val{inxS} = val_t;            
        end
    case 'IType'
        for inxS = 1:numel(S),           
            val{inxS} = S(inxS).Type;
        end
    case 'Type'
        for inxS = 1:numel(S),
            val_t = {};             
            for ttype = S(inxS).Type,        
                val_t = horzcat(val_t,{typeconvert(S,ttype)});
            end            
            val{inxS} = val_t;
        end        
    case {'ALL','all','All'}
        val = getstruct(S);
    otherwise
        for inxS = 1:numel(S),        
            val{inxS} = eval(['S(' num2str(inxS) ').' prop_name]);  % Might fail
        end
    end
end


