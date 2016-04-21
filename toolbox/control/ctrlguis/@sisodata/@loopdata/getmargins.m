function Margins = getmargins(LoopData)
%GETMARGINS  Computes stability margins.

%   Authors: P. Gahinet
%   Copyright 1986-2002 The MathWorks, Inc. 
%   $Revision: 1.13 $  $Date: 2002/04/10 04:53:04 $

% RE: not called unless OpenLoop is well defined

% Quick exit if margin data is uptodate
Margins = LoopData.Margins;
if isempty(LoopData.Plant.Model) | ~isempty(Margins)
    return
end
    
% Compute margins
% RE: Units are: GM(absolute)  Pm(degree)  Wcg,Wcp(radians/sec)
lwarn = lastwarn; warn = warning('off'); 
[Gm,Pm,Wcg,Wcp,isStable] = ...
   margin(getzpkgain(LoopData.Compensator,'mag') * getopenloop(LoopData));
warning(warn); lastwarn(lwarn);

% Build and store result
Margins = struct('Gm',Gm,'Pm',Pm,'Wcg',Wcg,'Wcp',Wcp,'Stable',isStable);
LoopData.Margins = Margins;
