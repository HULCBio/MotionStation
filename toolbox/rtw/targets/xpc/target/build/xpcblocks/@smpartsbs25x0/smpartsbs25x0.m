function S = smpartsbs25x0(varargin)
% SMPARTSBS25x0  Shared Memory partitioning class with extensions for SBS 25x0 
%  S=smpartsbs25x0(PSTR)
%  S=smpartsbs25x0(POBJ)
% 

%   Copyright 2004 The MathWorks, Inc. 
%   $Revision: 1.1.6.1 $  $Date: 2004/01/22 18:35:01 $
if nargin == 0 || (nargin > 0 && isempty(varargin{1})),
    SM = smpartition;
    SWit.WIT = {'off'};
    S = class(SWit,'smpartsbs25x0',SM);
    return;
end
    % Grab FIRST entry
    if iscell(varargin{1}),
        firstentry = varargin{1}{1};
        varargin{1}{1} = []; % Do NOT append it!        
    else
        firstentry = varargin{1};
        varargin{1} = []; % Do NOT append it!
    end
    % First entry creates the class
    if isa(firstentry,'smpartsbs25x0')
         % Special case, copy constructor 
        S = firstentry;
    elseif isa(firstentry,'smpartition')
        sins = firstentry;
        for inxS=1:numel(sins),
            for inxW = 1:numseg(sins),
                SWit(1).WIT{inxW} = 'off';
            end
            S(inxS) = class(SWit,'smpartsbs25x0',sins);
        end
    elseif isa(firstentry,'struct'),
        pstruct = firstentry;
        sins = smpartition(firstentry);
        for inxS=1:numel(sins),
            sin = sins(inxS);
            SWit(1).WIT = cell(1,numseg(sin));
            for inxE = 1:numseg(sin),
                if isfield(pstruct,'WIT');
                    if isempty(pstruct(inxE).WIT),
                        pstruct(inxE).WIT = 'off';
                    else
                        inxW = strmatch(lower(pstruct(inxE).WIT),['first';'last ';'all  ';'off  ';'[]   ']);
                        if isempty(inxW),
                            error('WIT parameter limited to ''first'',''last'',''all'' and ''off''');
                        end
                        if inxW == 5,
                            pstruct(inxE).WIT = 'off';
                        end
                    end
                    SWit(1).WIT{inxE} = lower(pstruct(inxE).WIT);
                else
                    SWit(1).WIT{inxE} = 'off';
                end
            end
            S(inxS) = class(SWit,'smpartsbs25x0',sin);
        end
    else
        error('smpartsbs25x0 requires a partition structure or object to be contructed');
    end
    % The Rest get appended....
    nr = length(varargin);
    for ir = 1:nr,
        if iscell(varargin{ir}),
            nc = length(varargin{ir}),
            for ic = 1:nc,
                for inxS=1:numel(S),
                    if ~isempty(varargin{ir}{ic}),
                        S(inxS) = append(S(inxS),varargin{ir}{ic});
                    end
                end      
            end
        else
            for inxS=1:numel(S),
                if ~isempty(varargin{ir}),                
                    S(inxS) = append(S(inxS),varargin{ir});
                end
            end      
        end
    end

end


