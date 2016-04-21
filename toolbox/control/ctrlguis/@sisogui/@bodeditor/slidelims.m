function slidelims(Editor,action,Gain,varargin)
%SLIDELIMS  Manages Y limits during gain refresh.

%   Author(s): P. Gahinet
%   Copyright 1986-2002 The MathWorks, Inc. 
%   $Revision: 1.8 $  $Date: 2002/04/10 04:56:36 $

if strcmp(Editor.Axes.YlimMode{1},'manual')
    % Quick exit
    return
end

% RE: Used by trackgain & refreshgainC/F 
MagAx = getaxes(Editor.Axes);  MagAx = MagAx(1);
MoveData = Editor.EditModeData;  % persistent move data

switch action
case 'init'
    % Initialize Y limit manager
    %    Editor.slidelims('init',Gain)
    %    Editor.slidelims('init',Gain,'mousetrackon')
    MoveData.MagRange = 20*log10(Editor.yextent('mag'));
    MoveData.OldGain = 20*log10(Gain);  % current gain in dB
    if nargin>3
        % Initialize pointer motion control
        moveptr(MagAx,'init');
    end
    
case 'update'
    % Update limits during move
    NewGain = 20*log10(Gain);
    
    % Determine if mag limits must be updated
    if NewGain~=MoveData.OldGain,  % protect against repeat call trackgain->refreshgain
        if isinf(MoveData.OldGain) 
            % No plot previously shown: set limits
            updateview(Editor)
        else
            % Keep plot within focus by shifting Y limits
            MovePtr = LocalShiftLims(Editor,...
                MoveData.MagRange+NewGain,NewGain-MoveData.OldGain);
            if MovePtr & nargin>3
                % Reposition mouse pointer 
                moveptr(MagAx,'move',varargin{:});
            end
        end
        % Store new gain value (in dB)
        MoveData.OldGain = NewGain;    
    end
end

Editor.EditModeData = MoveData;


%---------------------- Local functions -------------------------------

function MovePtr = LocalShiftLims(Editor,MagRange,yTravel)
% Shift mag limits to keep magnitude plot in focus while dragging it.

%RE: MagRange is in dB
Axes = Editor.Axes;
MagAxes = getaxes(Axes);  MagAxes = MagAxes(1);
MagUnits = Axes.YUnits{1};
yTravel = sign(yTravel)*min(40,abs(yTravel));  % to limit Y lim expansion

% Convert mag. limits to dB
MagLimdB = get(MagAxes,'Ylim');
if strcmp(MagUnits,'abs')
    MagLimdB(1) = max(MagLimdB(1),eps*MagLimdB(2));
    MagLimdB = 20*log10(MagLimdB);
    ExtraJump = 0;
else
    ExtraJump = 20;
end

% Determine if mag. plot is slipping out of focus
HalfRange = (MagRange(2)-MagRange(1))/2;
MovePtr = (isfinite(HalfRange) & ...
   (MagRange(1)<MagLimdB(1)-min(20,HalfRange) | MagRange(2)>MagLimdB(2)));

if MovePtr
   % Adjust limits
   if yTravel>0 
      % Up
      MagLimdB(1) = 20*floor(MagRange(1)/20);
      MagLimdB(2) = 20*ceil(MagRange(2)/20) + ExtraJump * ceil(yTravel/20);
   else
      % Down
      MagLimdB(1) = 20*floor(MagRange(1)/20) - ExtraJump * ceil(-yTravel/20);
      MagLimdB(2) = 20*ceil(MagRange(2)/20);
   end
   
   % Set new limits
   % RE: Protected set to avoid any side effects, including change in YlimMode
   Axes.setylim(unitconv(MagLimdB,'dB',MagUnits),1,'basic');
   Axes.send('PostLimitChanged')
end

