function [FixedZeros,FixedPoles] = fixedpz(LoopData)
%FIXEDPZ  Get fixed poles and zeros from the calculated open-loop.

%   Author(s): P. Gahinet
%   Copyright 1986-2002 The MathWorks, Inc. 
%   $Revision: 1.7 $  $Date: 2002/04/10 04:53:01 $

% If the filter forms a minor-loop we need to find the resultant open-loop
switch LoopData.Configuration
case {1,2,3}
    FixedZeros = [LoopData.Plant.Zero ; LoopData.Sensor.Zero];
    FixedPoles = [LoopData.Plant.Pole ; LoopData.Sensor.Pole];
case 4
    [FixedZeros,FixedPoles] = zpkdata(LoopData.getminorloop,'v');
end

