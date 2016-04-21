function outarg=iduifile(arg,file,dum,dom)
%IDUIFILE Handles file operations in ident.
%   Arguments:
%   load_data   Opens the dialog box for importing datavariable
%   load_iodata Opens the dialog box for importing data in i/o form
%   load_model  Opens the dialog box for importing models
%   load_mat    Loads the selected mat file
%   done_data   Final operations when inserting data
%   reset       Resets the dialog's different boxes
%   insert      Inserts i/o data into summary board
%   test1       Tests if sampling interval reasonable

%   L. Ljung 4-4-94
%   Copyright 1986-2004 The MathWorks, Inc.
%   $Revision: 1.29.4.4 $  $Date: 2004/04/10 23:19:38 $


Xsum = findobj(get(0,'children'),'flat','tag','sitb16');
XID = get(Xsum,'Userdata');
warflag = strcmp(get(XID.warning,'checked'),'on');

if strcmp(arg,'load_iodata')
    cb1='iduipoin(1);iduistat(''Compiling...'');';
    cb2='iduipoin(1);';
    cb3='iduipoin(2);';
    FigName=idlaytab('figname',19);
    if figflag(FigName,0)
        test = get(XID.hload(1,2),'UserData');
        if ~strcmp(test,file)
            [te,nr]=figflag(FigName,0);
            close(nr)
        end
    end
    if ~figflag(FigName,0)
        iduistat('Opening the import dialog box ...')
        layout
        butw=mStdButtonWidth;buth=mStdButtonHeight;
        FigW=iduilay2(2);
        f=figure('vis','off',...
            'DockControls','off',...
            'NumberTitle','off','Name',FigName,...
            'Integerhandle','off','HandleVisibility','callback',...
            'Color',get(0,'DefaultUIControlBackgroundColor'),'tag','sitb19');
        set(f,'Menubar','none');
        strload=[];
        XID.hload(1,1) = f;
        % LEVEL 1
        
        pos = iduilay1(FigW,4,2);
        uicontrol(f,'pos',pos(1,:),'style','frame');
        uicontrol(f,'pos',pos(2,:),...
            'style','push','string','Import','callback',...
            [cb1,'iduifile(''insert'');',cb3]);
        uicontrol(f,'pos',pos(3,:),'style',...
            'push','string','Reset','callback','iduifile(''reset'',1)');
        uicontrol(f,'pos',pos(4,:),...
            'style','push','string','Close',...
            'callback','set(gcf,''vis'',''off'')');
        switch file
            case 'object'
                hlp = 'iduihelp(''iduiimp1.hlp'',''Importing Data Object'');';
            case 'data_td'
                hlp = 'iduihelp(''iduiimp2.hlp'',''Importing Time Domain Data'');';
            case 'data_fd'
                hlp = 'iduihelp(''iduiimp3.hlp'',''Importing Frequency  Domain Data'');';
        end
        uicontrol(f,'pos',pos(5,:),...
            'style','push','string','Help',...
            'callback',hlp);
        pos1 = pos;
        
        % LEVEL 1.5 Frame for data type
        pos2 = iduilay1(FigW,4,4,4,2);
        
        uicontrol(f,'pos',pos2(1,:)+[FigW 0 0  0],'style','Frame');
        XID.hload(1,12) = uicontrol(f,'pos',...
            pos2(5,:)+[FigW 0 0 2.4*buth],...
            'style','edit',...
            'HorizontalAlignment','left',...
            'String','','max',2,'Backgroundcolor','w',...
            'Tooltip',['Enter here any notes that will follow the' ...
                ' data.']);
        uicontrol(f,'pos',pos2(2,:)+[FigW 0 0 0],'style','text','HorizontalAlignment',...
            'left','string','Notes','Fontweight',...
            'bold');
        levright = pos2(1,2)+pos2(1,4);
        % LEVEL 2 Frame for Data Info 
        lev2=pos(1,2)+pos(1,4);
        pos = iduilay1(FigW,10,5,lev2,4,[2 2]/2);
        pos2 = iduilay1(FigW,10,5,lev2,4,[1 3]/2);
        pos2 = pos2+ones(size(pos2,1),1)*(FigW*[1 0 0 0]);
        
        uicontrol(f,'pos',pos(1,:),'style','frame');
        posright = iduilay1(FigW,3,3,levright);
        uicontrol(f,'pos',posright(1,:)+[FigW 0 0 0],'style','frame');
        
        XID.hload(1,14) =     uicontrol(f,'pos',pos(11,:),'style','push',...
            'string','More','callback','iduifile(''more'')');
        
        XID.hload(1,17) = uicontrol(f,'pos',pos2(7,:),...
            'Backgroundcolor','w',...
            'HorizontalAlignment','left','style','Edit','string',' ');
        uicontrol(f,'pos',pos2(6,:),'style','text',...
            'HorizontalAlignment','left','string','Output:');
        XID.hload(1,18) = uicontrol(f,'pos',pos2(5,:),...
            'Backgroundcolor','w',...
            'HorizontalAlignment','left','style','Edit','string',' ');
        uicontrol(f,'pos',pos2(4,:),'style','text',...
            'HorizontalAlignment','left','string', 'Input:');
        
        
        uicontrol(f,'pos',pos(4,:),'style',...
            'text','string','Data name:',...
            'HorizontalAlignment','left');
        XID.hload(1,4) = uicontrol(f,'pos',pos(5,:),'style','edit',...
            'HorizontalAlignment','left',...
            'String','mydata','Backgroundcolor','w');
        XID.hload(1,2) = uicontrol(f,'pos',pos(6,:),...
            'String','Starting time:','style','text',...
            'horizontalalignment','left','userdata','td');
        XID.hload(1,8) = uicontrol(f,'pos',pos(7,:),...
            'style','edit','String','1','tag','startt',...
            'HorizontalAlignment','left','callback','iduifile(''test1'');',...
            'Backgroundcolor','w');
        uicontrol(f,'pos',pos(8,:)+[0 0 20 0],...
            'String','Sampling interval:','style','text',...
            'horizontalalignment','left');
        XID.hload(1,6) = uicontrol(f,'pos',pos(9,:),'tag','tsamp',...
            'HorizontalAlignment','left','callback','iduifile(''test1'');',...
            'style','edit','String','1','Backgroundcolor','w');
        uicontrol(f,'pos',[pos(2,1:2) ...
                FigW-2*(mEdgeToFrame+mFrameToText) pos(2,4)],...
            'style','text','string','Data Information',...
            'HorizontalAlignment','center','fontweight','bold');
        uicontrol(f,'pos',[pos(2,1:2) ...
                FigW-2*(mEdgeToFrame+mFrameToText) pos(2,4)]+[FigW 0 0 0],...
            'style','text','string','Physical Units of Variables ',...
            'HorizontalAlignment','center','fontweight','bold');
        
        
        % LEVEL 3 Frame for Variable info
        
        lev3=pos(1,2)+pos(1,4);
        
        pos = iduilay1(FigW,8,4,lev3,4,[1.5 2.5]/2);
        uicontrol(f,'pos',pos(1,:),'style','frame');
        uicontrol(f,'pos',pos(2,:)+[0 0 FigW-pos(2,3)-2*(mEdgeToFrame+mFrameToText) 0],'style','text','horizontalalignment','center','string',...
            'Workspace Variable','fontweight','bold');
        XID.hload(1,24) = uicontrol(f,'pos',pos(4,:),...
            'HorizontalAlignment','left',...
            'style','text');
        
        XID.hload(1,11)=...
            uicontrol(f,'pos',pos(5,:),...
            'style','edit','Backgroundcolor','w',...
            'HorizontalAlignment','left');
        if strcmp(file(1:4),'data')
            set(XID.hload(1,11),'callback',...
                'iduifile(''iddata'');','tooltip',...
                ['Any MATLAB expression that evaluates to an N-by-Nu matrix']);
            set(XID.hload(1,24),'string','Input:')
            set(XID.hload(1,2),'UserData',file);
        else
            set(XID.hload(1,11),'callback','iduifile(''object'');','tooltip',...
                ['Any IDDATA, IDFRD or FRD object in Workspace.']);
            set(XID.hload(1,24),'string','Object:','tooltip',...
                ['Any IDDATA, IDFRD or FRD object in Workspace.']);
            set(XID.hload(1,2),'UserData','obje_td');
            XID.hload(1,25) = uicontrol(f,'pos',pos(6,:),...
                'style','text','string','Object class:',...
                'HorizontalAlignment','left','tooltip','Will be filled out automatically');
            XID.hload(1,13)=...
                uicontrol(f,'pos',pos(7,:),...
                'style','text',...
                'HorizontalAlignment','left','tooltip','Will be filled out automatically'); 
            XID.hload(1,3) = uicontrol(f,'pos',pos(9,:),'HorizontalAlignment','left',...
                'style','text');
        end
        if strcmp(file(1:4),'data')
            XID.hload(1,25) = uicontrol(f,'pos',pos(6,:),...
                'style','text','string','Output:',...
                'HorizontalAlignment','left');
            XID.hload(1,13)=...
                uicontrol(f,'pos',pos(7,:),...
                'style','edit','Backgroundcolor','w',...
                'HorizontalAlignment','left','tooltip',...
                ['Any MATLAB expression that evaluates to an N-by-Ny matrix']);
            % if strcmp(file,'data_fd')
            XID.hload(1,3) = uicontrol(f,'pos',pos(9,:),'HorizontalAlignment','left',...
                'style','edit','Backgroundcolor','w','tooltip',...
                ['Any MATLAB expression that evaluates to an N-by-1 vector']);
            XID.hload(1,5) = uicontrol(f,'pos',pos(8,:),'HorizontalAlignment','left',...
                'style','text','string','Frequency');
            % end
        end
        uicontrol(f,'pos',pos(1,:)+[FigW 0 0 0],'style','frame');
        uicontrol(f,'pos',pos(4,:)+[FigW 0 0 0],...
            'HorizontalAlignment','left',...
            'style','text','string','Input:')
        XID.hload(1,19)=...
            uicontrol(f,'pos',pos(5,:)+[FigW 0 0 0],...
            'style','edit','Backgroundcolor','w',...
            'HorizontalAlignment','left','tooltip',...
            ['Enter channel names as strings without quotes, comma separated']);
        uicontrol(f,'pos',pos(6,:)+[FigW 0 0 0],...
            'style','text','string','Output:',...
            'HorizontalAlignment','left');
        XID.hload(1,20)=...
            uicontrol(f,'pos',pos(7,:)+[FigW 0 0 0],...
            'style','edit','Backgroundcolor','w',...
            'HorizontalAlignment','left','tooltip',...
            ['Enter channel names as strings without quotes, comma separated']);
        
        uicontrol(f,'pos',...
            [pos(2,1:2) FigW-2*(mEdgeToFrame+mFrameToText) pos(2,4)]+[FigW 0 0 0],...
            'style','text','string',...
            'Channel Names','fontweight','bold');
        %%% TOP LEVEL
        lev3=pos(1,2)+pos(1,4);
        
        pos = iduilay1(FigW,3,3,lev3,4);
        uicontrol(f,'style','frame','pos',pos(1,:));
        if strcmp(file(1:6),'data_f')
            
            popstr ={'Frequency Domain Signals',...
                    'Freq. Function (Complex)','Freq. Function (Amp/Phase)','Data Object'};%,'IDDATA/IDFRD object'};
            tt = ['Data are column vectors or arrays defining Inputs and Outputs or the '...
                    'Frequency Response.'];
            XID.hload(1,21) = uicontrol(f,'pos',...
                pos(3,:)+[0 -buth/2 0 +buth/2],'style','pop',...
                'backgroundcolor','white',...
                'string', popstr,'callback',...
                'iduifile(''pop'');','fontweight','bold',...
                'tooltip',tt);
        elseif strcmp(file(1:4),'data')
            XID.hload(1,21) = uicontrol(f,'pos',...
                pos(3,:)+[0 -buth/2 0 +buth/2],'style','pop',...
                'string', {'Time-Domain Signals','Data Object'},'fontweight','bold',...
                'tooltip', 'Data are column vectors or arrays defining Inputs and Outputs',...
                'callback','iduifile(''pop'');',...
                'backgroundcolor','white');
        else %object
            XID.hload(1,21) = uicontrol(f,'pos',...
                pos(3,:)+[0 -buth/2 0 +buth/2],'style','pop',...
                'string',{'IDDATA or IDFRD/FRD','Time Domain Signals',...
                    'Frequency Domain Signals'},'fontweight','bold',...
                'tooltip',['Enter as workspace variable an ',...
                    'IDDATA or an IDFRD object.'],...
                'backgroundcolor','white',...
                'callback','iduifile(''pop'');');
        end
        uicontrol(f,'pos',pos(2,:),'style','text','HorizontalAlignment',...
            'center','string','Data Format for Signals','Fontweight',...
            'bold');
        uicontrol(f,'pos',pos(1,:)+[FigW 0 0 0],'style','frame');
        XID.hload(1,10) = uicontrol(f,'pos',pos(2,:)+[FigW 0 0 0],'style','text',...
            'string','Input Properties','horizontalalignment',...
            'center','fontweight','bold');
        XID.hload(1,15) = uicontrol(f,'pos',pos(3,:)+[FigW+butw 0 -butw 0],...
            'backgroundcolor','white',...
            'style','pop','string','zoh|foh|bl','tooltip',...
            ['zoh=Zero-Order-Hold, foh=First-Order-Hold, bl=BandLimited'],...
            'userdata',0,'callback','set(gco,''Userdata'',1);');
        XID.hload(1,7) = uicontrol(f,'pos',pos(3,:)+[FigW 0 -butw*1.2 0],'style','text',...
            'HorizontalAlignment','left','string','InterSample:',...
            'Tooltip', 'Same for all inputs/experiments. Use IDDATA object if different');
        XID.hload(1,16) = uicontrol(f,'pos',pos(4,:)+...
            [FigW+butw 0 -butw*1 0],...
            'Backgroundcolor','w',...
            'HorizontalAlignment','left','style','Edit','string','inf',...
            'Tooltip',['Enter input period (same for all inputs).',...
                'Use ''inf'' for nonperiodic.'],'Userdata',0,...
            'callback','set(gco,''Userdata'',1);');
        XID.hload(1,23) = uicontrol(f,'pos',pos(4,:)+[FigW 0 -butw*1.2 0],'style','text',...
            'HorizontalAlignment','left','string','Period:');
        FigWH=[FigW pos(1,2)+pos(1,4)+mEdgeToFrame];
        ScreenPos = get(0,'ScreenSize');
        Sumbpos=get(XID.sumb(1),'pos');
        FigXY=max([0,0],(Sumbpos(1:2)+Sumbpos(3:4)-[0,FigWH(2)]));
        FigXY=min(FigXY,ScreenPos(3:4)-FigWH);
        FigPos=[FigXY FigWH];%+[FigW 0]];
        
        set(f,'pos',FigPos);
        set(get(f,'children'),'units','norm');
        if length(XID.layout)>18
            if XID.layout(19,3)
                eval('set(XID.hload(1,1),''pos'',XID.layout(19,1:4));','')
            end
        end  
        if nargin<3, set(XID.hload(1,1),'vis','on'),end
        iduistat('Enter input and output variable names.')
        
    end %if figflag
    set(Xsum,'UserData',XID);
    if strcmp(file(1:4),'data')
        iduifile('pop');
    end
elseif strcmp(arg,'load_model')
    cb1='iduipoin(1);iduistat(''Compiling...'');';
    cb2='iduipoin(1);';
    cb3='iduipoin(2);';
    
    FigName=idlaytab('figname',17);
    if ~figflag(FigName,0)
        iduistat('Opening the import dialog box ...')
        layout
        butw=mStdButtonWidth; buth=mStdButtonHeight;
        FigW=iduilay2(2);
        XID.hload(2,1)=figure('vis','off',...
            'DockControls','off',...
            'NumberTitle','off','Name',FigName,...
            'Integerhandle','off','HandleVisibility','callback',...
            'Color',get(0,'DefaultUIControlBackgroundColor'),'tag','sitb17');
        set(XID.hload(2,1),'Menubar','none');
        strload=[];
        
        % LEVEL 1
        
        pos = iduilay1(FigW,4,2);
        uicontrol(XID.hload(2,1),'pos',pos(1,:),'style','frame');
        uicontrol(XID.hload(2,1),'pos',pos(2,:),...
            'style','push','string','Import','callback',...
            [cb1,'iduifile(''insert_model'');',cb3]);
        uicontrol(XID.hload(2,1),'pos',pos(3,:),'style',...
            'push','string','Reset','callback','iduifile(''reset'',2)');
        uicontrol(XID.hload(2,1),'pos',pos(4,:),...
            'style','push','string','Close',...
            'callback','set(gcf,''vis'',''off'')');
        uicontrol(XID.hload(2,1),'pos',pos(5,:),...
            'style','push','string','Help',...
            'callback','iduihelp(''iduiimpm.hlp'',''Importing Models'');');
        
        % LEVEL 2 Frame for Data Info 
        lev2=pos(1,2)+pos(1,4);
        pos = iduilay1(FigW,5,5,lev2,4,4/2);
        uicontrol(XID.hload(2,1),'pos',pos(1,:),'style','frame');
        XID.hload(2,12) = uicontrol(XID.hload(2,1),'pos',pos(6,:)+...
            [0 0 0 2*buth+2*4],'style','edit',...
            'String','','max',2,'Backgroundcolor','w');
        uicontrol(XID.hload(2,1),'pos',pos(3,:),'style',...             
            'text','string','Notes:','Horizontalalignment','left');
        
        uicontrol(XID.hload(2,1),'pos',pos(2,:),...
            'style','text','string','Optional Model Information',...
            'HorizontalAlignment','center','Fontweight','bold');
        
        % LEVEL 3 Frame for Variable info
        lev3=pos(1,2)+pos(1,4);
        
        pos = iduilay1(FigW,5,5,lev3,3,2);
        uicontrol(XID.hload(2,1),'pos',pos(1,:),'style','frame');
        uicontrol(XID.hload(2,1),'pos',pos(2,:),'style','text','string',...
            'Model Variable','Fontweight','bold');
        uicontrol(XID.hload(2,1),'pos',pos(4,:)+[0 0 0 buth],'style','text','string',...
            'Enter the name of an IDMODEL or IDFRD workspace variable.', ...
            'HorizontalAlignment','left')
        
        XID.hload(2,4) = uicontrol(XID.hload(2,1),'pos',...
            pos(5,:),'style','edit','HorizontalAlignment','Left',...
            'String','','Backgroundcolor','w');
        FigWH=[FigW pos(1,2)+pos(1,4)+mEdgeToFrame];
        ScreenPos = get(0,'ScreenSize');
        Sumbpos=get(XID.sumb(1),'pos');
        FigXY=max([0,0],(Sumbpos(1:2)+Sumbpos(3:4)-[0,FigWH(2)]));
        FigXY=min(FigXY,ScreenPos(3:4)-FigWH);
        FigPos=[FigXY FigWH];
        set(XID.hload(2,1),'pos',FigPos);
        if length(XID.layout)>16
            if XID.layout(17,3)
                eval('set(XID.hload(2,1),''pos'',XID.layout(17,1:4));','')
            end
        end
        if nargin<3, set(XID.hload(2,1),'vis','on'),end
        set(get(XID.hload(2,1),'children'),'units','norm');
        iduistat('Enter model variable name.')
    end
    set(Xsum,'UserData',XID);
elseif strcmp(arg,'insert')
    iduistat('Inserting the data set ... ');
    %% First create the object in the 'DATA' case
    datatype = get(XID.hload(1,2),'userdata');
    stype = datatype(6:7); %td,fd or fr
    ap = (get(XID.hload(1,21),'value')==3); %amplitude/phase to be specified
    if strcmp(datatype(1:4),'data') % then we must first create the object
        stype = datatype(6:7); %td,fd or fr
        
        inpn=get(XID.hload(1,11),'string');
        outn=get(XID.hload(1,13),'string');
        if stype=='fd'|stype=='fr' % pick frequencies
            fren = get(XID.hload(1,3),'string');
            if isempty(fren)|strcmp(deblank(fren),'[]')
                errordlg(['For frequency functions and freqency domain data,'...
                        ' a frequency vector must be supplied.'],'Error Dialog','modal')
                return
            end
            try
                fre = evalin('base',fren);
            catch
                errordlg(['The frequency variable cannot be evaluated.',...
                        ' Check if the variable exists in the workspace.'],'Error Dialog','modal'); 
                return
            end
            
        end
        if (isempty(outn)|strcmp(deblank(outn),'[]'))
            if any(strcmp(stype,{'td','fd'}))
                errordlg('An output must always be supplied.','Error Dialog','modal')
                return
            elseif strcmp(stype,'fr')&ap
                errordlg('An phase variable must always be supplied.','Error Dialog','modal')
                return
            end
        end            
        if isempty(inpn)
            if ~strcmp(stype,'fr')
                tsq = questdlg(str2mat('No input variable has been specified.',['Should a time',...
                        ' series data set be created from the output variable?'],...
                    '(To avoid this question in the future, enter ''[]'' for the input.)'),...
                    'Time Series Data?');
                switch tsq
                    case 'Yes'
                        u = [];
                    otherwise
                        return
                end
            elseif ap % fr-ap
                errordlg('An amplitude  function must always be supplied.','Error Dialog','modal')
                return
            else
                errordlg('A frequency  function must always be supplied.','Error Dialog','modal')
                return
            end
        else
            try
                u = evalin('base',inpn);
            catch
                errordlg(char({['The input variable cannot be evaluated.'],...
                        ['Check if the variable exists in the workspace and, in the ',...
                            'multi-input case, that the different inputs have the ',...
                            'same number of rows.']}),'Error Dialog','modal'); 
                return
            end
        end
        if ~isempty(outn)
            try
                y = evalin('base',outn);
            catch
                errordlg({'The output variable cannot be evaluated.',...
                        ['Check if the variable exists in the workspace and, in the ',...
                            'multi-output case, that the different outputs have the ',...
                            'same number of rows.']},'Error Dialog','modal'); 
                return
            end
        else
            y =[];
        end
        
        if isa(y,'iddata')|isa(u,'iddata')
            errordlg(['The output or input variable is an IDDATA object. ',...
                    'Choose ''Import Object'' in the Data Menu instead.'],...
                'Error Dialog','modal');
            return
        end
        % Now test the sizes and check multiexp data
        if isa(y,'cell')|isa(u,'cell')
            errordlg(['To import multi-experiment data, first create the IDDATA object',...
                    ' in command line (see Help IDDATA), and then import.'],'Error Dialog','modal');
            return
        end
        if stype=='fr'
            erme = ['The frequency function data should either be a vector (SISO model) or a',...
                    ' ny-by-nu-Nfreq array.'];
            fdim = size(size(u)); fdim = fdim(2);
            %kolla y
            if fdim==2
                if min(size(u))==1
                    Nnu = length(u);
                    ny = 1; nu =1;
                    u = reshape(u,1,1,Nnu);
                end
                
            elseif fdim ==3
                [ny,nu,Nnu] = size(u);
            else 
                errordlg(erme,'Error Dialog','modal');
                return
            end
            if ap
                if ~all(size(u)==size(y))
                    errordlg(['The amplitude and phase must have the same sizes.',...
                        ' Please check the dimensions.'],'Error Dialog','modal')
                    return
                end
                u = u.*exp(i*pi/180*y);
                y =[];
            end
            if length(fre)~=length(u)|(length(y)>0&length(y)~=length(fre))
                errordlg(['The frequency vector, the responsedata and the spectrumdata ',...
                        '(if entered) must all have the same length.'],'Error Dialog','modal');
                return
            end
            try
                data = idfrd(u,fre,'spectrumdata',y);
            catch
                errordlg(lasterr,'Error Dialog','modal');
                return
            end
        end 
        if stype == 'td'|stype == 'fd'       
            [Nny,ny]=size(y); %check 0
            if Nny==0
                iduistat('No data inserted.');
                return
            end
            
            [Nnu,nu]=size(u); % check 0
            if Nny~=Nnu&Nnu>0
                errordlg(['The input and output must have the same number',...
                        ' of rows.'],'Error Dialog','modal');
                iduistat('No data inserted.');
                return
            end
            if nu>Nnu
                bns=questdlg(['You have more input channels than data points. Should ',...
                    'the input matrix be transposed?']);
                switch bns
                    case 'Yes'
                        u=u.';
                    case 'Cancel'
                        return
                end
            end
            if ny>Nny
                bns=questdlg(['You have more output channels than data points. Should ',...
                    'the output matrix be transposed?']);
                switch bns
                    case 'Yes'
                        y=y.';
                    case 'Cancel'
                        return
                end
            end
                
            try
                if stype=='td'
                    data = iddata(y,u);
                else
                    data = iddata(y,u,'Domain','Frequency','Frequency',fre);
                end
            catch errordlg(lasterr,'Error Dialog','Modal');
                return
            end
        end
        %% Now set the tstart/frequency unit
        if isa(data,'iddata')
            Ne = size(data,'Ne');
            dom = pvget(data,'Domain'); dom = lower(dom(1));
        else
            Ne = 1;
            dom = 'f';
        end
        str2=get(XID.hload(1,8),'string');
        %        if iduifile('test1',str1,'tsamp');return,end
        if dom=='t'
            if iduifile('test1',str2,'startt');return,end
            str2 = eval(str2);
        else
            str2=str2(find(str2~=' '));
            if str2(1)=='{'
                str2 = str2(2:end);
            end
            if str2(end)=='}';
                str2 = str2(1:end-1);
            end
            if Ne>1
                com = findstr(str2,',');
                %ucom = findstr(una,',');
                com =[com, length(str2)+1];
                str2c{1} = deblank(str2(1:com(1)-1));
                for k = 1:length(com)-1
                    str2c{k+1} = deblank(str2(com(k)+1:com(k+1)-1));
                end
                str2 = str2c;
            end
        end
        
        
        % data=pvset(data,'Ts',eval(str1),'Name',dAta_n);
        try
            if isa(data,'iddata')
                data = pvset(data,'Tstart',str2);
            else
                data = pvset(data,'Units',str2);
            end
        catch 
            errordlg(lasterr,'Error Dialog','Modal');
            return
        end
    else
        iddn = get(XID.hload(1,11),'string');
        try
            data = evalin('base',iddn);
        catch
            errordlg(char({['The variable cannot be evaluated.'],...
                    ['Check if the variable exists in the workspace.']}),'Error Dialog','modal'); 
            return
        end   
    end
    
    % Now data is an object
    dAta_n=get(XID.hload(1,4),'string');
    una = get(XID.hload(1,19),'string');
    yna = get(XID.hload(1,20),'string');
    uu = get(XID.hload(1,18),'string');
    yu = get(XID.hload(1,17),'string');
    if ~strcmp(stype,'fr')
        intertouch = get(XID.hload(1,15),'userdata');
        inter = get(XID.hload(1,15),'value');
        pertouch = get(XID.hload(1,16),'userdata');
        per = get(XID.hload(1,16),'string');
    end
    if isempty(dAta_n)
        try
            dAta_n=[outn,inpn];set(XID.hload(1,4),'string',dAta_n),drawnow
        catch
            errordlg('A Data name must be supplied.','Error Dialog','modal');
            return
        end
    end
    if isa(data,'iddata')
        Ne = size(data,'Ne');
        dom = pvget(data,'Domain'); dom = lower(dom(1));
    else
        Ne = 1;
        dom = 'f';
    end
    str1=get(XID.hload(1,6),'string');
    str2=get(XID.hload(1,8),'string');
    if get(XID.hload(1,6),'userdata')
        if iduifile('test1',str1,'tsamp');return,end
    end
    if dom=='t'
        if iduifile('test1',str2,'startt');return,end
        data = pvset(data,'Tstart',eval(str2));
    end
    
    if dom=='f'
        if any(lower(str2)=='h')
            data = chgunits(data,'rad/s'); %always rad/s in GUI
            warndlg(['The frequency unit in the data set representation within the GUI is always ''rad/s''.',...
                    ' You can choose desired frequency scales in the plots by the pulldown menus.'],...
                'warning','modal')
        end
    end
    if get(XID.hload(1,6),'userdata')
        data=pvset(data,'Ts',eval(str1));
    end
    data = pvset(data,'Name',dAta_n);
    
    [Ncap,ny,nu] =sizedat(data);
    if nu==0&dom=='f'
        %errordlg(['No estimation is currently supported for '...
        %'frequency domain data without an input.'],'Error Dialog','modal')
        %return
    end
    yna = deblank(yna);
    if ~isempty(yna)
        ycom = findstr(yna,',');
        ycom =[ycom, length(yna)+1];
        yname{1} = deblank(yna(1:ycom(1)-1));
        for k = 1:length(ycom)-1
            yname{k+1} = deblank(yna(ycom(k)+1:ycom(k+1)-1));
        end
        if length(yname)~=ny
            errordlg(...
                ['The number of OutputNames must equal the number of channels.',...
                    ' The different names should be separed by commas in the edit field.'],'Error Dialog','modal');
            iduifile('more');
            return
        end
        data = pvset(data,'OutputName',yname);
        
    end
    una = deblank(una);
    if ~isempty(una)
        ucom = findstr(una,',');
        ucom =[ucom, length(una)+1];
        uname{1} = deblank(una(1:ucom(1)-1));
        for k = 1:length(ucom)-1
            uname{k+1} = deblank(una(ucom(k)+1:ucom(k+1)-1));
        end
        if length(uname)~=nu
            errordlg(['The number of InputNames must equal the number of channels.',...
                    ' The different name should be separed by commas in the edit field.'],'Error Dialog','modal');
            iduifile('more');
            return
        end
        data = pvset(data,'InputName',uname);
    end
    yu = deblank(yu);
    if ~isempty(yu)
        ycom = findstr(yu,',');
        ycom =[ycom, length(yu)+1];
        yun{1} = deblank(yu(1:ycom(1)-1));
        for k = 1:length(ycom)-1
            yun{k+1} = deblank(yu(ycom(k)+1:ycom(k+1)-1));
        end
        if length(yun)~=ny
            errordlg(['The number of OutputUnits must equal the number of channels.',...
                    ' The different name should be separed by commas in the edit field.'],'Error Dialog','modal');
            iduifile('more');
            return
        end
        data = pvset(data,'OutputUnit',yun);
        
    end
    uu = deblank(uu);
    if ~isempty(uu)
        ucom = findstr(uu,',');
        ucom =[ucom, length(uu)+1];
        uun{1} = deblank(uu(1:ucom(1)-1));
        for k = 1:length(ucom)-1
            uun{k+1} = deblank(uu(ucom(k)+1:ucom(k+1)-1));
        end
        if length(uun)~=nu
            errordlg(['The number of InputUnits must equal the number of channels.',...
                    ' The different name should be separed by commas in the edit field.'],'Error Dialog','modal');
            iduifile('more');
            return
        end
        data = pvset(data,'InputUnit',uun);
    end
    
    SL=get(XID.hload(1,12),'string');
    if ~isempty(SL)
        data = iduiinfo('set',data,SL);
    end
    data = iduiinfo('add',data,[' % Import   ',dAta_n]);
    if ~strcmp(stype,'fr')
        if intertouch
            for kexp = 1:Ne
                for ku = 1:nu
                    if inter==1
                        ints{ku,kexp} = 'foh';
                    elseif inter==2
                        ints{ku,kexp} = 'foh';
                    elseif inter==3
                        ints{ku,kexp} = 'bl';
                    end
                end
            end
            data = pvset(data,'InterSample',ints);
        end
        if pertouch
            per = eval(per);
            if ~iscell(per)&length(per)>1
                errordlg(['All inputs must be assigned the same period.'...
                        ' For multiexperiment data with different periods, a cell',...
                        ' array must be used, like in {inf, 27}.'],'Error Dialog','modal')
                return
            end
            if ~iscell(per),per = {per};end
            if iscell(per)
                if length(per)==1&Ne>1
                    per = repmat(per,1,Ne);
                elseif length(per)~=Ne
                    errordlg('The period must be a cellarray of length # of experiments.',...
                        'Error Dialog','modal');
                    return
                end
            end
            
            err = 0;
            for kexp = 1:Ne
                pers = per{kexp};
                if ~strcmp(pers,'inf')
                    
                    if ~isa(pers,'double')
                        err=1;
                    elseif length(pers)>1
                        err=1;
                    elseif pers<=0|floor(pers)~=pers
                        err = 1;
                    end
                end
                perss{kexp} = ones(nu,1)*pers;
            end
            if err
                errordlg({['The period must either be given as inf (no quotes)',...
                            ' or as a positive integer. The same period',...
                            ' is assumed for all input channels.'],...
                        ['For multiexperiment data use a' ...
                            ' cell array.']},'Error Dialog','modal');
                return
            end
            try
                data = pvset(data,'Period',perss);
            catch
                errordlg(lasterr,'Error Dialog','modal')
            end
        end
    end
    lastwarn('')
    was = warning;
    warning off
    data = nyqcut(data);
    warning(was)
    N = sizedat(data);
    if N==0
        errordlg(['Empty data set',...
            ' (after frequencies above the Nyquist frequency have been removed).'],...
        'Error Dialog','modal')
    return
end
    if ~isempty(lastwarn)&warflag
        warndlg(lastwarn,'Warning','modal');
    end
    iduiinsd(data,1);
    
    
elseif strcmp(arg,'reset')
    iduistat('Resetting the dialog entries ...')   
    if file==2
        set(XID.hload(2,[4,12]),'string','');
    elseif any(file==[1,3])
        set(XID.hload(file,[4,3,12]),'string','');
        try
            if strcmp(get(XID.hload(file,2),'userdata'),'data_td')
                set(XID.hload(file,8),'string',int2str(1)); %%Tstart
            else
                set(XID.hload(file,8),'string','rad/s');
            end
            set(XID.hload(file,6),'string',int2str(1));
        catch
        end
        if file==1,
            set(XID.hload(1,[11,13,17:20]),'string','');
            set(XID.hload(1,16),'string','inf');
            set(XID.hload(1,15),'value',1);
        end
        % if file==3,set(XID.hload(3,10),'string',int2str(1));end
    end
    iduistat('')
elseif strcmp(arg,'test1')
    % Test if sampling interval and startt are reasonable
    % Find out the domain
    set(XID.hload(1,6),'userdata',1); % To mark that it has been touched
    dominf = get(XID.hload(1,21),'tag'); 
    dom = lower(dominf(1));   
    %dum = 't'/'f' means time/frequency domain data
    
    if nargin<2
        Tsstring=get(iduigco,'string');
        tagg=get(iduigco,'tag');
    else
        Tsstring=file;
        tagg=dum;
    end
    if dom=='f'&strcmp(tagg,'startt') % then this willbe tested later
        return
    end
    outarg=0;
    try
        testts=eval(Tsstring);
    catch
        outarg=1;
    end
    if strcmp(tagg,'tsamp')
        msg={'The sampling interval could not be evaluated.',...
                'It must be given as a positive real number.',...
                'Variable names in the workspace cannot be used.',...
                'For Multiexperiment data use a cell array.'};
    else
        msg={'The starting time could not be evaluated.',...
                'It must be given as a real number.',...
                'Variable names in the workspace cannot be used.',...
                'For Multiexperiment data use a cell array.'};
    end
    if outarg
        errordlg(msg,'Error Dialog','modal');
        return
    end
    if ~iscell(testts)
        testts1={testts};
    else
        testts1 = testts;
    end
    for kexp = 1:length(testts1)
        testts=testts1{kexp};
        
        if length(testts)>1|length(testts)<1,
            outarg = 1;
        end
        
        if isstr(testts),outarg=1;end
        if testts(1)<0&strcmp(tagg,'tsamp'),outarg=1;end
        if testts(1)==0&strcmp(tagg,'tsamp')&dom=='t',outarg=1;end
    end
    if outarg
        errordlg(msg,'Error Dialog','modal');
        return
    end
elseif strcmp(arg,'object')
    iddn = get(XID.hload(1,11),'string');
    set(XID.hload(1,6),'userdata',0) % To mark that Ts has not been touched
    try
        idd = evalin('base',iddn);
    catch
        errordlg(char({['The variable cannot be evaluated.'],...
                ['Check if the variable exists in the workspace.']}),'Error Dialog','modal'); 
        return
    end   
    if isa(idd,'frd')
        idd = idfrd(idd);
        frdflag = 1;
        fdflag = 1;
        set(XID.hload(1,13),'string','FRD');
        set(XID.hload(1,21),'tag','frc');
        set(XID.hload(1,[7,15,10,23,16]),'enable','off');
    elseif isa(idd,'idfrd')
        
        frdflag = 1;
        fdflag = 1;
        set(XID.hload(1,13),'string','IDFRD');
        set(XID.hload(1,21),'tag','frc');
        set(XID.hload(1,[7,15,10,23,16]),'enable','off');
        
    elseif isa(idd,'iddata')
        frdflag = 0;
        dom = pvget(idd,'Domain');
        if strcmp(lower(dom),'frequency');
            fdflag = 1;
            set(XID.hload(1,13),'string','IDDATA (Freq. Domain)');
            set(XID.hload(1,21),'tag','fdd');
        else
            fdflag = 0;
            set(XID.hload(1,13),'string','IDDATA (Time Domain)');
            set(XID.hload(1,21),'tag','tdd');
        end
        Ne = size(idd,'Ne');
        if Ne>1
            set(XID.hload(1,3),'string',['Contains ',int2str(Ne),' experiments.'])
        else
            set(XID.hload(1,3),'string','')
        end
        set(XID.hload(1,[7,15,10,23,16]),'enable','on');
        
    else
        errordlg([iddn,' is not an IDDATA, FRD nor IDFRD object.'],'Error Dialog','modal');
        return
    end
    
    [Ndat,Nytest,Nutest] = sizedat(idd);
    
    if Nytest == 0
        errordlg([iddn,' has no output signal.'],'Error Dialog', ...
            'modal');
        return
    end
    
    data_n = pvget(idd,'Name');
    if isempty(data_n)
        data_n = iddn;
    end
    set(XID.hload(1,4),'string',data_n);
    yna = pvget(idd,'OutputName');
    ynna = [];
    for ky = 1:length(yna)
        ynna = [ynna,yna{ky},','];
    end
    ynna = ynna(1:end-1);
    una = pvget(idd,'InputName');
    unna = [];
    for ky = 1:length(una)
        unna = [unna,una{ky},','];
    end
    unna = unna(1:end-1);
    uu = pvget(idd,'InputUnit');
    unu = [];
    for ky = 1:length(uu)
        unu = [unu,uu{ky},','];
    end
    unu = unu(1:end-1);
    yu = pvget(idd,'OutputUnit');
    ynu = [];
    for ky = 1:length(yu)
        ynu = [ynu,yu{ky},','];
    end
    ynu = ynu(1:end-1);
    Ts = pvget(idd,'Ts');
    if ~frdflag
        Tstart = pvget(idd,'Tstart'); 
        per = pvget(idd,'Period');
        Tsstr = num2str(Ts{1});
        if ~fdflag
            Tssatr = num2str(Tstart{1});
        else
            Tssatr = Tstart{1};
        end
    end
    if ~frdflag
        int = pvget(idd,'InterSample');
        if ~isempty(int)
            int = int{1,1};
        end
        pers = per{1};
        perst = '';
        try
            perst = int2str(pers(1)); %Same per for all inputs
        end
        
    end
    if frdflag%|fdflag
        if iscell(Ts)
            Ts = Ts{1};
        end
        Tsstr = num2str(Ts);
        Tstart = get(idd,'Units');
        Tssatr = Tstart;
        if iscell(Tstart)
            Tssatr = Tstart{1};
        else
            Tssatr = Tstart;
        end
    end
    if ~frdflag    
        for kexp = 2:length(Ts)
            Tsstr=[Tsstr,',',num2str(Ts{kexp})];
            if fdflag
                Tssatr = [Tssatr,', ',Tstart{kexp}];
            else
                Tssatr=[Tssatr,',',num2str(Tstart{kexp})];
            end
            try
                pers1 = per{kexp};
                perst=[perst,',',int2str(pers1(1))];
            end
        end
        if length(Ts)>1
            Tsstr=['{',Tsstr,'}'];
            Tssatr=['{',Tssatr,'}'];
            if ~isempty(pers)
                perst=['{',perst,'}'];
            end
            %else
            %Tsstr = num2str(Ts{1});
        end   
        
    end
    set(XID.hload(1,6),'string',Tsstr);
    set(XID.hload(1,8),'string',Tssatr); %must not be a string
    if fdflag
        set(XID.hload(1,2),'string','Frequency unit:');
        if frdflag
            set(XID.hload(1,2),'userdata','obje_fr');
        else
            set(XID.hload(1,2),'userdata','obje_fd');
        end
    else
        set(XID.hload(1,2),'string','Starting time:');
        set(XID.hload(1,2),'userdata','obje_td');
    end
    set(XID.hload(1,19),'string',unna);
    set(XID.hload(1,20),'string',ynna);
    set(XID.hload(1,18),'string',unu);
    set(XID.hload(1,17),'string',ynu);
    if ~frdflag
        if isempty(int), int = 'NA';end % INT undedfined
        switch int
            case 'zoh'
                popv = 1;
            case 'foh'
                popv = 2;
            case 'bl'
                popv = 3;
            otherwise
                popv = 1;
        end
        set(XID.hload(1,15),'value',popv,'userdata',0);
        set(XID.hload(1,16),'string',perst,'userdata',0);
    end
    try
        set(XID.hload(1,12),'string',pvget(idd,'Notes'));
    catch
    end
    %     
elseif strcmp(arg,'more')
    if strcmp(get(XID.hload(1,14),'String'),'Less')
        return
    end
    
    f = XID.hload(1,1);
    set(f,'unit','pixel');
    set(get(XID.hload(1,1),'children'),'units','pixel');
    
    pos = get(f,'pos');
    set(f,'pos',[pos(1:2),2*pos(3),pos(4)]);
    set(f,'unit','norm');
    set(get(XID.hload(1,1),'children'),'units','norm');
    
    set(XID.hload(1,14),'String','Less','callback','iduifile(''less'')');
elseif strcmp(arg,'less')
    f = XID.hload(1,1);
    set(f,'unit','pixel');
    set(get(XID.hload(1,1),'children'),'units','pixel');
    
    pos = get(f,'pos');
    set(f,'pos',[pos(1:2),pos(3)/2,pos(4)]);
    set(f,'unit','norm');
    set(get(XID.hload(1,1),'children'),'units','norm');
    
    set(XID.hload(1,14),'String','More','callback', ...
        'iduifile(''more'')');
elseif strcmp(arg,'pop')
    test = get(XID.hload(1,2),'Userdata');
    popv = get(XID.hload(1,21),'Value');
    if (any(strcmp(test,{'data_fd','data_fr'}))&popv==4)|(strcmp(test,'data_td')&popv==2)
        % Then an object is called for
        iduifile('load_iodata','object');
        return
    end
    if strcmp(test(1:4),'obje') % then call for new figure
        if popv == 2
            iduifile('load_iodata','data_td');
        elseif popv==3
            iduifile('load_iodata','data_fd');
        end
        return
    end
    if any(strcmp(test,{'data_fd','data_fr'}))
        popv = popv+1;
    end
    switch popv
        case 1 %Time domain data
            set(XID.hload(1,2),'UserData','data_td','string','Starting time');
            set(XID.hload(1,8),'String',int2str(1));
            set(XID.hload(1,24),'String','Input:')
            set(XID.hload(1,25),'String','Output:')
            set(XID.hload(1,[11]),'callback',[],'tooltip',...
                ['Any MATLAB expression that evaluates to an N-by-Nu matrix']);
            set(XID.hload(1,[13]),'callback',[],'tooltip',...
                ['Any MATLAB expression that evaluates to an N-by-Ny matrix']);
            %%LL Tooltip  Outtput
            set(XID.hload(1,[13,25]),'enable','on','vis','on');
            set(XID.hload(1,[3,5]),'visible','off')
            set(XID.hload(1,[7 15 10 23 16]),'enable','on')
            set(XID.hload(1,21),'tag','tdd')
        case 2 % Frequency Domain Data
            set(XID.hload(1,2),'UserData','data_fd','String', 'Frequency unit');
            set(XID.hload(1,8),'String','rad/s');
            set(XID.hload(1,6),'Tooltip',...
                ['Enter the sampling interval of the underlying time signal.',...
                    'Use 0 for continuous time.'])
            set(XID.hload(1,24),'String','Input:')
            set(XID.hload(1,25),'String','Output:','vis','on')
            set(XID.hload(1,11),'callback',[],'tooltip',...
                ['Any MATLAB expression that evaluates to an N-by-Nu matrix']);
            set(XID.hload(1,[13]),'callback',[],'tooltip',...
                ['Any MATLAB expression that evaluates to an N-by-Ny matrix']);
            %%LL Tooltip  Outtput
            set(XID.hload(1,[13,25]),'enable','on','vis','on');
            set(XID.hload(1,[3,5]),'enable','on','visible','on')
            set(XID.hload(1,[7 15 10 23 16]),'enable','on')
            set(XID.hload(1,21),'tag','fdd')
            
        case 3
            %% prepare for IDFRD
            set(XID.hload(1,2),'UserData','data_fr','string','Frequency Unit');
            set(XID.hload(1,8),'String','rad/s');
            set(XID.hload(1,6),'Tooltip',...
                ['Enter the sampling interval of the underlying time signal.',...
                    'Use 0 for continuous time.'])
            set(XID.hload(1,24),'String','Freq. Func.','tooltip','Complex-valued frequency function')
            set(XID.hload(1,25),'String','Spectrum:','tooltip',...
                'Spectrum of the output disturbance','vis','off')
            set(XID.hload(1,11),'callback',[],'tooltip',...
                ['Any MATLAB expression that evaluates to an N-vector or an Ny-by-Nu-by-N array']);
            set(XID.hload(1,[13]),'callback',[],'tooltip',...
                ['Leave empty or any MATLAB expression that evaluates to an N vector or an Ny-by-Ny-by-N array'],...
                'vis','off');
            %%LL Tooltip  Outtput
            set(XID.hload(1,[13,25]),'enable','on');
            set(XID.hload(1,[3,5]),'enable','on')
            %               
            set(XID.hload(1,[7 15 10 23 16]),'enable','off')
            set(XID.hload(1,21),'tag','frc')
            
        case 4 % FF AMplitude/Phase
            %% prepare for IDFRD
            set(XID.hload(1,2),'UserData','data_fr','string','Freq. Unit');
            set(XID.hload(1,8),'String','rad/s');
            set(XID.hload(1,24),'String','Amplitude:','tooltip','Amplitude |G(omega)|')
            set(XID.hload(1,25),'String','Phase (deg):','tooltip','Phase in degrees','vis','on')
            set(XID.hload(1,11),'callback',[],'tooltip',...
                ['Any MATLAB expression that evaluates to an N-vector or an Ny-by-Nu-by-N array']);
            set(XID.hload(1,[13]),'callback',[],'tooltip',...
                ['Any MATLAB expression that evaluates to an N vector or an Ny-by-Nu-by-N array'],...
                'vis','on');
            %%LL Tooltip  Outtput
            set(XID.hload(1,[13,25]),'enable','on');
            set(XID.hload(1,[3,5]),'enable','on')
            set(XID.hload(1,21),'tag','fra')
            set(XID.hload(1,[7 15 10 23 16]),'enable','off')
    end
elseif strcmp(arg,'insert_model')
    name = get(XID.hload(2,4),'string');
    if isempty(name)
        errordlg('A model name must be supplied.','Error Dialog','modal')
        return
    end
    try
        mod = evalin('base',name); 
    catch
        errordlg(['The variable ',name,' does not exist in workspace.'],'Error Dialog','modal')
        return
    end
    if ~isa(mod,'idmodel') 
        if isa(mod,'lti')
            mod = idss(mod);
        elseif isa(mod,'idfrd')
        else
            try
                mod = th2ido(mod);
            catch
                errordlg(['The variable ',name,' is not of a recognized model type.'],'Error Dialog','modal')
                return
            end
        end        
    end
    try
        if isempty(pvget(mod,'Name'))
            nr = findstr(name,'{');
            nr1 = findstr(name,'('); 
            nr = min([nr,nr1]);
            if ~isempty(nr)
                if nr == 1
                    errordlg('Please remove parentheses in model name.','Error Dialog','modal')
                    return
                end
                name = name(1:min(nr)-1);
            end
            mod = pvset(mod,'Name',name);
        end
    catch
    end
    info = get(XID.hload(2,12),'string');
    if ~isempty(info);
        mod = iduiinfo('set',mod,info);
    end
    if isa(mod,'idmodel')&(any(isnan(pvget(mod,'ParameterVector')))|...
            any(isinf(pvget(mod,'ParameterVector'))))
        errordlg({'This model is not well defined. In contains',...
                ' NaN and/or Inf and cannot be imported.'},'Error Dialog',...
            'modal');
        return
    end
    iduiinsm(mod,0,[],1);
    
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [sig,Ncap,ny,nu,err] = xtract(handle,message,dim,empt)
err = 0;
name = get(handle,'string');
if isempty(name)
    if empt==1
        tsq = questdlg(str2mat('No ',message,' variable has been specified.',['Should a time',...
                ' series data set be created from the output variable?'],...
            '(To avoid this question in the future, enter ''[]'' for the input.)'),...
            'Time Series Data?');
        switch tsq
            case 'Yes'
                sig = [];
            otherwise
                err = 1;
                return
        end
    elseif empt == 2
        errordlg(['No ',message,' variable has been defined.'],'Error Dialog','modal');
        err = 1;
        
    end
else
    try
        sig = evalin('base',name);
    catch
        errordlg({['The ',message,' variable cannot be evaluated.'],...
                ['Check if the variable exists in the workspace and, in the ',...
                    'multi-input case, that the different inputs have the ',...
                    'same number of rows.']},'Error Dialog','modal'); 
        return
    end
end