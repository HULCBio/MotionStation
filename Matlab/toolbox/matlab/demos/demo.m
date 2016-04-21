function demo(action,categoryArg) 
% DEMO Run demonstrations. 
%
%   Type "demo" at the command line to browse available demos.
%
%   With the optional action argument demo
%       ('matlab'|'toolbox'|'simulink'|'blockset'|'stateflow'),
%   DEMO opens the demo screen to the specified subtopic.
%
%   With the optional categoryArg argument, 
%   DEMO opens to the specified toolbox or category, e.g.
%       demo toolbox signal
%       demo matlab language

%   derived from demo rev. 1.17
%   Ned Gulley, 6-21-93, Kelly Liu 6-12-96, jae Roh 9-27-96
%   Copyright 1984-2003 The MathWorks, Inc.
%   $Revision: 5.48.4.7 $  $Date: 2004/04/10 23:24:29 $

if usejava('mwt') == 1
   import com.mathworks.mlservices.MLHelpServices;
   if nargin<1,
      MLHelpServices.showDemos;
   elseif nargin==1
      MLHelpServices.showDemos(action);
   elseif nargin==2
      MLHelpServices.showDemos(action, categoryArg);
   end;
else
    % Java isn't available; use the old demo interface.
    
    if nargin<1,
        action = 'showmatlab';
        fSelectCategory = 0;
        fCmdLine = 1;
    else
        action = lower(action);
    end;
    
    indent = '      ';
    
    
    % add switch for show events
    categoryNames = {'matlab', 'toolboxes', 'simulink', ...
            'blocksets', 'real-time workshop', 'stateflow'};
    if (nargin > 0)
        fCmdLine = 0;
        % strmatch will also match partial strings
        catMatch = strmatch(action, categoryNames);
        % should only match one of these
        % but take only the first anyway
        
        if ~isempty(catMatch)
            action = ['show' categoryNames{catMatch(1)}];
            fCmdLine = 1;  % calling from the command line or another GUI
        end
        fSelectCategory = (nargin==2);
    end
    
    chooseMsg = 'Choose a subtopic to see a list of demos';
    clickMsg = 'Double click to expand this topic';
    
    figHandles = allchild(0);
    figH=findobj(figHandles, 'flat', 'Name', 'MATLAB Demo Window', ...
        'Tag', 'demo');
    
    if strcmp('rundemo',action)
        if figH
            LocalRunDemo(findobj(figH, 'Type', 'uicontrol', 'Tag', 'RunDemo'));
        end;
        % ====================================
        % Handle the SHOW events
    elseif any(strmatch('show',action))
        
        if isempty(figH)
            demo initialize;
            figHandles = allchild(0);
            figH=findobj(figHandles, 'flat', 'Name', 'MATLAB Demo Window', ...
                'Tag', 'demo');
            
            set(figH,'HandleVisibility','off');
        end;
        
        % raise the demo window if we're being invoked from the cmd line
        if(fCmdLine)
            figure(figH);
        end
        
        % because HandleVis is off, don't use gcf, use figH
        % get the global data
        param=get(figH,'UserData');
        
        % find ui controls
        % listboxes
        categoryListH = findobj(figH, ...
            'Type', 'uicontrol', 'Tag', 'CategoryListbox');
        index = get(categoryListH, 'UserData');
        demoListH = findobj(figH, 'Type','uicontrol','Tag','DemoListbox');
        %aboutListH = findobj(figH,'Type','uicontrol','Tag','AboutListbox');
        %aboutTopics = get(aboutListH, 'UserData');
        
        % buttons
        runBtn=findobj(figH, 'Type', 'uicontrol', 'Tag', 'RunDemo');
        closeBtn=findobj(figH, 'Type', 'uicontrol', 'Tag','return');
        
        catValue = get(categoryListH, 'Value');
        
        theTopic = index.topic(catValue);
        theCategory = index.category(catValue);
        
        if fCmdLine
            clickType = 'none';
        else
            clickType = get(figH,'SelectionType');
        end
        
        % support direct calls to each topic area
        
        
        topicList = param.topicList;
        
        switch action
        case 'showsimulink',
            theTopic = LocalGetTopic(topicList, 'Simulink', 1);
            incremListUpdate = 0;
        case 'showstateflow',
            theTopic = LocalGetTopic(topicList, 'Stateflow', 1);
            incremListUpdate = 0;
        case 'showtoolboxes',
            theTopic = LocalGetTopic(topicList, 'Toolboxes', 1);
            incremListUpdate = 0;
        case 'showblocksets',
            theTopic = LocalGetTopic(topicList, 'Blocksets', 1);
            incremListUpdate = 0;
        case 'showreal-time workshop',
            theTopic = LocalGetTopic(topicList, 'Real-Time Workshop', 1);
            incremListUpdate = 0;
        case 'showmatlab',
            theTopic = 1;
            incremListUpdate = 0;         
        otherwise
            incremListUpdate = 1;
        end
        
        if (~incremListUpdate)   % rewrite the list from scratch
            
            index.expanded = zeros(1,length(topicList));
            index.expanded(theTopic) = 1;         
            action = 'showlist';
            
            if (fSelectCategory)  % use the second argument
                theCategory = LocalGetTopic(...
                    LocalCellLower({param.pageList{theTopic}.Name}),...
                    [indent lower(categoryArg)],...
                    0);
                newValue = theCategory+theTopic;
            else
                newValue = theTopic;
                theCategory = 0;
            end
            
            
            theCategoryList = {}; % initialize
            nTopics = length(param.topicList);
            index.topic = [];
            index.category = [];
            
            for iTopic = 1:nTopics,
                if (index.expanded(iTopic))
                    prefix = '-';
                else
                    prefix = '+';
                end
                theCategoryList = cat(2, theCategoryList, ...
                    {[prefix param.topicList{iTopic}]});
                index.topic = cat(2, index.topic, iTopic);
                index.category = cat(2, index.category, 0);
                if (index.expanded(iTopic)),
                    nCategories = length({param.pageList{iTopic}.Name});
                    theCategoryList = cat(2, theCategoryList, ...
                        {param.pageList{iTopic}.Name});
                    index.topic = cat(2, index.topic, iTopic*ones(1,nCategories));
                    index.category = cat(2, index.category, (1:nCategories));
                end % if (index.expanded(iTopic)),
            end % for iTopic = 1:nTopics,
            
            set(categoryListH, 'String', theCategoryList);
            set(categoryListH, 'Value', newValue);
            set(categoryListH, 'ListboxTop', newValue);
            set(categoryListH, 'UserData', index);
        end
        
        switch action
        case 'showlist',
            if (theCategory == 0) % this is a topic heading
                % RECOMPUTE CATEGORY LIST
                % recompute the list to be displayed in the category listbox
                % compute indices (Topic, Category) for each 'value' of the
                % category list
                
                if (strcmp(clickType,'open'))                
                    index.expanded(theTopic) = not(index.expanded(theTopic));
                    theCategoryList = get(categoryListH, 'String');
                    
                    currentLength = length(theCategoryList);
                    insertPt = 1;
                    while index.topic(insertPt) ~= theTopic
                        insertPt = insertPt + 1;
                    end
                    if (index.expanded(theTopic))
                        prefix = '-';
                    else
                        prefix = '+';
                    end
                    theCategoryList(insertPt) = ...
                        {[prefix param.topicList{theTopic}]};
                    oldListboxTop = get(categoryListH,'ListboxTop');
                    if index.expanded(theTopic)
                        nCategories =length({param.pageList{theTopic}.Name});
                        index.topic = LocalSplice(insertPt,...
                            theTopic*ones(1,nCategories), index.topic);
                        index.category = LocalSplice(insertPt,...
                            (1:nCategories), index.category);
                        
                        for iCategory = 1:nCategories
                            theCategoryList = LocalSplice(insertPt,...
                                {param.pageList{theTopic}(iCategory).Name},...
                                theCategoryList);
                            insertPt = insertPt+1;
                        end
                        set(categoryListH, 'String', theCategoryList);
                    else
                        insertPt = insertPt + 1;
                        while (index.topic(insertPt) == theTopic) 
                            index.topic(insertPt) = [];
                            index.category(insertPt) = [];
                            theCategoryList(insertPt) = [];                   
                            
                            if (insertPt > length(index.topic))
                                break;
                            end
                        end
                        set(categoryListH, 'String', theCategoryList);
                    end
                    set(categoryListH, 'UserData', index);
                    set(categoryListH, 'ListboxTop', oldListboxTop)
                end   
                
                set(runBtn, 'String', 'Run', 'Enable', 'off');
                if (index.expanded(theTopic))
                    helpMsg = chooseMsg;
                else
                    helpMsg = clickMsg;
                end
                set(demoListH, 'String', helpMsg, ...
                    'Max', 2, ...
                    'Value', [], ...
                    'Enable', 'inactive');
                %set(aboutListH, 'String', aboutTopics{theTopic});
                %set(aboutListH, 'Value', []);
                
            else % if (category ~= 0) i.e. we have chosen a category
                theCategoryName = param.pageList{theTopic}(theCategory).Name;
                demoLabel=[theCategoryName ' Demos']; 
                
                demoList=char(param.pageList{theTopic}(theCategory).DemoList);
                % set callback
                fcnList=char(param.pageList{theTopic}(theCategory).FcnList);
                
                theDemo = 1;
                demoFcn = fcnList(theDemo,:);
                
                set(demoListH, 'Enable', 'on', 'Max', 1, 'Value', 1);
                set(demoListH, 'String', demoList);
                LocalSetRunBtn(runBtn, demoList(1,:), demoFcn);
                
                % now set new text in the 'about' list
                % Help is a cell array of strings
                hlpStr=param.pageList{theTopic}(theCategory).Help;
                % Name is a string
                namestr=param.pageList{theTopic}(theCategory).Name;
                namestr(1:length(indent)) = [];  %strip pad
                
                % only for the MATLAB categories, add a space
                if (theTopic == 1) % 
                    spacestr = ' ';
                else
                    spacestr = [];
                end
                % kludge: add some blanks to avoid colormap wierdness
                %set(aboutListH, 'String', [{namestr}; {spacestr}; hlpStr; ...
                %      {' '}; {' '}]);
                %set(aboutListH, 'Value', []);
            end % if (theCategory == 0), % this is a topic heading
            
            
        case 'showdemo',  % i.e. a click on the demo list
            
            theDemo = get(demoListH, 'Value');
            demoList=char(param.pageList{theTopic}(theCategory).DemoList);
            
            %set callback
            fcnList=char(param.pageList{theTopic}(theCategory).FcnList);
            demoFcn = fcnList(theDemo,:);
            
            LocalSetRunBtn(runBtn, demoList(theDemo,:), demoFcn);
            
            if (strcmp(clickType,'open'))
                LocalRunDemo(runBtn);
            end
            
        end % switch
        
        
        %=====================================
        % Handle INITIALIZATION
    elseif strcmp(action,'initialize'),
        
        % POSITION AND CREATE FIGURE
        
        oldRootUnits = get(0,'Units');
        set(0, 'Units', 'points');
        pixfactor = 72/get(0,'screenpixelsperinch');
        
        figurePos=get(0,'DefaultFigurePosition');
        figurePos(3:4)=[560 420];
        figurePos = figurePos * pixfactor;
        
        % Make sure the title bar of the window isn't off the screen
        rootScreenSize = get(0,'ScreenSize');
        % (position is [x(from left) y(bottom edge from bottom) width height]
        
        % check left edge and right edge
        if ((figurePos(1) < 1) ...
                || (figurePos(1)+figurePos(3) > rootScreenSize(3)))
            figurePos(1) = 30;
        end
        
        set(0, 'Units', oldRootUnits);
        
        % the figure 'position' does not include the menu bar or the title bar
        % really, the default figure position should adjust for this, but
        % for now, assume that the title and the menu bar take less than
        % sixty pixels  
        if ((figurePos(2)+figurePos(4)+60 > rootScreenSize(4)) ...
                || (figurePos(2) < 1))
            figurePos(2) = rootScreenSize(4) - figurePos(4) - 60;
        end
        
        load('dmbanner.mat','banner','bannerMap','figureColor');
        
        figH=figure( ...
            'Name','MATLAB Demo Window', ...
            'Units', 'points', ...
            'NumberTitle','off', ...
            'Visible','off', ...
            'IntegerHandle','off', ...
            'Resize','on', ...
            'Color', figureColor, ...
            'Colormap',bannerMap, ...
            'Position',figurePos, ...
            'Pointer','watch', ...
            'MenuBar','none', ... 
            'Tag', 'demo');
        
        % banner graphic
        
        % set graphic to true size and align with top of figure window
        [i, j] = size(banner);
        i = i*pixfactor;
        j = j*pixfactor;
        set(gca,'Units','points');
        p=get(gca,'Position');
        p(1:2)= [0 (figurePos(4)-i)];
        p(3:4)=[j i];
        set(gca, 'Position', p);
        bannerH = image(banner, 'Tag', 'banner');
        set(gca,'Units','normal');
        axis off;
        
        % put up a wait message temporarily
        waitPos = figurePos;
        waitPos(1:2) = [0 0];
        waitPos(4) = p(2);
        waitStr =  'Scanning the MATLAB path for demos...';
        a = axes;
        axis off;
        set(a, ...
            'Units', 'points', ...
            'Position', waitPos);
        
        waitH = text(.5, .7, waitStr);
        set(waitH, ...
            'HorizontalAlignment', 'center', ...
            'Color', [0 0 0], ...
            'FontSize', 14, ...
            'Tag', 'waittext');
        
        
        % Initialize  buttons and listboxes
        boxesNButtons = Localbuildpage(figH, chooseMsg);
        
        % when this precedes the Localbuildpage invocation,
        % the rest of the graphic disappears on UNIX (not PC)
        % make the figure visible
        set(figH, 'Visible', 'on','Pointer','watch');
        
        drawnow;
        % watchon here:
        % otherwise, watchon before drawnow puts up an I beam
        % with it around here, it's an arrow.
        
        demo_files = which('demos.xml', '-all');
        
        % INITIALIZE CONTENT STRUCTURES
        
        matList = [];
        simList = [];
        tbList = [];
        bsList = [];  
        
        for tbx_count=1:length(demo_files)
            filename = char(demo_files(tbx_count));
            demoStruct = LocalConvertXmlDemo(filename);
            if strcmp(demoStruct.Type, 'matlab') == 1
                matList = [matList demoStruct];
            elseif strcmp(demoStruct.Type, 'simulink') == 1
                simList = [simList demoStruct];
            elseif strcmp(demoStruct.Type, 'toolbox') == 1
                tbList = [tbList demoStruct];
            elseif strcmp(demoStruct.Type, 'blockset') == 1
                bsList = [bsList demoStruct];
            end
        end
        
        % finddemo will automatically search for all Demos.m files on the path
        [m_tbList, m_bsList] = finddemo;
        
        % NOTE: Assume there are no demos.m files which go under Simulink
        % or RTW, since there didn't used to be and if there are any new
        % ones, they should be in XML files now...
        tbList = [tbList m_tbList];
        bsList = [bsList m_tbList];
        
        if isempty(simList)
            simExist = 0;
        else
            simExist = 1;
        end
        
        param.simExist = simExist;
        
        % the matlab stuff (should!) always be there
        nTopics=1;
        topicList{1}='MATLAB';
        pageList{1} = matList;
        
        if ~isempty(tbList)
            nTopics=nTopics+1;       
            topicList{nTopics}='Toolboxes';
            pageList{nTopics} = tbList;
        end
        
        if simExist && ~isempty(simList)
            nTopics=nTopics+1;       
            topicList{nTopics}='Simulink';
            pageList{nTopics} = simList;
        end
        
        if ~isempty(bsList)
            nTopics=nTopics+1;
            topicList{nTopics}='Blocksets';
            pageList{nTopics}= bsList;
        end
        
        param.pageList  = pageList;
        param.topicList = topicList;
        
        for iTopic = 1:nTopics
            nCategories = length({param.pageList{iTopic}.Name});
            topicList{iTopic} = ['+' topicList{iTopic}];
            for iCategory = 1:nCategories
                param.pageList{iTopic}(iCategory).Name ...
                    = [indent param.pageList{iTopic}(iCategory).Name];
            end
        end
        
        % save this global data into the figure info
        set(figH,'UserData',param);
        
        categoryListH = findobj(figH, ...
            'Type', 'uicontrol', 'Tag', 'CategoryListbox');
        
        % make an index for the entries visible in the category list box    
        index.topic = 1:nTopics;
        index.category = zeros(1,nTopics);
        index.expanded = zeros(1,nTopics);
        
        set(categoryListH, ...
            'UserData', index, ...
            'String', topicList, ...
            'Value', 1);
        
        
        % allow resizing
        set(boxesNButtons, 'Units', 'normalized');
        
        % Initialization is now complete.
        set(waitH, 'Visible', 'off');
        
        set(boxesNButtons, 'Visible', 'on');
        drawnow;
        refresh;
        set(figH,'Pointer','arrow');
        
    end;  % if strmatch(action ...
end;  % if java isn't supported


function demoStruct = LocalConvertXmlDemo(filename)

fid = fopen(filename);
s = fread(fid,'*char')';

label_start = findstr(s, '<name>');
label_end = findstr(s, '</name>');
product_name = s(label_start+6 : label_end-1);
% Un-escape 'Dials &amp; Gauges'
product_name = strrep(product_name,'&amp;','&');

type_start = findstr(s, '<type>');
type_end = findstr(s, '</type>');
type = s(type_start+6 : type_end-1);

demosection_start = findstr(s,'<demosection>');
demosection_end = findstr(s,'</demosection>');

flat_list = 0;
if (isempty(demosection_start))
    flat_list = 1;
    demosection_start = findstr(s, '<demos>');
    demosection_end = findstr(s, '</demos>');
end

demoStruct(1).Name=product_name;
demoStruct(1).Type=type;
demoStruct(1).Help='';
demoStruct(1).DemoList='';
demoStruct(1).FcnList='';
for j=1:length(demosection_start);
    demosection = s(demosection_start(j)+12 : demosection_end(j)-1);
    if flat_list == 0
        label_start = findstr(demosection, '<label>');
        label_end = findstr(demosection, '</label>');
        section_label = demosection(label_start+7 : label_end-1);
        % Un-escape '&amp;' to '&';
        section_label = strrep(section_label,'&amp;','&');

        demoStruct(1).DemoList = [demoStruct(1).DemoList {section_label}];
        demoStruct(1).FcnList = [demoStruct(1).FcnList {''}];
    end
    
    t1 = findstr(demosection, '<demoitem>');
    t2 = findstr(demosection, '</demoitem>');
    for i=1:length(t1);
        res = demosection(t1(i)+12:t2(i)-1);
        label_start = findstr(res, '<label>');
        label_end = findstr(res, '</label>');
        label = res(label_start+7:label_end-1);
        % Un-escape '&amp;' to '&';
        label = strrep(label,'&amp;','&');

        callback_start = findstr(res, '<callback>');
        callback_end = findstr(res, '</callback>');
        callback = res(callback_start+10:callback_end-1);
        if (flat_list == 0)
            label = ['   ' label];
        end
        demoStruct(1).DemoList = [demoStruct(1).DemoList {label}];
        demoStruct(1).FcnList = [demoStruct(1).FcnList {callback}];
    end
end

fclose(fid);

%====================================
function handleArray = Localbuildpage(figH, chooseMsg) 
%  build buttons and listboxes for each page 
%  Kelly Liu 6-12-96
%  jae Roh 9-18-96

%====================================
% alternative geometry for the boxes and the buttons
% jae Roh 9-12-96 


figureColor = get(figH, 'Color');    

%====================================
% pull out the geometry information

labelHt=16.8;

pixfactor = 72/get(0,'screenpixelsperinch');

demoListPos = [210 65 320 257] * pixfactor;
%demoListPos = [210 65 320 118] * pixfactor;
catListPos =[30 65 160 257] * pixfactor;

btnHt = 30;
closeBtnPos = [38 18 206 btnHt] * pixfactor;
runBtnPos = [303 18 206 btnHt] * pixfactor;

% build demo listbox
demoListH = uicontrol( ...
    'Style', 'list', ...
    'HorizontalAlignment','left', ...
    'Units', 'points', ...
    'Visible', 'off',...
    'BackgroundColor', [1 1 1], ...
    'Max', 2, ...
    'Value', [], ...
    'Enable', 'inactive', ...
    'Position', demoListPos, ...
    'Callback', 'demo showdemo', ...
    'String', chooseMsg, ...
    'Tag', 'DemoListbox');

% Set up category listbox
tbxListH = uicontrol( ...
    'Style', 'list', ...
    'HorizontalAlignment','left', ...
    'Units','points', ...
    'Visible','off',...
    'BackgroundColor', [1 1 1], ...
    'Max', 1, ...
    'Value', 1, ...
    'Enable', 'on', ...
    'Position', catListPos, ...
    'Callback', 'demo showlist', ...
    'String', ' ', ...
    'Tag', 'CategoryListbox');

% The close button
backH = uicontrol( ...
    'Style', 'pushbutton', ...
    'Units', 'points', ...
    'Position', closeBtnPos, ...
    'String', 'Close', ...
    'Visible', 'off', ...
    'Tag', 'return', ...
    'Callback', 'close(gcbf)'); 

% The run button    
runH = uicontrol( ...
    'Style', 'pushbutton', ...
    'Units', 'points', ...
    'Position', runBtnPos, ...
    'String', 'Run', ...
    'Visible', 'off', ...
    'Enable', 'off', ...   
    'Tag', 'RunDemo', ...
    'Callback', 'demo rundemo'); 

handleArray = [runH backH tbxListH demoListH];


%=====================================
% insert into string, array or cell array of dim 1xn or nx1
function together = LocalSplice(insertPt, piece, target)

[sizeOne sizeTwo] = size(target);
% splice along the big dimension
if sizeOne > 1
    dim = 1;
    nItems = sizeOne;
    if sizeTwo > 1
        % then this is ambiguous...
    end
else % sizeTwo > 1
    dim = 2;
    nItems = sizeTwo;
end

if (insertPt<1)
    together =  cat(dim, piece, target);
elseif (insertPt>nItems)
    together =  cat(dim, target, piece);
else
    together = cat(dim, target(1:insertPt), ...
        piece,...
        target(insertPt+1:nItems));
end

% =====================================
function theTopic = LocalGetTopic(topicList, targetString, noHitTopic)

hits = strmatch(targetString, topicList);
if (hits)
    theTopic = hits(1);
else
    theTopic = noHitTopic;  % default if we don't find it
end

% =====================================
function LocalSetRunBtn(runBtn, labelStr, demoFcn)

nMax = 20;

if isempty(labelStr)
    labelStr='';
else
    % remove trailing and leading blanks
    [r,c] = find(labelStr ~= ' ' & labelStr ~= 0);
    if isempty(c)
        labelStr = '';
    else
        labelStr = labelStr(:,min(c):max(c));
    end
end


demoData.demoFcn = deblank(demoFcn);
demoData.demoName = labelStr;

% first, clip
if (length(labelStr)>nMax)
    labelStr = labelStr(1:nMax);
    
    % find the last space before the nMax'th character
    spaces = findstr(' ', labelStr);
    
    if (isempty(spaces))
        labelStr = [labelStr '...'];
    else
        % truncate to last complete word before nMax
        lastSpace = spaces(length(spaces));
        labelStr = [labelStr(1:lastSpace) '...'];
    end
end
if isempty(demoData.demoFcn)
    runString='Run';
    btnEnable='off';
else
    runString=['Run ' labelStr];
    btnEnable='on';
end

set(runBtn, ...
    'String', runString , ...
    'Enable',btnEnable, ...
    'UserData', demoData);

% =====================================
function warningStr = LocalSetWarningStr(demoFcn, demoName)
warningStr = ...
    ['Error running "' demoName '" demo (' ...
        demoFcn '):' ];
    
    % =====================================
    % protect against demos clearing the workspace
    function errorStatus = LocalSafeEval(tryStr, warningStr)
    
    % allow single quotes in the name of the demo
    warningStr = LocalDoubleQuote(warningStr);
    catchStr = ...
        ['errordlg([''' warningStr ''' sprintf(''\n'') lasterr],'...
            '''Demo Error'', ''replace''); errorCaught=1;'];
    errorStatus = LocalOneLevelDeeper(tryStr, catchStr);
    
    % =====================================
    function errorCaught = LocalOneLevelDeeper(tryStr, catchStr)
    errorCaught = 0;
    evalin('caller',tryStr, catchStr);
    % errorStatus bound in catchStr if there is an error
    % =====================================
    % run from the run button or from double click
    function LocalRunDemo(runBtn)
    
    if (runBtn)
        figH = gcbf;
        demoData = get(runBtn,'UserData');
        
        
        
        %======================================
        % Check for product dependencies and make sure all products
        % are present.  Only start demo if all is OK.  Else, show
        % an error dialog.
        
        dn=demoData.demoName;
        
        % only check if there are parens in the demo name
        if ~isempty(dn) && sum(dn=='(')
            % pull out whatever is between the parens
            depends=dn(find(dn=='(')+1:find(dn==')')-1);
            % cut out any spaces
            depends(depends==' ')='';
            prodList={};
            depends=[',' depends];
            csMarker=cumsum(depends==',');
            % loop over the number of commas
            for i=1:csMarker(end);
                nextOne=depends(csMarker==i);
                % chop off comma
                nextOne(1)=''; 
                % stuff string into cell array
                prodList{1,i}=nextOne;
            end;
            
            % Call PRODCHK to see if all products are present
            % and return an appropriate error message.
            
            % Prodchk punted to next release.  Restore when prodchk is
            % returned:
            %ProductMissing=prodchk(prodList);
            ProductMissing='';
        else   
            ProductMissing='';
        end;         
        
        % End of product checking code.
        %======================================
        
        % If there's a product missing, pop up the dialogue...
        if ~isempty(ProductMissing)
            ContactUs='Contact The MathWorks for more information.';
            msgbox({ProductMissing;ContactUs},'Product Missing','modal')
            
            % else fire off the demo.   
        else
            set(figH,'Pointer','watch');  % watchon
            oldFigs = allchild(0)';       % work with row vectors
            
            simExist = exist('find_system','builtin');
            if simExist
                oldSims = find_system(0,'SearchDepth',0)';
                oldVisSims = find_system(0,'SearchDepth',0,'Open','on')';
            end
            
            warningStr = LocalSetWarningStr(demoData.demoFcn, ...
                demoData.demoName);
            lasterr('');
            errorCaughtInDemo = LocalSafeEval(demoData.demoFcn, warningStr);
            
            set(figH,'Pointer','arrow');  % watchoff 
            
            % make sure we don't make invisible figures visible
            
            % this form does not preserve the stacking order
            % currentVisFigs = findobj(allchild(0),'flat','Visible','on')
            
            % flush the HG event queue so we get the right stacking order
            drawnow;      
            
            currentFigs = allchild(0)';
            currentVisFigs = currentFigs(find(LocalIsVisible(currentFigs)));
            
            if simExist
                currentSims = find_system(0,'SearchDepth',0)';
                currentVisSims = find_system(0,'SearchDepth',0,'Open','on')';
            end
            
            if errorCaughtInDemo
                % then close all new windows (including invisible figures
                % and systems) except the error dialog
                
                % we have used errordlg with Replace='replace', so there should not
                % ever be more than one errorfig with this name
                errorFig = findobj(currentFigs,'Name', 'Demo Error');
                
                if simExist
                    for s = setdiff(currentSims,oldSims)
                        close_system(s);
                    end
                end
                % some of the figures (scopes) may already be closed 
                currentFigs = allchild(0)';      
                close(setdiff(setdiff(currentFigs,oldFigs),errorFig));
                % bring error dialog to front
                figure(errorFig);
                lasterr('');
            else
                % bring new windows to front;
                % setdiff sorts its result: 
                % so use ismember to preserve ordering of new figs
                
                if simExist
                    % open block diagrams behind scopes and figures
                    newVisSims = ...
                        currentVisSims(find(~ismember(currentVisSims,oldVisSims)));
                    % bring forward from back to front
                    for s = fliplr(newVisSims)
                        open_system(s);
                    end
                end
                newVisFigs = ...
                    currentVisFigs(find(~ismember(currentVisFigs,oldFigs)));
                for f = fliplr(newVisFigs)
                    % f may contain Java frames in addition to figure.
                    % Make sure f is a figure
                    if strcmp(get(f,'Type'),'figure'),
                        figure(f);
                    end
                end
            end         
        end
    end
    
    % =====================================
    function resultV = LocalIsVisible(aFigHandleVector)
    resultV = strcmp('on', get(aFigHandleVector,'Visible'))';
    % returns a row vector
    
    
    % =====================================
    function lowerArray = LocalCellLower(theCellArray)
    
    i = 1;
    for anElement = theCellArray
        lowerArray{i} = lower(anElement{1});
        i = i+1;
    end
    
    %==================================================
    function outStr=LocalDoubleQuote(inStr)
    % add double quote to quoted string
    outStr=inStr(sort([1:length(inStr) find(inStr=='''')]));
    
