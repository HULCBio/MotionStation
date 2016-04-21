function val = get(S,prop_name)
% GET  Retrieve raw parition parameters
%   AD = GET(S,'Address') Returns cell array of addresses
%   AL = GET(S,'Alignment') Returns cell array of alignments
%   DT = GET(S,'Type') 
%   SZ = GET(S,'Size')
%   STR= GET(S,'all') Returns all parameters in a structure
% 
% See also SMPARTITION

%   Copyright 2004 The MathWorks, Inc. 
%   $Revision: 1.1.6.1 $  $Date: 2004/01/22 18:34:49 $

if nargin == 1,
    prop_name = 'all';
end
ns = numel(S);
if ns == 1,
    switch prop_name
    case 'WIT'
        val = S.WIT;
    case {'ALL','all','All'}
        val = get(S.smpartition);
        for inxP = 1:length(val),
           val(inxP).WIT = S.WIT{inxP}; 
        end        
    otherwise
        val = get(S.smpartition,prop_name);
    end
elseif ns >= 2,
    switch prop_name    
    case 'WIT'
        for inxS = 1:numel(S),
            val{inxS} = S(inxS).WIT;
        end
    case {'ALL','all','All'}
        val = getstruct(S);
        for inxS = 1:numel(S),        
            for inxP = 1:length(val),
               val{inxS}(inxP).WIT = S.WIT{inxP}; 
            end
        end
   otherwise
       val = {};
       for inxS = 1:numel(S), 
            val{inxS} = get(S(inxS).smpartition,prop_name);
       end
    end
end


