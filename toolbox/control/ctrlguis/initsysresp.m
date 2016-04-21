function initsysresp(r,RespType,Prefs,RespStyle)
%INITSYSRESP  Generic initialization of system responses.
% 
%   INITSYSRESP(R,PlotType,PlotPrefs,RespStyle)

%   Author(s): P. Gahinet, B. Eryilmaz
%   Revised  : Kamesh Subbarao
%   Copyright 1986-2002 The MathWorks, Inc. 
%   $Revision: 1.34 $ $Date: 2002/05/11 17:36:45 $

% RE: * invoked by LTI methods and LTI Viewer
%     * r is a @waveform instance

% Plot-type-specific settings
TimeResp = any(strcmp(RespType,{'step','impulse','initial','lsim'}));
if TimeResp && ~isct(r.DataSrc.Model)
   % Staircase appearance for discrete-time systems 
   set(r.View,'Style','stairs')  
end

% Sync preferences
syncprefs(r.View, Prefs);

% Built-in characteristics
if TimeResp && ~strcmp(RespType,'lsim')  
   % Show steady-state line
   c = r.addchar('FinalValue','resppack.TimeFinalValueData', 'resppack.TimeFinalValueView');
   syncprefs(c.Data, Prefs); % initialize parameters
end

% User-defined plot style
if nargin>3
   r.setstyle(RespStyle)
end