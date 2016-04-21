function M = getBlockedMoves(this)

% Blocking strategy depends on move allocation specification

% Author(s): Larry Ricker
% Revised:
% Copyright 1986-2003 The MathWorks, Inc. 
% $Revision: 1.1.8.2 $ $Date: 2003/10/15 18:48:06 $

Moves = evalin('base', this.BlockMoves);
P = evalin('base', this.P);
if Moves > P
    Moves = P;
end            
switch this.BlockAllocation
    case 'Beginning'
        M = [ones(1,Moves-1), P-Moves];
    case 'End'
        M = [P-Moves, ones(1,Moves-1)];
    case 'Uniform'
        M = [fix(P/Moves)*ones(1,Moves-1)];
        M = [M, P-sum(M)];
    case 'Custom'
        M = evalin('base',this.CustomAllocation);
    otherwise
        warning(sprintf(['Unexpected block allocation "%s".', ...
                '  Used "Beginning".'],this.BlockAllocation))
end
