function ruleedit(action);
%
%  Purpose
%  Rule editor and parser.
%  Synopsis
%  ruleedit('a')
%  ruleedit(a)
%  Description
%  
%  The Rule Editor, when invoked using ruleedit('a'), is used to modify the
%  rules of a FIS structure stored in a file, a.fis. It can also be used to
%  inspect the rules being used by a fuzzy inference system. 
%  To use this editor to create rules, you must first have all of the input
%  and output variables you want to use defined with the FIS editor. You can
%  create the rules using the listbox and check
%  box choices for input and
%  output variables, connections, and weights. 
%  The syntax ruleedit(a) is used when you want to operate on a workspace
%  variable for a FIS structure called a. 
%
%  Menu Items
%  On the Rule Editor, there is a menu bar that allows you to open related GUI 
%  tools, open and save systems, and so on. The File menu for the Rule Editor 
%  is the same as the one found on the FIS Editor. Refer to the Reference 
%  entry fuzzy for more information.
%  Use the Edit menu items:
%  Undo: to undo the most recent change.
%  Use the View menu items:
%  Edit FIS properties... to invoke the FIS Editor.
%  Edit membership functions... to invoke the Membership Function Editor.
%  View rules... to invoke the Rule Viewer.
%  View surface... to invoke the Surface Viewer.
%  Use the Options menu items:
%  Language to select the language: English, Deutsch, and Francais
%  Format: to select the format: 
%  verbose uses the words *if* and *then* and so on to create actual 
%  sentences.
%  symbolic substitutes some symbols for the words used in the verbose mode. 
%  For example, *if A and B then C* becomes *A & B => C.*
%  indexed mirrors how the rule is stored in the FIS matrix.
%
%  See also ADDRULE, MFEDIT, RULEVIEW, SHOWRULE, SURFVIEW

%   Ned Gulley, 3-30-94 Kelly Liu, 4-10-97, N. Hickey 03-17-01
%   Copyright 1994-2004 The MathWorks, Inc.
%   $Revision: 1.52.2.3 $  $Date: 2004/04/10 23:15:35 $

if nargin<1,
    newFis=newfis('Untitled');
    newFis=addvar(newFis,'input','input1',[0 1],'init');
    newFis=addvar(newFis,'output','output1',[0 1],'init');
    action=newFis;
end

if isstr(action),
    if action(1)~='#',
        % The string "action" is not a switch for this function, 
        % so it must be a disk file
        fis=readfis(action);
        action='#initialize';
    end
else
    % For initialization, the fis matrix is passed in as the parameter
    fis=action;
    action='#initialize';
end;

switch action,
case '#initialize',
    fisName=fis.name;
    fisType=fis.type;

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
    %===================================
    % Information for all objects
    frmColor=192/255*[1 1 1];
    btnColor=192/255*[1 1 1];
    popupColor=192/255*[1 1 1];
    editColor=255/255*[1 1 1];
    axColor=128/255*[1 1 1];
    border=.01;
    spacing=.01;
    figPos=get(0,'DefaultFigurePosition');
    maxRight=1;
    maxTop=1;
    btnWid=.14;
    btnHt=0.05;
 
    %====================================
    % The FIGURE
    thisfis{1}=fis;
    figNumber=figure( ...
        'Name',['Rule Editor: ' fisName], ...
        'NumberTitle','off', ...
        'IntegerHandle','off',...
        'Color',frmColor, ...
        'CloseRequestFcn','fisgui #close',...
        'MenuBar','none', ...
        'Visible','off', ...
        'UserData',thisfis, ...
        'Position',figPos, ...
        'Tag','ruleedit', ...
        'BackingStore','off', ...
        'DockControls', 'off');
    figPos=get(figNumber,'position');

    %====================================
    % The MENUBAR items
    % Call fisgui to create the menubar items
    fisgui #initialize

    %========================================================
    % The MAIN frame 
    bottom=border;
    top=maxTop-border; 
    right=maxRight-border;
    left=border;
    frmBorder=spacing;
    frmPos=[left-frmBorder bottom-frmBorder ...
        right-left+frmBorder*2 top-bottom+frmBorder*2];
    mainFrmHndl=uicontrol( ...
        'Units','normal', ...
        'Style','frame', ...
        'Position',frmPos, ...
        'BackgroundColor',frmColor);
    %====================================

    bottom=border+4*spacing+btnHt;
    % The RULES frame 
    top=maxTop-border-spacing;
    right=maxRight-border-spacing;
    left=border+spacing;
    frmBorder=spacing;
    frmPos=[left-frmBorder bottom-frmBorder ...
        right-left+frmBorder*2 top-bottom+frmBorder*2];
    ruleFrmHndl=uicontrol( ...
        'Style','frame', ...
        'Units','normal', ...
        'Position',frmPos, ...
        'BackgroundColor',frmColor);
    %------------------------------------
    % The RULES edit window
    rulePos=[left top-(top-bottom)*2/5-border (right-left) (top-bottom)*2/5];
    if numRules>0,
        labelStr=' ';
    else
        labelStr=' ';
        msgStr=['No rules for system "' fisName '"'];
        statmsg(figNumber,msgStr);
    end
    name='rulewindow';
    pos=[left bottom btnWid*2 btnHt];
    ruleHndl=uicontrol( ...
        'Style','listbox', ...
        'Units','normal', ...
        'Position',rulePos, ...
        'BackgroundColor',editColor, ...
        'HorizontalAlignment','left', ...
        'Callback', 'ruleedit #getrule',...
        'Max',1, ...
        'Tag',name);
    %========radio button for and, or=========
    frmPos=[left bottom ...
        btnWid+spacing btnHt*2.6];
    clsFrmHndl=uicontrol( ...
        'Style','frame', ...
        'Units','normal', ...
        'Position',frmPos, ...
        'BackgroundColor',frmColor);
    labelPos=[left+1*spacing bottom+btnHt*2 ...
        btnWid*.9 btnHt];
    clsFrmHndl=uicontrol( ...
        'Style','text', ...
        'Units','normal', ...
        'Position',labelPos, ...
        'String', 'Connection',...
        'BackgroundColor',frmColor);
    pos=[left+2*spacing bottom+1*spacing btnWid*.6 btnHt];
    helpHndl=uicontrol( ...
        'Style','radio', ...
        'Units','normal', ...
        'Position',pos, ...
        'BackgroundColor',btnColor, ...
        'String','and', ...
        'Tag', 'radio',...
        'Max', 1,...
        'Value', 1,...
        'Callback','ruleedit #radio');
    pos=[left+2*spacing bottom+btnHt+1*spacing btnWid*.6 btnHt];
    helpHndl=uicontrol( ...
        'Style','radio', ...
        'Units','normal', ...
        'Position',pos, ...
        'BackgroundColor',btnColor, ...
        'String','or', ...
        'Tag', 'radio',...
        'Max', 1,...
        'Callback','ruleedit #radio');
    %=====weight text=================
    pos=[left+(btnWid)+btnHt/2+spacing bottom+btnHt*2 btnWid*.7 btnHt];
    helpHndl=uicontrol( ...
        'Style','text', ...
        'Units','normal', ...
        'Position',pos, ...
        'BackgroundColor',frmColor, ...
        'String','Weight:');
    pos=[left+btnWid+btnHt bottom btnWid/2 btnHt];
    helpHndl=uicontrol( ...
        'Style','edit', ...
        'Units','normal', ...
        'Position',pos, ...
        'BackgroundColor','white', ...
        'String',num2str(1),...
        'Callback', 'wStr=max(min(1, str2double(get(gcbo, ''String''))), 0); set(gcbo, ''string'', num2str(wStr))', ... 
        'Tag', 'weight');
    %=========delete======================
    boxDstn=btnWid+spacing;
    boxWidth=(right-left)/6;
    pos=[left+boxDstn*2 bottom btnWid btnHt];
    helpHndl=uicontrol( ...
        'Style','pushbutton', ...
        'Units','normal', ...
        'Position',pos, ...
        'String','Delete rule',...
        'Callback', 'ruleedit #delete',...
        'Tag', 'delete');
 
    %========button for add=========
    pos=[left+boxDstn*3 bottom btnWid btnHt];
    helpHndl=uicontrol( ...
        'Style','push', ...
        'Units','normal', ...
        'Position',pos, ...
        'BackgroundColor',btnColor, ...
        'String','Add rule', ...
        'Callback','ruleedit #add');
    %========button for apply=========
    pos=[left+boxDstn*4 bottom btnWid btnHt];
    helpHndl=uicontrol( ...
        'Style','push', ...
        'Units','normal', ...
        'Position',pos, ...
        'BackgroundColor',btnColor, ...
        'String','Change rule', ...
        'Callback','ruleedit #add');
    %=======buttons for shift=============
    pos=[right-2*spacing-btnWid*2/3 bottom btnWid/3 btnHt];
    helpHndl=uicontrol( ...
        'Style','push', ...
        'Units','normal', ...
        'Position',pos, ...
        'BackgroundColor',btnColor, ...
        'Tag', 'shiftright',...
        'String','<<', ...
        'Callback','ruleedit #shiftright');
    pos=[right-spacing-btnWid/3 bottom btnWid/3 btnHt];
    helpHndl=uicontrol( ...
        'Style','push', ...
        'Units','normal', ...
        'Position',pos, ...
        'BackgroundColor',btnColor, ...
        'Tag', 'shiftleft',...
        'String','>>', ...
        'Callback','ruleedit #shiftleft');

    %====================================
    % The CLOSE frame 
    bottom=border+4*spacing+btnHt;
    top=bottom+btnHt;
    right=maxRight-border-spacing;
    % Left should be snug up against Rule Format frame
    left=border+spacing;

    frmBorder=spacing;

    %====================================
    % The STATUS frame 
    bottom=border+spacing;
    top=bottom+btnHt;
    right=maxRight-border-spacing;
    left=border+spacing;
    frmBorder=spacing;
    frmPos=[left-frmBorder bottom-frmBorder ...
        (right-left)*2/3+frmBorder*2 top-bottom+frmBorder*2];
    mainFrmHndl=uicontrol( ...
        'Style','frame', ...
        'Units','normal', ...
        'Position',frmPos, ...
        'BackgroundColor',frmColor);

    frmPos=[left-frmBorder+(right-left)*2/3+frmBorder*3 bottom-frmBorder ...
        (right-left)*1/3-frmBorder top-bottom+frmBorder*2];
    mainFrmHndl=uicontrol( ...
        'Style','frame', ...
        'Units','normal', ...
        'Position',frmPos, ...
        'BackgroundColor',frmColor);

    %------------------------------------
    % The STATUS text window
    labelStr=['FIS Name: ' fisName];
    name='status';
    pos=[left bottom (right-left)/2 btnHt];
    txtHndl=uicontrol( ...
        'Style','text', ...
        'BackgroundColor',frmColor, ...
        'HorizontalAlignment','left', ...
        'Units','normal', ...
        'Position',pos, ...
        'Tag',name, ...
        'String',labelStr);
    %------------------------------------
    % The HELP button
%    bottom=bottom+spacing;
    labelStr='Help';
    callbackStr='ruleedit #help';
    helpHndl=uicontrol( ...
        'Style','push', ...
        'Units','normal', ...
        'Position',[right-2*btnWid-spacing bottom btnWid btnHt], ...
        'BackgroundColor',btnColor, ...
        'String',labelStr, ...
        'Callback',callbackStr);

    %------------------------------------
    % The CLOSE button
    labelStr='Close';
    callbackStr='fisgui #close';
    closeHndl=uicontrol( ...
        'Style','push', ...
        'Units','normal', ...
        'Position',[right-btnWid bottom btnWid btnHt], ...
        'BackgroundColor',btnColor, ...
        'String',labelStr, ...
        'Callback',callbackStr);
    ruleedit #update

    % Normalize all coordinates
    hndlList=findobj(figNumber,'Units','pixels');
    set(hndlList,'Units','normalized');

    % Uncover the figure
    thisfis{1}=fis;
    set(figNumber, ...
        'Visible','on', ...
        'UserData',thisfis, ...
        'HandleVisibility','callback');

%%init 
   index=1;
   localgetrule(figNumber, index, fis)
case '#update',
    %====================================
    
    figNumber=watchon;
    
    oldfis=get(figNumber,'UserData');
    fis=oldfis{1};
    numRules=length(fis.rule);
    fisName=fis.name;

    % The RULES FORMAT menu
    popupHndl=findobj(figNumber,'Type','uimenu','Tag','rulefrmt', 'Checked','on');
    formatStr=lower(get(popupHndl,'Label'));
    formatStr=deblank(formatStr);
    formatStr=fliplr(deblank(fliplr(formatStr)));
    % The RULES edit window
    name='rulewindow';
    hndl=findobj(figNumber,'Type','uicontrol','Tag',name);
    if numRules>0,
        langHndl=findobj(figNumber,'Type','uimenu', 'Tag', 'lang', 'Checked','on');
        lang=lower(get(langHndl,'Label'));
        labelStr=showrule(fis,1:numRules,formatStr,lang);
    else
        labelStr=' ';
        msgStr=['No rules for system "' fisName '"'];
        statmsg(figNumber,msgStr);
    end
    set(hndl, 'Value', 1, 'String',labelStr);

    i=1;
    j=1;
    nameinHndl=[];
    nameoutHndl=[];
    tempinHndl=findobj(figNumber, 'Tag', ['ruleinmake' num2str(i)]);
    tempoutHndl=findobj(figNumber, 'Tag', ['ruleoutmake' num2str(i)]);
    if ~isempty(tempinHndl)
       nameinHndl(i)=tempinHndl;
    end
    if ~isempty(tempoutHndl)
       nameoutHndl(j)=tempoutHndl;
    end
    while ~isempty(tempinHndl)
     i=i+1;
     tempinHndl=findobj(figNumber, 'Tag', ['ruleinmake' num2str(i)]);
     if ~isempty(tempinHndl)
       nameinHndl(i)=tempinHndl;
     end
    end
    while ~isempty(tempoutHndl)
     j=j+1;
     tempoutHndl=findobj(figNumber, 'Tag', ['ruleoutmake' num2str(j)]);
     if ~isempty(tempoutHndl)
       nameoutHndl(j)=tempoutHndl;
     end
    end
    if (~isempty(nameinHndl))|(~isempty(nameoutHndl) )
      for k=1:length(nameinHndl)  
       tempradioHndl=findobj(figNumber, 'Tag', ['ruleinradio' num2str(k)]);
       templabelHndl=findobj(figNumber, 'Tag', ['ruleinlabel' num2str(k)]);
       tempkeywHndl=findobj(figNumber, 'Tag', ['ruleinkeyw' num2str(k)]);
       delete(tempradioHndl);
       delete(templabelHndl);
       delete(tempkeywHndl);
      end
      for k=1:length(nameoutHndl)  
       tempradioHndl=findobj(figNumber, 'Tag', ['ruleoutradio' num2str(k)]);
       templabelHndl=findobj(figNumber, 'Tag', ['ruleoutlabel' num2str(k)]);
       tempkeywHndl=findobj(figNumber, 'Tag', ['ruleoutkeyw' num2str(k)]);
       delete(tempradioHndl);
       delete(templabelHndl);
       delete(tempkeywHndl);
      end
       delete(nameoutHndl);
       delete(nameinHndl)
    end
    localAddrulemake(fis);
    shiftlHndl=findobj(figNumber, 'Tag', 'shiftleft'); 
    shiftrHndl=findobj(figNumber, 'Tag', 'shiftright'); 
    if isfield(fis, 'input') & isfield(fis, 'output')
      if length(fis.input)+length(fis.output)<6
        set(shiftlHndl, 'Enable', 'off');
        set(shiftrHndl, 'Enable', 'off');
      else
        set(shiftlHndl, 'Enable', 'on');
        set(shiftrHndl, 'Enable', 'on');
      end
    end
    watchoff(figNumber)

case '#disprules',
    %====================================
    figNumber=watchon;
    menuHndl=findobj(figNumber,'Type','uimenu','Tag','rulefrmt', 'Checked','on');
    dispStyle=lower(get(menuHndl,'Label'));
    dispStyle=deblank(dispStyle);
    dispStyle=fliplr(deblank(fliplr(dispStyle)));
    oldfis=get(figNumber,'UserData');
    fis=oldfis{1};
    numRules=length(fis.rule);
    if numRules==0,
        msgStr=['There are no rules for this system.'];
        statmsg(figNumber,msgStr);
    else
        msgStr=['Translating to ' dispStyle ' format'];
        statmsg(figNumber,msgStr);
        editHndl=findobj(figNumber,'Tag', 'rulewindow');
        langHndl=findobj(figNumber,'Type','uimenu','Tag', 'lang', 'Checked','on');
        lang=lower(get(langHndl,'Label'));
        editStr=showrule(fis,1:numRules,dispStyle,lang);
       % editStr=char([32*ones(size(editStr,1),1) editStr]);
        set(editHndl,'String',editStr);
    end
    watchoff(figNumber);
case '#langselect';
    %====================================
    figNumber=watchon;
    langSelectHndl=gcbo;
    langMenuHndl=get(langSelectHndl,'Parent');
    langUnselectHndl=findobj(langMenuHndl,'Checked','on');
    set(langUnselectHndl,'Checked','off');
    set(langSelectHndl,'Checked','on');
    ruleedit #disprules
    watchoff(figNumber)
case '#formatselect';
    %====================================
    figNumber=watchon;
    langSelectHndl=gcbo;
    langMenuHndl=get(langSelectHndl,'Parent');
    langUnselectHndl=findobj(langMenuHndl,'Checked','on');
    set(langUnselectHndl,'Checked','off');
    set(langSelectHndl,'Checked','on');
    ruleedit #disprules
    watchoff(figNumber)
case '#shiftright';
    oldfis=get(gcbf, 'Userdata');
    fis=oldfis{1};
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
    set(gcbf, 'Unit', 'normal');
    stop=0;
    for i=1:numInputs
     Hndl=findobj(gcbf, 'Tag', ['ruleinmake' num2str(i)]);
     radioHndl=findobj(gcbf, 'Tag', ['ruleinradio', num2str(i)]);
     labelHndl=findobj(gcbf, 'Tag', ['ruleinlabel', num2str(i)]);
     keyHndl=findobj(gcbf, 'Tag', ['ruleinkeyw', num2str(i)]);
     set(Hndl, 'Unit', 'normal');
     set(radioHndl, 'Unit', 'normal');
     set(labelHndl, 'Unit', 'normal');
     set(keyHndl, 'Unit', 'normal');

     pos=get(Hndl, 'Position');
     poslabel=get(labelHndl, 'Position');
     posradio=get(radioHndl, 'Position');
     poskey=get(keyHndl, 'Position');
     if i==1 & pos(1)>=.01
       stop=1;
       break
     end
     pos=pos+[.05, 0, 0, 0];
     posradio=posradio+[.05, 0, 0, 0];
     poslabel=poslabel+[.05, 0, 0, 0];
     poskey=poskey+[.05, 0, 0, 0];
     set(Hndl, 'Position', pos);
     set(radioHndl, 'Position', posradio);
     set(labelHndl, 'Position', poslabel);
     set(keyHndl, 'Position', poskey);
    end
    if stop==0
     for i=1:numOutputs
      Hndl=findobj(gcbf, 'Tag', ['ruleoutmake' num2str(i)]);
      radioHndl=findobj(gcbf, 'Tag', ['ruleoutradio', num2str(i)]);
      labelHndl=findobj(gcbf, 'Tag', ['ruleoutlabel', num2str(i)]);
      keyHndl=findobj(gcbf, 'Tag', ['ruleoutkeyw', num2str(i)]);
      set(Hndl, 'Unit', 'normal');
      set(radioHndl, 'Unit', 'normal');
      set(labelHndl, 'Unit', 'normal');
      set(keyHndl, 'Unit', 'normal');
      pos=get(Hndl, 'Position');
      poslabel=get(labelHndl, 'Position');
      posradio=get(radioHndl, 'Position');
      poskey=get(keyHndl, 'Position');
      pos=pos+[.05, 0, 0, 0];
      posradio=posradio+[.05, 0, 0, 0];
      poslabel=poslabel+[.05, 0, 0, 0];
      poskey=poskey+[.05, 0, 0, 0];
      set(Hndl, 'Position', pos);
      set(radioHndl, 'Position', posradio);
      set(labelHndl, 'Position', poslabel);
      set(keyHndl, 'Position', poskey);
     end
    end
case '#shiftleft';
    oldfis=get(gcbf, 'Userdata');
    fis=oldfis{1};
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
    set(gcbf, 'Unit', 'normal');
    lastone=numOutputs;
    stop=0;
    for i=lastone:-1:1
     Hndl=findobj(gcbf, 'Tag', ['ruleoutmake' num2str(i)]);
     radioHndl=findobj(gcbf, 'Tag', ['ruleoutradio', num2str(i)]);
     labelHndl=findobj(gcbf, 'Tag', ['ruleoutlabel', num2str(i)]);
     keyHndl=findobj(gcbf, 'Tag', ['ruleoutkeyw', num2str(i)]);
     set(Hndl, 'Unit', 'normal');
     set(radioHndl, 'Unit', 'normal');
     set(labelHndl, 'Unit', 'normal');
     set(keyHndl, 'Unit', 'normal');
     pos=get(Hndl, 'Position');
     poslabel=get(labelHndl, 'Position');
     posradio=get(radioHndl, 'Position');
     poskey=get(keyHndl, 'Position');
     if i==lastone & pos(1)<=1-pos(3)-.01
       stop=1;
       break
     end
     pos=pos-[.05, 0, 0, 0];
     posradio=posradio-[.05, 0, 0, 0];
     poslabel=poslabel-[.05, 0, 0, 0];
     poskey=poskey-[.05, 0, 0, 0];
     set(Hndl, 'Position', pos);
     set(radioHndl, 'Position', posradio);
     set(labelHndl, 'Position', poslabel);
     set(keyHndl, 'Position', poskey);
    end
    if stop==0
     lastone=numInputs;
     for i=1:lastone
      Hndl=findobj(gcbf, 'Tag', ['ruleinmake' num2str(i)]);
      radioHndl=findobj(gcbf, 'Tag', ['ruleinradio', num2str(i)]);
      labelHndl=findobj(gcbf, 'Tag', ['ruleinlabel', num2str(i)]);
      keyHndl=findobj(gcbf, 'Tag', ['ruleinkeyw', num2str(i)]);
     set(Hndl, 'Unit', 'normal');
     set(radioHndl, 'Unit', 'normal');
     set(labelHndl, 'Unit', 'normal');
     set(keyHndl, 'Unit', 'normal');
      pos=get(Hndl, 'Position');
      poslabel=get(labelHndl, 'Position');
      posradio=get(radioHndl, 'Position');
      poskey=get(keyHndl, 'Position');
      pos=pos-[.05, 0, 0, 0];
      set(Hndl, 'Position', pos);
      posradio=posradio-[.05, 0, 0, 0];
      poslabel=poslabel-[.05, 0, 0, 0];
      poskey=poskey-[.05, 0, 0, 0];
      set(radioHndl, 'Position', posradio);
      set(labelHndl, 'Position', poslabel);
      set(keyHndl, 'Position', poskey);
     end
    end
case '#add';
    thisact=get(gcbo, 'String');
    oldfis=get(gcbf, 'Userdata');
    fis=oldfis{1};

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

    errflag=1;                  %assume errflag=true
    sentence='if ';
    radioHndl=findobj(gcbf, 'Tag', 'radio');
    conn=2;
    for i=1:length(radioHndl)
       if get(radioHndl(i),'Value')~=0
         connStr=get(radioHndl(i),'String');
         if strcmp(connStr, 'and')
            conn=1;
         end
         break;
       end
    end
    for i=1:numInputs
      nameHndl=findobj(gcbf, 'Tag', ['ruleinmake' num2str(i)]);
      notHndl=findobj(gcbf, 'Tag', ['ruleinradio' num2str(i)]);
      if get(notHndl, 'Value')==0
        notvalue=1;
      else
        notvalue=-1;
      end
      value=get(nameHndl, 'Value');
      if value>length(fis.input(i).mf) %| ~isempty(fis.input(i).mf)
       str(i)=0;
      else
       str(i)=value*notvalue;
       errflag=0;       
      end
    end
   if errflag==0,
    errflag=1;
    for i=1:numOutputs
      nameHndl=findobj(gcbf, 'Tag', ['ruleoutmake' num2str(i)]);
      notHndl=findobj(gcbf, 'Tag', ['ruleoutradio' num2str(i)]);
      if get(notHndl, 'Value')==0
         notvalue= 1;
      else
         notvalue=-1;
      end
      value=get(nameHndl, 'Value');
      if value>length(fis.output(i).mf) %| ~isempty(fis.output(i).mf)
        str(numInputs+i) = 0;
      else
        str(numInputs+i)=value*notvalue;
       errflag=0;
      end
       
    end
   end
   if errflag==0;
    weightHndl=findobj(gcbf, 'tag', 'weight');
    weight=get(weightHndl, 'String'); 
   
    ruleHndl=findobj(gcbf, 'tag', 'rulewindow');
    if isempty(str2double(weight))
       wght=1;
    else
       wght=max(min(str2double(weight), 1), 0);
    end
    if strcmp(thisact, 'Add rule')
      index=length(fis.rule)+1;
      statusStr='added';
    else
     index=get(ruleHndl, 'Value');
      statusStr='changed';
    end 
    fis.rule(index).antecedent=str(1:numInputs);
    fis.rule(index).consequent=str(numInputs+1:end);
    fis.rule(index).weight=wght;
    fis.rule(index).connection=conn;
    if length(fis.rule)~=0
       delHndl=findobj(gcbf, 'Tag', 'delete');
       set(delHndl, 'Enable', 'on');
    end
    updtfis(gcbf,fis,[4 5]);
    pushundo(gcbf,fis);
    formatHndl=findobj(gcbf,'Type','uimenu','Tag','rulefrmt', 'Checked','on');
    formatStr=lower(get(formatHndl,'Label'));
    formatStr=deblank(formatStr);
    formatStr=fliplr(deblank(fliplr(formatStr)));
    langHndl=findobj(gcbf,'Type','uimenu', 'Tag', 'lang', 'Checked','on');
    lang=lower(get(langHndl,'Label'));
    lang=deblank(lang);
    lang=fliplr(deblank(fliplr(lang)));
    thisrule=showrule(fis,1:length(fis.rule), formatStr, lang); 
    set(ruleHndl,'String', thisrule, 'value', index);
    statusHndl=findobj(gcbf, 'Tag', 'status');
    set(statusHndl, 'String', ['The rule is ' statusStr]);
   else
    statusHndl=findobj(gcbf, 'Tag', 'status');
    set(statusHndl, 'String', 'The rule is incomplete');
   end
case '#delete';
    oldfis=get(gcbf, 'Userdata');
    fis=oldfis{1};
    if ~isfield(fis, 'rule') | length(fis.rule)==0
       delHndl=findobj(gcbf, 'Tag', 'delete');
       set(delHndl, 'Enable', 'off');
       return;
    end
    ruleHndl=findobj(gcbf, 'tag', 'rulewindow');
    thisrule=get(ruleHndl, 'String');
    index=get(ruleHndl, 'Value');
    thisrule(index, :)=[];
    fis.rule(index)=[];
    if length(fis.rule)==0
       delHndl=findobj(gcbf, 'Tag', 'delete');
       set(delHndl, 'Enable', 'off');
    end
    thisfis{1}=fis;
    if index>size(thisrule,1)
     set(ruleHndl, 'Value', max(1, index-1));
    end
    statusHndl=findobj(gcbf, 'Tag', 'status');
    set(statusHndl, 'String', 'The rule is deleted');
    pushundo(gcbf,fis);

    updtfis(gcbf,fis,[4 5]);
    formatHndl=findobj(gcbf,'Type','uimenu','Tag','rulefrmt', 'Checked','on');
    formatStr=lower(get(formatHndl,'Label'));
    formatStr=deblank(formatStr);
    formatStr=fliplr(deblank(fliplr(formatStr)));
    langHndl=findobj(gcbf,'Type','uimenu', 'Tag', 'lang', 'Checked','on');
    lang=lower(get(langHndl,'Label'));
    lang=deblank(lang);
    lang=fliplr(deblank(fliplr(lang)));
    thisrule=showrule(fis,1:length(fis.rule), formatStr, lang); 
    set(ruleHndl,'String', thisrule, 'value', max(1, index-1));

case '#radio';
    thisradio=gcbo;
    set(thisradio, 'Value', 1);
    radioHndl=findobj(gcbf, 'Tag', 'radio');
    for i=1:length(radioHndl)
     if thisradio~=radioHndl(i)
       set(radioHndl(i), 'Value', 0);
     end
    end
    oldfis=get(gcbf, 'Userdata');
    fis=oldfis{1};
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
    keyword=get(thisradio, 'String');
    for i=2:numInputs
     keyHndl(i)=findobj(gcbf, 'Tag', ['ruleinkeyw' num2str(i)]);
     set(keyHndl(i), 'String', keyword);
    end
    for i=2:numOutputs
     keyHndl(i)=findobj(gcbf, 'Tag', ['ruleoutkeyw' num2str(i)]);
     set(keyHndl(i), 'String', keyword);
    end
case '#getrule';
   index=get(gcbo, 'Value');
   oldfis=get(gcbf, 'Userdata');
   fis=oldfis{1};
   figNumber=gcbf;
   localgetrule(figNumber, index, fis)

case '#help';
    %====================================
    figNumber=watchon;
     helpwin(mfilename);
    watchoff(figNumber)
                                                          
end;    % if strcmp(action, ...

function localAddrulemake(fis)
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

    % Information for all objects
    frmColor=192/255*[1 1 1];
    btnColor=192/255*[1 1 1];
    popupColor=192/255*[1 1 1];
    editColor=255/255*[1 1 1];
    axColor=128/255*[1 1 1];

    border=.01;
    spacing=.01;
    figPos=get(0,'DefaultFigurePosition');
    maxRight=1;
    maxTop=1;
    btnWid=.14;
    btnHt=0.05;


    bottom=border+4*spacing+btnHt;
    top=bottom+btnHt;
    bottom=top+3*spacing;
    top=maxTop-border-spacing;
    right=maxRight-border-spacing;
    left=border+spacing;
    frmBorder=spacing;

    %------------------------------------
    % The RULES edit window1
    boxHeight=(top-bottom)*1/4;
    boxDstn=(right-left)/5;
    boxWidth=(right-left)/6;
    boxShiftY=(bottom+top)/8;
    for i=0:numInputs-1
       rulePos=[left+i*boxDstn bottom+boxShiftY boxWidth boxHeight];
       if numRules>0,
        labelStr=' ';
       else
        labelStr=' ';
        msgStr=['No rules for system "' fis.name '"'];
        statmsg(gcf,msgStr);
       end
       name=['ruleinmake' num2str(i+1)];
       if isfield(fis.input(i+1), 'mf') & ~isempty(fis.input(i+1).mf)
         str=getfis(fis, 'input', i+1, 'mflabels');
         str=strvcat(str, 'none');
       else
         str=[];
       end
       ruleHndl=uicontrol( ...
        'Style','listbox', ...
        'Units','normal', ...
        'Position',rulePos, ...
        'BackgroundColor',editColor, ...
        'HorizontalAlignment','left', ...
        'Max',1, ...
        'String', str,...
        'Tag',name);
       textPos=rulePos+[0, boxHeight+spacing, 0, btnHt*2/3-boxHeight];
       name=['ruleinlabel' num2str(i+1)];

       textHndl=uicontrol( ...
           'Style','text', ...
           'Units','normal', ...
           'Position',textPos, ...
           'BackgroundColor',frmColor, ...
           'String', [fis.input(i+1).name ' is'],...
           'HorizontalAlignment','center', ...
           'Tag',name);

       textPos=rulePos+[0, boxHeight+spacing+btnHt*2/3, 0, btnHt*2/3-boxHeight];
       name=['ruleinkeyw' num2str(i+1)];
       if i==0
         strname='If';
       else
        strHndl=findobj(gcf, 'Tag', 'radio');
      
        if get(strHndl(1), 'Value')==1
          strname=get(strHndl(1), 'String');
        else
          strname=get(strHndl(2), 'String');
        end
       end
       textHndl=uicontrol( ...
           'Style','text', ...
           'Units','normal', ...
           'Position',textPos, ...
           'BackgroundColor',frmColor, ...
           'String', strname,...
           'HorizontalAlignment','left', ...
           'Tag',name);

       pos=rulePos+[0, -btnHt, 0, btnHt-boxHeight];
       helpHndl=uicontrol( ...
        'Style','checkbox', ...
        'Units','normal', ...
        'Position',pos, ...
        'BackgroundColor',btnColor, ...
        'String','not', ...
        'Tag', ['ruleinradio' num2str(i+1)],...
        'Max', 1,...
        'Value', 0);
 
      end
    endedge=left+(numInputs+numOutputs)*boxDstn+boxWidth;
    if endedge>maxRight-left
      %out of border
       left1=left+numInputs*boxDstn;
       for i=0:numOutputs-1
          rulePos=[left1+i*boxDstn bottom+boxShiftY boxWidth boxHeight];
          name=['ruleoutmake' num2str(i+1)];
          if isfield(fis.output(i+1), 'mf') & ~isempty(fis.output(i+1).mf)
            str=getfis(fis, 'output', i+1, 'mflabels');
            str=strvcat(str, 'none');
          else
            str=[];
          end
           ruleHndl=uicontrol( ...
           'Style','listbox', ...
           'Units','normal', ...
           'Position',rulePos, ...
           'BackgroundColor',editColor, ...
           'HorizontalAlignment','left', ...
           'String', str,...
           'Max',1, ...
           'Tag',name);
          textPos=rulePos+[0, boxHeight+spacing, 0, btnHt*2/3-boxHeight];
          name=['ruleoutlabel' num2str(i+1)];

          textHndl=uicontrol( ...
           'Style','text', ...
           'Units','normal', ...
           'Position',textPos, ...
           'BackgroundColor',frmColor, ...
           'String', [fis.output(i+1).name ' is'],...
           'HorizontalAlignment','center', ...
           'Tag',name);

           textPos=rulePos+[0, boxHeight+spacing+btnHt*2/3, 0, btnHt*2/3-boxHeight];
           name=['ruleoutkeyw' num2str(i+1)];
           if i==0
            strname='Then';
           else
            strHndl=findobj(gcf, 'Tag', 'radio');
      
           if get(strHndl(1), 'Value')==1
             strname=get(strHndl(1), 'String');
           else
             strname=get(strHndl(2), 'String');
           end
         end
         textHndl=uicontrol( ...
           'Style','text', ...
           'Units','normal', ...
           'Position',textPos, ...
           'BackgroundColor',frmColor, ...
           'String', strname,...
           'HorizontalAlignment','left', ...
           'Tag',name);


         pos=rulePos+[0, -btnHt, 0, btnHt-boxHeight];
         helpHndl=uicontrol( ...
          'Style','checkbox', ...
          'Units','normal', ...
          'Position',pos, ...
          'BackgroundColor',btnColor, ...
          'String','not', ...
          'Tag', ['ruleoutradio' num2str(i+1)],...
          'Max', 1,...
          'Value', 0);

       end
    else
       for i=1:numOutputs
          outIndex=numOutputs+1;
          rulePos=[maxRight-i*boxDstn bottom+boxShiftY boxWidth boxHeight];
          name=['ruleoutmake' num2str(outIndex-i)];
          if isfield(fis.output(outIndex-i), 'mf') & ~isempty(fis.output(outIndex-i).mf)
            str=getfis(fis, 'output', outIndex-i, 'mflabels');
            str=strvcat(str, 'none');
          else
            str=[];
          end
          ruleHndl=uicontrol( ...
           'Style','listbox', ...
           'Units','normal', ...
           'Position',rulePos, ...
           'BackgroundColor',editColor, ...
           'HorizontalAlignment','left', ...
           'String', str,...
           'Max',1, ...
           'Tag',name);
          textPos=rulePos+[0, boxHeight+spacing, 0, btnHt*2/3-boxHeight];
          name=['ruleoutlabel' num2str(outIndex-i)];

          textHndl=uicontrol( ...
           'Style','text', ...
           'Units','normal', ...
           'Position',textPos, ...
           'BackgroundColor',frmColor, ...
           'String', [fis.output(outIndex-i).name ' is'],...
           'HorizontalAlignment','center', ...
           'Tag',name);

           textPos=rulePos+[0, boxHeight+spacing+btnHt*2/3, 0, btnHt*2/3-boxHeight];
           name=['ruleoutkeyw' num2str(outIndex-i)];
           if numOutputs==i
            strname='Then';
           else
            strHndl=findobj(gcf, 'Tag', 'radio');
      
            if get(strHndl(1), 'Value')==1
             strname=get(strHndl(1), 'String');
            else
             strname=get(strHndl(2), 'String');
            end
           end
           textHndl=uicontrol( ...
           'Style','text', ...
           'Units','normal', ...
           'Position',textPos, ...
           'BackgroundColor',frmColor, ...
           'String', strname,...
           'HorizontalAlignment','left', ...
           'Tag',name);


         pos=rulePos+[0, -btnHt, 0, btnHt-boxHeight];
         helpHndl=uicontrol( ...
          'Style','checkbox', ...
          'Units','normal', ...
          'Position',pos, ...
          'BackgroundColor',btnColor, ...
          'String','not', ...
          'Tag', ['ruleoutradio' num2str(outIndex-i)],...
          'Max', 1,...
          'Value', 0);

       end
    end        

function localgetrule(figNumber, index, fis)

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
    rulelist=fis.rule;
   else
    rulelist=[];
   end
   if isempty(rulelist)
       return;
   end
   radioHndl=findobj(figNumber, 'Tag', 'radio');
   weightHndl=findobj(figNumber, 'Tag', 'weight');
%   for i=2:numInputs
%    connectw(i-1)=findobj(figNumber, 'Tag', ['ruleinkeyw' num2str(i)]);
%   end
   connect=fis.rule(index).connection;
   weight=fis.rule(index).weight;
%   for i=1:0   %length(connectw)
%         if connect==1
%          set(connectw(i), 'String', 'and')
%         else
%          set(connectw(i), 'String', 'or')
%         end
%   end
   if connect==1
     set(radioHndl(1), 'value', 0);
     set(radioHndl(2), 'value', 1);
   else
     set(radioHndl(1), 'value', 1);
     set(radioHndl(2), 'value', 0);
   end
   set(weightHndl, 'String', num2str(weight));
   for i=1:numInputs
    Hndl=findobj(figNumber, 'Tag', ['ruleinmake' num2str(i)]);
    rulevarindex=rulelist(index).antecedent(i);
    if rulevarindex==0
     set(Hndl, 'Value', length(fis.input(i).mf)+1);
    else
     notHndl=findobj(figNumber, 'Tag', ['ruleinradio' num2str(i)]);
     if rulevarindex<0
       set(notHndl, 'Value', 1);
       rulevarindex=-rulevarindex;
     else
       set(notHndl, 'Value', 0);
     end
     set(Hndl, 'Value', rulevarindex);
    end
   end
   for i=1:numOutputs
    Hndl=findobj(figNumber, 'Tag', ['ruleoutmake' num2str(i)]);
    rulevarindex=rulelist(index).consequent(i);
    if rulevarindex==0
     set(Hndl, 'Value', length(fis.output(i).mf)+1);
    else
     notHndl=findobj(figNumber, 'Tag', ['ruleoutradio' num2str(i)]);
     if rulevarindex<0
       set(notHndl, 'Value', 1);
       rulevarindex=-rulevarindex;
     else
       set(notHndl, 'Value', 0);
     end
     set(Hndl, 'Value', rulevarindex);
    end
   end




