function fuzdemos
%FUZDEMOS List of all Fuzzy Logic Toolbox demos.
%   The command FUZDEMOS by itself will open a figure window
%   with buttons corresponding to each demo. To see a demo,
%   press a button.
%
%   Demos include the pole and cart demo, the truck backing demo, 
%   fuzzy c-means clustering, and others.

%   Kelly Liu, 10-24-97
%   Copyright 1994-2004 The MathWorks, Inc.
%   $Revision: 1.11.2.2 $  $Date: 2004/04/10 23:15:18 $

% Create GUI
labelList=[
    'ANFIS: Noise cancellation                    '
    'ANFIS: Time-series prediction                '
    'ANFIS: Gas mileliage prediction              '
    'Fuzzy c-means clustering                     '
    'Subtractive clustering                       '
    'Ball juggler                                 '
    'Inverse kinematics                           '
    'Defuzzification                              '
    'Membership function gallery                  '];

nameList=[
    'noisedm         '
    'mgtsdemo        '
    'gasdemo         '
    'fcmdemo         '
    'trips           '
    'juggler         '
    'invkine         '
    'defuzzdm        '
    'mfdemo          '];

% Add SIMULINK demos if SIMULINK is available
if exist('open_system')==5,
    labelList2=[ ...
            'Water Tank (sim)                '
        'Water Tank with Rule View (sim) '
        'Cart and pole (sim)             '
        'Cart and two poles (sim)        '
        'Ball and beam (sim)             '
        'Backing truck (sim)             '];
    labelList=str2mat(labelList,labelList2);
    nameList2=[ ...
            'sltank     '
        'sltankrule '
        'slcp1      '
        'slcpp1     '
        'slbb       '
        'sltbu      '];
    nameList=str2mat(nameList,nameList2);
end


figNum=figure('name', 'Fuzzy Logic Toolbox Demos',...
    'NumberTitle','off', ...
    'Visible','off',...
    'HandleVisibility','off',...
    'DockControls','off');
pos = get(figNum,'position');
pos(3) = .8 * pos(3);
set(figNum,'Position',pos)
hBorder = 0.06;
uicontrol(figNum, 'Style', 'listbox', ...
    'units','norm',...
    'Position',[hBorder .22 1-2*hBorder .7],...
    'String', labelList,  ...
    'Tag', 'listbox');
uicontrol(figNum, 'Style', 'pushbutton', ...
    'units','norm',...
    'Position',[hBorder .12 1-2*hBorder .06],...
    'String', 'Run this demo',...
    'Callback',@LocalRunDemo); 
uicontrol(figNum, 'Style', 'pushbutton', ...
    'units','norm',...
    'Position',[hBorder .04 1-2*hBorder .06],...
    'String', 'Close',...
    'Callback', 'close(gcbf)'); 
set(figNum,'Visible','on','Userdata', nameList)


%----------------

function LocalRunDemo(hSrc,event)

nameList=get(gcbf, 'Userdata');
listHndl=findobj(gcbf, 'Tag', 'listbox');
index=get(listHndl, 'Value');
eval(deblank(nameList(index,:)));

