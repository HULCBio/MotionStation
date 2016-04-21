function aero_atcscript(varargin)
% AERO_ATCSCRIPT Controls the Air Traffic Control Demo HTML page
%   AERO_ATCSCRIPT(action) executes the hyperlink callback associated with 
%   the string action.
%
%%   BUSDEMOSCRIPT(action,blockName) is used for the hiliteblock action. blockName
%%   contains the string name of the block to be highlighted using hilite_system.
%
%   The complete set of demo files is as follows.
%      1) aero_atc.mdl
%      2) aero_atc.htm
%      3) atc_737.bmp
%      4) atc_radar.bmp
%      5) aero_atc_weather.bmp
%      6) aero_atc_callback.m
%      7) aero_atcgui.m
%      8) aero_init_atc.m
%      9) atc_Image1.gif
%     10) atc_Image2.gif
%     11) aero_atcscript.m
%     12) aero_preload_atc.m

%   Stacey Gage
%	Copyright 1990-2003 The MathWorks, Inc.
%	$Revision: 1.6.2.2 $  $Date: 2004/04/15 00:39:00 $

persistent ATC_STEP_COUNTER

ni=nargin;

if ~ni,
    step = 'initialize';
else 
    step = varargin{1};
end

% If first time running the demo, or they closed the model
if isempty(ATC_STEP_COUNTER) & ni
    open_system('aero_atc');
    % Give the atc a CloseFcn so that, when it's closed, it reinitializes the flag
    set_param('aero_atc','CloseFcn','aero_atcscript(''close'')');
    ATC_STEP_COUNTER=zeros(1,3);
end

switch step
case 'initialize',
    % Open the web browser with the html file
    fullPathName=which('aero_atcscript');
    tok=filesep;
    indtok = findstr(fullPathName,tok);
    pathname = fullPathName(1:indtok(end));
    web([pathname,'aero_atc.htm']);
    
case 'step1',
    % Open the Simulink model
    ATC_STEP_COUNTER(1)=1;
    
case 'step2',
    % Run the model
    ATC_STEP_COUNTER(2)=1;
    set_param('aero_atc','simulationcommand','start');
    
case 'step3',
    ATC_STEP_COUNTER(3)=1;
    % display information about sim command
    helpwin sim
    
case 'hiliteblock'
    %---hilite appropriate blocks
    blockName = varargin{2};
    b=find_system('aero_atc','Type','block');
    
    % First make sure everything else is turned off
    hilite_system(b,'none');
    
    % Hilite the specific block
    hilite_system(['aero_atc/',blockName],'find')
    
case 'close',
    ATC_STEP_COUNTER=[];
    h = findobj('Type','figure','Name','Air Traffic RADAR Design Parameters');
    if ~isempty(h)
      close(h);
    end
    
otherwise
    warning('The requested action could not be taken.')
    
end	 % switch action

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function modArray = StripSelection(inArray)

modArray = strrep(inArray, '??? ', '');





