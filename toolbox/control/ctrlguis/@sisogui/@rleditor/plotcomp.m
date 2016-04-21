function plotcomp(Editor)
%PLOTCOMP  Renders compensator poles and zeros.

%   Author(s): P. Gahinet
%   Copyright 1986-2002 The MathWorks, Inc. 
%   $Revision: 1.19 $ $Date: 2002/04/10 04:57:47 $

% Get pole/zero group information
PZGroups = Editor.EditedObject.PZGroup;
Nf = length(PZGroups);  % number of groups after update

% Initialize list of PZ group renderers (@PZVIEW objects)
Nc = length(Editor.EditedPZ);  % current number of PZVIEW objects
% Delete extra groups
if Nc>Nf,
    delete(Editor.EditedPZ(Nf+1:Nc));
    Editor.EditedPZ = Editor.EditedPZ(1:Nf,:);
end
% Add new groups
for ct=Nc+1:Nf,
    Editor.EditedPZ = [Editor.EditedPZ ; sisogui.pzview];
end

% Render each pole/zero group
PlotAxes = getaxes(Editor.Axes);
HG = Editor.HG;  
HG.Compensator = zeros(0,1);
for ct=1:Nf
    h = Editor.EditedPZ(ct);  % @pzview object rendering PZ group #CT
    h.GroupData = PZGroups(ct);
	HG.Compensator = [HG.Compensator ; LocalRender(h,PlotAxes,Editor)];
end
Editor.HG = HG;


%----------------- Local functions -----------------

%%%%%%%%%%%%%%%
% LocalRender %
%%%%%%%%%%%%%%%
function hPZ = LocalRender(hView,PlotAxes,Editor)
% Renders pole/zero group
% HVIEW = @PZVIEW object rendering a given pole/zero group
% hPZ = handles of created HG objects (no repetition)

Style = Editor.LineStyle;
Zlevel = Editor.zlevel('compensator');

% Render zeros
Zeros = hView.GroupData.Zero;   % zero values
hZeros = zeros(size(Zeros));
for ct=1:length(hZeros)
    hZeros(ct) = line(real(Zeros(ct)),imag(Zeros(ct)),Zlevel,...
        'LineStyle','none',...
        'Color',Style.Color.Compensator,...
        'Marker','o','MarkerSize',6,...
        'Parent',PlotAxes,...
        'HelpTopicKey','sisocompensatorpolezero',...
        'ButtonDownFcn',{@LocalMovePZ Editor 'init'}); 
	setappdata(hZeros(ct),'PZVIEW',hView);
end
hView.Zero = hZeros;

% Render poles
Poles = hView.GroupData.Pole;   % pole values
hPoles = zeros(size(Poles));
for ct=1:length(hPoles)
    hPoles(ct) = line(real(Poles(ct)),imag(Poles(ct)),Zlevel,...
        'LineStyle','none',...
        'Color',Style.Color.Compensator,...
        'Marker','x','MarkerSize',8,...
        'Parent',PlotAxes,...
        'HelpTopicKey','sisocompensatorpolezero',...
        'ButtonDownFcn',{@LocalMovePZ Editor 'init'});  
	setappdata(hPoles(ct),'PZVIEW',hView);
end
hView.Pole = hPoles;

% Overall list of HG objects
hPZ = [hZeros;hPoles];

%%%%%%%%%%%%%%%%%%%
%%% LocalMovePZ %%%
%%%%%%%%%%%%%%%%%%%
function LocalMovePZ(hSrc,junk,Editor,action)
% Callback for button down on closed-loop poles
% REVISIT: merge with trackpz when directed callbacks are available
persistent SISOfig WBMU

switch action
case 'init'
	% Initialize move
	SISOfig = gcbf;
	if ~strcmp(Editor.EditMode,'idle')
        % Redirect to editor axes
        Editor.mouseevent('bd',get(hSrc,'parent'));
    elseif strcmp(get(SISOfig,'SelectionType'),'normal')
		% Change pointer
        setptr(SISOfig,'closedhand')
		% Take over window mouse events
		WBMU = get(SISOfig,{'WindowButtonMotionFcn','WindowButtonUpFcn'});
		set(SISOfig,'WindowButtonMotionFcn',{@LocalMovePZ Editor 'acquire'},...
			'WindowButtonUpFcn',{@LocalMovePZ Editor 'finish'});
        % Initialize tracking algorithm and notify peers
        Editor.trackpz('init');
    end
case 'acquire'
	% Track mouse location (move)
	Editor.trackpz('acquire');
case 'finish'
	% Restore initial conditions
	set(SISOfig,{'WindowButtonMotionFcn','WindowButtonUpFcn'},WBMU,'Pointer','arrow')
	% Clean up and update
	Editor.trackpz('finish');
end
