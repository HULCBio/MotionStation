function anfisedit(action);
%ANFISEDIT anfis GUI tool.
%   The ANFIS Editor is used to create, train, and test a Sugeno fuzzy system. 
%
%   See also FUZZY, MFEDIT, RULEEDIT, RULEVIEW, SURFVIEW.

%   Kelly Liu, Dec. 96  N. Hickey Jan. 2001
%   Copyright 1994-2004 The MathWorks, Inc.
%   $Revision: 1.42.4.3 $  $Date: 2004/04/10 23:15:22 $

if nargin<1,
    % Open up an untitled system.
    newFis=newfis('Untitled', 'sugeno');
    newFis=addvar(newFis,'input','emptyinput1',[0 1],'init');
    newFis=addvar(newFis,'output','output1',[0 1],'init');
    action=newFis;
end

if isstr(action),
    if action(1)~='#',
        % The string "action" is not a switch for this function, 
        % so it must be a disk file
        fis=readfis(action);
        if ~strcmp(fis.type, 'sugeno') | length(fis.output)>1
            disp('anfis editor only works on Sugeno systems with one output');
            return;
        else
            action='#initialize';
        end
    end
else
    % For initialization, the fis is passed in as the parameter
    fis=action;
    action='#initialize';
end;
%=======initialize anfisedit============
switch action
case '#initialize',
    if isfield(fis, 'input')
        numInputs=length(fis.input);
    else
        numInputs=0;
    end
    
    if isfield(fis, 'output')
        numOutputs=length(fis.output);
    else
        numOutputs=0;
    end
    if isfield(fis, 'rule')
        numRules=length(fis.rule);
    else
        numRules=0;
    end
    
    numInputMFs = zeros(1,numInputs);
    for i=1:numInputs
        numInputMFs(i)=length(fis.input(i).mf);
    end
    totalInputMFs=sum(numInputMFs);
    fisnodenum=numInputs+2*totalInputMFs+2*numRules+2+1;
    infoStr=['Number of nodes: ' num2str(fisnodenum)];
    
    fisName=fis.name;
    nameStr=['Anfis Editor: ' fisName];
    savefis{1}=fis;
    figNumber=figure( ...
        'Name',nameStr, ...
        'Units', 'pixels', ...
        'Color', [.75 .75 .75],...
        'NumberTitle','off', ...
        'MenuBar','none', ...
        'IntegerHandle','off',...
        'Tag', 'anfisedit',...
        'Userdata', savefis,...
        'Visible','off', ...
        'DockControls', 'off');
    
    
    %====================================
    % The MENUBAR items
    
    % Call fisgui to create the menubar items
    fisgui #initialize
    
    axes( ...
        'Units','normalized', ...
        'Position',[0.10 0.55 0.65 0.38]);
    
    %===================================    
    left=0.03;
    right=0.75;
    bottom=0.05;
    labelHt=0.03;
    spacing=0.005;
    frmBorder=0.012;
    %======Set up the anfis info Window==========
    top=0.5;    
    % First, the all the frames 
    frmPos=[0 0 1 .47];
    frmHandle=LocalBuildFrmTxt(frmPos, '', 'frame', 'mainfrm'); 
    frmPos=[.01 .115 .292 .34];
    frmHandle=LocalBuildFrmTxt(frmPos, '', 'frame', 'datafrm'); 
    midfrmwidth=.25;
    frmPos=[.315 .115 midfrmwidth .34];
    frmHandle=LocalBuildFrmTxt(frmPos, '', 'frame', 'midbtnfrm'); 
    frmPos=[.575 .115 .195 .34];
    frmHandle=LocalBuildFrmTxt(frmPos, '', 'frame', 'rightbtnfrm'); 
    frmPos=[.78 .115 .21 .34];
    frmHandle=LocalBuildFrmTxt(frmPos, '', 'frame', 'infofrm'); 
    frmPos=[.01 .0218 .62 .073];
    frmHandle=LocalBuildFrmTxt(frmPos, '', 'frame', 'statusfrm'); 
    frmPos=[.64 .0218 .35 .073];
    frmHandle=LocalBuildFrmTxt(frmPos, '', 'frame', 'statusfrm'); 
    
    %======load data===============
    left=.02;
    labelPos=[.05+left .42 .15 .042];    
    lableHndl=LocalBuildFrmTxt(labelPos, '   Load data', 'text', 'lable2');
    width=.13;
    height=.04;
    left1=left+.14;
    width1=.13;
    height1=.04;
    labelPos=[left .38 .1 .042];    
    lableHndl=LocalBuildFrmTxt(labelPos, 'Type:', 'text', 'lable2');
    labelPos=[left1 .38 .1 .042];    
    lableHndl=LocalBuildFrmTxt(labelPos, 'From:', 'text', 'lable2');
    labelPos=[left .33 width height];    
    mcwPos=[left1 .30 width1 height1];
    lableHandle=LocalBuildUi(labelPos, 'radio', 'anfisedit #radioloadtype', 'Training', 'dattype');
    set(lableHandle, 'Max', 1, 'Value', 1);
    % Then the editable text field
    
    mcwHndl=LocalBuildUi(mcwPos, 'radio', 'anfisedit #radioloadfrom', 'disk', 'trndatin');
    set(mcwHndl, 'Max', 1, 'Value', 1);
    labelPos=[left .28 width height];    
    mcwPos=[left1 .23 width1 height1];
    lableHandle=LocalBuildUi(labelPos,  'radio', 'anfisedit #radioloadtype', 'Testing','dattype');
    set(lableHandle, 'Max', 1, 'Min', 0);
    % Then the editable text field
    
    mcwHndl=LocalBuildUi(mcwPos, 'radio', 'anfisedit #radioloadfrom', 'worksp.', 'trndatin');
    
    labelPos=[left .23 width height];    
    lableHandle=LocalBuildUi(labelPos,  'radio', 'anfisedit #radioloadtype', 'Checking','dattype');
    set(lableHandle, 'Max', 1, 'Min', 0);
    
    labelPos=[left .18 width height];    
    lableHandle=LocalBuildUi(labelPos,  'radio', 'anfisedit #radioloadtype', 'Demo','dattype');
    set(lableHandle, 'Max', 1, 'Min', 0);
    
    %   set(mcwHndl, 'Max', 1);
    mcwPos=[left .13 .13 height]; 
    %=======The Open Training set button==============
    delHndl=LocalBuildUi(mcwPos, 'pushbutton', 'anfisedit #opentrn', 'Load Data...', 'opentrn');
    mcwPos=[left+.14 .13 .13 height]; 
    delHndl=LocalBuildUi(mcwPos, 'pushbutton', 'anfisedit #cleardata', 'Clear Data', 'opentrn');
    
    
    %========Set up the Status Window ==================     
    
    % Then the status text field
    mcwPos=[0.02 0.04 0.55 0.040];
    mcwHndl=LocalBuildUi(mcwPos, 'text', '', '', 'status');
    %==========set genfis area============================
    % The text label
    labelPos=[.34 .42 .18 .042];      
    lableHndl=LocalBuildFrmTxt(labelPos, '   Generate FIS', 'text', 'lable2');
    left=.33;
    width=.225;
    height=.04;
    labelPos=[left .35  width height];    
    lableHandle=LocalBuildUi(labelPos, 'radio', 'anfisedit #radiogenfis', 'Load from disk', 'genfis');
    labelPos=[left .30  width height];    
    lableHandle=LocalBuildUi(labelPos, 'radio', 'anfisedit #radiogenfis', 'Load from worksp.', 'genfis');
    labelPos=[left .25  width height];    
    lableHandle=LocalBuildUi(labelPos, 'radio', 'anfisedit #radiogenfis', 'Grid partition', 'genfis');
    set(lableHandle, 'Max', 1, 'Value', 1);
    labelPos=[left .20  width height];    
    lableHandle=LocalBuildUi(labelPos, 'radio', 'anfisedit #radiogenfis', 'Sub. clustering', 'genfis');
    % Then the editable text field
    labelPos=[left .13  width height];    
    
    mcwHndl=LocalBuildUi(labelPos, 'pushbutton', 'anfisedit #genfis', 'Generate FIS ...', 'genfisbtn');
    
    
    %====================================
    % Information for anfis
    left=0.80;
    btnWid=0.15;
    top=.55;
    frmBorder=0.02;
    frmPos=[left-frmBorder .5 btnWid+2*frmBorder .46];
    frmHandle=LocalBuildFrmTxt(frmPos, '', 'frame', '');
    labelPos=[left .95 .15 .030];    
    lableHndl=LocalBuildFrmTxt(labelPos, '  ANFIS Info.', 'text', 'lable2');
    % Then the info text field
    mcwPos=[left .65 .15 .24]; 
    textHndl=LocalBuildFrmTxt(mcwPos, infoStr, 'text', 'Comments');
    mcwPos=[left .57 .15 .04]; 
    
    % Create the Structure button
    StrctBtnHndl=LocalBuildUi(mcwPos, 'pushbutton', '', 'Structure', 'plotstrc');
    set(StrctBtnHndl,'CallBack', @LocalStructureBtnCallback);
    
    set(StrctBtnHndl, 'Backgroundcolor', [0.75 0.75 0.75], 'HorizontalAlignment', 'center'); 
    mcwPos=[left .52 .15 .04]; 
    delHndl=LocalBuildUi(mcwPos, 'pushbutton', 'cla', 'Clear Plot', '');
    set(delHndl, 'HorizontalAlignment', 'center');
    
    %=========The Train fis=============
    labelPos=[.6 .42 .14 .042];    
    lableHndl=LocalBuildFrmTxt(labelPos, '   Train FIS', 'text', 'lable2');
    frmBorder=0.02;
    btnHt=0.03;
    yPos=top+.31;
    left=.595;
    width=.16;
    height=.04;
    labelPos=[left .39  width height];    
    lableHandle=LocalBuildFrmTxt(labelPos, 'Optim. Method:','text', '');
    labelPos=[left .35  width height];    
    lableHandle=LocalBuildUi(labelPos, 'popupmenu', '', {'backpropa', 'hybrid'}, 'trnmethod');
    set(lableHandle, 'value', 2);
    labelPos=[left .295  width height];    
    lableHandle=LocalBuildFrmTxt(labelPos, 'Error Tolerance:','text', '');
    labelPos=[left .26  width height];    
    lableHandle=LocalBuildUi(labelPos, 'edit', 'anfisedit #errorlim', '0', 'errlim');
    set(lableHandle, 'backgroundcolor', 'white');
    labelPos=[left .22  width height];    
    lableHandle=LocalBuildFrmTxt(labelPos,'Epochs:',  'text','');
    set(lableHandle, 'Max', 1, 'Value', 1);
    labelPos=[left .19  width height];    
    lableHandle=LocalBuildUi(labelPos, 'edit', 'anfisedit #reset', '3', 'epoch');
    set(lableHandle, 'backgroundcolor', 'white', 'Max', 1);
    % Then the editable text field
    
    labelPos=[left .13  width height];    
    
    mcwHndl=LocalBuildUi(labelPos, 'pushbutton', 'anfisedit #start', 'Train Now', 'startbtn');
    %=========The test fis=============
    labelPos=[.82 .42 .14 .042];    
    lableHndl=LocalBuildFrmTxt(labelPos, '   Test FIS', 'text', 'lable2');
    frmBorder=0.02;
    left=.79;
    width=.19;
    height=.04;
    labelPos=[left .34  width height];    
    lableHandle=LocalBuildFrmTxt(labelPos, 'Plot against:', 'text', '');
    labelPos=[left .30  width height];    
    lableHandle=LocalBuildUi(labelPos, 'radio', 'anfisedit #radiotest', 'Training data', 'test');
    set(lableHandle, 'Max', 1, 'Value', 1);
    labelPos=[left .25  width height];    
    lableHandle=LocalBuildUi(labelPos, 'radio', 'anfisedit #radiotest', 'Testing data', 'test');
    labelPos=[left .2  width height];    
    set(lableHandle, 'Max', 1, 'Value', 0);
    lableHandle=LocalBuildUi(labelPos, 'radio', 'anfisedit #radiotest', 'Checking data', 'test');
    set(lableHandle, 'Max', 1, 'Value', 0);
    labelPos=[left .205  width height];    
    % Then the editable text field
    labelPos=[left .13  width height];    
    
    mcwHndl=LocalBuildUi(labelPos, 'pushbutton', 'anfisedit #test', 'Test Now', 'testbtn');
    
    %=======The Close button=============
    closeHndl=LocalBuildBtns('pushbutton', 0, 'Close', 'fisgui #close', 'close');
    helpHndl=LocalBuildBtns('pushbutton', 0, 'Close', 'anfisedit #help', 'help');
    pos=get(helpHndl, 'Position');
    pos(1)=pos(1)-.17;
    set(helpHndl, 'Position', pos, 'String', 'Help');
    %====================================
    % The MENUBAR items
    % First create the menus standard to every GUI
    
    LocalEnableBtns(fis(1));   
    textHndl=findobj(figNumber, 'Tag', 'Comments');
    %textstr=get(textHndl, 'String');
    if isfield(fis, 'input') & isfield(fis, 'output')
        textstr={['# of inputs: ' num2str(length(fis(1).input))],  ['# of outputs: ' ...
                    num2str(length(fis(1).output))], [ '# of input mfs: '], [ num2str(getfis(fis(1), 'inmfs'))]};
    else
        textstr = '';
    end
    set(textHndl, 'String', textstr);
    
    % Finally make figure visible and protect it
    set(figNumber,'Visible','on','HandleVisibility','callback')
    
case '#update',
    %==========updata anfis information==========================
    WatchFig=watchon;
    figNumber = gcbf;
    oldfis=get(figNumber,'UserData');
    fis=oldfis{1};
    % Clear the current variable plots and redisplay
    textHndl=findobj(figNumber, 'Tag', 'Comments');
    %textstr=get(textHndl, 'String');
    textstr={['# of inputs: ' num2str(length(fis.input))], ['# of outputs: ' ...
                num2str(length(fis.output))],  ['# of input mfs: '], [ num2str(getfis(fis(1), 'inmfs'))]};
    set(textHndl, 'String', textstr);
    LocalEnableBtns(fis(1));
    if length(fis)<=1
        undomenu=findobj(figNumber, 'Tag', 'undo');
        set(undomenu, 'Enable', 'off');
    end
    watchoff(WatchFig);
    %========start/stop training==============
case '#start',
    figNumber = gcbf;
    oldfis=get(figNumber, 'UserData');
    fis=oldfis{1};
    chkvector=[];
    if ~isfield(fis, 'trndata')| isempty(fis.trndata(1))
        msgbox('no training data yet');
    elseif isempty(fis.input(1).mf)
        msgbox('No membership functions! Use mf editor or genfis button to generate membership functions');
    elseif ~isfield(fis, 'rule') | isempty(fis.rule)
        msgbox('No rules yet! Use rule editor or genfis button to generate rules.');
    else
        if isfield(fis, 'chkdata')
            testdata=fis.chkdata;
        else
            testdata=[];
        end
        EpochHndl=findobj(figNumber, 'Tag', 'epoch');
        numEpochs=str2double(get(EpochHndl, 'String'));
        if isempty(numEpochs)
            numEpochs=0;
        end
        txtHndl=findobj(figNumber, 'Tag', 'status');
        stopHndl=findobj(figNumber, 'Tag', 'startbtn');
        stopflag=get(stopHndl, 'String');
        fismat1=fis;
        errHndl=[];
        if strcmp(stopflag, 'Train Now')
            %=========init plot for training==========
            cla;
            set(stopHndl, 'String', 'Stop');
            errHndl=findobj(figNumber, 'Tag', 'errline');
            chkHndl=findobj(figNumber, 'Tag', 'chkline');
            errLimHndl=findobj(figNumber, 'Tag', 'errlim');
            methodHndl=findobj(figNumber, 'Tag', 'trnmethod');
            method=get(methodHndl, 'value');
            errlim=str2double(get(errLimHndl, 'String'));
            xlabelHndl=get(gca, 'XLabel');
            ylabelHndl=get(gca, 'YLabel');
            set(xlabelHndl, 'String', 'Epochs');
            set(ylabelHndl, 'String', 'Error');
            if isempty(errlim)
                errlim=0;
            end
            if isempty(errHndl)|length(get(errHndl, 'Xdata'))~=numEpochs
                if length(get(errHndl, 'Xdata'))~=numEpochs
                    delete(errHndl)
                end
                errHndl=line([1:numEpochs], [1:numEpochs], 'linestyle', 'none',...
                    'marker', '*', 'Tag', 'errline');
            end
            if isfield(fis, 'chkdata') & ~isempty(fis.chkdata) & (isempty(chkHndl)|length(get(chkHndl, 'Xdata'))~=numEpochs)
                if length(get(chkHndl, 'Xdata'))~=numEpochs
                    delete(chkHndl)
                end
                chkHndl=line([1:numEpochs], [1:numEpochs], 'linestyle', 'none',...
                    'marker', '.', 'MarkerSize', 10, 'Tag', 'chkline');
                chkvector=zeros(numEpochs,1);
            end
            errvector=zeros(numEpochs,1);
            %========start training=============
            testHndl=findobj(gcbf, 'Tag', 'testbtn');
            set(testHndl, 'Enable', 'off');
            try
                for i=1:numEpochs
                    [fismat1, trn_err, stepSize, fismat2, chk_err]=anfis(fis.trndata, fismat1, 2, NaN, testdata, method-1);
                    if ~isempty(chkHndl)
                        chkvector(i)=chk_err(1);
                        set(chkHndl, 'Ydata', chkvector);
                    end
                    errvector(i)=trn_err(1);
                    if ~isempty(errHndl)
                        set(errHndl, 'Ydata', errvector);
                        drawnow
                    end
                    txtStr={['Epoch ' num2str(i) ':error= ' num2str(trn_err(1))]};
                    set(txtHndl, 'String', txtStr);
                    stopflag=get(stopHndl, 'String');
                    if strcmp(stopflag, 'Train Now')| trn_err(1)<=errlim
                        break;
                    end
                end   %end of if Satrt
            catch
                error(lasterr)
            end
            title('Training Error');
            set(testHndl, 'Enable', 'on');
            set(stopHndl, 'String', 'Train Now');
        else
            %=========reset start button=========
            set(stopHndl, 'String', 'Train Now');
        end
        % end of for loop
        if ~isempty(chkvector)
            trnedfis=fismat2;
        else
            trnedfis=fismat1;
        end
        trnedfis.trndata=fis.trndata;
        if isfield(fis, 'tstdata');
            trnedfis.tstdata=fis.tstdata;
        end 
        if isfield(fis, 'chkdata');
            trnedfis.chkdata=fis.chkdata;
        end 
        %      set(gcf, 'UserData', trnedfis);
        WatchFig=watchon;
        %===========updata fis for all the fis editors=======
        updtfis(figNumber,trnedfis,[2 3 4 5 6]);
        pushundo(gcbf, trnedfis);
        watchoff(WatchFig);
    end
    %========take training input data from commandline workspace
case '#trndatin',
    figNumber = gcbf;
    fis=get(figNumber, 'UserData');
    fis=fis(1);
    trndatinHndl=findobj(figNumber, 'Tag', 'trndatin');
    trndatinTxt=get(trndatinHndl, 'String');
    trnData=[];
    trnData=evalin('base', trndatinTxt, '[]');
    if isempty(trnData),
        msgbox('No such variable (or variable is empty)')
    else
        fis.trndata(:,1:length(fis.input))=trnData
    end   
    %========take training output data from commandline workspace
    
    
    
case '#genfis',
    figNumber=gcbf;
    genHndl=findobj(figNumber, 'Tag', 'genfis');
    n=get(genHndl, 'Value');
    indexStr='';
    for i=1:length(n)
        if n{i}~=0
            indexStr=get(genHndl(i), 'String');
            break;
        end
    end
    oldfis=get(figNumber,'UserData');
    fis=oldfis{1};
    if ~isfield(fis, 'trndata');
        trnData=[];
    else
        trnData=fis.trndata;
    end
    fismat=[];
    param=[];
    switch indexStr
    case 'Grid partition'
        %========use grid genfis===========
        if isempty(trnData)
            msgbox('Load training data in order to generate ANFIS');
            return
        end
        mfType=getfis(fis, 'inmftypes');   
        dlgFig=findobj('type', 'figure', 'Tag', 'genfis1dlg');
        
        if isempty(dlgFig)
            param=gfmfdlg('#init', fis);
        else
            figure(dlgFig);
        end
        if ~isempty(param)
            mfType=char(param(2));
            outType=char(param(3));
            
            inmflist=str2num(param{1});  % don't use STR2DOUBLE here (can be multi-valued)
            if ~isempty(inmflist)&length(inmflist)~=length(fis.input)
                inmflist(end+1:length(fis.input))=inmflist(end);
            end
            if isempty(inmflist)
                inmflist=[2];
            end
            if isempty(mfType)
                % for i=1:length(fis.input)
                %     mfType(i,:)='gbellmf';
                % end
                mfType='gbellmf';
            end
            
            fismat=genfis1(trnData, inmflist, mfType, outType);
            %in case user changed the following from mfedit or fiseditor
            fismat.type=fis.type;
            fismat.name=fis.name;
            fismat.andMethod = fis.andMethod;
            fismat.orMethod = fis.orMethod;
            fismat.defuzzMethod =fis.defuzzMethod;
            fismat.impMethod = fis.impMethod;
            fismat.aggMethod = fis.aggMethod;
        end
        
    case 'Sub. clustering'
        %========use cluster genfis=====================
        if isempty(trnData)
            msgbox('Load training data in order to generate ANFIS');
            return
        end
        param=inputdlg({'Range of influence:', 'Squash factor:','Accept ratio:','Reject ratio:'},...
            'Parameters for clustering genfis', 1,...
            {'.5', '1.25', '.5', '.15'});
        
        if ~isempty(param)
            watchon;
            fismat=genfis2(trnData(:,1:length(fis.input)), trnData(:,length(fis.input)+1), ...
                str2double(param{1}),[], [str2double(param(2:4));0]');
            fismat.name=fis.name;
            watchoff   
        end
    case 'Load from disk'
        [fname, fpath]=uigetfile('*.fis'); 
        if fname ~=0
            fismat=readfis([fpath fname]);
            %make sure loading a sugeno type fis structure
            if ~strcmp(fismat.type, 'sugeno')
                msgbox('Not a sugeno type, no fis structure is loaded');
                fismat=[];
            end
        end 
    case 'Load from worksp.'
        vname=[];
        vname=inputdlg('input variable name');
        
        if ~isempty(vname)
            fismat=evalin('base', char(vname), '[]');
        end
        if isempty(fismat),
            msgbox('No such variable (or variable is empty)')
        else
            if ~strcmp(fismat.type, 'sugeno')
                msgbox('Not a sugeno type, no fis structure is loaded');
                fismat=[];
            end
        end   
    end
    if ~isempty(fismat)
        if isfield(fis, 'tstdata')
            fismat.tstdata=fis.tstdata;
        end 
        if isfield(fis, 'chkdata')
            fismat.chkdata=fis.chkdata;
        end 
        set(figNumber, 'Name',['Anfis Editor: ' fismat.name]); 
        fismat.trndata=trnData;
        textHndl=findobj(gcbf, 'Tag', 'Comments');
        textstr={['# of input: ' num2str(length(fismat.input))], ['# of outputs: ' ...
                    num2str(length(fismat.output))],  ['# of input mfs: '], [num2str(getfis(fismat, 'inmfs'))]};
        set(textHndl, 'String', textstr);
        cmtHndl=findobj(gcbf, 'Tag', 'status');
        set(cmtHndl, 'String', 'a new fis generated');
        %      set(figNumber, 'Userdata', fismat);
        %========updata all the fis editors===============
        %       set(textHndl, 'String', 'New fis generated');
        pushundo(figNumber, fismat);
        updtfis(figNumber,fismat,[2 3 4 5]);
        LocalEnableBtns(fismat);  
    end   
    
    
    %========open training set file================                
case '#opentrn',
    
    % open an existing file
    oldfis=get(gcbf,'UserData'); 
    fis=oldfis{1};
    typeHndl=findobj(gcbf, 'Tag', 'dattype');
    fromHndl=findobj(gcbf, 'Tag', 'trndatin');
    for i=1:length(typeHndl)
        if get(typeHndl(i), 'Value')==1 
            thistype=get(typeHndl(i), 'String');
            switch thistype
            case 'Testing',
                type ='test';
            case 'Training',
                type='train';
            case 'Checking',
                type='check';
            otherwise,
                type='demo';
            end
            break
        end
    end
    inNum=length(fis.input);
    outNum=length(fis.output);
    varname=[];
    if get(fromHndl(2), 'value') ==0 & ~strcmp(type, 'demo')
        %from workspace
        vname=[];
        trndata=[];
        vname=inputdlg('input variable name');
        dtloaded=0;
        if ~isempty(vname)
            trndata=evalin('base', char(vname), '[]');
            if isempty(trndata),
                msgbox('No such variable (or variable is empty)')
            else
                dtloaded=1;
            end   
        end     
     elseif ~strcmp(type, 'demo')
        %from file
        [fname, fpath]=uigetfile('*.dat'); 
        dtloaded=0;
        trndata=[];
        if isstr(fname)&isstr(fpath)
           trndata=load([fpath fname]);
           dtloaded=1;
        end 
     else
        %demo data
        load('fuzex1trn.dat');
        load('fuzex1chk.dat');
        trndata=fuzex1trn;
        tstdata=fuzex1chk;
        chkdata=[];
        fis=genfis1(trndata, 4, 'gaussmf');
        fis.trndata=trndata;
        fis.tstdata=tstdata;
        fis.chkdata=chkdata;
        dtloaded=1;
        inNum = size(trndata,2)-1;
    end  
    if ~isempty(trndata) & ~strcmp(type, 'demo'),
        if size(trndata, 2)<=1
            msgbox('Data needs to be at least two columes! No data is loaded.')
            clear trndata;
            statueHndl=findobj(gcbf, 'Tag', 'status');
            set(statueHndl, 'String', [type ' data is not loaded']);
            return;
        end
        inNumNew=size(trndata,2)-1;
        if inNumNew~=inNum 
            if  ~strcmp(fis.input(1).name,'emptyinput1') | strcmp(type,'test')==1 | strcmp(type,'check')==1
                msgbox({['The number of inputs for ' type ' data is ' num2str(inNumNew)],...
                        ['The number of inputs for current fuzzy system is ' num2str(inNum)],...
                        ['No new ' type ' data is loaded']});
                qustout='No';
            else
                qustout='Yes';
            end
            if strcmp(qustout, 'Yes')==1
                if strcmp(fis.input(1).name,'emptyinput1'),
                    fis.input(1).name = 'input1';
                end
                dtloaded=1;
                if inNumNew>inNum
                    for i=inNum+1:inNumNew
                        fis=addvar(fis,'input',['input' num2str(i)],[0 1],'init');
                    end
                else
                    for i=inNum:-1:inNumNew+1
                        fis=rmvar(fis,'input', i, true);
                    end 
                end
                inNum=length(fis.input);
            else
                dtloaded=0;
                clear trndata;
                statueHndl=findobj(gcbf, 'Tag', 'status');
                
                set(statueHndl, 'String', 'Training data is not loaded');
            end
        end
    end
    if dtloaded==1
        lineMarker=['o', '.', '+'];
        colorIndex=1;
        titleStr='Demo Data';
        switch type
        case 'train'
            fis.trndata=trndata;
            titleStr='Training Data (ooo)';
        case 'test'
            fis.tstdata=trndata;
            titleStr='Testing Data (...)';
            colorIndex=2;
        case 'check'
            fis.chkdata=trndata;
            titleStr='Checking Data (+++)';
            colorIndex=3;
        end 
        updtfis(gcbf,fis,[6]);
        textHndl=findobj(gcbf, 'Tag', 'Comments');
        textstr={['# of inputs: ' num2str(length(fis.input))], ['# of outputs: ' ...
                    num2str(length(fis.output))],  ['# of input mfs: '], [ num2str(getfis(fis, 'inmfs'))],...
                ['# of ' type ' data pairs: ' num2str(size(trndata,1))]};
        targetlineHndl=line([1:size(trndata, 1)], trndata(:, inNum+outNum),...
            'lineStyle', 'none', ...
            'Marker', lineMarker(colorIndex), 'Tag', 'targetline'); 
        title(titleStr);
        xlabelHndl=get(gca, 'XLabel');
        
        set(xlabelHndl, 'String', 'data set index');
        ylabelHndl=get(gca, 'YLabel');
        set(ylabelHndl, 'String', 'Output');
        set(textHndl, 'String', textstr);
        cmtHndl=findobj(gcbf, 'Tag', 'status');
        set(cmtHndl, 'String', [type ' data loaded']);
        pushundo(gcbf, fis);
        %      set(gcbf, 'UserData', fis); 
    end
    
    LocalEnableBtns(fis);  
    
    %% end
    %=============test anfis==============
case '#test',
    fis=get(gcbf,'UserData');
    fis=fis{1};
    testHndl=findobj(gcbf, 'Tag', 'test');
    cla
    for i=1:length(testHndl)
        if get(testHndl(i), 'Value')==1 
            thistype=get(testHndl(i), 'String');
            testdata=[];
            markerStr='o';
            switch thistype
            case 'Testing data',
                if isfield(fis, 'tstdata')
                    testdata=fis.tstdata;
                    markerStr='.';
                else
                    msgbox([thistype ' does not exist']);         
                    return
                end
            case 'Training data',
                if isfield(fis, 'trndata')
                    testdata=fis.trndata;
                    markerStr='o';
                else
                    msgbox([thistype ' does not exist']);
                    return
                end
            case 'Checking data',
                if isfield(fis, 'chkdata')
                    testdata=fis.chkdata;
                    markerStr='+';
                else
                    msgbox([thistype ' does not exist']);
                    return
                end
            otherwise,
                msgbox([thistype ' does not exist']);
                return
            end
            break
        end
    end
    if ~isempty(testdata)
        xlabelHndl=get(gca, 'XLabel');
        ylabelHndl=get(gca, 'YLabel');
        set(xlabelHndl, 'String', 'Index');
        set(ylabelHndl, 'String', 'Output');
        datasize=size(testdata, 1);
        inputnum=size(testdata, 2)-1;
        targetdata=testdata(1:datasize, inputnum+1);
        testOut=evalfis(testdata(1:datasize, 1:inputnum), fis);
        %      errordata=sum(abs(targetdata-testOut))/length(targetdata);
        errordata=sqrt(sum((targetdata-testOut)'*(targetdata-testOut))/length(targetdata));
        targetlineHndl=line([1:datasize],targetdata,...
            'lineStyle', 'none', 'Marker', markerStr); 
        title( [thistype ' : ' markerStr '   FIS output : *']);
        testlineHndl=line([1:datasize],testOut, 'lineStyle', 'none', 'Marker', '*', 'Color', 'red'); 
        statueHndl=findobj(gcbf, 'Tag', 'status');
        set(statueHndl, 'String', ['Average testing error: ' num2str(errordata)]);
    else
        msgbox([thistype ' does not exist']);
    end
case '#cleardata'
    oldfis=get(gcbf,'UserData'); 
    fis=oldfis{1};
    typeHndl=findobj(gcbf, 'Tag', 'dattype');
    for i=1:length(typeHndl)
        if get(typeHndl(i), 'Value')==1 
            thistype=get(typeHndl(i), 'String');
            out=questdlg({['do you really want to clear ' thistype ' Data?']}, '', 'Yes', 'No', 'No'); 
            if strcmp(out, 'Yes')
                switch thistype
                case 'Testing',
                    fis.tstdata=[];
                case 'Training',
                    fis.trndata=[];
                case 'Checking',
                    fis.chkdata=[];
                end
                cla
                pushundo(gcbf, fis);
            end
            break
        end
    end
    
case '#radioloadfrom'
    curHndl=gcbo;
    radioHndl=findobj(gcbf, 'Tag', 'trndatin');
    if radioHndl(1)==curHndl
        set(radioHndl(2), 'Value', 0);
        set(radioHndl(1), 'Value', get(radioHndl(1), 'max'));
    else
        set(radioHndl(1), 'Value', 0);
        set(radioHndl(2), 'Value', get(radioHndl(2), 'max'));
    end
case '#radioloadtype'
    curHndl=gco;
    radioHndl=findobj(gcbf, 'Tag', 'dattype');
    set(radioHndl, 'Value', 0);
    set(curHndl, 'Value', 1);
case '#radiogenfis'
    curHndl=gco;
    set(curHndl, 'Value', get(curHndl, 'max'));
    thisstr=get(curHndl, 'String');
    genHndl=findobj(gcbf, 'Tag', 'genfisbtn');
    radioHndl=findobj(gcbf, 'Tag', 'genfis');
    for i=1:length(radioHndl)
        if radioHndl(i)~=curHndl
            set(radioHndl(i), 'Value', 0);
        end
    end
    switch thisstr
    case 'Grid partition'
        set(genHndl, 'String', 'Generate FIS ...');
    case 'Sub. clustering'
        set(genHndl, 'String', 'Generate FIS ...');
    otherwise
        set(genHndl, 'String', 'Load ...');
    end
case '#radiotest'
    curHndl=gco;
    set(curHndl, 'Value', get(curHndl, 'max'));
    radioHndl=findobj(gcbf, 'Tag', 'test');
    for i=1:length(radioHndl)
        if radioHndl(i)~=curHndl
            set(radioHndl(i), 'Value', 0);
        end
    end
case '#help'
    figNumber=watchon;
    helpwin(mfilename)
    watchoff(figNumber)
end;    % if strcmp(action, ...
% End of function anfisedit

%==================================================
function LocalEnableBtns(fis)
% control the enable property for buttons, based on whether training data/mf/rule
% has already set
figNumber = gcbf;
startHndl = findobj(figNumber, 'Tag', 'startbtn');

if ~isfield(fis, 'trndata')| isempty(fis.trndata)| isempty(fis.input(1).mf) 
    %| isempty(fis.input(1).mf)|...
    %      ~isfield(fis, 'rule') | isempty(fis.rule)
    set(startHndl, 'Enable', 'off');
else
    set(startHndl, 'Enable', 'on');
end

%genHndl = findobj(gcf, 'Tag', 'genfis');

%if ~isfield(fis, 'trndata')| isempty(fis.trndata(1))
%   set(genHndl, 'Enable', 'off');
%else
%   set(genHndl, 'Enable', 'on'); 
%end
plotHndl = findobj(figNumber, 'Tag', 'plotstrc');
testHndl = findobj(figNumber, 'Tag', 'testbtn');
if isfield(fis,'input') & (isempty(fis.input(1).mf) | ~isfield(fis, 'rule') | isempty(fis.rule))
    set(plotHndl, 'Enable', 'off');
    set(testHndl, 'Enable', 'off');
    
else
    set(plotHndl, 'Enable', 'on');
    set(testHndl, 'Enable', 'on');
    
end


%==================================================
function uiHandle=LocalBuildUi(uiPos, uiStyle, uiCallback, promptStr, uiTag)
% build uicontrol 
uiHandle=uicontrol( ...
    'Style',uiStyle, ...
    'HorizontalAlignment','left', ...
    'BackgroundColor',[.75 .75 .75], ...  
    'Units','normalized', ...
    'Max',20, ...
    'Position',uiPos, ...
    'Callback',uiCallback, ... 
    'Tag', uiTag, ...
    'String',promptStr);

%==================================================
function frmHandle=LocalBuildFrmTxt(frmPos, txtStr, uiStyle, txtTag)
% Build frame and label with an edge
%frmColor=192/255*[1 1 1];
frmColor=[.75 .75 .75];
frmHandle=uicontrol( ...
    'Style', uiStyle, ...
    'Units','normalized', ...
    'Position',frmPos, ...
    'HorizontalAlignment', 'left',...
    'BackgroundColor',frmColor, ...
    'String', txtStr, ...
    'Tag', txtTag);
%   'ForegroundColor',[1 1 1], ...                  %generates an edge

%==================================================
function btHandle=LocalBuildBtns(thisstyle, btnNumber, labelStr, callbackStr, uiTag)
% build buttons or check boxes so they easily aline on the right

labelColor=[0.75 0.75 0.75];
top=0.953;
left=0.825;
btnWid=0.15;
btnHt=0.05;
bottom=0.032;
% Spacing between the button and the next command's label
spacing=0.03;

yPos=top-(btnNumber-1)*(btnHt+spacing);
if strcmp(labelStr, 'Close')==1
    yPos= bottom;
elseif strcmp(labelStr, 'Info')==1
    yPos= bottom+btnHt+spacing; 
else
    yPos=top-(btnNumber-1)*(btnHt+spacing)-btnHt;
end
% Generic button information
btnPos=[left yPos btnWid btnHt];
btHandle=uicontrol( ...
    'Style',thisstyle, ...
    'Units','normalized', ...
    'Position',btnPos, ...
    'String',labelStr, ...
    'Tag', uiTag, ...
    'Callback',callbackStr); 


%==================================================
function LocalStructureBtnCallback(eventSrc, eventdata)
% Plots initial anfis structure, can only be called when Structure button is enabled,
% therefore no need to check for existing figure. eventSrc is Structure btn hndl

% Get the default figure position at the root level
default_pos = get(0,'DefaultFigurePosition');

% The main figure is the parent of the Structure button which issued this callback
MainFigHndl = get(eventSrc,'Parent');

SubFigHndl=figure('Name', 'Anfis Model Structure',...
    'Position', default_pos + [40 -40 0 0], ...
    'Unit', 'normal',...
    'NumberTitle','off',...
    'HandleVisibility','callback',...
    'Color', [.75 .75 .75],...
    'MenuBar','none', ...
    'DefaultTextFontSize',8+2*isunix, ...
    'DeleteFcn',{@LocalCloseSubFigCallback eventSrc}, ...
    'DockControls', 'off');

% Create the axis where the structure will be drawn
AxesHndl = axes('Parent',SubFigHndl,'Visible','off', ...
    'Position', [0.01 0.132 0.975 0.82], ...
    'XLimMode', 'Manual', ...
    'Xlim', [-0.30 1.22], 'Ylim', [0 1.0]);       

% Create status bar and Help/Close frames
uicontrol('Parent',SubFigHndl,'Style', 'frame',...
    'Unit', 'normal',...
    'BackgroundColor',[0.75 0.75 0.75], ...
    'Position', [.01 .0218 .45 .073]);
uicontrol('Parent',SubFigHndl,'Style', 'frame',...
    'Unit', 'normal',...
    'BackgroundColor',[0.75 0.75 0.75], ...
    'Position', [.47 .0218 .52 .073]);
uicontrol('Parent',SubFigHndl,'Style', 'text',...
    'Unit', 'normal',...
    'Position', [.02 .025 .4 .05],...
    'BackgroundColor',[0.75 0.75 0.75], ...
    'FontSize',get(SubFigHndl,'DefaultTextFontSize'), ...
    'HorizontalAlignment','Left', ...
    'String', 'Click on each node to see detailed information');

% Create Help and Close buttons     
helpHndl=LocalBuildBtns('pushbutton', 0, 'Close', 'anfisedit #help', 'help');
pos=get(helpHndl, 'Position');
pos(1)=pos(1)-.17;
set(helpHndl, 'Position', pos, 'String', 'Help');
uicontrol('Parent',SubFigHndl,'Style', 'pushbutton',...
    'Unit', 'normal',...
    'Position', [0.825 0.032 0.15 0.05],...
    'Callback',  'close(gcbf)', 'String', 'Close');

% Create the update button
UpDateBtnHndl = uicontrol('Parent',SubFigHndl,'Style', 'pushbutton',...
    'Unit', 'normal',...
    'Position', [0.825-2*0.17 0.032 0.15 0.05],...
    'String', 'Update', ...
    'CallBack',{@LocalUpDateStructure MainFigHndl AxesHndl});

% Create a listener to close the Structure GUI when the main figure is closed
listener = handle.listener(MainFigHndl, 'ObjectBeingDestroyed', ...
    {@LocalCloseMainFigCallback SubFigHndl});
% Store the listener
set(SubFigHndl, 'UserData', listener);

% Disable the main figure Structure button
set(eventSrc,'Enable','off');

% Call the Local function to draw the structure on the axis
LocalUpDateStructure(UpDateBtnHndl, [], MainFigHndl, AxesHndl);


%==================================================
function LocalUpDateStructure(eventSrc, eventData, MainFigHndl, AxesHndl)
% Redraw the anfis structure on the figure when the update button is pressed

% If the Structure has already been drawn delete it and redraw
kids = get(AxesHndl,'Children');
delete(kids(ishandle(kids)));

SubFigHndl = get(eventSrc,'Parent');

% The FIS is stored in the UserData of the main figure
fis=get(MainFigHndl, 'UserData');
fis=fis{1};

% Create a text box to show node information during mouse button down on object
TextHndl=uicontrol('Parent',SubFigHndl,'Style', 'text', 'Unit', 'norm',...
    'Visible', 'off',...
    'Fontsize',8 + 2*isunix, ...
    'BackGroundColor',[1 1 .6]);

% Give a text label to each node
text([-0.25 -0.029 0.43 0.63 1.06], [1.01 1.01 1.01 1.01 1.01], ...
    {'input', 'inputmf', 'rule', 'outputmf', 'output'}, ...
    'Parent',AxesHndl,'Fontsize',get(SubFigHndl,'DefaultTextFontSize'));

%======== calculate input nodes and input mfs
% The input node centres are first calculated then plotted later to ensure correct layering
instep=1/(length(fis.input)+1);
outstep=1/(length(fis.output)+1);
theta=0:pi/5:2*pi;
r= 0.02;
rsin=r*sin(theta);
rcos=r*cos(theta);

numin = length(fis.input);
total_nummf = 0;
for id = 1:numin
    nummf(id) = length(fis.input(id).mf);
    total_nummf = total_nummf + nummf(id);
end
mfstep = 1/(total_nummf + numin);

for id = 1:numin
    total_mf_block = 0;
    for jid = numin:-1:id + 1
        mf_block(jid) = (nummf(jid) + 1)*mfstep;
        total_mf_block = total_mf_block + mf_block(jid);
    end 
    % Calculate the input node centres
    input_node_ctr(id)   = total_mf_block + (nummf(id) + 1)*mfstep/2;
    for kid = 1:nummf(id)
        % Calculate the input mf node centres
        inputmf_node_ctr(id,kid) = total_mf_block + mfstep*(nummf(id)+1-kid);
    end 
end

%=========rules and output mfs
rulestep=length(fis.rule)+1;

% Plot the connections from output mf nodes to the weighted sum output nodes
for i=1:length(fis.output)
    for j=1:length(fis.rule)
        line([0.7 0.9], [(rulestep-j)/rulestep outstep*i], [-1 -1], 'color', 'black','Parent',AxesHndl);
    end
end   

% Plot the connections from the input mf nodes to the rule nodes
for id = 1:length(fis.rule)
    conn = fis.rule(id).connection;
    numa = length(fis.rule(id).antecedent);
    y_pos_rule = (rulestep-id)/rulestep;
    for jid = 1:numa
        ruleindex=fis.rule(id).antecedent(jid);
        if ruleindex~=0
            if ruleindex < 0 
                thiscolor = 'green';
                InfoTxt = 'Not True';
            else
                thiscolor = 'black';
                InfoTxt = 'True';
            end
            mfstep=instep/(nummf(jid)+1);
            % Plot the connections between the inputmf nodes and the rule nodes
            LineHndl = line([0.0 0.45], ...
                [inputmf_node_ctr(jid,abs(ruleindex)) y_pos_rule], [-1 -1], ...
                'Color', char(thiscolor),'Parent',AxesHndl, ...
                'ButtonDownFcn', {@LocalMouseBtnDown TextHndl InfoTxt});
        end
    end  
    
    % Plot the connections from the rule nodes to the output mf nodes
    line([0.45 0.7], [y_pos_rule y_pos_rule], [-1 -1], 'color', 'black','Parent',AxesHndl);
    
    % Draw the rule nodes
    xcircle=r*sin(theta)+0.45;
    ycircle=r*cos(theta)+y_pos_rule;  
    zcircle = ones(length(ycircle));
    % rulecolor = AND    OR  
    rulecolor={'blue', 'red'};
    thiscolor = rulecolor{conn};
    InfoTxt = ['Rule ' sprintf('%i',id)];
    patch(xcircle, ycircle, 'w',...
        'ButtonDownFcn', {@LocalMouseBtnDown TextHndl InfoTxt},...
        'FaceColor',thiscolor, ...
        'Parent',AxesHndl);
    
    % Draw the outputmf nodes
    xcircle=xcircle+0.25;
    InfoTxt = ['Output MF ' sprintf('%i',fis.rule(id).consequent(1))];
    patch(xcircle, ycircle, 'w',...
        'ButtonDownFcn', {@LocalMouseBtnDown TextHndl InfoTxt},...
        'Parent',AxesHndl); 
end

% Plot the input mf nodes
for id = 1:numin
    for kid = 1:nummf(id)
        xcircle = rsin - 0.0;
        ycircle = rcos + inputmf_node_ctr(id,kid);
        zcircle = 10*ones(length(ycircle));
        % Plot the connections between the inputmf nodes and the rule nodes
        line([-0.2 0.0], [input_node_ctr(id) inputmf_node_ctr(id,kid)], [-1 -1], 'Parent',AxesHndl,'color', 'black');
        InfoTxt = ['Input ' sprintf('%i',id) ',' ' MF ' fis.input(id).mf(kid).name];
        patch(xcircle, ycircle, zcircle, 'w',...
            'ButtonDownFcn', {@LocalMouseBtnDown TextHndl InfoTxt},...
            'Parent',AxesHndl);
    end
    
    % Plot the input nodes
    xcircle = rsin - 0.2;
    ycircle = rcos + input_node_ctr(id);
    InfoTxt = ['Input ' sprintf('%i',id)];
    patch(xcircle, ycircle, 'black', ...
        'ButtonDownFcn', {@LocalMouseBtnDown TextHndl InfoTxt}, ...
        'Parent',AxesHndl);
end

%=====output nodes
line([0.9 1.1], [outstep outstep], 'color', 'black','Parent',AxesHndl);

for id=1:length(fis.output)
    xcircle=rsin+0.9;
    ycircle=rcos+outstep*id;     
    InfoTxt = ['Aggregated Output ' sprintf('%i',id)];
    patch(xcircle, ycircle, zcircle, 'w',...
        'ButtonDownFcn', {@LocalMouseBtnDown TextHndl InfoTxt},...
        'Parent',AxesHndl);
end

%=======normalize and dividing node
xcircle=rsin+1.1;
ycircle=rcos+outstep;   
InfoTxt = ['Output'];
patch(xcircle, ycircle, 'black',...
    'ButtonDownFcn', {@LocalMouseBtnDown TextHndl InfoTxt},...
    'Parent',AxesHndl);

%============== create a custom legend ===============
line([0.90 1.22 1.22 0.90 0.90],[0.0 0.0 0.2 0.2 0.0], 'Parent',AxesHndl,'Color','black');
text([0.94 1.12 1.12 1.12], [0.16 0.115 0.07 0.025], ...
    {'Logical Operations', 'and', 'or', 'not'}, ...
    'Fontsize',get(SubFigHndl,'DefaultTextFontSize'),'Parent',AxesHndl);
% Create the blue AND circle, the red OR circle and the green NOT line
xcircle=r*sin(theta)+1.;      ycircle=r*cos(theta)+0.12;     patch(xcircle, ycircle,'blue','Parent',AxesHndl);
xcircle=r*sin(theta)+1.;      ycircle=r*cos(theta)+0.07;     patch(xcircle, ycircle,'red','Parent',AxesHndl);
line([0.95 1.05],[0.03 0.03],'LineWidth',1,'Color','green','Parent',AxesHndl);


%==================================================
function LocalCloseMainFigCallback(eventSrc, eventData, SubFigHndl)
% A listener callback when the main figure window is closed
delete(SubFigHndl);


%==================================================
function LocalCloseSubFigCallback(eventSrc, eventData, StrctBtnHndl)
% Operates when the Structure diagram sub-figure is closed
set(StrctBtnHndl,'Enable','on');


%==================================================
function LocalMouseBtnDown(eventSrc, eventData, TextHndl, InfoTxt)
% Operates when user button downs on objects in the Anfis Model Structure window.
% eventSrc is the hndl of the object where the btn down event occurred
AxesHndl = get(eventSrc,'Parent');
FigHndl = get(AxesHndl,'Parent');
CP = get(FigHndl,'CurrentPoint');

switch  get(eventSrc,'Type');
    
case 'line'
    set(eventSrc,'LineWidth',4);
case 'patch' 
    set(TextHndl, ...
        'String', InfoTxt, ...
        'Visible', 'on');
    ex = get(TextHndl,'Extent');
    set(TextHndl,'Position',[CP(1,1) CP(1,2) ex(3) ex(4)]);
end

% Reset the sub-figure window btn up function, and pass the text hndl and the selected object hndl
set(FigHndl,'WindowButtonUpFcn',{@LocalWindowBtnUpFcn TextHndl eventSrc});

%==================================================
function LocalWindowBtnUpFcn(eventSrc, eventData, varargin)
% Operates when the Window Button Up occurs, varargin = [ TextHndl objHndl ]

switch  get(varargin{2},'Type');
    
case 'line'
    set(varargin{2},'LineWidth',0.5);
case 'patch'
    set(varargin{1},'Visible','off');
end

% Reset the sub-figure window btn up function to do nothing
set(eventSrc,'WindowButtonUpFcn', ' ');