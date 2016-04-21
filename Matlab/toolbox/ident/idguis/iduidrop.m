function [dat,dat_n,dat_i,do_com]=iduidrop(ax1,ax2)
%IDUIDROP Manages dropping one axes on another in ident window.
%   Drops axes ax1 onto axes ax2 and handles all consequences of the drop.

%   L. Ljung 9-27-94
%   Copyright 1986-2004 The MathWorks, Inc.
%   $Revision: 1.29.4.2 $ $Date: 2004/04/10 23:19:35 $

Xsum = findobj(get(0,'children'),'flat','tag','sitb16');
XID = get(Xsum,'Userdata');
try
    XIDcounters = XID.counters;
catch
end
dat=[];dat_n=[];dat_i=[];do_com=[];
newax=0;

if nargin<2,return,end
iduistat('');
do_com='';
if ax1==ax2,return,end
par1=get(ax1,'parent');par2=get(ax2,'parent');
tag2=get(ax2,'tag');tag1=get(ax1,'tag');
if length(tag2)<5,tag2='     ';end
pos2=get(ax2,'pos');pos1=get(ax1,'pos');
testtag1=findobj(ax1,'tag','modelline0');
testtag2=findobj(ax1,'tag','dataline0');
if strcmp(get(par1,'name'),idlaytab('figname',34))
    fromwaste=1;
else
    fromwaste=0;
end
if (strcmp(get(par2,'name'),idlaytab('figname',34))&par1~=par2)...
        |strcmp(tag2(1:5),'waste')
    towaste=1;
else
    towaste=0;
end
if ~isempty(testtag1)|~isempty(testtag2)
    nodrop=1;
else
    nodrop=0;
end
if towaste
    if nodrop
        iduistat('Cannot drop empty icon into Trash.');
        return
    end
    stopp=iduiwast('throw',ax1);
    if stopp,return,end
    newax=1;
elseif strcmp(tag2(1:5),'modst')% This ia a drop on a model structure
    hstr=findobj(ax1,'tag','name');
    if strcmp(tag1(1:5),'data ')|nodrop
        errordlg('You can only drop a model here.','Error Dialog','modal');
        return
    elseif strcmp(tag1(1:5),'model')
        modn=get(hstr,'string');%mod_info=get(hstr,'userdata');
        hl=findobj(ax1,'tag','modelline');
        mod=get(hl,'Userdata');
        
        %type=mod_info(1,1:3);
        if ~isa(mod,'idmodel')%if strcmp(type,'spa')|strcmp(type,'cra')
            errordlg(['You cannot drop a spectral model or a correlation', ...
                    ' model here'],'Error Dialog','modal');
            return
        end
        if isa(mod,'idproc')
            idprocest('open');
            XID = get(Xsum,'Userdata');

            hand = XID.procest(1,6);
            set(hand,'string',modn,'userdata',mod);
            idprocest('radio',[2 3],1);
            idprocest('model2gui','drop')
        else
            idparest('open');
            XID = get(Xsum,'Userdata');

        if get(XID.parest(4),'value')~=6
            set(XID.parest(4),'value',6);
            idparest('mstype','off');
        end
        set(XID.parest(3),'string',modn,'userdata',tag1);drawnow
        set(XID.parest(7),'string',[modn,'n']);
        iduistat(['The model ',modn,' is the current model structure.'])
        
    end
end
elseif strcmp(tag2(1:5),'ltivi')
    if nodrop
        iduistat('Empty icon.');
        return
    end
    if fromwaste
        iduistat('First drop trash item on regular icon.'),return
    end
    color=get(ax2,'color');
    hstr=findobj(ax1,'tag','name');
    if strcmp(tag1(1:5),'data ')
        ismodel=0; iduistat('Cannot use LTI Viewer for data.'),return
    elseif strcmp(tag1(1:5),'model')
        hl=findobj(ax1,'tag','modelline');
        ismodel=1;
    end
    dat=get(hl,'UserData');
    %% Check for valid systems.
    nu = size(dat,'nu');
    if ismodel        
        %% The ltiviewer functions for idmodel and idfrd model objects.
        if ~isa(dat,'idmodel')&~isa(dat,'idfrd')  
            iduistat('Cannot use LTI Viewer for CRA models.'),
            return
        %% The ltiview does not support complex idmodel systems.
        elseif ~isreal(dat) & isa(dat,'idmodel')
            iduistat('LTI Viewer is not supported for models with complex data'),
            return
        elseif isa(dat,'idfrd') & (nu == 0)
        %% The ltiview does not support output spectra models.    
            iduistat('Cannot plot output spectra of idfrd models.'),
            return    
        end
        
    end
    set(ax2,'color','r'),drawnow
    
    %% Find the name of the model.
    dat_n = get(hstr,'String');
    %% Create a new model variable of the model name.
    eval([dat_n,'=dat;'],'')

    %% Check to see if a valid ltiviewer is stored in the ident GUI.
    try 
        kk = XID.ltiview;
        if ~isa(kk,'viewgui.ltiviewer');
            kk =[];
        end
    catch
        kk= [];
    end
    
    %% Check to see if the ltiviewer is available to the user.
    if ~exist('ltiview')
        iduistat('No LTI Viewer available.')
        return
    end
    
    % Figure out the color and pass it to the viewer.
    hl=findobj(ax1,'tag','modelline');
    line_color = get(hl,'color');
    if isaimp(dat)
     eval(sprintf([dat_n,' = ssimp(%s);'],dat_n))
 end
    if isempty(kk)
        %% Create an ltiview if one has not been created.  If the first
        %% model is of the class idmodel, then default to a step plot.  If
        %% the model is a idfrd model, then default to a bode plot.
        if isa(dat,'idmodel')
            eval(sprintf('[fig,kk] = ltiview(''step'',%s);',dat_n));
        else
            eval(sprintf('[fig,kk] = ltiview(''bode'',%s);',dat_n));
        end
        %% Set the linestyle to the color of the model in the ident gui and
        %% set the name and tag for the figure.
        kk.setstyle(kk.Systems,'Color',line_color,'LineStyle','-','Marker','none'); 
        set(fig,'Name','Ident: LTI Viewer','Tag','sitb37');
        %% Make the Edit\Refresh menu item invisible
        set(kk.HG.FigureMenu.EditMenu.RefreshSystems,'Visible','off')
        %% Store the ltiviewer
        XID.ltiview = kk;
        set(Xsum,'UserData',XID);        
    else
        %% Find out if the ltiviewer has a model of the same name.  If one
        %% exists, replace it.
        oldnames = get(kk.Systems,'Name');
        nrdup = strmatch(dat_n,oldnames,'exact');        
        %% Add the new model to the ltiviewer.
        eval(sprintf('kk.importsys(''%s'',%s)',dat_n,dat_n));
        if ~isempty(nrdup)
            wrnstr ={['A model with name ',dat_n,' is already displayed.']; ...
                    'The new model with this name will erase the old one.';...
                    'Note that a model''s name can be changed by double-clicking,';...
                    '(right-click, cntrl-click) on its icon.'};
            warndlg(wrnstr,'LTI-Viewer Models','non-modal');
            %% Set the linestyle to the color of the model in the ident gui
            kk.setstyle(kk.Systems(end),'Color',line_color,'LineStyle','-','Marker','none'); 
        else
            %% Set the linestyle to the color of the model in the ident gui
            kk.setstyle(kk.Systems(end),'Color',line_color,'LineStyle','-','Marker','none'); 
        end
    end
    iduistat('Model inserted into LTI Viewer.' )
    newax=0;
    set(ax2,'color',color);
elseif strcmp(tag2(1:5),'expor')
    if nodrop
        iduistat('Cannot export empty icon.');
        return
    end
    if fromwaste
        iduistat('First drop trash item on regular icon.'),return
    end
    color=get(ax2,'color');
    set(ax2,'color','r'),drawnow
    hstr=findobj(ax1,'tag','name');
    if strcmp(tag1(1:5),'data ')
        hl=findobj(ax1,'tag','dataline');
        ismodel=0;
    elseif strcmp(tag1(1:5),'model')
        hl=findobj(ax1,'tag','modelline');
        ismodel=1;
    end
    dat=get(hl,'UserData'); 
    dat_n = pvget(dat,'Name'); 
    
    
    dat= iduiinfo('add',dat,[' Export   ',dat_n]);%pvget(dat,'Notes');
    
    %do_com=[dat_n,'=dat;clear dat_n dat outarg'];
    statusex =[];
    try
        evalin('base',[dat_n,';']);
        exvar = 1;
    catch
        exvar = 0;
    end
    if exvar
        drawnow
        ans = questdlg([dat_n,' exists in WS. Overwrite it?'],'Overwrite?',...
            'Yes','No','Cancel','No');
        switch ans
        case {'No','Cancel'}
            %do_com = 'clear outarg';
            statusex = ' not';
        end
    end
    assignin('base',dat_n,dat);
    iduistat([dat_n,' has',statusex,' been exported.'])
    newax=0;
    set(ax2,'color',color);
elseif strcmp(tag2(1:5),'seles')|strcmp(tag2(1:5),'selva')
    if fromwaste
        iduistat('First drop trash item on regular icon.'),return
    end
    if ~strcmp(tag1(1:5),'data ')|nodrop
        errordlg('You can only drop data at the Working/Validation Data box.','Error Dialog','modal');
        return
    end
    idinseva(ax1,tag2(1:5));
elseif strcmp(tag2,'merge')
    hl=findobj(ax1,'tag','dataline');
    dat=get(hl,'Userdata');
    set(XID.sel(2,7),'Userdata',dat);
    iduiexp('merge_data');
else % we are now dropping icon on icon
    if ~strcmp(tag1(1:5),tag2(1:5))&~(fromwaste&par1==par2)
        errordlg({['Cannot drop models onto data icons or vice versa.'],...
                '',['(If you want to move an IDFRD data/model, first export it and then',...
            ' reimport it.)']},'Error Dialog','modal');
        return
    end
    XIDcounters(5)=1; % To tell that there is a change in the board.
    if par1~=par2
        iswaste=0;
        if fromwaste
            testtag1=findobj(ax2,'tag','modelline');
            testtag2=findobj(ax2,'tag','dataline');
            if ~isempty(testtag1)|~isempty(testtag2)
                iduistat('Cannot drop trash contents on non-empty icon.')
                return
            end
            iswaste=1;
            wbas=findobj(get(XID.sumb(1),'children'),'flat','tag','waste');
            wslist=idnonzer(get(wbas,'userdata'));
            nr=findobj(wslist,'tag',tag1);
            delete(nr)
            wslist=wslist(find(wslist~=nr));
            set(wbas,'userdata',wslist);
            axnr=get(par1,'userdata');  % The list of available axes in trash
            set(par1,'userdata',[ax1,axnr(:)'])
            if isempty(wslist)
                hfull=findobj(wbas,'tag','full');
                hem=findobj(wbas,'tag','empty');
                set(hfull,'vis','off');set(hem,'vis','on');
                set(XID.sbmen(10),'enable','off');
            end
        end
        hl1=findobj(ax1,'type','line');hl2=findobj(ax2,'type','line');
        hstr1=findobj(ax1,'tag','name');hstr2=findobj(ax2,'tag','name');      
        if ~iswaste
            ax2tag=get(ax2,'tag');ax2usd=get(ax2,'userdata');
            ax2xlim=get(ax2,'xlim');ax2ylim=get(ax2,'ylim');
            s2str=get(hstr2,'string');s2usd=get(hstr2,'userdata');
            h2xdata=get(hl2,'xdata');h2ydata=get(hl2,'ydata');
            h2lw=get(hl2,'linewidth');
            h2color=get(hl2,'color');h2usd=get(hl2,'userdata');
            h2colax=get(ax2,'color');
            h2tag=get(hl2,'tag');h2vis=get(hl2,'vis');h2vv=get(hstr2,'vis');
        end
        set(ax2,'tag',get(ax1,'tag'),'userdata',get(ax1,'userdata'),...
            'xlim',get(ax1,'xlim'),'ylim',get(ax1,'ylim'),...
            'color',get(ax1,'color'));
        set(hstr2,'string',get(hstr1,'string'),'userdata',get(hstr1,...
            'userdata'),'vis',get(hstr1,'vis'));
        
        set(hl2,'xdata',get(hl1,'xdata'),'ydata',get(hl1,'ydata'),...
            'color',get(hl1,'color'),'userdata',get(hl1,'userdata'),...
            'vis',get(hl1,'vis'),...
            'tag',get(hl1,'tag'),'linewidth',get(hl1,'linewidth'))
        
        if ~iswaste
            set(ax1,'tag',ax2tag,'userdata',ax2usd,...
                'xlim',ax2xlim,'ylim',ax2ylim,'color',h2colax);
            set(hstr1,'string',s2str,'userdata',s2usd,'vis',h2vv);
            set(hl1,'xdata',h2xdata,'ydata',h2ydata,...
                'color',h2color,'userdata',h2usd,...
                'tag',h2tag,'vis',h2vis,'linewidth',h2lw)
        else
            platecol=get(0,'DefaultUIcontrolBackgroundcolor');
            set(ax1,'color',platecol)
            set(get(ax1,'children'),'vis','off')
        end
    else
        set(ax1,'pos',pos2); 
        set(ax2,'pos',pos1);newax=0; drawnow
    end
end
if newax
    fig=get(ax1,'parent');
    figure(fig)
    newh=axes('units','norm','color',...
        get(fig,'color'),'xtick',[],...
        'ytick',[],'xticklabel',[],'yticklabel',[],'box','on',...
        'drawmode','fast');
    set(newh,'pos',pos1);
    newht=text('pos',[0.5 0],'units','norm','fontsize',10,'tag','name',...
        'horizontalalignment','center','verticalalignment','bottom');
    newhl=line('vis','off','erasemode','normal');
    map=idlayout('colors');
    
    if strcmp(tag1(1:5),'model')
        XIDcounters(2)=XIDcounters(2)+1;
        kk=XIDcounters(2);
        set(newh,'tag',['model',int2str(kk)]);
        set(newhl,'color',map(rem(kk,20)+1,:),'tag','modelline0');
    else
        XIDcounters(1)=XIDcounters(1)+1;
        kk=XIDcounters(1);
        set(newh,'tag',['data ',int2str(kk)]);
        set(newhl,'color',map(rem(kk,20)+1,:),'tag','dataline0');
    end
    
end
XID = get(Xsum,'Userdata');
XID.counters = XIDcounters;
set(Xsum,'UserData',XID);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function mod = ssimp(imp);
% transform to ss and remove, orderly, the negative inputdelay
ninpd = pvget(imp,'InputDelay'); %negative
if ninpd(1)<0
B = pvget(imp,'B');
imp = pvset(imp,'B',B(:,:,-ninpd(1)+1:end),'InputDelay',zeros(size(ninpd)));
end
mod = ss(imp,'m');
