function fullblockname = mpc_getblockpath(model)

% Copyright 2004 The MathWorks, Inc.

%% Get the full block path/name of an MPC block given a model. If there
%% is more than one MPC block this function prompts the user to select
%% which one will be used

fullblockname = '';
mpcblocks = find_system(model,'MaskType','MPC');
if length(mpcblocks)==0
    errordlg('No MPC blocks are present in the Simulink model',...
      'Model Predictive Control Toolbox','modal')
    return
elseif length(mpcblocks)==1
     fullblockname = mpcblocks{1};
else % Ask the user which block
     fullblockname = mpcdlg(mpcblocks);
end


function thisblock = mpcdlg(blocknames)

f = figure('MenuBar','none','NumberTitle','off','Units','Characters',...
            'Position',[103.8 50.69 59.2 9.76],'Resize','off',...
            'NumberTitle','off','Name','Simulink Control Design Options');
blockpopup = uicontrol('style','popup','Units','Characters','Position',[25.2 5 30.2 2.30],...
    'String', blocknames,'Parent',f);
blocklabel = uicontrol('style','text','Units','Characters','Position',[3.8 5.846 21.2 1.154],...
    'String', 'Select MPC block','Parent',f);
okbtn = uicontrol('style','pushbutton','Units','Characters','String','OK','Position',...
    [25.2 2 13.2 1.769], 'Callback', {@localOK f},'Parent',f);
cancelbtn = uicontrol('style','pushbutton','Units','Characters','String','Cancel','Position',...
    [41.2 1.923 13.2 1.769], 'Callback', {@localCancel f},'Parent',f);

uiwait(f)
button = get(f,'Userdata');
if strcmp(button,'OK')
    thisblock = blocknames{get(blockpopup,'Value')};
else
    thisblock = '';
end
close(f)