function Frame = hgedit(h)
%HGEDIT  Open GUI for editing LTI Viewer Preferences (HG)

%   Author(s): A. DiVergilio
%   Copyright 1986-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2004/04/11 00:16:06 $

%---Watch on
 set(h.Target,'Pointer','watch');

%---Get handle to editor frame for preference object
 Frame = h.EditorFrame;

%---Create a new editor if one is not found
if isempty(Frame)
   %---UI properties
    W = 360;
    H = 450;
    CC = [.8 .8 .8];
    if ispc
       FS = 10;
    else
       FS = 12;
    end

   %---Frame
    Frame = figure('Name','LTI Viewer Preferences',...
       'Visible','off','MenuBar','none','HandleVisibility','callback',...
       'IntegerHandle','off','NumberTitle','off',...
       'Color',CC,'DefaultUIControlBackgroundColor',CC,'DefaultUIControlFontSize',FS,...
       'Units','pixels','DefaultUIControlUnits','pixels',...
       'Position',[0 0 W H],'Resize','off');
    set(Frame,'DeleteFcn',{@localCancel,Frame});
    centerfig(Frame,h.Target);

   %---Store handle to frame in preference object (this must occur before copy!)
    h.EditorFrame = Frame;

   %---Listen for Target destruction
    s.TargetDestroyedListener = handle.listener(h.Target,'ObjectBeingDestroyed',{@localDispose,Frame});

   %---Handle to current Viewer Preferences
    s.OldPrefs = h;
   %---Copy of current Viewer Preferences for editing
    s.NewPrefs = copy(s.OldPrefs);
   %---Temporarily clear property values (we'll set them back after listeners are installed)
    AllProps = fieldnames(s.NewPrefs);
    for n=1:size(AllProps,1)
       set(s.NewPrefs,AllProps{n,:},'');
    end

   redge = 5; ledge = 7; tedge = 5; bedge = 5; bs = 5; bw = 78; bh = 26;
   %---OK
    s.OK = uicontrol('Parent',Frame,'Style','pushb','Visible','on','String','OK',...
       'Position',[W-redge-4*bw-3*bs bedge bw bh],'Callback',{@localOK,Frame});
   %---Cancel
    s.Cancel = uicontrol('Parent',Frame,'Style','pushb','Visible','on','String','Cancel',...
       'Position',[W-redge-3*bw-2*bs bedge bw bh],'Callback',{@localCancel,Frame});
   %---Help
    s.Help = uicontrol('Parent',Frame,'Style','pushb','Visible','on','String','Help',...
       'Position',[W-redge-2*bw-1*bs bedge bw bh],'Callback','ctrlguihelp(''viewer_preferences'');');
   %---Apply
    s.Apply = uicontrol('Parent',Frame,'Style','pushb','Visible','on','String','Apply',...
       'Position',[W-redge-1*bw-0*bs bedge bw bh],'Callback',{@localApply,Frame});

   %---Units
    Units = unit_hg(s.NewPrefs,Frame,[ledge H-tedge-100 W-redge-ledge 100]);
    np = get(Units,'Position');

   %---Characteristics
    Char = char_hg(s.NewPrefs,Frame,[ledge np(2)-tedge-100 W-redge-ledge 100]);
    np = get(Char,'Position');

   %---Time Vector
    Time = tvec_hg(s.NewPrefs,Frame,[ledge np(2)-tedge-100 W-redge-ledge 100]);
    np = get(Time,'Position');

   %---Freq Vector
    Freq = fvec_hg(s.NewPrefs,Frame,[ledge np(2)-tedge-100 W-redge-ledge 100]);

   %---Store structure in Frame UserData
    set(Frame,'UserData',s);

   %---Show GUIs
    set([Frame Units Char Time Freq],'Visible','on');

   %---Set property values (listeners will update GUI)
    for n=1:size(AllProps,1)
       set(s.NewPrefs,AllProps{n,:},s.OldPrefs.get(AllProps{n,:}));
    end

else
   %---Structure of handles/data
    s = get(Frame,'UserData');
   %---Copy current Viewer Preferences to our editable copy
   %--- (our listeners will update the GUI automatically)
    set(s.NewPrefs,get(s.OldPrefs));
   %---Raise Frame (for HG, this also de-iconifies)
    set(Frame,'Visible','off','Visible','on');

end

%---Watch off
 set(h.Target,'Pointer','arrow');


%%%%%%%%%%%
% localOK %
%%%%%%%%%%%
function localOK(eventSrc,eventData,Frame)
 localApply(eventSrc,eventData,Frame);
 set(Frame,'Visible','off');


%%%%%%%%%%%%%%%
% localCancel %
%%%%%%%%%%%%%%%
function localCancel(eventSrc,eventData,Frame)
 s = get(Frame,'UserData');
 set(s.NewPrefs,get(s.OldPrefs));
 set(Frame,'Visible','off');


%%%%%%%%%%%%%%
% localApply %
%%%%%%%%%%%%%%
function localApply(eventSrc,eventData,Frame)
 s = get(Frame,'UserData');
 set(Frame,'Pointer','watch');
 set(s.OldPrefs,get(s.NewPrefs));
 set(Frame,'Pointer','arrow');

%%%%%%%%%%%%%%%%
% localDispose %
%%%%%%%%%%%%%%%%
function localDispose(eventSrc,eventData,Frame)
 delete(Frame);
