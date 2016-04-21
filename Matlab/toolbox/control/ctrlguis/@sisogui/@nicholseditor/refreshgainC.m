function refreshgainC(Editor, action)
%REFRESHGAINC  Refreshes Nichols plot during dynamic edit of C's gain.

%   Author(s): Bora Eryilmaz
%   Revised:
%   Copyright 1986-2002 The MathWorks, Inc.
%   $Revision: 1.9 $ $Date: 2002/04/10 05:05:05 $

%RE: Do not use persistent variables here (several instance of this 
%    editor may track gain changes in parallel).

switch action
 case 'init'
  % Initialization for dynamic gain update (drag)
  % Switch editor's RefreshMode to quick
  Editor.RefreshMode = 'quick';
  
  % Get initial Y location of poles/zeros (for normalized compensator)
  HG = Editor.HG;
  
  % Handles of Nichols plot objects (zero/pole markers for plant/compensator)
  hPZ = [HG.System ; HG.Compensator];

  % Get frequency data of corresponding objects in rad/sec
  FreqPZ = get(hPZ, {'UserData'});
  FreqPZ = cat(1, FreqPZ{:});

  % Compute interpolated Magnitude locations (in absolute units)
  MagPZ = Editor.interpmag(Editor.Frequency, Editor.Magnitude, FreqPZ);
  
  % Install listener on gain data
  CompData = Editor.LoopData.Compensator;
  Editor.EditModeData = struct('GainListener', ...
	handle.listener(CompData, findprop(CompData, 'Gain'), ...
       'PropertyPostSet', {@LocalUpdatePlot Editor MagPZ hPZ}));

  % Initialize Y limit manager
  Editor.slidelims('init', getzpkgain(CompData,'mag'));
  
 case 'finish'
  % Return editor's RefreshMode to normal
  Editor.RefreshMode = 'normal';
  
  % Delete listener
  delete(Editor.EditModeData.GainListener);
  Editor.EditModeData = [];
end


% ----------------------------------------------------------------------------%
% Local Functions
% ----------------------------------------------------------------------------%

% ----------------------------------------------------------------------------%
% Function: LocalUpdatePlot
% Updates Nichols plot curve and pole/zero markers' position.
% ----------------------------------------------------------------------------%
function LocalUpdatePlot(hSrc, event, Editor, MagPZ, hPZ)

% Gwet new compensator gain
NewGain = getzpkgain(Editor.EditedObject,'mag');

% Update Nichols plot
% REMARK: Gain sign can't change in drag mode!
set(Editor.HG.NicholsPlot, 'Ydata', mag2dB(Editor.Magnitude * NewGain))
set(hPZ,{'Ydata'},num2cell(mag2dB(MagPZ * NewGain)))

% Update stability margins (using interpolation)
Editor.refreshmargin;

% Update Y limits
Editor.slidelims('update', NewGain);
