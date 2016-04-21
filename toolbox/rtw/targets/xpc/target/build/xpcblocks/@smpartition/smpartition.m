function S = smpartition(varargin)
% SMPARTITION Shared Memory partitioning class 
%  S=SMPARTITION(PSTR)
%  S=SMPARTITION(POBJ)
% 

% Copyright 2004 The MathWorks, Inc.


% We accept multiple arguments, this appends them as needed
default.Address = [];
default.Type = [];
default.Alignment = [];
default.Size = [];  
default.Internal = [];
default.NBytes = [];  % Used internally : Bytes per segment (includes alignment)
S = class(default,'smpartition');
if nargin == 0 || isempty(varargin{1}),
    sin.Address = '0x0';
    sin.Type = 'uint32';
    sin.Alignment = '4';
    sin.Size = '1';
    S = append(S,sin);
else
    for j = 1:length(varargin),  % Merge all entries
        sins = varargin{j};
        if iscell(sins),  % Append entries in cell array (useful for derived class)
            for inxS = 1:numel(sins),
                if inxS > numel(S),
                    S(inxS) = class(default,'smpartition');
                end
                S(inxS) = append(S(inxS),sins{inxS});
            end
        elseif isa(sins,'smpartition')  % Copy constructor (pass through)
            S = sins;
            return;
        else
            S = append(S,sins);
        end
    end
end
