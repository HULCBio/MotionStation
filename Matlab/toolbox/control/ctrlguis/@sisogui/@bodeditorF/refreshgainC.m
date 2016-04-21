function refreshgainC(Editor,action)
%REFRESHGAINC  Refreshes plot during dynamic edit of C's gain.

%   Author(s): P. Gahinet
%   Copyright 1986-2002 The MathWorks, Inc. 
%   $Revision: 1.9 $  $Date: 2002/04/10 05:03:58 $

%RE: Do not use persistent variables here (several instance of this 
%    editor may track gain changes in parallel).

% Nothing to do if closed-loop plot is not shown
if strcmp(Editor.ClosedLoopVisible,'off')
    return
end

switch action
    
case 'init'
    % Initialization for dynamic gain update (drag)
    % Switch editor's RefreshMode to quick
    Editor.RefreshMode = 'quick';
    
    % Compute frequency response of loop components
	S = Editor.LoopData.freqresp(Editor.ClosedLoopFrequency);
	S.F = S.F * getzpkgain(Editor.EditedObject,'mag');

    % Install listener on compensator gain
    CompData = Editor.LoopData.Compensator;
    Editor.EditModeData = struct('GainListener',...
        handle.listener(CompData,findprop(CompData,'Gain'),...
        'PropertyPostSet',{@LocalUpdatePlot Editor S}));
    
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
function LocalUpdatePlot(hSrcProp,event,Editor,S)
% Updates mag curve position
LoopData = Editor.LoopData;

% Compute updated closed-loop response
GainC = getzpkgain(LoopData.Compensator,'mag'); 
CG = GainC * S.C .* S.G; 
FG = S.F .* S.G;
ReturnDifference = (1 - LoopData.FeedbackSign * CG .* S.H);

switch LoopData.Configuration
case 1
	CL = S.F .* CG ./ ReturnDifference;
case 2
	CL = FG ./ ReturnDifference;
case 3
	CL = (FG + CG) ./ ReturnDifference;
case 4
    CL = CG ./ (ReturnDifference - FG .* S.H);
end

% Update closed-loop plot
set(Editor.HG.BodePlot(1,2),'Ydata',...
	unitconv(abs(CL),'abs',Editor.Axes.YUnits{1}))
set(Editor.HG.BodePlot(2,2),'Ydata',...
	unitconv(unwrap(angle(CL)),'rad',Editor.Axes.YUnits{2}))

