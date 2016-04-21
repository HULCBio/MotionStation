function reset(LoopData,Scope)
%RESET  Cleans up dependent data when core data changes.
%
%   See also SISOTOOL.

%   Author(s): P. Gahinet
%   Revised  : N. Hickey
%   Copyright 1986-2002 The MathWorks, Inc.
%   $Revision: 1.6 $  $Date: 2002/04/10 04:53:35 $

switch Scope
case 'gainC'
    % Modified C's gain: keep open loop
    LoopData.ClosedLoop = [];
    LoopData.Margins = [];
case 'gainF'
    switch LoopData.Configuration
    case {1,2}
        % Filter is not in open or closed-loop so do nothing        
    case 3
        % Filter affects closed-loop only, so clear it
        LoopData.ClosedLoop = [];
    case 4
        % Filter affects open and closed-loop so clear all
        LoopData.ClosedLoop = [];
        LoopData.Margins = [];
        LoopData.OpenLoop = [];
        LoopData.MinorLoop = [];        
    end
case 'all'
    % Sweeping change: clear all dependencies
    LoopData.ClosedLoop = [];
    LoopData.Margins = [];
    LoopData.OpenLoop = [];
    LoopData.MinorLoop = [];    
end