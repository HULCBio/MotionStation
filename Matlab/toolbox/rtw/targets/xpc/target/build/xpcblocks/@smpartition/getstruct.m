function SP = getstruct(S,varargin)
%  GETSTRUCT - retrieve partition definition as structure
% Return the structural equivalent of the parition
%
%  getstruct(S) = 
%  getstruct(S,2) = 
%  getstruct(S,

% Copyright 2004 The MathWorks, Inc.

if nargin == 1,  % Get entire structure
    nS = numel(S);
    for inxS = 1:nS,    
        SP{inxS} = struct('Address',get(S(inxS),'Address'),...
                    'Type',get(S(inxS),'Type'),...
                    'Alignment',get(S(inxS),'Alignment'),...
                    'Size',get(S(inxS),'Size')...
                    );
    end
    if nS == 1,
        SP = SP{1};
    end
elseif nargin == 2,
   inx = varargin{1};
   if ischar(inx) && strcmp(inx,'all')
       SP = struct('Address',S.Address{1},...
            'Type',S.Type{1},...
            'Alignment',S.Alignment{1},...
            'Size',S.Size{1}...
            );
        for inx =2:length(S.Address)-1
            SP(inx).Address = S.Address{inx};
            SP(inx).Type = S.Type{inx};
            SP(inx).Alignment = S.Alignment{inx};
            SP(inx).Size = S.Size{inx};
        end
   elseif isnumeric(inx) && inx > 0.5 && inx < length(S.Address)+0.5,
       inx = round(inx);
       SP = struct('Address',S.Address{inx},...
            'Type',S.Type{inx},...
            'Alignment',S.Alignment{inx},...
            'Size',S.Size{inx}...
            );
   else
      error('getstruct requires a valid index or ''all''');
   end
    
else
    error('getstruct only accepts a single index')
end
