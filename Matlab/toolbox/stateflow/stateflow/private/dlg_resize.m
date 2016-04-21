function dlg_resize( dialogManager )
%DLG_RESIZE( DIALOGMANAGER )  Resizes the dialog figure.

%   E.Mehran Mestchian
%   Copyright 1995-2002 The MathWorks, Inc.
%   $Revision: 1.13.2.1 $  $Date: 2004/04/15 00:57:07 $

   error(nargchk(0,1,nargin));
   error(nargchk(0,0,nargout));

   if nargin>0
      dialogProperty = feval(dialogManager,'dialogProperty');
   else
      dialogProperty = '.dialog';
   end

	%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	% Get userData and movements
	%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

   fig = gcbf;
	if isempty(fig),
		fig = gcf;
	end

	userData = get(fig, 'UserData');

   % Some simple checks on the integrity of the dialog userData
   if ~isstruct(userData) | ~isfield(userData,'objectId')
      warning('Bad object dialog UserData.');
   	return;
   end

   objectId = userData.objectId;
   if ~sf('ishandle',objectId) | sf('get',objectId,dialogProperty)<=0
      warning('Bad object dialog UserData.objectId.');
		return;
   end

	vectHG = userData.vectHGHandle;
	newPos = get(fig, 'Position');
   minExtent = userData.geom.minExtent;

   % See if minExtent needs to be calculated
   if isempty(minExtent)
      % Calculate the minimum extent of this dialog
      minExtent = calculate_min_extent(userData.geom.position, vectHG);
      userData.geom.minExtent = minExtent;
   end

   % The new figure position must be bigger than minimum extent allowed
   if any(newPos(3:4) < minExtent)
      tooSmallText = findobj(fig,'Tag','TOO SMALL');
      if all(newPos(3:4) < minExtent)
         msgText = 'Window is too small!';
      elseif newPos(3) < minExtent(1)
         msgText = 'Window width is too small!';
      else
         msgText = 'Window height is too small!';
      end
		visibleVect = findobj(vectHG,'Visible','on');
      set(visibleVect,'Visible','off');
		pos = get(fig,'Position');
		pos(1:2)=[0 0];
		pos(4) = pos(4)/2;
		if isempty(tooSmallText)
	      tooSmallText = uicontrol(...
	          'Parent',fig...
	         ,'Style','text'...
	         ,'String',msgText...
	         ,'Position',pos...
	         ,'Background',get(fig,'Color')...
	      	,'Userdata',visibleVect...
				,'HorizontalAlignment','center'...
	         ,'Tag','TOO SMALL'...
	      );
		else
			set(tooSmallText,'Position',pos,'String',msgText);
		end
      return;
   else
      tooSmallText = findobj(fig,'Tag','TOO SMALL');
   	if ~isempty(tooSmallText)
			visibleVec = get(tooSmallText,'Userdata');
			if iscell(visibleVec)
				visibleVec = [visibleVec{:}];
			end
			set(visibleVec,'Visible','on');
	      delete(tooSmallText);
		end
   end

	deltaX = newPos(3) - userData.geom.position(3);
	deltaY = newPos(4) - userData.geom.position(4);

	% apply the movements

   apply_resize_method(vectHG, deltaX, deltaY);
   
   % Reset the position in Fig UserData
   
   userData.geom.position = newPos;
   set(fig, 'UserData',userData);

   if nargin>0
      feval(dialogManager,'resized',objectId);
   end
   
	return;


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function apply_resize_method(handleVect, deltaX, deltaY)
%
%  Apply the resize method to a vector of HG handles.
%  Each object should have the UserData fields:
%
%		.refObject		HG object the position is referenced
%		.refCorner		Object corner to reference
%		.offset			Offset of origin from the reference corner
%		.heightScale	Proportion of height movement to resize object
%		.widthScale		Proportion of width movement to resize object
%

	for hndl = 	handleVect,
		
		userData = get(hndl,'UserData');
		currPos = get(hndl,'Position');
		if ~isempty(userData) & isfield(userData,'geom')
			refPos = get(userData.geom.refObject,'Position');
	
			% If ref object is a figure set the origin to 0 for
			% correct referencing
			if strcmp(get(userData.geom.refObject,'Type'),'figure')
			  refPos(1:2) = 0;
			end
	
			switch(userData.geom.refCorner)
				case('BL'),	origin = refPos(1:2) + userData.geom.offset;
				case('BR'), origin = refPos(1:2) + userData.geom.offset + [refPos(3) 0];
				case('TL'), origin = refPos(1:2) + userData.geom.offset + [0 refPos(4)];
				case('TR'), origin = refPos(1:2) + userData.geom.offset + refPos(3:4);
				otherwise, error(['Bad refCorner entry: '  userData.geom.refCorner]);
			end
	
			extent =  currPos(3:4) + [userData.geom.widthScale*deltaX userData.geom.heightScale*deltaY];
			newPos =[origin extent];
	   	set(hndl,'Position',newPos);
		else
			warning('Bad resizable uicontrol');
		end
	end

	return;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function minExtent = calculate_min_extent(initialPosition, vectHG)
%
%  Workout the minimum figure extent which makes sense 
%  givent the objects in vectHG and the initial extent
%  of the figure.

maxDeltaW = initialPosition(3);
maxDeltaH = initialPosition(4);

	for hndl = 	vectHG,
		
		userData = get(hndl,'UserData');
		currPos = get(hndl,'Position');
      
      if userData.geom.widthScale
         wDeltaToError = currPos(3)/userData.geom.widthScale;
         if wDeltaToError < maxDeltaW,
            maxDeltaW = wDeltaToError;
         end
      end
      
      if userData.geom.heightScale
         hDeltaToError = currPos(4)/userData.geom.heightScale;
         if hDeltaToError  < maxDeltaH,
            maxDeltaH = hDeltaToError;
         end
      end
      
	end
   
   minExtent = initialPosition(3:4) - [maxDeltaW maxDeltaH] + [1 1];

	return;


