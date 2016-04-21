function pj = prepareui( pj, Fig )
%PREPAREUI Method to draw Uicontrol objects in output.
%   Mimics user interface objects as Images so they appear in output.
%   Takes screen captures of user interface objects and creates true  
%   color Images in the same location as the user interface objects so 
%   the uicontrols themselves seem to print (which they can not because
%   they are drawn by the windowing system, not MATLAB).
%
%   Ex:
%      pj = PREPAREUI( pj, h ); %modifies PrintJob object pj and creates
%                               %Images of Uicontrols in Figure h
%
%   See also PREPARE, RESTORE, PREPAREHG, RESTOREUI.

%   Copyright 1984-2002 The MathWorks, Inc. 
%   $Revision: 1.8 $  $Date: 2002/04/10 17:10:31 $

error( nargchk(2,2,nargin) )

if ~isequal(size(Fig), [1 1]) | ~isfigure( Fig )
    error( 'Need a handle to a Figure object.' )
end
    
%Early exist if the user has requested not to see controls in output.
if ~pj.PrintUI
    return
end

%Bail if device doesn't support TC images.
if  strcmp( pj.Driver, 'hpgl' ) | strcmp( pj.Driver, 'ill' )
    pj.UIData = [];
    return
end

%Now that we know it is a Figure, see if there is anything to do
pj.UIData.UICHandles = findall(Fig,'Type','uicontrol','Visible','on');
if isempty(pj.UIData.UICHandles)
    pj.UIData = [];
    return
end
    

ComputerType=computer;
pj.UIData.OldRootUnits=get(0,'Units');
pj.UIData.OldFigUnits=get(Fig,'Units');
pj.UIData.OldFigPosition=get(Fig,'Position');
pj.UIData.OldFigVisible=get(Fig,'Visible');
set( Fig, 'units', 'points' )
pj.UIData.MovedFigure = screenpos( Fig, get( Fig, 'position' ) );
pj.UIData.OldFigCMap=get(Fig,'Colormap');

set([0 Fig],'Units','pixels');

%%% UI Controls %%%

pj.UIData.AxisHandles = [];
Frame = [];
FrameNum = 0;
if ~isempty(pj.UIData.UICHandles)
    % Making the assumption that the bottom uicontrol is usually
    % created first and underneath the others.
    pj.UIData.UICHandles=flipud(pj.UIData.UICHandles);
    pj.UIData.UICUnits=get(pj.UIData.UICHandles,{'Units'});
    set(pj.UIData.UICHandles,'Units','pixels');
    
    for Clp=1:length(pj.UIData.UICHandles)
        FrameFlag=1;
        CurCtrlPos = rectaroundcontrol( pj.UIData.UICHandles(Clp) );
        CurCtrlUnits = pj.UIData.UICUnits{Clp};
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %Check to see if completely contained in previous frames
        %and that the framing control has same units (so the scale similarly)
        for Frmlp=1:FrameNum
            if CurCtrlPos(1)>=Frame{Frmlp}.Pos(1) & ...
                    CurCtrlPos(2)>=Frame{Frmlp}.Pos(2) & ...
                    sum(CurCtrlPos([1 3]))<=sum(Frame{Frmlp}.Pos([1 3])) & ...
                    sum(CurCtrlPos([2 4]))<=sum(Frame{Frmlp}.Pos([2 4])) & ...
                    strcmp( Frame{Frmlp}.Units, CurCtrlUnits )
                
                FrameFlag=0;
                break;
            end % if CurCtrlPos
        end % Frmlp
        
        %%%%%%%%%%%%%%%%%%%
        % It is the first, or a new frame
        if FrameNum > 0
            RmvFrmLoc=[];
            if FrameFlag,
                for inlp=1:length(Frame),
                    if CurCtrlPos(1)>=Frame{inlp}.Pos(1) & ...
                            CurCtrlPos(2)>=Frame{inlp}.Pos(2) & ...
                            sum(CurCtrlPos([1 3]))<=sum(Frame{inlp}.Pos([1 3])) & ...
                            sum(CurCtrlPos([2 4]))<=sum(Frame{inlp}.Pos([2 4])) & ...
                            strcmp( Frame{Frmlp}.Units, CurCtrlUnits )
                        
                        % New Frame Contains an old frame
                        RmvFrmLoc=[RmvFrmLoc inlp];
                    end
                end
                
                if ~isempty( RmvFrmLoc )
                    Frame(RmvFrmLoc) = [];
                end
                FrameNum=length(Frame)+1;
                Frame{FrameNum}.Pos = CurCtrlPos;
                Frame{FrameNum}.Units = CurCtrlUnits;
            end % if FrameFlag
            
        else
            Frame{1}.Pos = CurCtrlPos;
            Frame{1}.Units = CurCtrlUnits;
            FrameNum=1;
        end % if FrameNum
    end % for Clp
    
end % if ~isempty(UIC)


%%% Create images %%%

if FrameNum > 0
    CapturedImages = [];
    CapturedMaps = [];
    
    %Pop it to top of window stacking order
    figure( Fig )
    
    % Capture images for each uicontrol first
    prevWarnState=warning;
    warning('off');
    for lp=1:length(Frame)
        if feature('NewMovieFormat')
            CapturedImages{lp} = getframe(Fig,Frame{lp}.Pos(:)); 
        else
            [CapturedImages{lp}.cdata, CapturedImages{lp}.colormap]=getframe(Fig,Frame{lp}.Pos(:));
        end
    end
    warning(prevWarnState);
    
    %reinstate warning status
    
    % Draw each image to stand in for the uicontrols
    for lp=1:length(Frame)
        if ~isempty(CapturedImages{lp})
            if ~isempty( CapturedImages{lp}.colormap )
                CapturedImages{lp}.cdata = ind2rgb(CapturedImages{lp}.cdata, CapturedImages{lp}.colormap);    
                CapturedImages{lp}.colormap = [];
            end
            
            pj.UIData.AxisHandles(lp)=axes('Parent',Fig, ...
                'Units'         ,'pixels'        , ...
                'Position'      ,Frame{lp}.Pos(:), ...
                'Tag'           ,'PrintUI'         ...
                );                       
            %call low level command so NextPlot has no affect, fix Axes.
            ImgHandle=image('cdata',CapturedImages{lp}.cdata, 'Parent',pj.UIData.AxisHandles(lp));
            set(pj.UIData.AxisHandles(lp), ...
                'Units'          ,Frame{lp}.Units, ...
                'Visible'        ,'on'       , ...
                'ColorOrder'     ,[0 0 0]     , ...
                'XTick'          ,[]          , ...
                'XTickLabelMode' ,'manual'    , ...
                'YTick'          ,[]          , ...
                'YTickLabelMode' ,'manual'    , ...
                'YDir'           ,'reverse'   , ...
                'XLim'           ,[0.5 Frame{lp}.Pos(3)+0.5], ...
                'YLim'           ,[0.5 Frame{lp}.Pos(4)+0.5]  ...
                );
        else
            pj.UIData.AxisHandles(lp)=[-1];
            warning('Screen capture failed - UIcontrol will not appear in output.');
        end %if ~isempty(capturedimages)
    end % for lp
    
end % if FrameNum

set(Fig, 'Units', pj.UIData.OldFigUnits );
set(0,   'Units', pj.UIData.OldRootUnits);
if ~isempty(pj.UIData.UICHandles),
  % Make uicontrols invisible because Motif on Sol2 sometimes seg-v's
  % if the uicontrols are visible while resizing in normalized units.
  % note we don't store the old visible state since we searched for visible
  % uicontrols in the findobj above.
  set(pj.UIData.UICHandles,'visible','off');
end



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%% RectAroundControl %%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function rect = rectaroundcontrol( ch )
%RECTAROUNDCONTROL Get rectangle that tightly bounds UiControl
%   On some platforms the asked for position is not used because it
%   is the LAF on those platforms to have the height of some styles of
%   UiControls be dependent upon the fontsize of the label of the control.

rect = get(ch,'position');

%A little fudgying is required since pop-up menus do not obey their
%position property -- they are Windows widgets we can't control completely.
if strcmp( 'popupmenu', get(ch,'style') ) & strncmp(computer,'PC',2)
    ext = get(ch,'extent');
    %Mac and PC both draw a little bit differently.
    if strncmp(computer,'PC',2)
        rect(2) = rect(2) + rect(4) - ext(4) - 4;
        rect(4) = ext(4)+4;
    end
end
