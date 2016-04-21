% $Revision: 1.1.4.1 $
% $Date: 2004/04/11 00:15:30 $
%
% Copyright 1994-2004 The MathWorks, Inc.
%
% Abstract:
%   Data for rtwdemo_udt.mdl

clear;

ENG_SPEED = Simulink.NumericType;
ENG_SPEED.Description = 'Engine speed type';
ENG_SPEED.Category = 'Single';
ENG_SPEED.IsAlias = true; % Alias to single

S16 = Simulink.AliasType;
S16.Description = 'Alias to ENG_SPEED';
S16.BaseType = 'ENG_SPEED';
