function refreshpzC(Editor,event,varargin)
%REFRESHPZC  Refreshes plot during dynamic edit of C's poles and zeros.

%   Author(s): P. Gahinet
%   Revised  : N. Hickey
%   Copyright 1986-2002 The MathWorks, Inc. 
%   $Revision: 1.23 $  $Date: 2002/04/10 04:58:05 $

% Process events
switch event 
case 'init'   
    % Switch editor's RefreshMode to quick
    Editor.RefreshMode = 'quick';
    
    % Use NGAINS gain values for root locus refreshing
    nGains = 25;  % Number of gain values while dragging
    MinGain = log10(Editor.LocusGains(2));
    MaxGain = log10(Editor.LocusGains(end-2));
    LocusGains = [Editor.LocusGains(1) , ...
            logspace(MinGain,max(MinGain+1,MaxGain),nGains) , ...
            Editor.LocusGains(end-1:end)];
    
    % Initialization for dynamic gain update (drag).
    PZGroup = varargin{1};    % Modified PZGROUP (C or F)
    
    % Install listener on PZGROUP data
    L = handle.listener(PZGroup,'PZDataChanged',...
       {@LocalUpdatePlot Editor LocusGains});
    L.CallbackTarget = PZGroup;
    Editor.EditModeData = L;
    
case 'finish'
    % Clean up after dynamic gain update (drag)
    % Return editor's RefreshMode to normal
    Editor.RefreshMode = 'normal';
    
    % Delete listener
    delete(Editor.EditModeData);
    Editor.EditModeData = [];
end


%%%%%%%%%%%%%%%%%%%%%%%
%%% LocalUpdatePlot %%%
%%%%%%%%%%%%%%%%%%%%%%%
function LocalUpdatePlot(PZGroup,eventData,Editor,LocusGains)
% Update plot by moving compensator pole/zero and redrawing locus

% Identify moved PZVIEW group (corresponding to PZGROUP)
MovedGroup = Editor.EditedPZ(Editor.EditedObject.PZGroup==PZGroup);

% Update position of moved pole/zero
MovedHandles = [MovedGroup.Zero;MovedGroup.Pole];
NewValues = [PZGroup.Zero;PZGroup.Pole];
for ct=1:length(MovedHandles)
    set(MovedHandles(ct),...
        'Xdata',real(NewValues(ct)),'Ydata',imag(NewValues(ct)))
end

% Update root locus plot for compensator
Editor.refreshplot([], LocusGains, 0);