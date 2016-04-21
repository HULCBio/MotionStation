function slidelims(Editor, action, Gain, varargin)
%SLIDELIMS  Manages Y limits during gain refresh.

%   Author(s): Bora Eryilmaz
%   Revised:
%   Copyright 1986-2002 The MathWorks, Inc. 
%   $Revision: 1.13 $  $Date: 2002/04/10 05:06:21 $

% Quick exit
if strcmp(Editor.Axes.YlimMode, 'manual')
  return
end

% REMARK: Used by trackgain & refreshgainC/F 
PlotAxes = getaxes(Editor.Axes);
MoveData = Editor.EditModeData;  % persistent move data

switch action
case 'init'
   % Initialize Y limit manager
   %    Editor.slidelims('init', Gain)
   %    Editor.slidelims('init', Gain, 'mousetrackon')
   MoveData.MagRange = 20*log10(Editor.xyextent('mag'));
   MoveData.OldGain  = 20*log10(Gain);  % current gain in dB
   if nargin > 3
      % Initialize pointer motion control
      moveptr(PlotAxes,'init');
   end
   
case 'update'
   % Update limits during move
   NewGain = 20*log10(Gain);
   
   % Determine if mag limits must be updated
   if NewGain ~= MoveData.OldGain
      % protect against repeat call trackgain -> refreshgain
      if isinf(MoveData.OldGain)
         % No plot previously shown: set limits
         updateview(Editor)
      else
         % Keep plot within focus by shifting Y limits
         MovePtr = LocalShiftLims(Editor, ...
            MoveData.MagRange+NewGain, NewGain-MoveData.OldGain);
         if MovePtr & (nargin > 3)
            % Reposition mouse pointer 
            moveptr(PlotAxes,'move',varargin{:});
         end
      end
      % Store new gain value (in dB)
      MoveData.OldGain = NewGain;    
   end
end
Editor.EditModeData = MoveData;


%---------------------- Local functions -------------------------------
function MovePtr = LocalShiftLims(Editor, MagRange, yTravel)
% Shift mag limits to keep magnitude plot in focus while dragging it.

%RE: MagRange is in dB, yTravel is in dB
Axes = Editor.Axes;
PlotAxes = getaxes(Axes);
yTravel = sign(yTravel)*min(20, abs(yTravel));  % to limit Ylim expansion
MagLimdB = get(PlotAxes, 'Ylim');
ExtraJump = 20;

% Determine if mag. plot is slipping out of focus
HalfRange = (MagRange(2)-MagRange(1)) / 2;
MovePtr = (isfinite(HalfRange) & ...
   (MagRange(1) < MagLimdB(1)-min(20, HalfRange) | MagRange(2) > MagLimdB(2)));

if MovePtr
  % Adjust limits
  if yTravel > 0 
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
  Axes.setylim(MagLimdB,1,'basic');
  Axes.send('PostLimitChanged')
end
