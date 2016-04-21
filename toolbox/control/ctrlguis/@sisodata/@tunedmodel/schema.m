function schema
%SCHEMA  Schema for tunable SISO model class.

%   Author(s): P. Gahinet
%   Copyright 1986-2002 The MathWorks, Inc. 
%   $Revision: 1.4 $ $Date: 2002/04/10 04:54:46 $

% Register class 
c = schema.class(findpackage('sisodata'),'tunedmodel');

% Public properties
schema.prop(c,'Identifier','string');  % Model identifier
schema.prop(c,'Name','string');        % Model name
schema.prop(c,'Format','string');      % Model format
% TimeConstant1: (1 + T s)   
% TimeConstant2: (1 + s/p)
% ZeroPoleGain:  (s + p)
schema.prop(c,'PZGroup','handle vector');   % Pole/zero groups
schema.prop(c,'Gain','MATLAB array');       % Formatted gain (struct w/ fields Magnitude and Sign)
% The formatted gain 
%    F_Gain = Gain.Magnitude * Gain.Sign 
% corresponds to:
%    TimeConstant1-2 --> DC gain
%    ZeroPoleGain    --> ZPK model gain
% For all formats, the zpk gain is derived from the formatted gain by
%    ZPK_Gain =  FormatFactor * F_Gain
% where 
%    FormatFactor = formatfactor(tunedmodel)
schema.prop(c,'Ts','double');               % Sample time 
 
% Private properties
p = schema.prop(c,'Listeners','handle vector');  % Listeners
set(p,'AccessFlags.PublicGet','off','AccessFlags.PublicSet','off');
    
