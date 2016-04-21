function lightmui(varargin)

%LIGHTMUI GUI to control position of lights on a globe or 3D map
%          
%  LIGHTMUI(HAX) creates a GUI to control the position of lights
%  on a globe or 3D map in map axes HAX.  The position of lights
%  may be controlled by clicking and dragging the icon or by 
%  dialog boxes.  Right click on the appropriate icon in the GUI to
%  invoke the corresponding dialog box.  The light color may be
%  changed by the entering the RGB components manually or by 
%  clicking on the push button.
%
%  See also LIGHTM

%  Copyright 1996-2003 The MathWorks, Inc.
%  $Revision: 1.2.4.1 $  $Date: 2003/08/01 18:18:42 $

%  Written by: L. Job

switch nargin
case 1
    hax = varargin{1};
    if length(hax)>1
        error('H must be a single map axes')
    end
    if ~ismap(hax)
        error('H must be map axes')
    end
    hlight = findobj(hax,'type','light');    
    if isempty(hlight)
        error('No light objects exist in axes H')
    end
    
	figure('numbertitle','off','name','LIGHTMUI'); 
    axesm('miller','grid','on'); displaym(worldlo('POline'));
	set(handlem('allline'),'color',0.65*[1 1 1])
	tightmap    
    figColor = get(gcf,'color');
    htxt = uicontrol('style','text','backgroundcolor',figColor,...
                     'units','normalized','horizontalalignment','left',...
                     'pos',[0.0283    0.0377    0.5402    0.0397],...
                     'tag','uitextbox');
    zdatam(handlem('allline'),0);
    set(handlem('allline'),'handlevisibility','off','buttondownfcn','')
    s.hlight = hlight;
    s.currentval = [];
    s.indx = [];
    s.geopos = [];
    s.clat = [];
    s.clon = [];
    s.calt = [];
    s.ccol = [];
    setappdata(gcf,'s',s);
    action = 'initialize';
case 2
    [h,action] = deal(varargin{1:2});
otherwise
    error('Incorrect Number of Input Arguments')
end

switch action
    
case 'initialize'
    
    s = getappdata(gcf,'s');
    for i = 1:length(s.hlight(:))
        mstruct = getm(get(s.hlight(i),'parent'));
        p = get(s.hlight(i),'pos');
        col = get(s.hlight(i),'color');
        tag = get(s.hlight(i),'tag');
        [lat,lon,alt] = minvtran(mstruct,p(1),p(2),p(3));
        h = plotm(lat,lon,1,'ko','markerfacecolor',col,'markersize',10,...
                 'tag',num2str(i),'linewidth',2,...
                 'buttondownfcn','lightmui([],''down'')');
    end

case 'dialogbox'
    
    figtag = ['Light - ' get(gco,'tag')];
    h = findobj('tag',figtag);
    if ishandle(h)
        figure(h);
        return 
    end
    
    s = getappdata(gcf,'s'); 
    figure('name',figtag,'tag',figtag,'Units','char',...
           'pos',[122.5000    7.2500   38.0000   21.4375],'backingstore','off',...
           'buttondownfcn','if isempty(allchild(gcbf)), close(gcbf), end',...
           'handlevisibility','on','integerhandle','off','inverthardcopy','off',...
           'menubar','none','numbertitle','off','resize','off','windowstyle','normal');

    framecolor = [0.8944 0.8944 0.8944];
   	hf = uicontrol('style','frame','units','char',...
                   'pos',[1.0000    0.4375   36.0000   20.6875],'backgroundcolor',framecolor);
               
    ht = uicontrol('style','text','units','char','horizontalalignment','left',...
                   'backgroundcolor',framecolor,'String','LATITUDE','fontweight','bold',...
                   'pos',[2.8500   19.0000   32.3000    1.0000]);
    str = sprintf('%10.4f',s.clat); s.currentval = str;
    he = uicontrol('style','edit','units','char','fontsize',9,'fontweight','bold','string',str,...
                   'pos',[2.8500   17.1500   32.3000    1.6078],'tooltipstring','Enter Latitude',...
                   'callback','lightmui([],''changelatitude'')','tag','elat');
    setappdata(he,'s',s);      
    
    ht = uicontrol('style','text','units','char','horizontalalignment','left',...
                   'backgroundcolor',framecolor,'String','LONGITUDE','fontweight','bold',...
                   'pos',[2.8500   14.0000   32.3000    1.0000]);
    str = sprintf('%10.4f',s.clon); s.currentval = str;
    he = uicontrol('style','edit','units','char','fontsize',9,'fontweight','bold','string',str,...
                   'pos',[2.8500   12.1500   32.3000    1.6078],'tooltipstring','Enter Longitude',...
                   'callback','lightmui([],''changelongitude'')','tag','elon');
    setappdata(he,'s',s);           
    
    ht = uicontrol('style','text','units','char','horizontalalignment','left',...
                   'backgroundcolor',framecolor,'String','ALTITUDE','fontweight','bold',...
                   'pos',[2.8500   9.0000   32.3000    1.0000]);
    str = sprintf('%10.4f',s.calt); s.currentval = str;
    he = uicontrol('style','edit','units','char','fontsize',9,'fontweight','bold','string',str,...
                   'pos',[2.8500   7.1500   32.3000    1.6078],'tooltipstring','Enter Altitude',...
                   'callback','lightmui([],''changealtitude'')','tag','ealt');
    setappdata(he,'s',s);      
    
    ht = uicontrol('style','text','units','char','horizontalalignment','left',...
                   'backgroundcolor',framecolor,'String','COLOR','fontweight','bold',...
                   'pos',[2.8500   4.0000   32.3000    1.0000]);
    str = sprintf('%10.4f',s.ccol); s.currentval = str;
    he = uicontrol('style','edit','units','char','fontsize',9,'fontweight','bold','string',str,...
                   'pos',[2.8500   2.1500   32.3000    1.6078],'tooltipstring','Enter Color',...
                   'callback','lightmui([],''editcolor'')','tag','ecol');
    setappdata(he,'s',s);  
    
    hp = uicontrol('style','push','units','char','horizontalalignment','left',...
                   'backgroundcolor',framecolor,'String','','fontweight','bold',...
                   'pos',[15.0000 4.0000 20.0000 1.0000],'tooltipstring','Click to invoke color palette',...
                   'callback','lightmui([],''pickcolor'')','tag','pcol');
    % fill in current color in button           
    mat = repmat(1,[8 110 3]);
    mat(:,:,1) = s.ccol(1)*mat(:,:,1);
    mat(:,:,2) = s.ccol(2)*mat(:,:,2);
    mat(:,:,3) = s.ccol(3)*mat(:,:,3);
    % add black boundary
    mat(1,:,1) = 0*mat(1,:,1); mat(end,:,1) = 0*mat(end,:,1); 
    mat(:,1,1) = 0*mat(:,1,1); mat(:,end,1) = 0*mat(:,end,1);
    mat(1,:,2) = 0*mat(1,:,2); mat(end,:,2) = 0*mat(end,:,2); 
    mat(:,1,2) = 0*mat(:,1,2); mat(:,end,2) = 0*mat(:,end,2);
    mat(1,:,3) = 0*mat(1,:,3); mat(end,:,3) = 0*mat(end,:,3); 
    mat(:,1,3) = 0*mat(:,1,3); mat(:,end,3) = 0*mat(:,end,3);
    set(hp,'cdata',mat);
    setappdata(hp,'s',s);
    
case 'pickcolor'
    
    s = getappdata(gcbo,'s');
    c = uisetcolor(s.ccol);
    s.ccol = c;
    setappdata(gcbo,'s',s);
    
    % fill in current color in button           
    mat = repmat(1,[8 110 3]);
    mat(:,:,1) = s.ccol(1)*mat(:,:,1);
    mat(:,:,2) = s.ccol(2)*mat(:,:,2);
    mat(:,:,3) = s.ccol(3)*mat(:,:,3);
    % add black boundary
    mat(1,:,1) = 0*mat(1,:,1); mat(end,:,1) = 0*mat(end,:,1); 
    mat(:,1,1) = 0*mat(:,1,1); mat(:,end,1) = 0*mat(:,end,1);
    mat(1,:,2) = 0*mat(1,:,2); mat(end,:,2) = 0*mat(end,:,2); 
    mat(:,1,2) = 0*mat(:,1,2); mat(:,end,2) = 0*mat(:,end,2);
    mat(1,:,3) = 0*mat(1,:,3); mat(end,:,3) = 0*mat(end,:,3); 
    mat(:,1,3) = 0*mat(:,1,3); mat(:,end,3) = 0*mat(:,end,3);
    set(gcbo,'cdata',mat);
    
    % change the color in the GUI 
    h = findobj('tag',num2str(s.indx));
    set(h,'markerfacecolor',s.ccol);
    
    % update the string in the edit box
    he = findobj(get(gcbo,'parent'),'tag','ecol');
    str = sprintf('%10.4f',s.ccol); s.currentval = str;
    set(he,'string',str);
    setappdata(he,'s',s);
    
    % update color of light on globe
    if ishandle(s.hlight(s.indx))
        set(s.hlight(s.indx),'color',s.ccol);
    else
        warndlg({'Graphics handle does not exist'},'Input Error')
    end
    
case 'editcolor'
    
    cval = str2num(get(gcbo,'string'));
    s = getappdata(gcbo,'s');
    if isempty(cval) | length(cval) ~= 3
        warndlg({'Enter RGB components as a three element vector'},'Input Error')
        set(gcbo,'string',s.currentval);
        return
    end
    if cval(1)>1 | cval(1)<0 | cval(2)>1 | cval(2)<0 | cval(3)>1 | cval(3)<0
        warndlg({'RGB components must be between 0 and 1 inclusive'},'Input Error')
        set(gcbo,'string',s.currentval);
        return
    end
    
    s.ccol = cval; s.currentval = num2str(cval); setappdata(gcbo,'s',s)
    
    % change the color in the control
    hp = findobj(gcf,'style','push');
    % fill in current color in button           
    mat = repmat(1,[8 110 3]);
    mat(:,:,1) = s.ccol(1)*mat(:,:,1);
    mat(:,:,2) = s.ccol(2)*mat(:,:,2);
    mat(:,:,3) = s.ccol(3)*mat(:,:,3);
    % add black boundary
    mat(1,:,1) = 0*mat(1,:,1); mat(end,:,1) = 0*mat(end,:,1); 
    mat(:,1,1) = 0*mat(:,1,1); mat(:,end,1) = 0*mat(:,end,1);
    mat(1,:,2) = 0*mat(1,:,2); mat(end,:,2) = 0*mat(end,:,2); 
    mat(:,1,2) = 0*mat(:,1,2); mat(:,end,2) = 0*mat(:,end,2);
    mat(1,:,3) = 0*mat(1,:,3); mat(end,:,3) = 0*mat(end,:,3); 
    mat(:,1,3) = 0*mat(:,1,3); mat(:,end,3) = 0*mat(:,end,3);
    set(hp,'cdata',mat);
    
    % change the color in the GUI 
    h = findobj('tag',num2str(s.indx));
    
    % update color of light on globe
    if ishandle(h)
        set(h,'markerfacecolor',s.ccol);
    else
        warndlg({'Graphics handle does not exist'},'Input Error')
    end
    
    % update color of light on globe
    % update color of light on globe
    if ishandle(s.hlight(s.indx))
        set(s.hlight(s.indx),'color',s.ccol);
    else
        warndlg({'Graphics handle does not exist'},'Input Error')
    end
    
case 'changelatitude'
    
    cval = str2num(get(gcbo,'string'));
    s = getappdata(gcbo,'s');
    if isempty(cval)
        warndlg({'Enter a numeric value for Latitude'},'Input Error')
        set(gcbo,'string',s.currentval);
        return
    end
    
    if cval>90 | cval<-90
        warndlg({'Latitude must be between -90 and 90 inclusively'},'Input Error')
        set(gcbo,'string',s.currentval);
        return
    end
        
    s.currentval = num2str(cval); setappdata(gcbo,'s',s)
    
    % change the position in the GUI and on the map
    h = findobj('tag',num2str(s.indx));
    
    % does handle exist? 
    if ishandle(h)
        mstruct1 = getm(get(h,'parent'));
        x = get(h,'xdata'); y = get(h,'ydata'); z = get(h,'zdata');
    else
        warndlg({'Graphics handle does not exist'},'Input Error')
        return
    end
    
    [lat,lon,alt] = minvtran(mstruct1,x,y,z);
    
    % replace lat with new value
    lat = cval; 
    % update position on GUI
    [x,y,z] = mfwdtran(mstruct1,lat,lon,alt);
    set(h,'xdata',x,'ydata',y);
    
    % does handle exist? 
    if ~ishandle(s.hlight(s.indx))
        warndlg({'Graphics handle does not exist'},'Input Error')
        return
    end
    
    % update position of light on globe
    mstruct2 = getm(get(s.hlight(s.indx),'parent'));
    p = get(s.hlight(s.indx),'position');
    [lat,lon,alt] = minvtran(mstruct2,p(1),p(2),p(3));
    lat = cval;
    [nx,ny,nz] = mfwdtran(mstruct2,lat,lon,alt);
    set(s.hlight(s.indx),'position',[nx ny nz])
    
case 'changelongitude'
    
    cval = str2num(get(gcbo,'string'));
    s = getappdata(gcbo,'s');
    if isempty(cval)
        warndlg({'Enter a numeric value for Longitude'},'Input Error')
        set(gcbo,'string',s.currentval);
        return
    end
    
    if cval>180 | cval<-180
        warndlg({'Longitude must be between -180 and 180 inclusively'},'Input Error')
        set(gcbo,'string',s.currentval);
        return
    end
    
    s.currentval = num2str(cval); setappdata(gcbo,'s',s)
    
    % change the position in the GUI and on the map
    h = findobj('tag',num2str(s.indx));
    
    % does handle exist? 
    if ishandle(h)
        mstruct1 = getm(get(h,'parent'));
        x = get(h,'xdata'); y = get(h,'ydata'); z = get(h,'zdata');
    else
        warndlg({'Graphics handle does not exist'},'Input Error')
        return
    end
    
    [lat,lon,alt] = minvtran(mstruct1,x,y,z);
    
    % replace lat with new value
    lon = cval; 
    % update position on GUI
    [x,y,z] = mfwdtran(mstruct1,lat,lon,alt);
    set(h,'xdata',x,'ydata',y);
    
    % does handle exist? 
    if ~ishandle(s.hlight(s.indx))
        warndlg({'Graphics handle does not exist'},'Input Error')
        return
    end
    
    % update position of light on globe
    mstruct2 = getm(get(s.hlight(s.indx),'parent'));
    p = get(s.hlight(s.indx),'position');
    [lat,lon,alt] = minvtran(mstruct2,p(1),p(2),p(3));
    lon = cval;
    [nx,ny,nz] = mfwdtran(mstruct2,lat,lon,alt);
    set(s.hlight(s.indx),'position',[nx ny nz])
    
case 'changealtitude'
    
    cval = str2num(get(gcbo,'string'));
    s = getappdata(gcbo,'s');
    if isempty(cval) | cval < 0
        warndlg({'Enter a non-negative numeric value for Altitude'},'Input Error')
        set(gcbo,'string',s.currentval);
        return
    end
    
    s.currentval = num2str(cval); setappdata(gcbo,'s',s)
    
    % change the position in the GUI and on the map
    h = findobj('tag',num2str(s.indx));
    
    % does handle exist? 
    if ishandle(h)
        mstruct1 = getm(get(h,'parent'));
        x = get(h,'xdata'); y = get(h,'ydata'); z = get(h,'zdata');
    else
        warndlg({'Graphics handle does not exist'},'Input Error')
        return
    end
    
    [lat,lon,alt] = minvtran(mstruct1,x,y,z);
        
    % does handle exist? 
    if ~ishandle(s.hlight(s.indx))
        warndlg({'Graphics handle does not exist'},'Input Error')
        return
    end
    
    % update position of light on globe
    mstruct2 = getm(get(s.hlight(s.indx),'parent'));
    p = get(s.hlight(s.indx),'position');
    [lat,lon,alt] = minvtran(mstruct2,p(1),p(2),p(3));
    alt = cval;
    [nx,ny,nz] = mfwdtran(mstruct2,lat,lon,alt);
    set(s.hlight(s.indx),'position',[nx ny nz])
    
case 'getprops'
               
    s = getappdata(gcf,'s');
    indx = str2num(get(gco,'tag'));
    mstruct = getm(get(s.hlight(indx),'parent'));
    p = get(s.hlight(indx),'position');
    ccol = get(s.hlight(indx),'color');
    [clat,clon,calt] = minvtran(mstruct,p(1),p(2),p(3));
    s.indx = indx;
    s.clat = clat;
    s.clon = clon;
    s.calt = calt;
    s.ccol = ccol;
    setappdata(gcf,'s',s)
    
case 'down'
    
    s = getappdata(gcf,'s');
    obj = get(gco);
    stype = get(gcf,'selectiontype');
    
    switch stype
    case 'alt'
        
        lightmui([],'getprops')
        lightmui([],'dialogbox')
        
    case 'normal'
        
        cview = get(gca,'view');
        if cview(1) ~= 0 | cview(2) ~= 90
            btn = questdlg( strvcat('Must be in 2D view for operation.',...
			                        'Change to 2D view?'),...
						    'Incorrect View','Change','Cancel','Change');
		
            switch btn
			    case 'Change',      view(2);
				case 'Cancel',      return
            end
        else
            set(gco,'erasemode','xor')
            set(gcf,'pointer','fullcrosshair')
            set(gcf,'windowbuttonmotionfcn','lightmui([],''move'')')
            set(gcf,'windowbuttonupfcn','lightmui([],''up'')')
		end
         
    end

case 'move'
    
    cpos = get(gca,'currentpoint');
    x = cpos(1,1); y = cpos(1,2);
    set(gco,'xdata',x,'ydata',y);
    [lat,lon] = minvtran(x,y);
    str = ['Latitude = ' sprintf('%6.2f',lat) ', Longitude = ' ...
            sprintf('%6.2f',lon)];
    set(findobj(gcf,'tag','uitextbox'),'string',str)    
   
    % update dialog box if necessary
    figtag = ['Light - ' get(gco,'tag')];
    h = findobj('tag',figtag);
    if ishandle(h)
        h1 = findobj(h,'tag','elat');
        set(h1,'string',sprintf('%6.2f',lat));
        h1 = findobj(h,'tag','elon');
        set(h1,'string',sprintf('%6.2f',lon));
    end
    
case 'up'
    
    cpos = get(gca,'currentpoint');
    x = cpos(1,1); y = cpos(1,2);
    set(gco,'xdata',x,'ydata',y);
    [lat,lon] = minvtran(x,y);
    
    % update dialog box if necessary
    figtag = ['Light - ' get(gco,'tag')];
    h = findobj('tag',figtag);
    if ishandle(h)
        h1 = findobj(h,'tag','elat');
        set(h1,'string',sprintf('%6.2f',lat));
        h1 = findobj(h,'tag','elon');
        set(h1,'string',sprintf('%6.2f',lon));
    end
    
	set(findobj(gcf,'tag','uitextbox'),'string','')
    set(gcf,'pointer','arrow')
    set(gco,'erasemode','normal')
    set(gcf,'windowbuttonmotionfcn','')
    set(gcf,'windowbuttonupfcn','')
    
    s = getappdata(gcf,'s');
    indx = str2num(get(gco,'tag'));
    
    if ~ishandle(s.hlight(indx))
        warndlg({'Graphics handle does not exist'},'Input Error')
        return
    end
    
    mstruct = getm(get(s.hlight(indx),'parent'));
    p = get(s.hlight(indx),'position');
    [clat,clon,calt] = minvtran(mstruct,p(1),p(2),p(3));
    [nx,ny,nz] = mfwdtran(mstruct,lat,lon,calt);
    set(s.hlight(indx),'position',[nx ny nz])
    
    s.geopos = [lat lon];
    setappdata(gcf,'s',s);
    
end
