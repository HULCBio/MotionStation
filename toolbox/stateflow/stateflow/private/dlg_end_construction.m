function dlg_end_construction( fig, c, figWidth, figHeight, vectHGHandle, id, dialog, figUserData)
%DLG_END_CONSTRUCTION( FIG, CONSTANTS, FIGWIDTH, FIGHEIGHT, VECTHGHANDLE, ID, DIALOG)

%   Copyright 1995-2002 The MathWorks, Inc.
%   $Revision: 1.12.2.1 $  $Date: 2004/04/15 00:56:53 $

	% Fig Height
   figHeight = figHeight + c.ymargin;

   % Setup dialog figure's user data
   figUserData.objectId = id;
   figUserData.vectHGHandle = vectHGHandle;
	figUserData.geom.position = get(fig,'Position');
%%%	figUserData.hyperLinks = findobj(vectHGHandle,'Forground','blue');

   % Initialize the minimum extent to empty matrix. This
   % would inform dlg_resize to work out an appropriate minimum
   % extent based on width and height of vectHGHandle(s).
   figUserData.geom.minExtent = [];

	% Put fig handle in Stateflow data dictionary. But avoid sub-dialogs!
	dlgFig = sf('get',id,'.dialog');
	if dlgFig==0 | ~ishandle(dlgFig)
      sf('set',id,'.dialog',fig);
      isSubDialog=0;						% WJA 7-28-98 To fix target manager bug
   else
      isSubDialog=1;						% WJA 7-28-98 To fix target manager bug
	end

   % Resize the figure based on the new height and width
	figPosition(3:4) = [figWidth figHeight];
   % Reposition the figure to middle of the screen
	units = get(0,'Units');
	set(0,'Units','points');
	scr = get(0,'ScreenSize');
	pos = get(0,'PointerLocation');
	set(0,'Units',units);
	halfGeom = figPosition(3:4)/2;
	if any(pos-halfGeom<scr(1:2)) | any(pos+halfGeom>scr(1:2)+scr(3:4))
		figPosition(1:2) = scr(1:2)+(scr(3:4)-figPosition(3:4))/2;
	else
		figPosition(1:2) = pos(1:2)-halfGeom;
	end

	figUserData.geom.position = figPosition;

   set(fig...
      ,'Position',figPosition...
	   ,'UserData',figUserData...
      ,'ResizeFcn',['sf(''Private'',''dlg_resize'',''',dialog,''');']...
   );

	% Refresh the figure as long as it is a subdialog (WJA 7-28-98 To fix target manager bug)
   if ~isSubDialog,
      feval(dialog,'refresh',id);
   end
   

   dlg_sort_uicontrols(fig);

	set(fig,'Visible','on');


