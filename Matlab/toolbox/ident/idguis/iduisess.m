function err = iduisess(arg,Pathn,Filen)
%IDUISESS Handles load and save session as well as renaming of session.
%   Arguments:
%   load    Load session
%   save    Save session
%   save_as Save session as ...
%   direct  Load session directly from file menu

%   L. Ljung 4-4-94
%   Copyright 1986-2003 The MathWorks, Inc.
%   $Revision: 1.15.4.1 $ $Date: 2004/04/10 23:19:57 $

Xsum = findobj(get(0,'children'),'flat','tag','sitb16');

XID = get(Xsum,'Userdata');

iduistat('');
if strcmp(arg,'direct')
    mennr=Pathn;
    filen=get(XID.sbmen(mennr),'userdata');
    pathn=get(XID.sbmen(mennr),'tag');
    if strcmp('open',get(XID.sbmen(1),'tag'))
        othersess=[1:2*(mennr-6),2*(mennr-5)+1:8];
        XID.sessions=XID.sessions([othersess,2*(mennr-6)+1:2*(mennr-6)+2],:);
    end
    set(Xsum,'UserData',XID);
    iduisess('load',pathn,filen);
    XID = get(Xsum,'UserData');
elseif strcmp(arg,'load')
    Model = []; Data = [];% To avoid possible confusion with an m-File Model if such exists
    gcm=gcbo;
    if strcmp(get(gcm,'tag'),'open'),msg='Open';else msg='Merge';end
    if nargin<2
        iduistat('Enter path and file name in the dialog.')
        flag=0;
        eval('[file_name,path_name]=uigetfile(''*.sid'',[msg,'' Session'']);',...
            'flag=1;')
        if flag
            iduistat('The file does not exist.')
            return
        end
        nopath=0;
    else
        file_name=Filen;path_name=Pathn;
        if isempty(Pathn),nopath=1;else nopath=0;end
        dotnr=find(file_name=='.');
        if isempty(dotnr),file_name=[file_name,'.sid'];end
    end
    newsess=0;
    iduistat(['Opening session ',file_name,' ...'])
    if isstr(file_name)
        err=0;
        eval(['load(''' path_name file_name ''',''-mat'')'],'err=1;')
        if err
            errordlg(['The file ',path_name,file_name,' cannot be found' ...
                    ' or cannot be loaded.'],'Error Dialog','modal');
            return
        end
        try
            vers = sidversion;
        catch           
            vers = 0;
        end
        if ~vers
            stopp = 0;
            sido2n
            if stopp
                errordlg(['The file is not an ident session file. Please' ...
                        ' check file name.'],'Error Dialog','modal');
                return
            end
        end
        kDc = length(Data); 
        kMc = length(Model);
        % First extract the axes information
        for kc = 1:kDc
            try
                ut = pvget(Data{kc},'Utility');
                datp(kc,:) = ut.axinfo;
            catch
                datp(kc) = [];
            end
        end
        for kc = 1:kMc
            if isstruct(Model{kc})
                modp(kc,:)=Model{kc}.axinfo;
            else
                try
                    ut = pvget(Model{kc},'Utility');
                    modp(kc,:) = ut.axinfo;
                catch
                    modp(kc,:) =zeros(1,8);
                end
            end
        end
        sessname=file_name;
        dotnr=find(sessname=='.');
        if ~isempty(dotnr),sessname=sessname(1:dotnr(1)-1);end
        hnr=XID.sumb(1);
        emp=[findobj(hnr,'tag','dataline','vis','on');...
                findobj(hnr,'tag','modelline','vis','on')];
        if isempty(emp),nono=[];else nono=1;end % List of non-empty boards
        cursbs=findobj(0,'tag','sitb30');%Current summary boards
        sbnr=1;    % List of current summary board numbers
        for hnr=cursbs(:)'
            nrb=get(hnr,'userdata');
            sbnr=[sbnr,nrb];
            emp=[findobj(hnr,'tag','dataline','vis','on');...
                    findobj(hnr,'tag','modelline','vis','on')];
            if ~isempty(emp),nono=[nono,nrb];end
        end
        % Renumber boards if necessary:
        if ~isempty(nono)
            try
                isempty(XID.posd1);
            catch
                XID.posd1 = [];
            end
            if isempty(XID.posd1)
                iddmtab(2);
                XID = get(Xsum,'User');
            end
            lbn=length(Board.nr);
            maxnr=length(nono)+lbn;newlist=1:maxnr;
            for kk=nono
                newlist=newlist(find(newlist~=kk));
            end
            newlist=newlist(1:lbn);
            [Board.nr,sorti] = sort(Board.nr);
            Board.notes = Board.notes(sorti);
            for kk=lbn:-1:1
                if newlist(kk)~=Board.nr(kk)
                    eval('indxd=find(datp(:,1)==Board.nr(kk));','indxd=[];')
                    datp(indxd,1)=newlist(kk)*ones(1,length(indxd))';
                    eval('indxm=find(modp(:,1)==Board.nr(kk));','indxm=[];')
                    modp(indxm,1)=newlist(kk)*ones(1,length(indxm))';
                    if Board.nr(kk)~=1
                    else
                        for ki=indxm'
                            [trash,knrim] = min(sum(abs((XID.posm-ones(16,1)*modp(ki,2:5))')));
                            modp(ki,2:5)=XID.posm1(knrim,:);
                        end
                        for ki=indxd'
                            [trash,knrid] = min(sum(abs((XID.posd-ones(8,1)*datp(ki,2:5))')));
                            datp(ki,2:5)=XID.posd1(knrid,:);
                        end
                    end
                end
            end
            Board.nr=newlist;
            newsess=0;
        else
            newsess=1;
            XID.path = [path_name,file_name];
            set(XID.sumb(1),'userdata',XID);
            set(XID.sumb(1),'name',['ident: ',sessname])
            
        end  % isempty(nono)
        for kbcou=1:length(Board.nr)
            kbn = Board.nr(kbcou);
            if kbn>1
                create=0;
                try
                    if strcmp(get(XID.sumb(knb),'tag'),'sitb30')&...
                            get(XID.sumb(kbn),'Userdata')==kbn
                        create = 0;
                    else
                        create = 1;
                    end
                catch
                    create = 1;
                end
                if create,iddmtab(kbn);end
                XID = get(Xsum,'UserData');
                texth=findobj(XID.sumb(kbn),'tag','notes');
                set(texth,'string',Board.notes{kbcou});
            end
        end
        for kc=1:kDc
            hax=iduiinsd(Data{kc},0,datp(kc,:));
            if newsess
                if kc==working_data,idinseva(hax,'seles',1);end
                if kc==validation_data,idinseva(hax,'selva',1);end
            end
        end
        for kc=1:kMc
            iduiinsm(Model{kc},0,modp(kc,:));
        end
    else 
        iduistat('Load session canceled.'),return
    end %isstring
    XID = get(Xsum,'UserData');
    if newsess,
        XID.counters(5)=0;
        kma = strmatch(file_name,XID.sessions,'exact');
        if kma&strmatch(path_name,XID.sessions(kma+1,:),'exact')
            XID.sessions([kma,kma+1],:)=[];
        end
        
        XID.sessions=str2mat(file_name,path_name,XID.sessions);
        XID.sessions=XID.sessions(1:8,:);
        for ksess=1:4  % Update direct file menus
            [label,acc]=menulabel(['&',int2str(ksess),' ',...
                    deblank(XID.sessions(2*ksess-1,:))]);
            set(XID.sbmen(ksess+5),'label',label,...
                'userdata',deblank(XID.sessions(2*ksess-1,:)),...
                'tag',deblank(XID.sessions(2*ksess,:)));
        end
        set(Xsum,'UserData',XID)
        idlaytab('save_file');
        set(XID.sbmen([3,5]),'enable','on');
        if ~nopath,set(XID.sbmen(4),'enable','on'),end
        [label,acc]=menulabel('&Merge session... ^o');
        set(XID.sbmen(1),'label',label,'tag','merge');
    else
        XID.counters(5)=1;
    end
    iduistat('Session open. Use Views or double-click (right mouse) on icons for more info.')
elseif strcmp(arg,'save')
    if nargin<2
        PathFileName=XID.path;   
        if isempty(PathFileName),iduisess('save_as'),return,end
    else 
        if nargin<3,Filen='';end
        PathFileName=[Pathn,Filen];
    end
    iduistat(['Saving session to ',PathFileName,' ...'])
    working_data=get(get(XID.hw(3,1),'zlabel'),'userdata');
    validation_data=get(get(XID.hw(4,1),'zlabel'),'userdata');
    sumb=[XID.sumb(1);findobj(get(0,'children'),'flat','tag','sitb30')];
    Model = {};
    Data = {};
    km = 0; kd = 0;kb = 0;
    
    Board.nr = [];
    sidversion=1;
    for ksb=sumb(:)'
        kb = kb+1;
        modnr=findobj(ksb,'tag','modelline','vis','on');
        datnr=findobj(ksb,'tag','dataline','vis','on');
        kwinname=get(ksb,'name');
        kpar1=find(kwinname=='(');kpar2=find(kwinname==')');
        if isempty(kpar1)
            wino=1;
        else
            wino=eval(kwinname(kpar1+1:kpar2-1));
        end
        Board.nr=[Board.nr,wino];
        if wino>1
            Board.notes{kb} = get(findobj(ksb,'tag','notes'),'string');
        else
            Board.notes{kb} = 'This is the main Board.';
        end
        for kc=modnr(:)'
            km = km+1;
            kcp=get(kc,'parent'); 
            modp=[wino,get(kcp,'pos'),get(kc,'color')];
            mod = get(kc,'UserData');
            if isstruct(mod)
                mod.axinfo = modp;
                Model{km} = mod;
            else
                ut = pvget(mod,'Utility');
                ut.axinfo = modp;
                Model{km} = pvset(mod,'Utility',ut);
            end
        end
        for kc=datnr(:)'
            kd=kd+1;
            kcp=get(kc,'parent');datatag=get(kcp,'tag');
            if strcmp(datatag,working_data)
                working_data = kd;
            end
            if strcmp(datatag,validation_data)
                validation_data = kd;
            end
            datp = [wino,get(kcp,'pos'),get(kc,'color')];
            dat = get(kc,'UserData');
            ut = pvget(dat,'UserData');
            ut.axinfo = datp;
            Data{kd} = pvset(dat,'Utility',ut);
        end
    end
    XID = get(Xsum,'UserData');
    
    err=0;
    try
        save(PathFileName,'Model','Data','Board','working_data',...
            'validation_data','sidversion')
    catch
        err = 1;
        errordlg(str2mat('Save failed. Check your writing privileges.'),'Error Dialog','modal');
        return
    end
    % Only when save successful do we set the clean flag
    Xsum = findobj(get(0,'children'),'flat','tag','sitb16');
    XID = get(Xsum,'Userdata');
    XID.counters(5)=0;
    set(Xsum,'UserData',XID);
    iduistat([PathFileName,' saved.'])
elseif strcmp(arg,'save_as')
    iduistat('Enter path and file name in the dialog.')
    [filen,pathn]=uiputfile('*.sid','Save Session');
    iduistat('') 
    if any(filen=='(')|any(filen==')')
        errordlg('Parentheses are not allowed in filenames.','Error Dialog','modal');
        return
    end
    if isstr(filen)
        dotnr=find(filen=='.');if isempty(dotnr),filen=[filen,'.sid'];end
        if exist([pathn,filen])
            click = questdlg(['File ',pathn,filen,' exists. Overwrite?'],'Save Session');
            if any(strcmp(click,{'No','Cancel'}))
                return
            end
        end
        err=iduisess('save',pathn,filen);
    else
        return
    end
    XID = get(Xsum,'UserData');
    if err,
        % Saving errored, so return
        return
    end
    XID.path = [pathn,filen];
    set(XID.sumb(1),'userdata',XID);
    dotnr=find(filen=='.');
    if ~isempty(dotnr),sessname=filen(1:dotnr-1);else sessname=filen;end
    set(XID.sumb(1),'name',['ident: ',sessname])
    extras=findobj(get(0,'children'),'flat','tag','sitb30');
    for ksb=extras(:)'
        kwinname=get(ksb,'name');
        kpar1=find(kwinname=='(');kpar2=find(kwinname==')');
        set(ksb,'name',['ident: ',sessname,' ',kwinname(kpar1:kpar2)])
    end
    XID.sessions=str2mat(filen,pathn,XID.sessions);
    XID.sessions=XID.sessions(1:8,:);
    for ksess=1:4  % Update direct file menus
        [label,acc]=menulabel(['&',int2str(ksess),' ',...
                deblank(XID.sessions(2*ksess-1,:))]);
        set(XID.sbmen(ksess+5),'label',label,...
            'userdata',deblank(XID.sessions(2*ksess-1,:)),...
            'tag',deblank(XID.sessions(2*ksess,:)),'enable','on');
    end
    
    set(XID.sbmen(4),'enable','on');
    set(Xsum,'UserData',XID)
    idlaytab('save_file');
    
end
set(Xsum,'UserData',XID);
