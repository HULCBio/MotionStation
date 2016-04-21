function refreshgainF(Editor,action)
%REFRESHGAINF  Refreshes plot during dynamic edit of F's gain.

%   Author(s): P. Gahinet
%   Revised:   N. Hickey
%   Copyright 1986-2002 The MathWorks, Inc. 
%   $Revision: 1.13 $  $Date: 2002/04/10 05:04:03 $

%RE: Do not use persistent variables here (several instance of this 
%    editor may track gain changes in parallel).

switch action
    
case 'init'
    % Initialization for dynamic gain update (drag)
    % Switch editor's RefreshMode to quick
    Editor.RefreshMode = 'quick';
    % Get initial Y location of poles/zeros (for normalized edited model)
    hPZ = Editor.HG.Compensator.Magnitude;
    W = get(hPZ,{'Xdata'});
    W = unitconv(cat(1,W{:}),Editor.Axes.XUnits,'rad/sec');
    MagPZ = Editor.interpmag(Editor.Frequency,Editor.Magnitude,W);  % in abs units
    
    % Install listener on filter gain (save it in EditModeData)
    LoopData = Editor.LoopData;
    if strcmp(Editor.ClosedLoopVisible,'on') & ...
          any(LoopData.Configuration==[3 4])
       % Precompute frequency response to speed up closed loop update
       S = freqresp(LoopData,Editor.ClosedLoopFrequency);
       S.C = S.C * getzpkgain(LoopData.Compensator,'mag'); 
    else 
       S = [];
    end
    GL = handle.listener(LoopData.Filter,findprop(LoopData.Filter,'Gain'),...
       'PropertyPostSet',{@LocalUpdatePlot MagPZ hPZ S});
    GL.CallbackTarget = Editor;
    Editor.EditModeData = struct('GainListener',GL);
    
    % Initialize Y limit manager
    Editor.slidelims('init',getzpkgain(LoopData.Filter,'mag'));
    
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
function LocalUpdatePlot(Editor,event,MagPZ,hPZ,S)
% Updates mag curve position
MagUnits = Editor.Axes.YUnits{1};
LoopData = Editor.LoopData;
GainF = getzpkgain(Editor.EditedObject,'mag'); 

% Update filter magnitude plot
% RE: Gain sign can't change in drag mode!
set(Editor.HG.BodePlot(1,1),'Ydata',...
    unitconv(Editor.Magnitude * GainF,'abs',MagUnits))
Ypz = unitconv(MagPZ * GainF,'abs',MagUnits);
for ct=1:length(hPZ)
    set(hPZ(ct),'Ydata',Ypz(ct))
end

% Update closed-loop plot
if strcmp(Editor.ClosedLoopVisible,'on')
    switch LoopData.Configuration
    case {1,2}
        % A pre-filter setup is being used so a lightweight update calculation is possible        
        set(Editor.HG.BodePlot(1,2),'Ydata',...
            unitconv(Editor.ClosedLoopMagnitude * GainF,'abs',MagUnits))
        
    case {3,4}        
        % Compute updated closed-loop response
        CG  = S.C .* S.G; 
        FG  = GainF * S.F .* S.G;
        ReturnDifference = (1 - LoopData.FeedbackSign * CG .* S.H);
        switch LoopData.Configuration
        case 3
            CL = (FG + CG) ./ ReturnDifference;
        case 4
            CL = CG ./ (ReturnDifference - FG .* S.H);                        
        end
        
        % Filter is in the closed-loop therefore the phase will change
        set(Editor.HG.BodePlot(1,2),'Ydata', unitconv(abs(CL),'abs',MagUnits));
        set(Editor.HG.BodePlot(2,2),'Ydata', ...
            unitconv(unwrap(angle(CL)),'rad',Editor.Axes.YUnits{2}));        
    end
    
end    

% Update Y limits
Editor.slidelims('update',GainF);

