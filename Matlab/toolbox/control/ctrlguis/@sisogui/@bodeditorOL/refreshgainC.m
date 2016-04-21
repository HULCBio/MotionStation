function refreshgainC(Editor,action)
%REFRESHGAINC  Refreshes plot during dynamic edit of C's gain.

%   Author(s): P. Gahinet
%   Copyright 1986-2002 The MathWorks, Inc. 
%   $Revision: 1.26 $  $Date: 2002/04/10 05:02:58 $

%RE: Do not use persistent variables here (several instance of this 
%    editor may track gain changes in parallel).

switch action
    
case 'init'
    % Initialization for dynamic gain update (drag)
    % Switch editor's RefreshMode to quick
    Editor.RefreshMode = 'quick';
    
    % Get initial Y location of poles/zeros (for normalized edited model)
    hPZ = [Editor.HG.Compensator.Magnitude; Editor.HG.System.Magnitude];
    W = get(hPZ,{'Xdata'});
    W = unitconv(cat(1,W{:}),Editor.Axes.XUnits,'rad/sec');
    MagPZ = Editor.interpmag(Editor.Frequency,Editor.Magnitude,W);  % in abs units
    
    % Install listener on compensator gain (save ref in EditModeData)
    CompData = Editor.LoopData.Compensator;
    Editor.EditModeData = struct('GainListener',...
        handle.listener(CompData,findprop(CompData,'Gain'),...
        'PropertyPostSet',{@LocalUpdatePlot Editor MagPZ hPZ}));
    
    % Initialize Y limit manager
    Editor.slidelims('init',getzpkgain(CompData,'mag'));

case 'finish'
    % Return editor's RefreshMode to normal
    Editor.RefreshMode = 'normal';
    
    % Delete listener
    delete(Editor.EditModeData.GainListener);
    Editor.EditModeData = [];
    
end


%-------------------------Local Functions-------------------------

%%%%%%%%%%%%%%%%%%%%%%%
%%% LocalUpdatePlot %%%
%%%%%%%%%%%%%%%%%%%%%%%
function LocalUpdatePlot(hSrcProp,event,Editor,MagPZ,hPZ)
% Updates mag curve position
MagUnits = Editor.Axes.YUnits{1};

% Adjust position of magnitude plot
NewGain = getzpkgain(Editor.EditedObject,'mag'); 

% Update magnitude plot
% RE: Gain sign can't change in drag mode!
set(Editor.HG.BodePlot(1),'Ydata',...
    unitconv(Editor.Magnitude * NewGain,'abs',MagUnits))
Ypz = unitconv(MagPZ * NewGain,'abs',MagUnits);
for ct=1:length(hPZ)
    set(hPZ(ct),'Ydata',Ypz(ct))
end

% Update stability margins (using interpolation)
Editor.refreshmargin;

% Update Y limits
Editor.slidelims('update',NewGain);





