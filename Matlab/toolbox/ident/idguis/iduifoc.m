function iduifoc(arg)
%IDUICRA Handles the correlation analysis dialog.

%   L. Ljung 9-27-94
%   Copyright 1986-2004 The MathWorks, Inc.
%   $Revision: 1.2.4.2 $ $Date: 2004/04/10 23:19:40 $

%global XIDplotw XIDlayout
Xsum = findobj(get(0,'children'),'flat','tag','sitb16');
XID = get(Xsum,'Userdata');

if strcmp(arg,'open')
    figname=idlaytab('figname',42);
    if ~figflag(figname,0)
        iduistat('Opening the estimation focus dialog box ...')
        layout
        FigW = iduilay2(3);
        
        f=figure('vis','off',...
            'DockControls','off',...
            'NumberTitle','off','Name',figname,'HandleVisibility','callback',...
            'Color',get(0,'DefaultUIControlBackgroundColor'),...
            'tag','sitb42');
        set(f,'Menubar','none');
        
        % LEVEL1
        
        pos = iduilay1(FigW,3);
        uicontrol(f,'pos',pos(1,:),'style','frame');
        uicontrol(f,'pos',pos(2,:),'style','push','string','Apply',...
            'callback','iduifoc(''range'');')
        uicontrol(f,'pos',pos(3,:),'style','push','string','Close',...
            'callback','set(gcf,''visible'',''off'')')
        uicontrol(f,'pos',pos(4,:),'style','push','string','Help','callback',...
            'iduihelp(''idfoc.hlp'',''Help: Estiation Focus'');')
        lev2 =pos(1,2)+pos(1,4);
        pos = iduilay1(FigW,2,2,lev2,[],[1.2 1.8]);
        uicontrol(f,'pos',pos(1,:),'style','frame');
        
        XID.foc(1) = uicontrol(f,'pos',pos(3,:),'style','edit','string','','callback',...
            'iduifoc(''range'');','backgroundcolor','white');
        uicontrol(f,'pos',pos(2,:),'style','text','string','Enter Passband(s) in rad/s');
        poslev=pos(1,2)+pos(1,4)+mEdgeToFrame;
        ScreenPos = get(0,'ScreenSize');
        FigWH=[FigW poslev];
        FigPos=[(ScreenPos(3:4)-FigWH)/2 FigWH];
        set(f,'pos',FigPos);
        set(get(f,'children'),'unit','norm')
        if length(XID.layout)>39,if XID.layout(40,3)
                eval('set(f,''pos'',XID.layout(40,1:4))','')
            end,end
        set(f,'vis','on')
        iduistat('')
    end
    set(Xsum,'UserData',XID)
    %end
elseif strcmp(arg,'range')
    rg = get(XID.foc(1),'string');
    try
        rge = eval(['[',rg,']']);
    catch
        try
            rge=evalin('base');
        catch
            errordlg('The variable you entered  is neither a matrix nor a workspace variable.',...
                'Error Dialog','modal');
            return
        end
    end
    if ~(isa(rge,'double')|isa(rge,'lti')|isa(rge,'idmodel'))
        errordlg('The variable you entered  is neither a matrix nor an LIT or IDMODEL variable.',...
            'Error Dialog','modal');
        return
    end
    if isa(rge,'double')
        [nr,nc]=size(rge);
        if nc~=2
            dat=iduigetd('e','me');
            dom = pvget(dat,'Domain'); dom = lower(dom(1));
            nrs = pvget(dat,'SamplingInstants');
            nrs = size(nrs{1},1);
            if ~(dom=='f' & nc==nrs)
                errordlg(['If a matrix is entered it must have 2 columns, where ',...
                        'each row defines a passband. For frequency domain data ',...
                        ' it could also be a row vector of the ',...
                        'same length as the number of frequencies in the data.'],'Error Dialog','modal');
                return
               
            end
             if (dom=='f' & nc==nrs)
                 rge=rge';
             end
        end
    end         
    usd = {rge,rg};
    try
        set(XID.procest(2,9),'Userdata',usd);
    end
    try
        set(XID.parest(18),'Userdata',usd);
    end
end
