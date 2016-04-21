function refreshpzF(Editor,event,varargin)
%REFRESHPZF  Refreshes open-loop plots during dynamic edit of F's poles and zeros.

%   Author(s): N. Hickey
%   Copyright 1986-2002 The MathWorks, Inc. 
%   $Revision: 1.10 $  $Date: 2002/04/10 05:03:19 $

% Only need to update the open-loop plot when filter forms a minor-loop
if Editor.LoopData.Configuration~=4
    return
end

% Process events
switch event 
case 'init'
    % Initialization for dynamic gain update (drag).
    PZGroup = varargin{1};     % Modified PZGROUP
    
    % Switch editor's RefreshMode to quick
    Editor.RefreshMode = 'quick';      
    
    % Hide "fixed" poles and zeros (their number may change with F)
    set([Editor.HG.System.Magnitude;Editor.HG.System.Phase],'Visible','off')
      
    % Include C's x and o frequencies in main freq. vector
    hPZ  = [Editor.HG.Compensator.Magnitude; Editor.HG.Compensator.Phase]; 
    Wpz = get(hPZ,{'Xdata'});    
    Wpz = unitconv(cat(1,Wpz{:}),Editor.Axes.XUnits,'rad/sec');   
    W = [Editor.Frequency; Wpz]; 
    [junk,is] = sort(W);    % sorting needed to unwrap phase

    % Precompute frequency response of loop components
    LoopData = Editor.LoopData;
    S = LoopData.freqresp(W);
    S.F = getzpkgain(LoopData.Filter,'mag') * S.F;

      % Install listener on PZGROUP data and store listener reference  
    % Note that although listener is activated when a p/z moves the OL gain will change 
    InitPhase = round(Editor.Phase(1)/180);  % initial phase (as multiple of 180)
    L = handle.listener(PZGroup,'PZDataChanged',... 
       {@refreshplot W S InitPhase is get(PZGroup) PZGroup});
    L.CallbackTarget = Editor;
    Editor.EditModeData = L;
        
case 'finish'
    % Clean up after dynamic gain update (drag)
    % Return editor's RefreshMode to normal
    Editor.RefreshMode = 'normal';
    
    % Delete gain listener
    delete(Editor.EditModeData);    
    Editor.EditModeData = [];
       
end