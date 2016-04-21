function nnident(cmd,arg1,arg2,arg3)
%NNIDENT Neural Network Identification GUI for Neural Network Controller Toolbox.
%
%  Synopsis
%
%    nnident(cmd,arg1,arg2,arg3)
%
%  Warning!!
%
%    This function may be altered or removed in future
%    releases of the Neural Network Toolbox. We recommend
%    you do not write code which calls this function.
%    This function is generally being called from a Simulink block.

% Orlando De Jesus, Martin Hagan, 1-25-00
% Copyright 1992-2002 The MathWorks, Inc.
% $Revision: 1.7 $ $Date: 2002/04/14 21:11:10 $

% Orlando De Jesus. Strict generation of random signals for training. 
% Final plots after training (Target and NN) have the same axis to easier comparative results.

% CONSTANTS
func_index=['trainbfg';'trainbr ';'traincgb';'traincgf';'traincgp';'traingd ';'traingdm';'traingda';'traingdx';'trainlm ';'trainoss';'trainrp ';'trainscg'];

% DEFAULTS
if nargin == 0, cmd = ''; else cmd = lower(cmd); end

% FIND WINDOW IF IT EXISTS
fig = 0;

% 9/3/99 We alow the program to see hidden handles
fig=findall(0,'type','figure','tag','nnident');
if (size(fig,1)==0), fig=0; end

if (length(get(fig,'children')) == 0), fig = 0; end

% GET WINDOW DATA IF IT EXISTS
if fig
  H = get(fig,'userdata');
  
  if strcmp(cmd,'')
    if get(H.gcbh_ptr,'userdata')~=arg1
      delete(fig);
      fig=0;
    end
  else
    % ODJ 1-13-00 We check if the field SimulationStatus exist before reading that field
    if isfield(get(H.gcbh_ptr,'userdata'))
       if isfield(get_param(get_param(get(H.gcbh_ptr,'userdata'),'parent'),'objectparameters'),'SimulationStatus')
          SimulationStatus=get_param(get_param(get(H.gcbh_ptr,'userdata'),'parent'),'simulationstatus');
       else
          SimulationStatus='none';
       end
    else
       SimulationStatus='none';
    end
       
    if (strcmp(SimulationStatus,'running') | strcmp(SimulationStatus,'paused')) & ~strcmp(cmd,'close')
      set(H.error_messages,'string','You must stop the simulation to change NN configuration parameters.');
      return;
    end
  end

end

%==================================================================
% Activate the window.
%
% ME() or ME('')
%==================================================================

if strcmp(cmd,'') | isempty(cmd)
  if fig
    figure(fig)
    set(fig,'visible','on')
  else
    nncontrolutil('nnident','init',arg1,arg2,arg3)
  end

%==================================================================
% Close the window.
%
% ME() or ME('')
%==================================================================

elseif strcmp(cmd,'close') & (fig)
   arg1=get(H.gcbh_ptr,'userdata');
   arg2=get(H.gcb_ptr,'userdata');
   if exist(cat(2,tempdir,'nnidentdata.mat'))
      delete(cat(2,tempdir,'nnidentdata.mat'));
   end
   parent_function=get(H.parent_function_ptr,'userdata');
   if ~strcmp(parent_function,'narma_l2')
      feval(parent_function,'',arg1,arg2,'nnident');
   end
   delete(fig);
%   nnmodref('',arg1,arg2);
  
%==================================================================
% Initialize the window.
%
% ME('init')
%==================================================================

elseif strcmp(cmd,'init') & (~fig)
    
  % 1-13-00 ODJ We check if the system is locked.
  sys_par=arg2;
  sys_par2=arg2;
  while ~isempty(sys_par2)
      sys_par=sys_par2;
      sys_par2=get_param(sys_par,'parent');
  end
  if strcmp('on',get_param(sys_par,'lock'))
      window_en='off';
  else
      window_en='on';
  end

  H.StdColor = get(0,'DefaultUicontrolBackgroundColor');
  H.StdUnit='points';
  H.PointsToPixels = 72/get(0,'ScreenPixelsPerInch');

  if strcmp(arg3,'narma_l2')
     H.me='Plant Identification - NARMA-L2';
  else
     H.me = 'Plant Identification';
  end
  fig = figure('Units',H.StdUnit, ...
  'Color',[0.8 0.8 0.8], ...
   'IntegerHandle',  'off',...
   'Interruptible','off', ...
   'BusyAction','cancel', ...
   'HandleVis','Callback', ...
  'MenuBar','none', ...
   'Name',H.me, ...
   'Numbertitle','off', ...
  'PaperUnits',H.StdUnit, ...
  'Position',[45 30 350 358], ...
  'Tag','nnident', ...
  'ToolBar','none');
  frame4 = uicontrol('Parent',fig, ...
  'Units',H.StdUnit, ...
  'BackgroundColor',[0.8 0.8 0.8], ...
  'ListboxTop',0, ...
  'Position',[5 2 340 22], ...
  'Style','frame', ...
  'Tag','Frame4');
  frame5 = uicontrol('Parent',fig, ...
  'Units',H.StdUnit, ...
  'BackgroundColor',[0.8 0.8 0.8], ...
  'ListboxTop',0, ...
  'Position',[5 26 340 67], ...
  'Style','frame', ...
  'Tag','Frame5');
  h1 = uicontrol('Parent',fig, ...
  'Units',H.StdUnit, ...
  'BackgroundColor',[0.8 0.8 0.8], ...
    'Enable',window_en, ...
  'ListboxTop',0, ...
  'Position',[130 83.5 90.25 15], ...
  'String','Training Parameters', ...
  'Style','text', ...
  'Tag','StaticText1');
  frame1 = uicontrol('Parent',fig, ...
  'Units',H.StdUnit, ...
  'BackgroundColor',[0.8 0.8 0.8], ...
  'ListboxTop',0, ...
  'Position',[5 103 340 137], ...
  'Style','frame', ...
  'Tag','Frame1');
  h1 = uicontrol('Parent',fig, ...
  'Units',H.StdUnit, ...
  'BackgroundColor',[0.8 0.8 0.8], ...
    'Enable',window_en, ...
  'ListboxTop',0, ...
  'Position',[140 229.75 70.25 15], ...
  'String','Training Data', ...
  'Style','text', ...
  'Tag','StaticText1');
  frame6 = uicontrol('Parent',fig, ...
  'Units',H.StdUnit, ...
  'BackgroundColor',[0.8 0.8 0.8], ...
  'ListboxTop',0, ...
  'Position',[5 248 340 73], ...
  'Style','frame', ...
  'Tag','Frame6');
  h1 = uicontrol('Parent',fig, ...
  'Units',H.StdUnit, ...
  'BackgroundColor',[0.8 0.8 0.8], ...
    'Enable',window_en, ...
  'ListboxTop',0, ...
  'Position',[130 310.75 90.25 15], ...
  'String','Network Architecture', ...
  'Style','text', ...
  'Tag','StaticText1');
  H.Title_nnident = uicontrol('Parent',fig, ...
  'Units',H.StdUnit, ...
  'BackgroundColor',[0.8 0.8 0.8], ...
  'FontSize',14, ...
  'ListboxTop',0, ...
  'Position',[24.75 330 298.5 21.75], ...
  'String',H.me, ...
  'Style','text', ...
   'Tag','Title_nnident');
  H.Hidden_layer_size = uicontrol('Parent',fig, ...
  'Units',H.StdUnit, ...
  'BackgroundColor',[1 1 1], ...
    'Enable',window_en, ...
  'ListboxTop',0, ...
  'Position',[125 296 45 15], ...
  'Style','edit', ...
   'ToolTipStr','Defines the size of the second layer of the neural network plant model.',...
  'Tag','Hidden_layer');
  H.Hidden_layer_text = uicontrol('Parent',fig, ...
  'Units',H.StdUnit, ...
  'BackgroundColor',[0.8 0.8 0.8], ...
    'Enable',window_en, ...
    'HorizontalAlignment','right', ...
  'ListboxTop',0, ...
  'Position',[10 296 110 15], ...
  'String','Size of Hidden Layer', ...
  'Style','text', ...
   'ToolTipStr','Defines the size of the second layer of the neural network plant model.',...
  'Tag','StaticText1');
  H.simulink_file_text = uicontrol('Parent',fig, ...
  'Units',H.StdUnit, ...
  'BackgroundColor',[0.8 0.8 0.8], ...
    'Enable',window_en, ...
  'ListboxTop',0, ...
  'Position',[170 151 110 15], ...
  'String','Simulink Plant Model:', ...
  'Style','text', ...
   'ToolTipStr','Simulink file containing the plant to be modeled.',...
  'Tag','StaticText1');
  H.BrowseButton = uicontrol('Parent',fig, ...
  'Unit',H.StdUnit, ...
  'Callback','nncontrolutil(''nnident'',''browsesim'',gcbf);', ...
    'Enable',window_en, ...
  'ListboxTop',0, ...
  'Position',[285 151 45 16], ...
  'String','Browse', ...
   'ToolTipStr','Allow the user to select a Simulink file.',...
  'Tag','BrowseButton');
  H.simulink_file = uicontrol('Parent',fig, ...
  'Units',H.StdUnit, ...
  'BackgroundColor',[1 1 1], ...
    'Enable',window_en, ...
  'Callback','nncontrolutil(''nnident'',''clearpath'',gcbf);', ...
  'HorizontalAlignment','left', ...
  'ListboxTop',0, ...
  'Position',[185 129 145 15], ...
  'Style','edit', ...
   'ToolTipStr','Simulink file containing the plant to be modeled.',...
  'Tag','Plant_model');
  H.Sampling_text = uicontrol('Parent',fig, ...
  'Units',H.StdUnit, ...
  'BackgroundColor',[0.8 0.8 0.8], ...
    'Enable',window_en, ...
   'HorizontalAlignment','right', ...
  'ListboxTop',0, ...
  'Position',[10 275 110 15], ...
  'String','Sampling Interval (sec)', ...
  'Style','text', ...
   'ToolTipStr','Sampling interval at which the data will be collected from the Simulink plant model.',...
  'Tag','StaticText1');
  H.Sampling_time = uicontrol('Parent',fig, ...
  'Units',H.StdUnit, ...
  'BackgroundColor',[1 1 1], ...
    'Enable',window_en, ...
  'ListboxTop',0, ...
  'Position',[125 275 45 15], ...
  'Style','edit', ...
   'ToolTipStr','Sampling interval at which the data will be collected from the Simulink plant model.',...
  'Tag','Sampling_time');
  H.Delayed_input_text = uicontrol('Parent',fig, ...
  'Units',H.StdUnit, ...
  'BackgroundColor',[0.8 0.8 0.8], ...
    'Enable',window_en, ...
   'HorizontalAlignment','right', ...
  'ListboxTop',0, ...
  'Position',[170 296 110 15], ...
  'String','No. Delayed Plant Inputs', ...
  'Style','text', ...
   'ToolTipStr','Defines how many delays on the plant input will be used to feed the neural network plant model.',...
  'Tag','StaticText1');
  H.Delayed_input = uicontrol('Parent',fig, ...
  'Units',H.StdUnit, ...
  'BackgroundColor',[1 1 1], ...
    'Enable',window_en, ...
  'ListboxTop',0, ...
  'Max',500, ...
  'Min',1, ...
  'Position',[285 296 45 15], ...
  'Style','edit', ...
  'Tag','Ni', ...
   'ToolTipStr','Defines how many delays on the plant input will be used to feed the neural network plant model.',...
  'Value',1);
  H.Delayed_output_text = uicontrol('Parent',fig, ...
  'Units',H.StdUnit, ...
  'BackgroundColor',[0.8 0.8 0.8], ...
    'Enable',window_en, ...
   'HorizontalAlignment','right', ...
  'ListboxTop',0, ...
  'Position',[170 274 110 15], ...
  'String','No. Delayed Plant Outputs', ...
  'Style','text', ...
   'ToolTipStr','Defines how many delays on the plant output will be used to feed the neural network plant model.',...
  'Tag','StaticText1');
  H.Delayed_output = uicontrol('Parent',fig, ...
  'Units',H.StdUnit, ...
  'BackgroundColor',[1 1 1], ...
    'Enable',window_en, ...
  'ListboxTop',0, ...
  'Max',500, ...
  'Min',1, ...
  'Position',[285 274 45 15], ...
  'Style','edit', ...
  'Tag','Nj', ...
   'ToolTipStr','Defines how many delays on the plant output will be used to feed the neural network plant model.',...
  'Value',1);
  H.Limit_output_data = uicontrol('Parent',fig, ...
  'Units',H.StdUnit, ...
  'BackgroundColor',[0.8 0.8 0.8], ...
  'Callback','nncontrolutil(''nnident'',''limit_output'')', ...
    'Enable',window_en, ...
  'ListboxTop',0, ...
  'Position',[200 217 110 15], ...
  'String','Limit Output Data', ...
  'Style','checkbox', ...
  'Tag','checkbox3', ...
   'ToolTipStr','If selected, the plant output data will be bounded.',...
  'Value',1);
  H.Normalize_data = uicontrol('Parent',fig, ...
  'Units',H.StdUnit, ...
  'BackgroundColor',[0.8 0.8 0.8], ...
    'Enable',window_en, ...
  'ListboxTop',0, ...
  'Position',[20 253 110 15], ...
  'String','Normalize Training Data', ...
  'Style','checkbox', ...
  'Tag','checkbox2', ...
   'ToolTipStr','If selected, the plant input-output data will be normalized.',...
  'Value',1);
  H.Use_Previous_Weights_but = uicontrol('Parent',fig, ...
  'Units',H.StdUnit, ...
  'BackgroundColor',[0.8 0.8 0.8], ...
    'Enable',window_en, ...
  'ListboxTop',0, ...
  'Position',[20 48 90 15], ...
  'String','Use Current Weights', ...
  'Style','checkbox', ...
  'Tag','checkbox2', ...
   'ToolTipStr','If selected, the current weights are used as initial values for continued training.',...
  'Value',0);
 H.Use_Validation_but = uicontrol('Parent',fig, ...
  'Units',H.StdUnit, ...
  'BackgroundColor',[0.8 0.8 0.8], ...
    'Enable',window_en, ...
  'ListboxTop',0, ...
  'Position',[130 48 90 15], ...
  'String','Use Validation Data', ...
  'Style','checkbox', ...
   'ToolTipStr','A validation data set will be used to stop training.',...
  'Tag','checkbox1');
  H.Use_Testing_but = uicontrol('Parent',fig, ...
  'Units',H.StdUnit, ...
  'BackgroundColor',[0.8 0.8 0.8], ...
    'Enable',window_en, ...
  'ListboxTop',0, ...
  'Position',[240 48 90 15], ...
  'String','Use Testing Data', ...
  'Style','checkbox', ...
   'ToolTipStr','A testing data set will be monitored during training.',...
  'Tag','checkbox1a');
  H.Max_input_text = uicontrol('Parent',fig, ...
  'Units',H.StdUnit, ...
  'BackgroundColor',[0.8 0.8 0.8], ...
    'Enable',window_en, ...
   'HorizontalAlignment','right', ...
  'ListboxTop',0, ...
  'Position',[10 195 110 15], ...
  'String','Maximum Plant Input', ...
  'Style','text', ...
   'ToolTipStr','Defines an upper bound on the random plant input.',...
  'Tag','Maximum_input_Text');
  H.Max_input = uicontrol('Parent',fig, ...
  'Units',H.StdUnit, ...
  'BackgroundColor',[1 1 1], ...
    'Enable',window_en, ...
  'ListboxTop',0, ...
  'Position',[125 195 45 15], ...
  'Style','edit', ...
   'ToolTipStr','Defines an upper bound on the random plant input.',...
  'Tag','Maximum_input');
  H.Min_input_text = uicontrol('Parent',fig, ...
  'Units',H.StdUnit, ...
  'BackgroundColor',[0.8 0.8 0.8], ...
    'Enable',window_en, ...
   'HorizontalAlignment','right', ...
  'ListboxTop',0, ...
  'Position',[10 173 110 15], ...
  'String','Minimum Plant Input', ...
  'Style','text', ...
   'ToolTipStr','Defines a lower bound on the random plant input.',...
  'Tag','Minimum_input_Text');
  H.Min_input = uicontrol('Parent',fig, ...
  'Units',H.StdUnit, ...
  'BackgroundColor',[1 1 1], ...
    'Enable',window_en, ...
  'ListboxTop',0, ...
  'Position',[125 173 45 15], ...
  'Style','edit', ...
   'ToolTipStr','Defines a lower bound on the random plant input.',...
  'Tag','Minimum_input');
  H.max_int_text = uicontrol('Parent',fig, ...
  'Units',H.StdUnit, ...
  'BackgroundColor',[0.8 0.8 0.8], ...
    'Enable',window_en, ...
   'HorizontalAlignment','right', ...
  'ListboxTop',0, ...
  'Position',[10 151 110 15], ...
  'String','Maximum Interval Value (sec)', ...
  'Style','text', ...
   'ToolTipStr','Defines a maximum interval over which the random plant input will remain constant.',...
  'Tag','StaticText2');
  H.max_int_edit = uicontrol('Parent',fig, ...
  'Units',H.StdUnit, ...
  'BackgroundColor',[1 1 1], ...
    'Enable',window_en, ...
  'ListboxTop',0, ...
  'Position',[125 151 45 15], ...
  'Style','edit', ...
   'ToolTipStr','Defines a maximum interval over which the random plant input will remain constant.',...
  'Tag','max_r_edit');
  H.min_int_text = uicontrol('Parent',fig, ...
  'Units',H.StdUnit, ...
  'BackgroundColor',[0.8 0.8 0.8], ...
    'Enable',window_en, ...
   'HorizontalAlignment','right', ...
  'ListboxTop',0, ...
  'Position',[10 129 110 15], ...
  'String','Minimum Interval Value (sec)', ...
  'Style','text', ...
   'ToolTipStr','Defines a minimum interval over which the random plant input will remain constant.',...
  'Tag','StaticText2');
  H.min_int_edit = uicontrol('Parent',fig, ...
  'Units',H.StdUnit, ...
  'BackgroundColor',[1 1 1], ...
    'Enable',window_en, ...
  'ListboxTop',0, ...
  'Position',[125 129 45 15], ...
  'Style','edit', ...
   'ToolTipStr','Defines a minimum interval over which the random plant input will remain constant.',...
  'Tag','EditText1');
  H.Max_output = uicontrol('Parent',fig, ...
  'Units',H.StdUnit, ...
  'BackgroundColor',[1 1 1], ...
    'Enable',window_en, ...
  'ListboxTop',0, ...
  'Position',[285 195 45 15], ...
  'Style','edit', ...
   'ToolTipStr','Defines an upper bound on the plant output.',...
  'Tag','Maximum_output');
  H.Max_output_text = uicontrol('Parent',fig, ...
  'Units',H.StdUnit, ...
  'BackgroundColor',[0.8 0.8 0.8], ...
    'Enable',window_en, ...
   'HorizontalAlignment','right', ...
  'ListboxTop',0, ...
  'Position',[170 195 110 15], ...
  'String','Maximum Plant Output', ...
  'Style','text', ...
   'ToolTipStr','Defines an upper bound on the plant output.',...
  'Tag','Maximum_output_text');
  H.Min_output_text = uicontrol('Parent',fig, ...
  'Units',H.StdUnit, ...
  'BackgroundColor',[0.8 0.8 0.8], ...
    'Enable',window_en, ...
   'HorizontalAlignment','right', ...
  'ListboxTop',0, ...
  'Position',[170 173 110 15], ...
  'String','Minimum Plant Output', ...
  'Style','text', ...
   'ToolTipStr','Defines a lower bound on the plant output.',...
  'Tag','Minimum_output_text');
  H.Min_output = uicontrol('Parent',fig, ...
  'Units',H.StdUnit, ...
  'BackgroundColor',[1 1 1], ...
    'Enable',window_en, ...
  'ListboxTop',0, ...
  'Position',[285 173 45 15], ...
  'Style','edit', ...
   'ToolTipStr','Defines a lower bound on the plant output.',...
  'Tag','Minimum_output');
  H.Samples_text = uicontrol('Parent',fig, ...
  'Units',H.StdUnit, ...
  'BackgroundColor',[0.8 0.8 0.8], ...
    'Enable',window_en, ...
   'HorizontalAlignment','right', ...
  'ListboxTop',0, ...
  'Position',[10 217 110 15], ...
  'String','Training Samples', ...
  'Style','text', ...
   'ToolTipStr','Defines how many data points will be generated for training.',...
  'Tag','StaticText1');
  H.Samples = uicontrol('Parent',fig, ...
  'Units',H.StdUnit, ...
  'BackgroundColor',[1 1 1], ...
    'Enable',window_en, ...
  'ListboxTop',0, ...
  'Position',[125 217 45 15], ...
  'Style','edit', ...
   'ToolTipStr','Defines how many data points will be generated for training.',...
  'Tag','Training_examples');
  H.trainfun_edit = uicontrol('Parent',fig, ...
  'Units',H.StdUnit, ...
  'BackgroundColor',[1 1 1], ...
    'Enable',window_en, ...
  'ListboxTop',0, ...
  'Position',[270 65 60 15], ...
  'Max',17, ...
  'String',['trainbfg';'trainbr ';'traincgb';'traincgf';'traincgp';'traingd ';'traingdm';'traingda';'traingdx';'trainlm ';'trainoss';'trainrp ';'trainscg'], ...
  'Style','popupmenu', ...
  'Tag','PopupMenu1', ...
  'Value',1);
  H.trainfun_text = uicontrol('Parent',fig, ...
  'Units',H.StdUnit, ...
  'BackgroundColor',[0.8 0.8 0.8], ...
    'Enable',window_en, ...
   'HorizontalAlignment','right', ...
  'ListboxTop',0, ...
  'Position',[180 65 85 15], ...
  'String','Training Function', ...
  'Style','text', ...
   'ToolTipStr','Select a training function for neural network plant model training.',...
  'Tag','StaticText3');
  H.epochs_text = uicontrol('Parent',fig, ...
  'Units',H.StdUnit, ...
  'BackgroundColor',[0.8 0.8 0.8], ...
    'Enable',window_en, ...
   'HorizontalAlignment','right', ...
  'ListboxTop',0, ...
  'Position',[10 65 110 15], ...
  'String','Training Epochs', ...
  'Style','text', ...
   'ToolTipStr','Defines number of iterations to train the neural network plant model.',...
  'Tag','StaticText1');
  H.epochs_h = uicontrol('Parent',fig, ...
  'Units',H.StdUnit, ...
  'BackgroundColor',[1 1 1], ...
    'Enable',window_en, ...
  'ListboxTop',0, ...
  'Position',[125 65 45 15], ...
  'Style','edit', ...
   'ToolTipStr','Defines number of iterations to train the neural network plant model.',...
  'Tag','Training_epochs');
  H.Start_but = uicontrol('Parent',fig, ...
  'Units',H.StdUnit, ...
  'BackgroundColor',[0.752941176470588 0.752941176470588 0.752941176470588], ...
  'Callback','nncontrolutil(''nnident'',''continue_training'')', ...
  'Enable','off', ...
  'ListboxTop',0, ...
  'Position',[20 30 85 16], ...
  'String','Train Network', ...
   'ToolTipStr','Train the neural network plant using the parameters shown in this window.',...
  'Tag','Pushbutton1');
  H.OK_but = uicontrol('Parent',fig, ...
  'Units',H.StdUnit, ...
  'BackgroundColor',[0.752941176470588 0.752941176470588 0.752941176470588], ...
  'Callback','nncontrolutil(''nnident'',''ok'')', ...
  'Enable','off', ...
  'ListboxTop',0, ...
  'Position',[115 30 65 16], ...
  'String','OK', ...
   'ToolTipStr','Save the neural network plant model into the controller block and close this menu.',...
  'Tag','Pushbutton1');
  H.Cancel_but = uicontrol('Parent',fig, ...
  'Units',H.StdUnit, ...
  'BackgroundColor',[0.752941176470588 0.752941176470588 0.752941176470588], ...
  'Callback','nncontrolutil(''nnident'',''close'')', ...
  'ListboxTop',0, ...
  'Position',[190 30 65 16], ...
  'String','Cancel', ...
   'ToolTipStr','Discard the neural network plant model and close this menu',...
  'Tag','Pushbutton1');
  H.Apply_but = uicontrol('Parent',fig, ...
  'Units',H.StdUnit, ...
  'BackgroundColor',[0.752941176470588 0.752941176470588 0.752941176470588], ...
  'Callback','nncontrolutil(''nnident'',''apply'')', ...
  'Enable','off', ...
  'ListboxTop',0, ...
  'Position',[265 30 65 16], ...
  'String','Apply', ...
   'ToolTipStr','Save the neural network plant model into the controller block',...
  'Tag','Pushbutton1');
  H.Simulating_text = uicontrol('Parent',fig, ...
  'Units',H.StdUnit, ...
  'BackgroundColor',[0.8 0.8 0.8], ...
   'FontWeight','bold', ...
  'ListboxTop',0, ...
  'Position',[9 50 120 15], ...
  'String','Simulating Plant', ...
  'Style','text', ...
   'Tag','StaticText1', ...
   'visible','off');
  H.error_messages= uicontrol('Parent',fig, ...
  'Units',H.StdUnit, ...
   'BackgroundColor',[0.752941176470588 0.752941176470588 0.752941176470588], ...
  'FontWeight','bold', ...
   'ForegroundColor',[0 0 1], ...
  'ListboxTop',0, ...
  'Position',[6 3 338 20], ...
  'Style','text', ...
  'ToolTipStr','Feedback line with important messages for the user.',...
  'Tag','StaticText1');

  H.Gen_data_but = uicontrol('Parent',fig, ...
  'Units',H.StdUnit, ...
  'BackgroundColor',[0.752941176470588 0.752941176470588 0.752941176470588], ...
  'Callback','nncontrolutil(''nnident'',''gen_data'')', ...
    'Enable',window_en, ...
  'ListboxTop',0, ...
  'Position',[20 106.75 100 16.5], ...
  'String','Generate Training Data', ...
  'Tag','Pushbutton1', ...
  'TooltipString','Generate data to be used in training the neural network plant model.');
if strcmp(arg3,'nnpredict')
   H.Get_data_file_but = uicontrol('Parent',fig, ...
  'Units',H.StdUnit, ...
  'BackgroundColor',[0.752941176470588 0.752941176470588 0.752941176470588], ...
  'Callback','nncontrolutil(''nndataimport'',''init'',gcbf,''nnpredict'');',...
    'Enable',window_en, ...
  'ListboxTop',0, ...
  'Position',[130 106.75 95 16.5], ...
  'String','Import Data', ...
  'Tag','Pushbutton1', ...
   'TooltipString','Import training data from the workspace or from a file.');
   H.Save_to_file_but = uicontrol('Parent',fig, ...
  'Units',H.StdUnit, ...
  'BackgroundColor',[0.752941176470588 0.752941176470588 0.752941176470588], ...
  'Callback','nncontrolutil(''nndataexport'',''init'',gcbf,''nnpredict'');',...
    'Enable',window_en, ...
  'ListboxTop',0, ...
  'Position',[235 106.75 95 16.5], ...
  'String','Export Data', ...
  'Tag','Pushbutton1', ...
  'TooltipString','Export training data to the workspace or to a file.');
elseif strcmp(arg3,'nnmodref')
   H.Get_data_file_but = uicontrol('Parent',fig, ...
  'Units',H.StdUnit, ...
  'BackgroundColor',[0.752941176470588 0.752941176470588 0.752941176470588], ...
  'Callback','nncontrolutil(''nndataimport'',''init'',gcbf,''nnmodref'');',...
    'Enable',window_en, ...
  'ListboxTop',0, ...
  'Position',[130 106.75 95 16.5], ...
  'String','Import Data', ...
  'Tag','Pushbutton1', ...
   'TooltipString','Import training data from the workspace or from a file.');
   H.Save_to_file_but = uicontrol('Parent',fig, ...
  'Units',H.StdUnit, ...
  'BackgroundColor',[0.752941176470588 0.752941176470588 0.752941176470588], ...
  'Callback','nncontrolutil(''nndataexport'',''init'',gcbf,''nnmodref'');',...
    'Enable',window_en, ...
  'ListboxTop',0, ...
  'Position',[235 106.75 95 16.5], ...
  'String','Export Data', ...
  'Tag','Pushbutton1', ...
  'TooltipString','Export training data to the workspace or to a file.');
elseif strcmp(arg3,'narma_l2')
   H.Get_data_file_but = uicontrol('Parent',fig, ...
  'Units',H.StdUnit, ...
  'BackgroundColor',[0.752941176470588 0.752941176470588 0.752941176470588], ...
  'Callback','nncontrolutil(''nndataimport'',''init'',gcbf,''narma_l2'');',...
    'Enable',window_en, ...
  'ListboxTop',0, ...
  'Position',[130 106.75 95 16.5], ...
  'String','Import Data', ...
  'Tag','Pushbutton1', ...
   'TooltipString','Import training data from the workspace or from a file.');
   H.Save_to_file_but = uicontrol('Parent',fig, ...
  'Units',H.StdUnit, ...
  'BackgroundColor',[0.752941176470588 0.752941176470588 0.752941176470588], ...
  'Callback','nncontrolutil(''nndataexport'',''init'',gcbf,''narma_l2'');',...
    'Enable',window_en, ...
  'ListboxTop',0, ...
  'Position',[235 106.75 95 16.5], ...
  'String','Export Data', ...
  'Tag','Pushbutton1', ...
  'TooltipString','Export training data to the workspace or to a file.');
end
H.Training_done=0;
H.Data_Generated=1;
H.Data_Available=0;
H.Data_Imported=0;

% We create the menus for the block.
H.Handles.Menus.File.Top= uimenu('Parent',fig, ...
   'Label','File');
if strcmp(arg3,'nnpredict')
  H.Handles.Menus.File.ImportModel = uimenu('Parent',...
    H.Handles.Menus.File.Top,...
    'Label','Import Network...',...
    'Accelerator','I',...
    'Callback','nncontrolutil(''nnimport'',''init'',gcbf,''nnpredict'',''nnident'');',...
    'Enable',window_en, ...
    'Tag','ImportModel');
  H.Handles.Menus.File.Export = uimenu('Parent',H.Handles.Menus.File.Top, ...
    'Label','Export Network...', ...
    'Accelerator','E', ...
    'Callback','nncontrolutil(''nnexport'',''init'',gcbf,''nnpredict'',''nnident'')', ...
    'Enable',window_en, ...
    'Tag','ExportMenu');
elseif strcmp(arg3,'nnmodref')
  H.Handles.Menus.File.ImportModel = uimenu('Parent',...
    H.Handles.Menus.File.Top,...
    'Label','Import Network...',...
    'Accelerator','I',...
    'Callback','nncontrolutil(''nnimport'',''init'',gcbf,''nnmodref'',''nnident'');',...
    'Enable',window_en, ...
    'Tag','ImportModel');
  H.Handles.Menus.File.Export = uimenu('Parent',H.Handles.Menus.File.Top, ...
    'Label','Export Network...', ...
    'Accelerator','E', ...
    'Callback','nncontrolutil(''nnexport'',''init'',gcbf,''nnmodref'',''nnident'')', ...
    'Enable',window_en, ...
    'Tag','ExportMenu');
elseif strcmp(arg3,'narma_l2')
  H.Handles.Menus.File.ImportModel = uimenu('Parent',...
    H.Handles.Menus.File.Top,...
    'Label','Import Network...',...
    'Accelerator','I',...
    'Callback','nncontrolutil(''nnimport'',''init'',gcbf,''narma_l2'',''nnident'');',...
    'Enable',window_en, ...
    'Tag','ImportModel');
  H.Handles.Menus.File.Export = uimenu('Parent',H.Handles.Menus.File.Top, ...
    'Label','Export Network...', ...
    'Accelerator','E', ...
    'Callback','nncontrolutil(''nnexport'',''init'',gcbf,''narma_l2'',''nnident'')', ...
    'Enable',window_en, ...
    'Tag','ExportMenu');
end 
H.Handles.Menus.File.Save_NN = uimenu('Parent',...
   H.Handles.Menus.File.Top,...
   'Label','Save',...
   'Separator','on', ...
   'Enable','off', ...
   'Accelerator','S',...
   'Callback','nncontrolutil(''nnident'',''apply'');',...
   'Tag','ImportModel');
H.Handles.Menus.File.Save_Exit_NN = uimenu('Parent',...
   H.Handles.Menus.File.Top,...
   'Label','Save and Exit',...
   'Enable','off', ...
   'Accelerator','A',...
   'Callback','nncontrolutil(''nnident'',''ok'');',...
   'Tag','ImportModel');
H.Handles.Menus.File.Close = uimenu('Parent',H.Handles.Menus.File.Top, ...
   'Callback','nncontrolutil(''nnident'',''close'',gcbf);', ...
   'Separator','on', ...
   'Label','Exit without saving', ...
   'Accelerator','X', ...
   'Tag','CloseMenu');

H.Handles.Menus.Window.Top = uimenu(fig, 'Label', 'Window', ...
   'Callback', winmenu('callback'), 'Tag', 'winmenu');
winmenu(fig);  % Initialize the submenu

H.Handles.Menus.Help.Top = uimenu('Parent',fig, ...
   'Label','Help');
H.Handles.Menus.Help.Main = uimenu('Parent',H.Handles.Menus.Help.Top, ...
   'Label','Main Help', ...
   'Callback','nncontrolutil(''nnidenthelp'',''main'');',...
   'Accelerator','H');
H.Handles.Menus.Help.PlantIdent = uimenu('Parent',H.Handles.Menus.Help.Top, ...
   'Label','Plant Identification...', ...
   'Separator','on',...
   'CallBack','nncontrolutil(''nnidenthelp'',''plant_ident'');');

  H.gcbh_ptr = uicontrol('Parent',fig,'visible','off');
  set(H.gcbh_ptr,'userdata',arg1);
  H.gcb_ptr = uicontrol('Parent',fig,'visible','off');
  set(H.gcb_ptr,'userdata',arg2);
  
  S1=get_param(arg1,'S1');                % S1 is ASCII
  if isempty(S1)        % If the field is empty we initialize default value.
     S1=num2str(0);
  else
     set(H.Hidden_layer_size,'string',S1);
  end
  H.S1_ptr = uicontrol('Parent',fig,'visible','off');
  set(H.S1_ptr,'userdata',str2num(S1));     % S1 is saved as number
  
  sim_file=get_param(arg1,'sim_file'); 
  if isempty(sim_file)        % If the field is empty we initialize default value.
     sim_file='';
  end
  H.sim_file_ptr = uicontrol('Parent',fig,'visible','off');
  set(H.simulink_file,'string',sim_file,'UserData',struct('FileName',sim_file,'PathName',[]));
  set(H.sim_file_ptr,'userdata',sim_file);
  
  Ts=get_param(arg1,'Ts'); 
  if isempty(Ts)        % If the field is empty we initialize default value.
     Ts=num2str(0);
  else
     set(H.Sampling_time,'string',Ts);
  end
  H.Ts_ptr = uicontrol('Parent',fig,'visible','off');
  set(H.Ts_ptr,'userdata',str2num(Ts));
  
  Ni=get_param(arg1,'Ni'); 
  if isempty(Ni)        % If the field is empty we initialize default value.
     Ni=num2str(0);
  else
     set(H.Delayed_input,'string',Ni);
  end
  H.Ni_ptr = uicontrol('Parent',fig,'visible','off');
  set(H.Ni_ptr,'userdata',str2num(Ni));
  
  Nj=get_param(arg1,'Nj'); 
  if isempty(Nj)        % If the field is empty we initialize default value.
     Nj=num2str(0);
  else
     set(H.Delayed_output,'string',Nj);
  end
  H.Nj_ptr = uicontrol('Parent',fig,'visible','off');
  set(H.Nj_ptr,'userdata',str2num(Nj));
  
  trainfun=get_param(arg1,'trainfun'); 
  if size(trainfun,2)==6
     trainfun(7:8)=' ';
  elseif size(trainfun,2)==7
     trainfun(8)=' ';
  end
  vv=strmatch(trainfun,func_index);
  set(H.trainfun_edit,'value',vv);
  
  Use_Validation=get_param(arg1,'Use_Validation'); 
  if isempty(Use_Validation)        % If the field is empty we initialize default value.
     Use_Validation=num2str(1);
  end
  set(H.Use_Validation_but,'value',str2num(Use_Validation));
  
  Use_Testing=get_param(arg1,'Use_Testing'); 
  if isempty(Use_Testing)        % If the field is empty we initialize default value.
     Use_Testing=num2str(1);
  end
  set(H.Use_Testing_but,'value',str2num(Use_Testing))
  
  max_i=get_param(arg1,'max_i'); 
  if isempty(max_i)        % If the field is empty we initialize default value.
     max_i=num2str(0);
  else
     set(H.Max_input,'string',max_i);
  end
  H.max_i_ptr = uicontrol('Parent',fig,'visible','off');
  set(H.max_i_ptr,'userdata',str2num(max_i));
  
  min_i=get_param(arg1,'min_i'); 
  if isempty(min_i)        % If the field is empty we initialize default value.
     min_i=num2str(0);
  else
     set(H.Min_input,'string',min_i);
  end
  H.min_i_ptr = uicontrol('Parent',fig,'visible','off');
  set(H.min_i_ptr,'userdata',str2num(min_i));
  
  max_i_int=get_param(arg1,'max_i_int'); 
  if isempty(max_i_int)        % If the field is empty we initialize default value.
     max_i_int=num2str(0);
  else
     set(H.max_int_edit,'string',max_i_int);
  end
  H.max_i_int_ptr = uicontrol('Parent',fig,'visible','off');
  set(H.max_i_int_ptr,'userdata',str2num(max_i_int));
  
  min_i_int=get_param(arg1,'min_i_int'); 
  if isempty(min_i_int)        % If the field is empty we initialize default value.
     min_i_int=num2str(0);
  else
     set(H.min_int_edit,'string',min_i_int);
  end
  H.min_i_int_ptr = uicontrol('Parent',fig,'visible','off');
  set(H.min_i_int_ptr,'userdata',str2num(min_i_int));
  
  Limit_output=get_param(arg1,'limit_output'); 
  if isempty(Limit_output)
     Limit_output='0';
  end
  set(H.Limit_output_data,'value',str2num(Limit_output))
  
  max_out=get_param(arg1,'max_output'); 
  if isempty(max_out)        % If the field is empty we initialize default value.
     max_out=num2str(0);
  else
     set(H.Max_output,'string',max_out);
  end
  H.max_out_ptr = uicontrol('Parent',fig,'visible','off');
  set(H.max_out_ptr,'userdata',str2num(max_out));
  
  min_out=get_param(arg1,'min_output'); 
  if isempty(min_out)        % If the field is empty we initialize default value.
     min_out=num2str(0);
  else
     set(H.Min_output,'string',min_out);
  end
  H.min_out_ptr = uicontrol('Parent',fig,'visible','off');
  set(H.min_out_ptr,'userdata',str2num(min_out));
  
  Use_Previous_Weights=get_param(arg1,'Use_Previous_Weights'); 
  if isempty(Use_Previous_Weights)        % If the field is empty we initialize default value.
     Use_Previous_Weights=num2str(1);
  end
  set(H.Use_Previous_Weights_but,'value',str2num(Use_Previous_Weights));
  H.Use_Previous_Weights_ptr = uicontrol('Parent',fig,'visible','off');
  set(H.Use_Previous_Weights_ptr,'userdata',str2num(Use_Previous_Weights));
  
  sam_training=get_param(arg1,'sam_training'); 
  if isempty(sam_training)        % If the field is empty we initialize default value.
     sam_training=num2str(0);
  else
     set(H.Samples,'string',sam_training);
  end
  H.sam_training_ptr = uicontrol('Parent',fig,'visible','off');
  set(H.sam_training_ptr,'userdata',str2num(sam_training));

  epochs=get_param(arg1,'epochs'); 
  if isempty(epochs)        % If the field is empty we initialize default value.
     epochs=num2str(0);
  else
     set(H.epochs_h,'string',epochs);
  end
  H.epochs_ptr = uicontrol('Parent',fig,'visible','off');
  set(H.epochs_ptr,'userdata',str2num(epochs));
 
  if strcmp(arg3,'narma_l2')
    % ODJ 1-13-00 Default values are assigned if the weight fields are empty.
    IW1_1=eval(strvcat(get_param(arg1,'IW1_1')),'0'); 
    H.IW1_1_ptr = uicontrol('Parent',fig,'visible','off');
    set(H.IW1_1_ptr,'userdata',IW1_1);
  
    % ODJ 1-13-00 Default values are assigned if the weight fields are empty.
    IW3_2=eval(strvcat(get_param(arg1,'IW3_2')),'0'); 
    H.IW3_2_ptr = uicontrol('Parent',fig,'visible','off');
    set(H.IW3_2_ptr,'userdata',IW3_2);
  
    % ODJ 1-13-00 Default values are assigned if the weight fields are empty.
    IW5_3=eval(strvcat(get_param(arg1,'IW5_3')),'0'); 
    H.IW5_3_ptr = uicontrol('Parent',fig,'visible','off');
    set(H.IW5_3_ptr,'userdata',IW5_3);
  
    % ODJ 1-13-00 Default values are assigned if the weight fields are empty.
    LW2_1=eval(strvcat(get_param(arg1,'LW2_1')),'0'); 
    H.LW2_1_ptr = uicontrol('Parent',fig,'visible','off');
    set(H.LW2_1_ptr,'userdata',LW2_1);
  
    % ODJ 1-13-00 Default values are assigned if the weight fields are empty.
    LW4_3=eval(strvcat(get_param(arg1,'LW4_3')),'0'); 
    H.LW4_3_ptr = uicontrol('Parent',fig,'visible','off');
    set(H.LW4_3_ptr,'userdata',LW4_3);
  
    % ODJ 1-13-00 Default values are assigned if the weight fields are empty.
    LW5_4=eval(strvcat(get_param(arg1,'LW5_4')),'0'); 
    H.LW5_4_ptr = uicontrol('Parent',fig,'visible','off');
    set(H.LW5_4_ptr,'userdata',LW5_4);
  
    % ODJ 1-13-00 Default values are assigned if the weight fields are empty.
    LW6_5=eval(strvcat(get_param(arg1,'LW6_5')),'0'); 
    H.LW6_5_ptr = uicontrol('Parent',fig,'visible','off');
    set(H.LW6_5_ptr,'userdata',LW6_5);
  
    % ODJ 1-13-00 Default values are assigned if the weight fields are empty.
    LW6_2=eval(strvcat(get_param(arg1,'LW6_2')),'0'); 
    H.LW6_2_ptr = uicontrol('Parent',fig,'visible','off');
    set(H.LW6_2_ptr,'userdata',LW6_2);
  
    % ODJ 1-13-00 Default values are assigned if the weight fields are empty.
    B1=eval(strvcat(get_param(arg1,'B1')),'0'); 
    H.B1_ptr = uicontrol('Parent',fig,'visible','off');
    set(H.B1_ptr,'userdata',B1);
  
    % ODJ 1-13-00 Default values are assigned if the weight fields are empty.
    B2=eval(strvcat(get_param(arg1,'B2')),'0'); 
    H.B2_ptr = uicontrol('Parent',fig,'visible','off');
    set(H.B2_ptr,'userdata',B2);
  
    % ODJ 1-13-00 Default values are assigned if the weight fields are empty.
    B3=eval(strvcat(get_param(arg1,'B3')),'0'); 
    H.B3_ptr = uicontrol('Parent',fig,'visible','off');
    set(H.B3_ptr,'userdata',B3);
  
    % ODJ 1-13-00 Default values are assigned if the weight fields are empty.
    B4=eval(strvcat(get_param(arg1,'B4')),'0'); 
    H.B4_ptr = uicontrol('Parent',fig,'visible','off');
    set(H.B4_ptr,'userdata',B4);
     
  else
    % ODJ 1-13-00 Default values are assigned if the weight fields are empty.
    IW=eval(strvcat(get_param(arg1,'IW')),'0'); 
    H.IW_ptr = uicontrol('Parent',fig,'visible','off');
    set(H.IW_ptr,'userdata',IW);
  
    % ODJ 1-13-00 Default values are assigned if the weight fields are empty.
    LW1_2=eval(strvcat(get_param(arg1,'LW1_2')),'0'); 
    H.LW1_2_ptr = uicontrol('Parent',fig,'visible','off');
    set(H.LW1_2_ptr,'userdata',LW1_2);
  
    % ODJ 1-13-00 Default values are assigned if the weight fields are empty.
    LW2_1=eval(strvcat(get_param(arg1,'LW2_1')),'0'); 
    H.LW2_1_ptr = uicontrol('Parent',fig,'visible','off');
    set(H.LW2_1_ptr,'userdata',LW2_1);
  
    % ODJ 1-13-00 Default values are assigned if the weight fields are empty.
    B1=eval(strvcat(get_param(arg1,'B1')),'0'); 
    H.B1_ptr = uicontrol('Parent',fig,'visible','off');
    set(H.B1_ptr,'userdata',B1);
  
    % ODJ 1-13-00 Default values are assigned if the weight fields are empty.
    B2=eval(strvcat(get_param(arg1,'B2')),'0'); 
    H.B2_ptr = uicontrol('Parent',fig,'visible','off');
    set(H.B2_ptr,'userdata',B2);
  end
  
  minp=get_param(arg1,'minp'); 
  H.minp_ptr = uicontrol('Parent',fig,'visible','off');
  set(H.minp_ptr,'userdata',minp);
  
  maxp=get_param(arg1,'maxp'); 
  H.maxp_ptr = uicontrol('Parent',fig,'visible','off');
  set(H.maxp_ptr,'userdata',maxp);
  
  mint=get_param(arg1,'mint'); 
  H.mint_ptr = uicontrol('Parent',fig,'visible','off');
  set(H.mint_ptr,'userdata',mint);
  
  maxt=get_param(arg1,'maxt'); 
  H.maxt_ptr = uicontrol('Parent',fig,'visible','off');
  set(H.maxt_ptr,'userdata',maxt);
  
  Normalize=str2num(get_param(arg1,'Normalize')); 
  if isempty(Normalize)        % If the field is empty we initialize default value.
     Normalize=0;
  end
  H.Normalize_ptr = uicontrol('Parent',fig,'visible','off');
  set(H.Normalize_ptr,'userdata',Normalize);
  set(H.Normalize_data,'value',Normalize);
  
  H.In_training_ptr = uicontrol('Parent',fig,'visible','off');
  set(H.In_training_ptr,'userdata',0);
  
  H.parent_function_ptr = uicontrol('Parent',fig,'visible','off');
  set(H.parent_function_ptr,'userdata',arg3);
  
  set(fig,'userdata',H);
  
  set(H.error_messages,'string',sprintf('Generate or import data before training the neural network plant.'));
  
  % IMPORTANT: This call must be here because we need H for the callback.
  nncontrolutil('nnident','limit_output');
  
elseif strcmp(cmd,'limit_output') & (fig)
   limit_output=get(H.Limit_output_data,'Value');
   if limit_output==1
     set(H.Max_output,'enable','on')
     set(H.Max_output_text,'enable','on')
     set(H.Min_output,'enable','on')
     set(H.Min_output_text,'enable','on')
   else
     set(H.Max_output,'enable','off')
     set(H.Max_output_text,'enable','off')
     set(H.Min_output,'enable','off')
     set(H.Min_output_text,'enable','off')
   end
  
  
elseif strcmp(cmd,'data_no_ok') & (fig)
%  set(H.Start_but,'enable','on')
  set(H.Cancel_but,'enable','on')
  if H.Training_done
     set(H.OK_but,'enable','on')
     set(H.Apply_but,'enable','on')
     set(H.Handles.Menus.File.Save_NN,'enable','on')
     set(H.Handles.Menus.File.Save_Exit_NN,'enable','on')
  end
  if H.Data_Available
     load(cat(2,tempdir,'nnidentdata.mat'),'N2');
     set(H.Start_but,'enable','on')
     st=sprintf('Your training data set has %d samples.\nYou can now train the network.',N2-1);
     set(H.error_messages,'string',st);   
  else
    set(H.error_messages,'string',sprintf('Generate or import data before training the neural network plant.'));
    set(H.Max_input,'enable','on')
    set(H.Max_input_text,'enable','on')
    set(H.Min_input,'enable','on')
    set(H.Min_input_text,'enable','on')
    set(H.max_int_edit,'enable','on')
    set(H.max_int_text,'enable','on')
    set(H.min_int_edit,'enable','on')
    set(H.min_int_text,'enable','on')
    set(H.Samples_text,'enable','on')
    set(H.Samples,'enable','on')
    set(H.Sampling_text,'enable','on')
    set(H.Sampling_time,'enable','on')
    set(H.Limit_output_data,'enable','on');
    limit_output=get(H.Limit_output_data,'Value');
    if limit_output==1
       set(H.Max_output,'enable','on')
       set(H.Max_output_text,'enable','on')
       set(H.Min_output,'enable','on')
       set(H.Min_output_text,'enable','on')
    end
    set(H.BrowseButton,'enable','on');
    set(H.simulink_file,'enable','on');
    set(H.simulink_file_text,'enable','on');
  end
  set(H.Simulating_text,'visible','off');   drawnow; % pause needed to refresh the message
  
  fig2=findall(0,'type','figure','tag','nnidentdata');
  delete(fig2);

  if exist(cat(2,tempdir,'nnidentdata2.mat'))
     delete(cat(2,tempdir,'nnidentdata2.mat'));
  end
  
  % We refresh the menu.
  arg1=get(H.gcbh_ptr,'userdata');
  arg2=get(H.gcb_ptr,'userdata');
  nncontrolutil('nnident','',arg1,arg2,'');
  
elseif strcmp(cmd,'browsesim')
   filterspec = '*.mdl';
   
   udFileEdit = get(H.simulink_file,'UserData');
   LastPath = udFileEdit.PathName;
   CurrentPath=pwd;
   if ~isempty(LastPath),
      cd(LastPath);
   end
   [filename,pathname] = uigetfile(filterspec,'Simulink Plant Model:');
   if ~isempty(LastPath),
      cd(CurrentPath);
   end
   
   if filename,
      if ~strcmpi(pathname(1:end-1),CurrentPath)
         ImportStr = [pathname,filename(1:end-4)];
      else
         ImportStr = filename(1:end-4);
      end
      udFileEdit.PathName=pathname;
      udFileEdit.FileName=filename;
      set(H.simulink_file,'String',filename(1:end-4),'UserData',udFileEdit);
   end
   
elseif strcmp(cmd,'clearpath') & (fig)
   %---Callback for the SImulink File box
   %    Whenever a new name is entered, update the Userdata
   NewName = get(gcbo,'String');
   indDot = findstr(NewName,'.');
   if ~isempty(indDot),
      NewName=NewName(1:indDot(end)-1);
      set(H.simulink_file,'String',NewName)   
   end
      
elseif strcmp(cmd,'erase_data') & (fig)
  set(H.Max_input,'enable','on')
  set(H.Max_input_text,'enable','on')
  set(H.Min_input,'enable','on')
  set(H.Min_input_text,'enable','on')
  set(H.max_int_edit,'enable','on')
  set(H.max_int_text,'enable','on')
  set(H.min_int_edit,'enable','on')
  set(H.min_int_text,'enable','on')
  set(H.Samples_text,'enable','on')
  set(H.Samples,'enable','on')
  set(H.Sampling_text,'enable','on')
  set(H.Sampling_time,'enable','on')
  set(H.Limit_output_data,'enable','on');
  limit_output=get(H.Limit_output_data,'Value');
  if limit_output==1
     set(H.Max_output,'enable','on')
     set(H.Max_output_text,'enable','on')
     set(H.Min_output,'enable','on')
     set(H.Min_output_text,'enable','on')
  end
  set(H.BrowseButton,'enable','on');
  set(H.simulink_file,'enable','on');
  set(H.simulink_file_text,'enable','on');
  H.Data_Generated=0;
  H.Data_Imported=0;
  H.Data_Available=0;
  set(H.Start_but,'enable','off')
  if exist(cat(2,tempdir,'nnidentdata2.mat'))
     delete(cat(2,tempdir,'nnidentdata2.mat'));
  end
  if exist(cat(2,tempdir,'nnidentdata.mat'))
     delete(cat(2,tempdir,'nnidentdata.mat'));
  end
  set(fig,'UserData',H);
  set(H.Gen_data_but,'String','Generate Training Data', ...
           'Callback','nncontrolutil(''nnident'',''gen_data'')', ...
          'TooltipString','Generate data to be used in training the neural network plant model.');
  set(H.error_messages,'string',sprintf('Generate or import data before training the neural network plant.'));
  
elseif (strcmp(cmd,'start_training') | strcmp(cmd,'continue_training') | strcmp(cmd,'data_ok') | ...
      strcmp(cmd,'gen_data') | strcmp(cmd,'have_file')) & (fig)
  if strcmp(cmd,'gen_data') & (fig)
%    H.Data_Generated=1;
    H.Data_Imported=0;
%    H.Training_done=0;
    set(fig,'UserData',H);

  elseif strcmp(cmd,'have_file') & (fig)
    ImportStr=arg1;
    H.Data_Imported=1;
    if nargin==3
       Data_Name=arg2;
    else
       U_Name=arg2;
       Y_Name=arg3;
    end
  end
  
  set(H.Start_but,'enable','off')
  set(H.Cancel_but,'enable','off')
  set(H.OK_but,'enable','off')
  set(H.Apply_but,'enable','off')
  set(H.Handles.Menus.File.Save_NN,'enable','off')
  set(H.Handles.Menus.File.Save_Exit_NN,'enable','off')
  if (strcmp(cmd,'gen_data') | strcmp(cmd,'have_file'))%strcmp(cmd,'start_training')
    arg1=get(H.gcbh_ptr,'userdata');
  
    a1 = str2num(get(H.Sampling_time,'string'));
    Ts=get_param(arg1,'Ts'); 
    if length(a1) == 0, 
       present_error(fig,H,H.Sampling_time,Ts,1, ...
          'You must initialize the sampling interval of your plant before training the neural network'); 
       return
    elseif a1<=0
       present_error(fig,H,H.Sampling_time,Ts,1, ...
          'You must set a positive sampling interval of your plant before training the neural network'); 
       return
    else Ts=a1; set(H.Ts_ptr,'userdata',Ts);  end
  
    fig2=findall(0,'type','figure','tag','nnidentdata');
    if size(fig2,1)==0, fig2=0; end

    if strcmp(cmd,'have_file')
      if nargin==3          % Structure
        if isempty(ImportStr)   % Workspace
          tr_dat=evalin('base',Data_Name);
          if ~isfield(tr_dat,'.flag')
             tr_dat.flag=ones(size(tr_dat.Y));
          end
          if ~isfield(tr_dat,'.Ts')
             tr_dat.Ts=Ts;
          end
        else
          a1 = ImportStr; 
          a2 = which(cat(2,a1,'.mat'));
          if (length(a1) == 0 | length(a2) == 0), 
             present_error(fig,H,0,0,0, ...
                'You must enter a valid filename for your training data, or the file directory must be defined in the MATLAB Path.'); 
             return
          else file_data=a1; end
          temp=load (file_data,Data_Name);
          tr_dat.U=getfield(temp,Data_Name,'U');
          tr_dat.Y=getfield(temp,Data_Name,'Y');
          if isfield(eval(cat(2,'temp.',Data_Name)),'flag')
             tr_dat.flag=getfield(temp,Data_Name,'flag');
          else
             tr_dat.flag=ones(size(tr_dat.Y));
          end
          if isfield(eval(cat(2,'temp.',Data_Name)),'Ts')
             tr_dat.Ts=getfield(temp,Data_Name,'Ts');
          else
             tr_dat.Ts=Ts;
          end
        end
      else       % Arrays.
        if isempty(ImportStr)   % Workspace
          tr_dat=struct('U',evalin('base',U_Name),'Y',evalin('base',Y_Name));
          tr_dat.flag=ones(size(tr_dat.Y));
          tr_dat.Ts=Ts;
        else
          a1 = ImportStr; 
          a2 = which(cat(2,a1,'.mat'));
          if (length(a1) == 0 | length(a2) == 0), 
             present_error(fig,H,0,0,0, ...
                'You must enter a valid filename for your training data, or the file directory must be defined in the MATLAB Path.'); 
             return
          else file_data=a1; end
          temp=load (file_data,U_Name,Y_Name);
          tr_dat.U=getfield(temp,U_Name);
          tr_dat.Y=getfield(temp,Y_Name);
          tr_dat.flag=ones(size(tr_dat.Y));
          tr_dat.Ts=Ts;
        end
      end
      
      % We verify direction of the input vectors.
      if size(tr_dat.U,1)<=1
         tr_dat.U=tr_dat.U';
      end
      if size(tr_dat.Y,1)<=1
         tr_dat.Y=tr_dat.Y';
      end
      if size(tr_dat.flag,1)<=1
         tr_dat.flag=tr_dat.flag';
      end
      sam_training=size(tr_dat.Y,1)-1;
      
      if fig2==0
        pos_fig2=get(fig,'Position');
        fig2 = figure('Units',          H.StdUnit,...
                 'CloseRequestFcn','nncontrolutil(''nnident'',''data_NO_ok'');', ...
                 'Interruptible','off', ...
                 'BusyAction','cancel', ...
                 'HandleVis','Callback', ...
                 'Name',           'Plant Input-Output Data',...
                 'Tag',            'nnidentdata',...
                 'NumberTitle',    'off',...
                 'Position',       pos_fig2, ...
                 'IntegerHandle',  'off',...
                 'Toolbar',        'none', ...
                'WindowStyle','modal');
        f2.h1=axes('Position',[0.13 0.60 0.74 0.32],'Parent',fig2);
        f2.h2=axes('Position',[0.13 0.15 0.74 0.32],'Parent',fig2);
        f2.message= uicontrol('Parent',fig2, ...
                                 'Units',H.StdUnit, ...
                                 'BackgroundColor',[0.752941176470588 0.752941176470588 0.752941176470588], ...
                                 'FontWeight','bold', ...
                                 'ForegroundColor',[0 0 1], ...
                                 'ListboxTop',0, ...
                                 'Position',[156 3 188 20], ...
                                 'Style','text', ...
                                 'Tag','StaticText1');
     else
        f2=get(fig2,'userdata');
        figure(fig2);
      end            
    
      f2.accept_but = uicontrol('Parent',fig2, ...
     'Units',H.StdUnit, ...
       'BackgroundColor',[0.752941176470588 0.752941176470588 0.752941176470588], ...
     'Callback','nncontrolutil(''nnident'',''data_ok'');', ...
     'ListboxTop',0, ...
     'Position',[2 2 68.75 15], ...
     'String','Accept Data', ...
      'Tag','Pushbutton1');
   
      st=sprintf('The imported data has %d samples.\nPlease Accept or Reject Data to continue.',sam_training);
      set(H.error_messages,'string',st);   
      set(f2.message,'string',st);   
    else   %strcmp(cmd,'gen_data')
      a1 = get(H.simulink_file,'string');
      udFileEdit = get(H.simulink_file,'UserData');
      LastPath = udFileEdit.PathName;
      if isempty(LastPath),
         a2 = which(cat(2,a1,'.mdl'));
      else
         a2 = which(cat(2,LastPath,cat(2,a1,'.mdl')));
      end
      if (length(a1) == 0 | length(a2) == 0), 
        present_error(fig,H,H.simulink_file,a1,0, ...
            'You must enter a valid filename for your Simulink plant model'); 
        return
     else 
        sim_file=a1; 
        OpenFlag=1;
        ErrorFlag=isempty(find_system(0,'flat','Name',sim_file));
        if ErrorFlag,
           ErrorFlag=~(exist(sim_file)==4);
           if ~ErrorFlag,
              OpenFlag=0;
              load_system(sim_file);
           end
        end
        if ErrorFlag,
           ErrMsg=[sim_file ' must be the name of a Simulink model.'];
           present_error(fig,H,H.simulink_file,a1,0,ErrMsg); 
           return
        end
          
        blk=get_param(sim_file,'blocks');
        iblk=0;oblk=0;
        for k=1:size(blk,1)
           if strcmp(get_param(cat(2,cat(2,sim_file,'/'),blk{k}),'blocktype'),'Inport')
              iblk=iblk+1;
           end
           if strcmp(get_param(cat(2,cat(2,sim_file,'/'),blk{k}),'blocktype'),'Outport')
              oblk=oblk+1;
           end
        end
        if ~OpenFlag,close_system(sim_file,0);end

        if iblk~=1 | oblk~=1
           present_error(fig,H,H.simulink_file,a1,0, ...
              'The Simulink plant model must have one Inport and one Outport'); 
           return
        end
        sim_path=a2(1:findstr(a2,a1)-1); set(H.sim_file_ptr,'userdata',sim_file);  
     end
  
      a1 = str2num(get(H.Max_input,'string'));
      max_i=get_param(arg1,'max_i'); 
      if length(a1) == 0, 
         present_error(fig,H,H.Max_input,max_i,1, ...
            'You must enter a valid number for the maximum plant input.'); 
         return
      else max_i=a1; set(H.max_i_ptr,'userdata',max_i); end
      
      a1 = str2num(get(H.Min_input,'string'));
      min_i=get_param(arg1,'min_i'); 
      if length(a1) == 0, 
         present_error(fig,H,H.Min_input,min_i,1, ...
            'You must enter a valid number for the minimum plant input.'); 
         return
      elseif a1>=max_i
         present_error(fig,H,H.Min_input,min_i,1, ...
            'You must enter valid numbers for the maximum and minimum plant inputs.'); 
         return
      else min_i=a1; set(H.min_i_ptr,'userdata',min_i); end
      
      a1 = str2num(get(H.max_int_edit,'string'));
      max_i_int=get_param(arg1,'max_i_int'); 
      if (length(a1) == 0) | a1<=0, 
         present_error(fig,H,H.max_int_edit,max_i_int,1, ...
            'You must enter a valid number for the maximum interval value over which the random input is constant.'); 
         return
      else max_i_int=a1; set(H.max_i_int_ptr,'userdata',max_i_int); end
      
      a1 = str2num(get(H.min_int_edit,'string'));
      min_i_int=get_param(arg1,'min_i_int'); 
      if (length(a1) == 0) | a1<=0, 
         present_error(fig,H,H.min_int_edit,min_i_int,1, ...
            'You must enter a valid number for the minimum interval value over which the random input is constant.'); 
         return
      elseif a1>=max_i_int
         present_error(fig,H,H.min_int_edit,min_i_int,1, ...
            'You must enter valid maximum and minimum interval values for constant input to the plant.'); 
         return
      else min_i_int=a1; set(H.min_i_int_ptr,'userdata',min_i_int); end
      
      a1 = str2num(get(H.Samples,'string'));
      sam_training=get_param(arg1,'sam_training'); 
      if (length(a1) == 0) | (a1 < 1) | (floor(a1)~=a1), 
         present_error(fig,H,H.Samples,sam_training,1, ...
            'You must enter a valid number of samples for training'); 
         return
      else sam_training=a1; set(H.sam_training_ptr,'userdata',sam_training); end
      
      Limit_output=get(H.Limit_output_data,'value');
      if Limit_output
         a1 = str2num(get(H.Max_output,'string'));
         max_out=get_param(arg1,'max_output'); 
         if length(a1) == 0, 
            present_error(fig,H,H.Max_output,max_out,1, ...
               'You must enter a valid maximum plant output'); 
            return
         else max_out=a1; set(H.max_out_ptr,'userdata',max_out); end
         
         a1 = str2num(get(H.Min_output,'string'));
         min_out=get_param(arg1,'min_output'); 
         if length(a1) == 0, 
            present_error(fig,H,H.Min_output,min_out,1, ...
               'You must enter a valid minimum plant output'); 
            return
         elseif a1>=max_out
            present_error(fig,H,H.Min_output,min_out,1, ...
               'You must enter valid maximum and minimum plant outputs'); 
            return
         else min_out=a1; set(H.min_out_ptr,'userdata',min_out); end
      else
         max_out=Inf;
         set(H.max_out_ptr,'userdata',max_out);
         min_out=-Inf;
         set(H.min_out_ptr,'userdata',min_out);
      end
      
      if fig2==0
        pos_fig2=get(fig,'Position');
        fig2 = figure('Units',          H.StdUnit,...
                 'Interruptible','off', ...
                 'BusyAction','cancel', ...
                 'HandleVis','Callback', ...
                 'CloseRequestFcn','nncontrolutil(''nnident'',''data_NO_ok'');', ...
                 'Name',           'Plant Input-Output Data',...
                 'Tag',            'nnidentdata',...
                 'NumberTitle',    'off',...
                 'Position',       pos_fig2, ...
                 'IntegerHandle',  'off',...
                 'Toolbar',        'none', ...
                'WindowStyle','modal');
        f2.h1=axes('Position',[0.13 0.60 0.74 0.32],'Parent',fig2);
        f2.h2=axes('Position',[0.13 0.15 0.74 0.32],'Parent',fig2);
        f2.message= uicontrol('Parent',fig2, ...
                                 'Units',H.StdUnit, ...
                                 'BackgroundColor',[0.752941176470588 0.752941176470588 0.752941176470588], ...
                                 'FontWeight','bold', ...
                                 'ForegroundColor',[0 0 1], ...
                                 'ListboxTop',0, ...
                                 'Position',[156 3 188 20], ...
                                 'Style','text', ...
                                 'Tag','StaticText1');
      else
        f2=get(fig2,'userdata');
        figure(fig2);
      end            
    
      f2.accept_but = uicontrol('Parent',fig2, ...
     'Units',H.StdUnit, ...
       'BackgroundColor',[0.752941176470588 0.752941176470588 0.752941176470588], ...
     'Callback','nncontrolutil(''nnident'',''stop_sim'');', ...
     'ListboxTop',0, ...
     'Position',[2 2 68.75 15], ...
     'String','Stop Simulation', ...
      'Tag','Pushbutton1');
      f2.stop=0;
      set(fig2,'UserData',f2);
      
      set(H.error_messages,'string','Simulating plant. Wait until sample data points are generated');
      drawnow; % pause needed to refresh the message
    
      options_ini=simset('OutputPoints','all');
      options=simset('OutputPoints','all');
      step_size=5;
      
      k=1;
      k1=1;
      % We change cursor shape.
      set(fig,'pointer','watch');
      Actual_path=pwd;
      if isempty(sim_path)
         sim_path=Actual_path;
      end
      cd(sim_path);
      tr_dat.Ts=Ts;
      min_k=ceil(min_i_int/Ts);
      while k<=sam_training %for k=1:sam_training
        if ceil((k1-1)/step_size)==(k1-1)/step_size
           newsample=rand*(max_i-min_i)+min_i;
           k1=1;
           step_size=ceil(max([min([(rand*(max_i_int-min_i_int)+min_i_int) max_i_int]) min_i_int])/Ts);
        end
        k1=k1+1;
        tr_dat.U(k,1)=newsample;
        [time,xx0,yy] = sim(sim_file,[(k-1)*Ts k*Ts],options,[[(k-1)*Ts k*Ts]' [tr_dat.U(k) tr_dat.U(k)]']);
        options.InitialState=xx0(size(xx0,1),:);
        if k==1
           tr_dat.Y(1,1)=yy(1);
        end
        tr_dat.Y(k+1,1)=yy(size(yy,1));
        tr_dat.flag(k,1)=1;
        if tr_dat.Y(k+1,1)>max_out | tr_dat.Y(k+1,1)<min_out
           options=options_ini;
           newsample=rand*(max_i-min_i)+min_i;
           k2=1;
           while k2<=1 %max_Ni_Nj
              k=k+1;
              tr_dat.U(k,1)=newsample;
              [time,xx0,yy] = sim(sim_file,[(k-1)*Ts k*Ts],options,[[(k-1)*Ts k*Ts]' [tr_dat.U(k) tr_dat.U(k)]']);
              options.InitialState=xx0(size(xx0,1),:);
              tr_dat.Y(k+1,1)=yy(size(yy,1));
              tr_dat.flag(k,1)=0;
              k2=k2+1;
           end
        end
        % 4-4-00 ODJ. We check for constant output, so we change the input.
        % We verified for constant output according to the minimum interval. 
        % We change the input if we didn't change in for last min_k*2 samples.
        % We also reset the k1 and step_size.
        if k>(min_k*2+1)
           if (abs(mean(tr_dat.Y(k-min_k+1:k+1,1))-mean(tr_dat.Y(k-min_k*2:k-min_k,1)))) < 1e-10 ...
                 & tr_dat.U(k) == tr_dat.U(k-min_k*2)
              newsample=rand*(max_i-min_i)+min_i;
              k1=2;
              step_size=ceil(max([min([(rand*(max_i_int-min_i_int)+min_i_int) max_i_int]) min_i_int])/Ts);
           end
        end
        
        if ceil(k/100)==k/100
          f2=get(fig2,'userdata');
          if f2.stop~=0
            st=sprintf('Simulation stopped by the user.\nPlease Accept or Reject Data to continue.');
            set(H.error_messages,'string',st);   
            H.Data_Available=0;
            set(fig,'UserData',H);
            sam_training=k;
            k=k+1;
            break
          end
           
          st=sprintf('Processing sample # %d of %d total samples.',k,sam_training);
          set(H.error_messages,'string',st);   
          set(f2.message,'string',st);   
          
          plot((0:k-1)*Ts,tr_dat.U(1:k),'Parent',f2.h1);
          plot((0:k-1)*Ts,tr_dat.Y(2:k+1),'Parent',f2.h2);
    
          set(get(f2.h1,'Title'),'string','Plant Input','fontweight','bold');
          set(get(f2.h2,'Title'),'string','Plant Output','fontweight','bold');
          set(get(f2.h1,'XLabel'),'string','time (s)');
          set(get(f2.h2,'XLabel'),'string','time (s)');
          
          set(fig2,'UserData',f2);
          drawnow;
        end
        k=k+1;
      end
      if ~f2.stop
         st=sprintf('Simulation concluded.\nPlease Accept or Reject Data to continue.');
         set(H.error_messages,'string',st);   
         set(f2.message,'string',st);   
      end
      set(fig,'pointer','arrow');
      cd(Actual_path);
      tr_dat.U(k,1)=newsample;         % We require U and Y have the same size.
      
      set(f2.message,'string',st);
      set(f2.accept_but,'Callback','nncontrolutil(''nnident'',''data_ok'');', ...
     'String','Accept Data');
    end
    
    set(H.Max_input,'enable','off')
    set(H.Max_input_text,'enable','off')
    set(H.Min_input,'enable','off')
    set(H.Min_input_text,'enable','off')
    set(H.max_int_edit,'enable','off')
    set(H.max_int_text,'enable','off')
    set(H.min_int_edit,'enable','off')
    set(H.min_int_text,'enable','off')
    set(H.Samples_text,'enable','off')
    set(H.Samples,'enable','off')
    set(H.Sampling_text,'enable','off')
    set(H.Sampling_time,'enable','off')
    set(H.Max_output,'enable','off')
    set(H.Max_output_text,'enable','off')
    set(H.Min_output,'enable','off')
    set(H.Min_output_text,'enable','off')
    set(H.Limit_output_data,'enable','off');
    set(H.BrowseButton,'enable','off');
    set(H.simulink_file,'enable','off');
    set(H.simulink_file_text,'enable','off');
    
    f2.Reject_but = uicontrol('Parent',fig2, ...
     'Units',H.StdUnit, ...
       'BackgroundColor',[0.752941176470588 0.752941176470588 0.752941176470588], ...
     'Callback','nncontrolutil(''nnident'',''data_NO_ok'');', ...
     'ListboxTop',0, ...
     'Position',[75 2 68.75 15], ...
     'String','Reject Data', ...
      'Tag','Pushbutton1');
    
    plot((0:sam_training-1)*Ts,tr_dat.U(1:sam_training),'Parent',f2.h1);
    plot((0:sam_training-1)*Ts,tr_dat.Y(2:sam_training+1),'Parent',f2.h2);
    set(f2.h1,'xlim',[0 (sam_training-1)*Ts]);
    set(f2.h2,'xlim',[0 (sam_training-1)*Ts]);
    
    set(get(f2.h1,'Title'),'string','Plant Input','fontweight','bold');
    set(get(f2.h2,'Title'),'string','Plant Output','fontweight','bold');
    set(get(f2.h1,'XLabel'),'string','time (s)');
    set(get(f2.h2,'XLabel'),'string','time (s)');
      
    set(fig,'userdata',H)
    set(fig2,'UserData',f2);
    save(cat(2,tempdir,'nnidentdata2.mat'));
    return;
    
  elseif strcmp(cmd,'data_ok')
    load(cat(2,tempdir,'nnidentdata2.mat'));
    delete(cat(2,tempdir,'nnidentdata2.mat'));
    delete(fig2);
  
    N2=length(tr_dat.U);
    st=sprintf('Your training data set has %d samples.\nYou can now train the network.',N2-1);
    set(H.error_messages,'string',st);   

    if H.Training_done==1
       set(H.Apply_but,'enable','on');
       set(H.OK_but,'enable','on');
       set(H.Handles.Menus.File.Save_NN,'enable','on')
       set(H.Handles.Menus.File.Save_Exit_NN,'enable','on')
    end
    set(H.Start_but,'enable','on');
    set(H.Cancel_but,'enable','on'); 
    
    H.Data_Available=1;
    if H.Data_Imported
       H.Data_Generated=0;
       set(H.Gen_data_but,'String','Erase Imported Data', ...
         'Callback','nncontrolutil(''nnident'',''erase_data'')', ...
         'TooltipString','The imported data will be erased and the Training Data section be enabled.');
    else
       H.Data_Generated=1;
       set(H.Gen_data_but,'String','Erase Generated Data', ...
         'Callback','nncontrolutil(''nnident'',''erase_data'')', ...
         'TooltipString','The generated data will be erased and the Training Data section will be enabled.');
    end
    set(fig,'userdata',H)
    
    save(cat(2,tempdir,'nnidentdata.mat'));
    return

  elseif strcmp(cmd,'continue_training')
    load(cat(2,tempdir,'nnidentdata.mat'));
    HH=msgbox({['The Neural Network is being configured.'] ['Training will start shortly.'] },H.me,'warn'); 
    delete(findobj(HH,'style','pushbutton'));
  pause(1);   % Pause works better here that drawnow.
    
    a1 = str2num(get(H.Hidden_layer_size,'string'));
    S1=get_param(arg1,'S1'); 
    if length(a1) == 0, 
       present_error(fig,H,H.Hidden_layer_size,S1,1, ...
          'You must initialize the size of the hidden layer before training the neural network.');
       delete(HH);
       return
    elseif a1<=0 | fix(a1)~=a1
       present_error(fig,H,H.Hidden_layer_size,S1,1, ...
          'You must set the size of the hidden layer to a positive integer before generating data or training the neural network');
       delete(HH);
       return
    else S1=a1; set(H.S1_ptr,'userdata',S1);  end
  
    a1 = str2num(get(H.Delayed_input,'string'));
    if (length(a1) == 0) | (a1 < 1) | (floor(a1)~=a1), 
       Ni=get_param(arg1,'Ni'); 
       present_error(fig,H,H.Delayed_input,Ni,1, ...
          'You must enter a valid number of delayed plant inputs'); 
       delete(HH);
       return
    else Ni=a1; set(H.Ni_ptr,'userdata',Ni);  end
  
    a1 = str2num(get(H.Delayed_output,'string'));
    if (length(a1) == 0) | (a1 < 0) | (floor(a1)~=a1), 
       Nj=get_param(arg1,'Nj'); 
       present_error(fig,H,H.Delayed_output,Nj,1, ...
          'You must enter a valid number of delayed plant outputs'); 
       delete(HH);
       return
    else Nj=a1; set(H.Nj_ptr,'userdata',Nj);  end
  
    a1 = get(H.trainfun_edit,'value');
    if (a1 < 1) | (a1 > 13), 
       trainfun=get_param(arg1,'trainfun'); 
       a1=strmatch(trainfun,func_index);
       present_error(fig,H,H.trainfun_edit,a1,0, ...
            'Please, correct the training function'); 
       delete(HH);
%       set(H.trainfun_edit,'value',a1);
       return
    else 
       trainfun=func_index(a1,:); 
       set_param(arg1,'trainfun',trainfun); 
       for k1=8:-1:1
           if trainfun(k1)==' '
              trainfun=trainfun(1:k1-1);
           else
              break
           end
       end
    end
  
    a1 = str2num(get(H.epochs_h,'string'));
    epochs=get_param(arg1,'epochs'); 
    if (length(a1) == 0) | (a1 < 1) | (floor(a1)~=a1), 
       present_error(fig,H,H.epochs_h,epochs,1, ...
          'You must enter a valid number of epochs before training the neural network'); 
       delete(HH);
       return
    else epochs=a1; set(H.epochs_ptr,'userdata',epochs); end
  
    Use_Previous_Weights=get(H.Use_Previous_Weights_but,'value');
    set(H.Use_Previous_Weights_ptr,'userdata',Use_Previous_Weights); 
    
    Normalize=get(H.Normalize_data,'Value');
    set(H.Normalize_ptr,'userdata',Normalize);

    set(H.In_training_ptr,'userdata',1);
  
    %  Inputs and targets are preprocessed so that minimum is -1
    %  and maximum is 1
%    if Normalize
      [U,minp,maxp,Y,mint,maxt] = premnmx(tr_dat.U,tr_dat.Y);
      set(H.minp_ptr,'userdata',minp);
      set(H.maxp_ptr,'userdata',maxp);
      set(H.mint_ptr,'userdata',mint);
      set(H.maxt_ptr,'userdata',maxt);
%   else
      % ODJ 6/30/99 We need the parameters minp,maxp,mint,maxt for latter simulations.
    if Normalize ~= 1
      Y=tr_dat.Y;
      U=tr_dat.U;
    end

    Use_Validation=get(H.Use_Validation_but,'value');
    Use_Testing=get(H.Use_Testing_but,'value');
    N2=length(U);
    if Use_Validation & Use_Testing
      N1=floor(N2/2);
      N3=floor(N2*3/4);
    elseif Use_Testing
      N1=floor(N2*3/4);
      N3=floor(N2*3/4);
    elseif Use_Validation
      N1=floor(N2*3/4);
      N3=N2;
    else
      N1=N2;
      N3=N2;
    end
    
    max_Ni_Nj=max([Ni Nj]);
    no_valid_data0=find(tr_dat.flag==0);
    % 8/27/99 ODJ flag only has information about disrrupted points. 
    % We must remove as many as delays are necessary to the Neural Network.
    no_valid_data=no_valid_data0;
    for k=1:max_Ni_Nj-1
       no_valid_data=[no_valid_data;no_valid_data0+k];
    end
    size_no_valid_data=size(no_valid_data,1);
    train_points=max_Ni_Nj:N1-1;
    valid_points=N1:N3-1;
    test_points=N3:N2-1;
    for k=1:size_no_valid_data
       train_points=train_points(find(train_points(:)~=no_valid_data(k)));
       valid_points=valid_points(find(valid_points(:)~=no_valid_data(k)));
       test_points=test_points(find(test_points(:)~=no_valid_data(k)));
    end
    
    S2=1;
    f1 = 'tansig';
    f2 = 'purelin';
    parent_function=get(H.parent_function_ptr,'userdata');
    if strcmp(parent_function,'narma_l2')
      ptr=cell(3,1);
      ttr=cell(1,1);
      vv.P=cell(3,1);
      vv.T=cell(1,1);
      tt.P=cell(3,1);
      tt.T=cell(1,1);
    
      ptr{1,1}=[Y(train_points)'];
      vv.P{1,1}=[Y(valid_points)'];
      tt.P{1,1}=[Y(test_points)'];
      for k=1:Nj-1
        ptr{1,1}=[ptr{1,1};[Y(train_points-k)']];
        vv.P{1,1}=[vv.P{1,1};Y(valid_points-k)'];
        tt.P{1,1}=[tt.P{1,1};Y(test_points-k)'];
      end
      ptr{3,1}=U(train_points)';
      vv.P{3,1}=U(valid_points)';
      tt.P{3,1}=U(test_points)';
      for k=1:Ni-1
        ptr{1,1}=[ptr{1,1};[U(train_points-k)']];
        vv.P{1,1}=[vv.P{1,1};U(valid_points-k)'];
        tt.P{1,1}=[tt.P{1,1};U(test_points-k)'];
      end
      ttr{1}=Y(train_points+1)';
      vv.T{1}=Y(valid_points+1)';
      tt.T{1}=Y(test_points+1)';
    
      ptr{2,1}=ptr{1,1};
      vv.P{2,1}=vv.P{1,1};
      tt.P{2,1}=tt.P{1,1};
      
      netn = newff(minmax([ptr{1,1} vv.P{1,1} tt.P{1,1}]),[S1 S2 S1 S2 1 1],{f1,f2,f1,f2,f2,f2},trainfun);
      netn.numInputs=2;
      netn.numInputs=3;
      netn.inputs{2}.size=netn.inputs{1}.size;
      netn.inputs{2}.range=netn.inputs{1}.range;  
      netn.inputs{3}.range=minmax(ptr{3,1});
      netn.biasConnect(5:6)=0;
      netn.layers{5}.netInputFcn='netprod';
      netn.inputConnect(3,2)=1;
      netn.inputConnect(5,3)=1;
      netn.layerConnect(6,2)=1;
      netn.layerConnect(3,2)=0;
  
      netn=initlay(netn);
    
      IW1_1=netn.IW{1,1};
      IW3_2=netn.IW{3,2};
      IW5_3=netn.IW{5,3};
      LW2_1=netn.LW{2,1};
      LW4_3=netn.LW{4,3};
      LW5_4=netn.LW{5,4};
      LW6_5=netn.LW{6,5};
      LW6_2=netn.LW{6,2};
      B1=netn.b{1};
      B2=netn.b{2};
      B3=netn.b{3};
      B4=netn.b{4};
    
      if Use_Previous_Weights & ~isempty(strvcat(get_param(arg1,'IW1_1')))
        IW1_1b=get(H.IW1_1_ptr,'userdata');
        IW3_2b=get(H.IW3_2_ptr,'userdata');
        IW5_3b=get(H.IW5_3_ptr,'userdata');
        LW2_1b=get(H.LW2_1_ptr,'userdata');
        LW4_3b=get(H.LW4_3_ptr,'userdata');
        LW5_4b=get(H.LW5_4_ptr,'userdata');
        LW6_5b=get(H.LW6_5_ptr,'userdata');
        LW6_2b=get(H.LW6_2_ptr,'userdata');
        B1b=get(H.B1_ptr,'userdata');
        B2b=get(H.B2_ptr,'userdata');
        B3b=get(H.B3_ptr,'userdata');
        B4b=get(H.B4_ptr,'userdata');
    
        IW1_1a=eval(strvcat(get_param(arg1,'IW1_1')));
        IW3_2a=eval(strvcat(get_param(arg1,'IW3_2')));
        IW5_3a=eval(strvcat(get_param(arg1,'IW5_3')));
        LW2_1a=eval(strvcat(get_param(arg1,'LW2_1')));
        LW4_3a=eval(strvcat(get_param(arg1,'LW4_3')));
        LW5_4a=eval(strvcat(get_param(arg1,'LW5_4')));
        LW6_5a=eval(strvcat(get_param(arg1,'LW6_5')));
        LW6_2a=eval(strvcat(get_param(arg1,'LW6_2')));
        B1a=eval(strvcat(get_param(arg1,'B1')));
        B2a=eval(strvcat(get_param(arg1,'B2')));
        B3a=eval(strvcat(get_param(arg1,'B3')));
        B4a=eval(strvcat(get_param(arg1,'B4')));
        if (size(IW1_1)==size(IW1_1a)) & (size(IW3_2)==size(IW3_2a)) & (size(IW5_3)==size(IW5_3a)) ...
              & (size(LW2_1)==size(LW2_1a)) & (size(LW4_3)==size(LW4_3a)) ...
              & (size(LW5_4)==size(LW5_4a)) & (size(LW6_5)==size(LW6_5a))  & (size(LW6_2)==size(LW6_2a)) ...
              & (size(B1)==size(B1a)) & (size(B2)==size(B2a)) & (size(B3)==size(B3a)) & (size(B4)==size(B4a))
           % If Weights different from last generated, we use Simulink weights.
           if (size(IW1_1)==size(IW1_1b)) & (size(IW3_2)==size(IW3_2b)) & (size(IW5_3)==size(IW5_3b)) ...
                 & (size(LW2_1)==size(LW2_1b)) & (size(LW4_3)==size(LW4_3b)) ...
                 & (size(LW5_4)==size(LW5_4b)) & (size(LW6_5)==size(LW6_5b))  & (size(LW6_2)==size(LW6_2b)) ...
                 & (size(B1)==size(B1b)) & (size(B2)==size(B2b)) & (size(B3)==size(B3b)) & (size(B4)==size(B4b))
              % We only compare IW1_1 to see if we have same values in simulink model and menu.
              cx=IW1_1b==IW1_1a;
              % Different weights, we ask which we want we prefer.
              if sum(cx(:))~=size(IW1_1(:),1)
                 if ishandle(HH)
                    delete(HH);
                 end
                 switch questdlg(...
                    {'You have a set of weights in the Simulink model and another set of weights generated in the current training process.'
                     ' ';
                     'Select which set of weights you want to use. If you select Simulink model weights, the generated weights are discarded.'
                     ' '},...
                     'Weight Selection','Simulink Model Weights','Generated Weights','Generated Weights');
                 case 'Simulink Model Weights'
                    overwriteOK = 1;
                 case 'Generated Weights'
                    overwriteOK = 0;
                 end % switch questdlg
              else
                 overwriteOK = 0;
              end
           else
              overwriteOK = 0;
           end
           if overwriteOK
              netn.IW{1,1}=IW1_1a;
              netn.IW{3,2}=IW3_2a;
              netn.IW{5,3}=IW5_3a;
              netn.LW{2,1}=LW2_1a;
              netn.LW{4,3}=LW4_3a;
              netn.LW{5,4}=LW5_4a;
              netn.LW{6,5}=LW6_5a;
              netn.LW{6,2}=LW6_2a;
              netn.b{1}=B1a;
              netn.b{2}=B2a;
              netn.b{3}=B3a;
              netn.b{4}=B4a;
           else
              netn.IW{1,1}=IW1_1b;
              netn.IW{3,2}=IW3_2b;
              netn.IW{5,3}=IW5_3b;
              netn.LW{2,1}=LW2_1b;
              netn.LW{4,3}=LW4_3b;
              netn.LW{5,4}=LW5_4b;
              netn.LW{6,5}=LW6_5b;
              netn.LW{6,2}=LW6_2b;
              netn.b{1}=B1b;
              netn.b{2}=B2b;
              netn.b{3}=B3b;
              netn.b{4}=B4b;
           end
        end
      end
    else
      ptr=[];
      vv.P=[];
      tt.P=[];
      for k=1:Nj
        ptr=[ptr;[Y(train_points-k+1)']];
        vv.P=[vv.P;Y(valid_points-k+1)'];
        tt.P=[tt.P;Y(test_points-k+1)'];
      end
      for k=1:Ni
        ptr=[ptr;[U(train_points+1-k)']];
        vv.P=[vv.P;U(valid_points-k+1)'];
        tt.P=[tt.P;U(test_points-k+1)'];
      end
      ttr=Y(train_points+1)';
      vv.T=Y(valid_points+1)';
      tt.T=Y(test_points+1)';

      netn = newff(minmax([ptr vv.P tt.P]),[S1 S2],{f1,f2},trainfun);
    
      netn2=netn;
      inputsrange=netn2.inputs{1}.range;
      iw=netn2.IW;
      netn2.inputs{1}.size=1;
      netn2.inputs{1}.range=inputsrange(Nj+1,:);
      netn2.layerconnect(1,2)=1;
      netn2.inputweights{1}.delays=[1:Ni];
      netn2.layerweights{1,2}.delays=[1:Nj];
      netn2.IW{1}=iw{1}(:,Nj+1:Ni+Nj);
      netn2.LW{1,2}=iw{1}(:,1:Nj);
  
      IW=netn2.IW{1,1};
      LW1_2=netn2.LW{1,2};
      LW2_1=netn2.LW{2,1};
      B1=netn2.b{1};
      B2=netn2.b{2};
  
      if Use_Previous_Weights & ~isempty(strvcat(get_param(arg1,'IW')))
        IWb=get(H.IW_ptr,'userdata');
        LW2_1b=get(H.LW2_1_ptr,'userdata');
        LW1_2b=get(H.LW1_2_ptr,'userdata');
        B1b=get(H.B1_ptr,'userdata');
        B2b=get(H.B2_ptr,'userdata');
        
        IW_2=eval(strvcat(get_param(arg1,'IW')));
        LW2_1_2=eval(strvcat(get_param(arg1,'LW2_1')));
        LW1_2_2=eval(strvcat(get_param(arg1,'LW1_2')));
        B1_2=eval(strvcat(get_param(arg1,'B1')));
        B2_2=eval(strvcat(get_param(arg1,'B2')));
        if (size(IW_2)==size(IW)) & (size(LW2_1_2)==size(LW2_1)) & (size(LW1_2_2)==size(LW1_2)) ...
            & (size(B1_2)==size(B1)) & (size(B2_2)==size(B2)) 
           % If Weights different from last generated, we use Simulink weights.
           if (size(IWb)==size(IW)) & (size(LW2_1b)==size(LW2_1)) & (size(LW1_2b)==size(LW1_2)) ...
               & (size(B1b)==size(B1)) & (size(B2b)==size(B2)) 
              % We only compare IW1_1 to see if we have same values in simulink model and menu.
              cx=IWb==IW_2;
              % Different weights, we ask which we want we prefer.
              if sum(cx(:))~=size(IW_2(:),1)
                 if ishandle(HH)
                    delete(HH);
                 end
                 switch questdlg(...
                    {'You have a set of weights in the Simulink model and another set of weights generated in the current training process.'
                     ' ';
                     'Select which set of weights you want to use. If you select Simulink model weights, the generated weights are discarded.'
                     ' '},...
                     'Weight Selection','Simulink Model Weights','Generated Weights','Generated Weights');
                 case 'Simulink Model Weights'
                    overwriteOK = 1;
                 case 'Generated Weights'
                    overwriteOK = 0;
                 end % switch questdlg
              else
                 overwriteOK = 0;
              end
           else
              overwriteOK = 0;
           end
           if overwriteOK
              netn.b{1}=B1_2;
              netn.b{2}=B2_2;
              netn.LW{2,1}=LW2_1_2;
              netn.IW{1,1}=[LW1_2_2 IW_2];
           else
              netn.b{1}=B1b;
              netn.b{2}=B2b;
              netn.LW{2,1}=LW2_1b;
              netn.IW{1,1}=[LW1_2b IWb];
           end
        end
      end
    end
    
       % Training function could be changed in continue training.
    a1 = get(H.trainfun_edit,'value');
    if (a1 < 1) | (a1 > 13), 
       trainfun=get_param(arg1,'trainfun'); 
       a1=strmatch(trainfun,func_index);
       present_error(fig,H,H.trainfun_edit,a1,0, ...
            'Please, correct the training function'); 
       if ishandle(HH)
          delete(HH);
       end
       return
    else 
       trainfun=func_index(a1,:); 
       set_param(arg1,'trainfun',trainfun); 
       for k1=8:-1:1
          if trainfun(k1)==' '
             trainfun=trainfun(1:k1-1);
          else
             break
          end
       end
    end
    netn.trainFcn=trainfun;
    
  end
  
  netn.trainParam.epochs = epochs;
  netn.trainParam.show = 1;
  netn.trainParam.min_grad=1e-10;
  
  set(H.error_messages,'string','Training Neural Network');
  set(fig,'pointer','watch');
  if ishandle(HH)
     delete(HH);
  end
  pause(1);            % works better than drawnow
  if ~Use_Testing & ~Use_Validation
    [netn,tr] = train(netn,ptr,ttr);
  elseif ~Use_Testing
    [netn,tr] = train(netn,ptr,ttr,[],[],vv);
  elseif ~Use_Validation
    [netn,tr] = train(netn,ptr,ttr,[],[],[],tt);
  else
    [netn,tr] = train(netn,ptr,ttr,[],[],vv,tt);
  end
  set(H.Simulating_text,'visible','off');   
  save(cat(2,tempdir,'nnidentdata.mat'));
  
  parent_function=get(H.parent_function_ptr,'userdata');
  if strcmp(parent_function,'nnpredict')
     title_fig2='NN Predictive Control';
  elseif strcmp(parent_function,'nnmodref')
     title_fig2='NN Model Reference Control';
  elseif strcmp(parent_function,'narma_l2')
     title_fig2='NN NARMA L2';
  end
  Ysim = sim(netn,ptr);
  fig2=findall(0,'type','figure','tag',cat(2,parent_function,'_train'));
  if size(fig2,1)==0, fig2=0; end

  matlab_position=get(0,'screensize');
  matlab_units=get(0,'units');
  if strcmp(matlab_units,'pixels');
     matlab_position=matlab_position*H.PointsToPixels;
  end
  if fig2==0
    fig2_position=[max([30 matlab_position(3)-410]) 90 328 335];
    fig2 = figure('Units',          H.StdUnit,...
                 'Interruptible','off', ...
                 'BusyAction','cancel', ...
                 'HandleVis','Callback', ...
                 'Name',           cat(2,'Training data for ',title_fig2),...
                 'Tag',            cat(2,parent_function,'_train'),...
                 'NumberTitle',    'off',...
                 'Position',fig2_position, ...
                 'IntegerHandle',  'off',...
                 'Toolbar',        'none');
    f2.h1=axes('Position',[0.13 0.58 0.32 0.34],'Parent',fig2);  %subplot(221);
    f2.h2=axes('Position',[0.57 0.58 0.32 0.34],'Parent',fig2);  %subplot(222);
    f2.h3=axes('Position',[0.13 0.11 0.32 0.34],'Parent',fig2);  %subplot(223);
    f2.h4=axes('Position',[0.57 0.11 0.32 0.34],'Parent',fig2);  %subplot(224);
  else
     f2=get(fig2,'userdata');
     figure(fig2);
  end         
  if strcmp(parent_function,'narma_l2')
    if Normalize
      plot((0:size(ptr{1,1},2)-1)*Ts,(ptr{3,1}+1)*(maxp-minp)/2+minp,'Parent',f2.h1);
      plot((0:size(ptr{1,1},2)-1)*Ts,(ttr{1}+1)*(maxt-mint)/2+mint,'Parent',f2.h2);
      set(f2.h2,'ylim',([min([ttr{1} Ysim{1} -1]) max([ttr{1} Ysim{1} 1])]+1)*(maxt-mint)/2+mint);
      plot((0:size(ptr{1,1},2)-1)*Ts,(ttr{1}-Ysim{1})*(maxt-mint)/2,'Parent',f2.h3);
      plot((0:size(ptr{1,1},2)-1)*Ts,(Ysim{1}+1)*(maxt-mint)/2+mint,'Parent',f2.h4);
      set(f2.h4,'ylim',([min([ttr{1} Ysim{1} -1]) max([ttr{1} Ysim{1} 1])]+1)*(maxt-mint)/2+mint);
    else
      plot((0:size(ptr{1,1},2)-1)*Ts,ptr{3,1},'Parent',f2.h1);
      plot((0:size(ptr{1,1},2)-1)*Ts,ttr{1},'Parent',f2.h2);
      set(f2.h2,'ylim',[min([ttr{1} Ysim{1} mint]) max([ttr{1} Ysim{1} maxt])]);
      plot((0:size(ptr{1,1},2)-1)*Ts,ttr{1}-Ysim{1},'Parent',f2.h3);
      plot((0:size(ptr{1,1},2)-1)*Ts,Ysim{1},'Parent',f2.h4);
      set(f2.h4,'ylim',[min([ttr{1} Ysim{1} mint]) max([ttr{1} Ysim{1} maxt])]);
    end
    set(f2.h1,'xlim',[0 (size(ptr{1,1},2)-1)*Ts]);
    set(f2.h2,'xlim',[0 (size(ptr{1,1},2)-1)*Ts]);
    set(f2.h3,'xlim',[0 (size(ptr{1,1},2)-1)*Ts]);
    set(f2.h4,'xlim',[0 (size(ptr{1,1},2)-1)*Ts]);
  else
    if Normalize
      plot((0:size(ptr,2)-1)*Ts,(ptr(Nj+1,:)+1)*(maxp-minp)/2+minp,'Parent',f2.h1);
      plot((0:size(ptr,2)-1)*Ts,(ttr+1)*(maxt-mint)/2+mint,'Parent',f2.h2);
      set(f2.h2,'ylim',([min([ttr Ysim -1]) max([ttr Ysim 1])]+1)*(maxt-mint)/2+mint);
      plot((0:size(ptr,2)-1)*Ts,(ttr-Ysim)*(maxt-mint)/2,'Parent',f2.h3);
      plot((0:size(ptr,2)-1)*Ts,(Ysim+1)*(maxt-mint)/2+mint,'Parent',f2.h4);
      set(f2.h4,'ylim',([min([ttr Ysim -1]) max([ttr Ysim 1])]+1)*(maxt-mint)/2+mint);
    else
      plot((0:size(ptr,2)-1)*Ts,ptr(Nj+1,:),'Parent',f2.h1);
      plot((0:size(ptr,2)-1)*Ts,ttr,'Parent',f2.h2);
      set(f2.h2,'ylim',[min([ttr Ysim mint]) max([ttr Ysim maxt])]);
      plot((0:size(ptr,2)-1)*Ts,ttr-Ysim,'Parent',f2.h3);
      plot((0:size(ptr,2)-1)*Ts,Ysim,'Parent',f2.h4);
      set(f2.h4,'ylim',[min([ttr Ysim mint]) max([ttr Ysim maxt])]);
    end
    set(f2.h1,'xlim',[0 (size(ptr,2)-1)*Ts]);
    set(f2.h2,'xlim',[0 (size(ptr,2)-1)*Ts]);
    set(f2.h3,'xlim',[0 (size(ptr,2)-1)*Ts]);
    set(f2.h4,'xlim',[0 (size(ptr,2)-1)*Ts]);
  end
  set(get(f2.h1,'Title'),'string','Input','fontweight','bold');
  set(get(f2.h2,'Title'),'string','Plant Output','fontweight','bold');
  set(get(f2.h3,'Title'),'string','Error','fontweight','bold');
  set(get(f2.h4,'Title'),'string','NN Output','fontweight','bold');
  set(get(f2.h3,'XLabel'),'string','time (s)');
  set(get(f2.h4,'XLabel'),'string','time (s)');
  set(fig2,'UserData',f2);


if Use_Validation
  Yvsim = sim(netn,vv.P);
  fig2=findall(0,'type','figure','tag',cat(2,parent_function,'_valid'));
  if size(fig2,1)==0, fig2=0; end
  if fig2==0
    fig2_position=[max([60 matlab_position(3)-380]) 60 328 335];
    fig2 = figure('Units',          H.StdUnit,...
                 'Interruptible','off', ...
                 'BusyAction','cancel', ...
                 'HandleVis','Callback', ...
                 'Name',           cat(2,'Validation data for ',title_fig2),...
                 'Tag',            cat(2,parent_function,'_valid'),...
                 'NumberTitle',    'off',...
                 'Position',fig2_position, ...
                 'IntegerHandle',  'off',...
                 'Toolbar',        'none');
    f2.h1=axes('Position',[0.13 0.58 0.32 0.34],'Parent',fig2);  %subplot(221);
    f2.h2=axes('Position',[0.57 0.58 0.32 0.34],'Parent',fig2);  %subplot(222);
    f2.h3=axes('Position',[0.13 0.11 0.32 0.34],'Parent',fig2);  %subplot(223);
    f2.h4=axes('Position',[0.57 0.11 0.32 0.34],'Parent',fig2);  %subplot(224);
  else
     f2=get(fig2,'userdata');
     figure(fig2);
  end            
  if strcmp(parent_function,'narma_l2')
    if Normalize
      plot((0:size(vv.P{1,1},2)-1)*Ts,(vv.P{3,1}+1)*(maxp-minp)/2+minp,'Parent',f2.h1);
      plot((0:size(vv.P{1,1},2)-1)*Ts,(vv.T{1}+1)*(maxt-mint)/2+mint,'Parent',f2.h2);
      set(f2.h2,'ylim',([min([vv.T{1} Yvsim{1} -1]) max([vv.T{1} Yvsim{1} 1])]+1)*(maxt-mint)/2+mint);
      plot((0:size(vv.P{1,1},2)-1)*Ts,(vv.T{1}-Yvsim{1})*(maxt-mint)/2,'Parent',f2.h3);
      plot((0:size(vv.P{1,1},2)-1)*Ts,(Yvsim{1}+1)*(maxt-mint)/2+mint,'Parent',f2.h4);
      set(f2.h4,'ylim',([min([vv.T{1} Yvsim{1} -1]) max([vv.T{1} Yvsim{1} 1])]+1)*(maxt-mint)/2+mint);
    else
      plot((0:size(vv.P{1,1},2)-1)*Ts,vv.P{3,1},'Parent',f2.h1);
      plot((0:size(vv.P{1,1},2)-1)*Ts,vv.T{1},'Parent',f2.h2);
      set(f2.h2,'ylim',[min([vv.T{1} Yvsim{1} mint]) max([vv.T{1} Yvsim{1} maxt])]);
      plot((0:size(vv.P{1,1},2)-1)*Ts,vv.T{1}-Yvsim{1},'Parent',f2.h3);
      plot((0:size(vv.P{1,1},2)-1)*Ts,Yvsim{1},'Parent',f2.h4);
      set(f2.h4,'ylim',[min([vv.T{1} Yvsim{1} mint]) max([vv.T{1} Yvsim{1} maxt])]);
    end
    set(f2.h1,'xlim',[0 (size(vv.P{1,1},2)-1)*Ts]);
    set(f2.h2,'xlim',[0 (size(vv.P{1,1},2)-1)*Ts]);
    set(f2.h3,'xlim',[0 (size(vv.P{1,1},2)-1)*Ts]);
    set(f2.h4,'xlim',[0 (size(vv.P{1,1},2)-1)*Ts]);
  else
    if Normalize
      plot((0:size(vv.P,2)-1)*Ts,(vv.P(Nj+1,:)+1)*(maxp-minp)/2+minp,'Parent',f2.h1);
      plot((0:size(vv.P,2)-1)*Ts,(vv.T+1)*(maxt-mint)/2+mint,'Parent',f2.h2);
      set(f2.h2,'ylim',([min([vv.T Yvsim -1]) max([vv.T Yvsim 1])]+1)*(maxt-mint)/2+mint);
      plot((0:size(vv.P,2)-1)*Ts,(vv.T-Yvsim)*(maxt-mint)/2,'Parent',f2.h3);
      plot((0:size(vv.P,2)-1)*Ts,(Yvsim+1)*(maxt-mint)/2+mint,'Parent',f2.h4);
      set(f2.h4,'ylim',([min([vv.T Yvsim -1]) max([vv.T Yvsim 1])]+1)*(maxt-mint)/2+mint);
    else
      plot((0:size(vv.P,2)-1)*Ts,vv.P(Nj+1,:),'Parent',f2.h1);
      plot((0:size(vv.P,2)-1)*Ts,vv.T,'Parent',f2.h2);
      set(f2.h2,'ylim',[min([vv.T Yvsim mint]) max([vv.T Yvsim maxt])]);
      plot((0:size(vv.P,2)-1)*Ts,vv.T-Yvsim,'Parent',f2.h3);
      plot((0:size(vv.P,2)-1)*Ts,Yvsim,'Parent',f2.h4);
      set(f2.h4,'ylim',[min([vv.T Yvsim mint]) max([vv.T Yvsim maxt])]);
    end
    set(f2.h1,'xlim',[0 (size(vv.P,2)-1)*Ts]);
    set(f2.h2,'xlim',[0 (size(vv.P,2)-1)*Ts]);
    set(f2.h3,'xlim',[0 (size(vv.P,2)-1)*Ts]);
    set(f2.h4,'xlim',[0 (size(vv.P,2)-1)*Ts]);
  end
  set(get(f2.h1,'Title'),'string','Input','fontweight','bold');
  set(get(f2.h2,'Title'),'string','Plant Output','fontweight','bold');
  set(get(f2.h3,'Title'),'string','Error','fontweight','bold');
  set(get(f2.h4,'Title'),'string','NN Output','fontweight','bold');
  set(get(f2.h3,'XLabel'),'string','time (s)');
  set(get(f2.h4,'XLabel'),'string','time (s)');
  set(fig2,'UserData',f2);
end
  
if Use_Testing
  [Ytsim,Pf,Af] = sim(netn,tt.P);
  fig2=findall(0,'type','figure','tag',cat(2,parent_function,'_test'));
  if size(fig2,1)==0, fig2=0; end
  if fig2==0
    fig2_position=[max([90 matlab_position(3)-350]) 30 328 335];
    fig2 = figure('Units',          H.StdUnit,...
                 'Interruptible','off', ...
                 'BusyAction','cancel', ...
                 'HandleVis','Callback', ...
                 'Name',           cat(2,'Testing data for ',title_fig2),...
                 'Tag',            cat(2,parent_function,'_test'),...
                 'NumberTitle',    'off',...
                 'Position',fig2_position, ...
                 'IntegerHandle',  'off',...
                 'Toolbar',        'none');
    f2.h1=axes('Position',[0.13 0.58 0.32 0.34],'Parent',fig2);  %subplot(221);
    f2.h2=axes('Position',[0.57 0.58 0.32 0.34],'Parent',fig2);  %subplot(222);
    f2.h3=axes('Position',[0.13 0.11 0.32 0.34],'Parent',fig2);  %subplot(223);
    f2.h4=axes('Position',[0.57 0.11 0.32 0.34],'Parent',fig2);  %subplot(224);
  else
     f2=get(fig2,'userdata');
     figure(fig2);
  end            
  if strcmp(parent_function,'narma_l2')
    if Normalize
      plot((0:size(tt.P{1,1},2)-1)*Ts,(tt.P{3,1}+1)*(maxp-minp)/2+minp,'Parent',f2.h1);
      plot((0:size(tt.P{1,1},2)-1)*Ts,(tt.T{1}+1)*(maxt-mint)/2+mint,'Parent',f2.h2);
      set(f2.h2,'ylim',([min([tt.T{1} Ytsim{1} -1]) max([tt.T{1} Ytsim{1} 1])]+1)*(maxt-mint)/2+mint);
      plot((0:size(tt.P{1,1},2)-1)*Ts,(tt.T{1}-Ytsim{1})*(maxt-mint)/2,'Parent',f2.h3);
      plot((0:size(tt.P{1,1},2)-1)*Ts,(Ytsim{1}+1)*(maxt-mint)/2+mint,'Parent',f2.h4);
      set(f2.h4,'ylim',([min([tt.T{1} Ytsim{1} -1]) max([tt.T{1} Ytsim{1} 1])]+1)*(maxt-mint)/2+mint);
    else
      plot((0:size(tt.P{1,1},2)-1)*Ts,tt.P{3,1},'Parent',f2.h1);
      plot((0:size(tt.P{1,1},2)-1)*Ts,tt.T{1},'Parent',f2.h2);
      set(f2.h2,'ylim',[min([tt.T{1} Ytsim{1} mint]) max([tt.T{1} Ytsim{1} maxt])]);
      plot((0:size(tt.P{1,1},2)-1)*Ts,tt.T{1}-Ytsim{1},'Parent',f2.h3);
      plot((0:size(tt.P{1,1},2)-1)*Ts,Ytsim{1},'Parent',f2.h4);
      set(f2.h4,'ylim',[min([tt.T{1} Ytsim{1} mint]) max([tt.T{1} Ytsim{1} maxt])]);
    end
    set(f2.h1,'xlim',[0 (size(tt.P{1,1},2)-1)*Ts]);
    set(f2.h2,'xlim',[0 (size(tt.P{1,1},2)-1)*Ts]);
    set(f2.h3,'xlim',[0 (size(tt.P{1,1},2)-1)*Ts]);
    set(f2.h4,'xlim',[0 (size(tt.P{1,1},2)-1)*Ts]);
  else
    if Normalize
      plot((0:size(tt.P,2)-1)*Ts,(tt.P(Nj+1,:)+1)*(maxp-minp)/2+minp,'Parent',f2.h1);
      plot((0:size(tt.P,2)-1)*Ts,(tt.T+1)*(maxt-mint)/2+mint,'Parent',f2.h2);
      set(f2.h2,'ylim',([min([tt.T Ytsim -1]) max([tt.T Ytsim 1])]+1)*(maxt-mint)/2+mint);
      plot((0:size(tt.P,2)-1)*Ts,(tt.T-Ytsim)*(maxt-mint)/2,'Parent',f2.h3);
      plot((0:size(tt.P,2)-1)*Ts,(Ytsim+1)*(maxt-mint)/2+mint,'Parent',f2.h4);
      set(f2.h4,'ylim',([min([tt.T Ytsim -1]) max([tt.T Ytsim 1])]+1)*(maxt-mint)/2+mint);
    else
      plot((0:size(tt.P,2)-1)*Ts,tt.P(Nj+1,:),'Parent',f2.h1);
      plot((0:size(tt.P,2)-1)*Ts,tt.T,'Parent',f2.h2);
      set(f2.h2,'ylim',[min([tt.T Ytsim mint]) max([tt.T Ytsim maxt])]);
      plot((0:size(tt.P,2)-1)*Ts,tt.T-Ytsim,'Parent',f2.h3);
      plot((0:size(tt.P,2)-1)*Ts,Ytsim,'Parent',f2.h4);
      set(f2.h4,'ylim',[min([tt.T Ytsim mint]) max([tt.T Ytsim maxt])]);
    end
    set(f2.h1,'xlim',[0 (size(tt.P,2)-1)*Ts]);
    set(f2.h2,'xlim',[0 (size(tt.P,2)-1)*Ts]);
    set(f2.h3,'xlim',[0 (size(tt.P,2)-1)*Ts]);
    set(f2.h4,'xlim',[0 (size(tt.P,2)-1)*Ts]);
  end
  set(get(f2.h1,'Title'),'string','Input','fontweight','bold');
  set(get(f2.h2,'Title'),'string','Plant Output','fontweight','bold');
  set(get(f2.h3,'Title'),'string','Error','fontweight','bold');
  set(get(f2.h4,'Title'),'string','NN Output','fontweight','bold');
  set(get(f2.h3,'XLabel'),'string','time (s)');
  set(get(f2.h4,'XLabel'),'string','time (s)');
  set(fig2,'UserData',f2);
end

  if strcmp(parent_function,'narma_l2')
    IW1_1=netn.IW{1,1};
    IW3_2=netn.IW{3,2};
    IW5_3=netn.IW{5,3};
    LW2_1=netn.LW{2,1};
    LW4_3=netn.LW{4,3};
    LW5_4=netn.LW{5,4};
    LW6_5=netn.LW{6,5};
    LW6_2=netn.LW{6,2};
    B1=netn.b{1};
    B2=netn.b{2};
    B3=netn.b{3};
    B4=netn.b{4};
   
    set(H.IW1_1_ptr,'userdata',IW1_1);
    set(H.IW3_2_ptr,'userdata',IW3_2);
    set(H.IW5_3_ptr,'userdata',IW5_3);
    set(H.LW2_1_ptr,'userdata',LW2_1);
    set(H.LW4_3_ptr,'userdata',LW4_3);
    set(H.LW5_4_ptr,'userdata',LW5_4);
    set(H.LW6_5_ptr,'userdata',LW6_5);
    set(H.LW6_2_ptr,'userdata',LW6_2);
    set(H.B1_ptr,'userdata',B1);
    set(H.B2_ptr,'userdata',B2);
    set(H.B3_ptr,'userdata',B3);
    set(H.B4_ptr,'userdata',B4);
  else
    netn2=netn;
    inputsrange=netn2.inputs{1}.range;
    iw=netn2.IW;
    netn2.inputs{1}.size=1;
    netn2.inputs{1}.range=inputsrange(Nj+1,:);
    netn2.layerconnect(1,2)=1;
    netn2.inputweights{1}.delays=[1:Ni];
    netn2.layerweights{1,2}.delays=[1:Nj];
    netn2.IW{1}=iw{1}(:,Nj+1:Ni+Nj);
    netn2.LW{1,2}=iw{1}(:,1:Nj);
    netn2.layerweights{1,2}.learnParam='learngdm';
  
    IW=netn2.IW{1,1};
    LW1_2=netn2.LW{1,2};
    LW2_1=netn2.LW{2,1};
    B1=netn2.b{1};
    B2=netn2.b{2};
  
    set(H.IW_ptr,'userdata',IW);
    set(H.LW1_2_ptr,'userdata',LW1_2);
    set(H.LW2_1_ptr,'userdata',LW2_1);
    set(H.B1_ptr,'userdata',B1);
    set(H.B2_ptr,'userdata',B2);
  end
  
  set(H.error_messages,'string','Training complete. You can generate or import new data, continue training or save results by selecting OK or Apply.');
  
  H.Training_done=1;
  set(H.Apply_but,'enable','on');
  set(H.OK_but,'enable','on');
  set(H.Handles.Menus.File.Save_NN,'enable','on')
  set(H.Handles.Menus.File.Save_Exit_NN,'enable','on')
  set(H.Start_but,'enable','on');
  set(H.Cancel_but,'enable','on'); 
  
  set(H.Use_Previous_Weights_ptr,'userdata',1);
  set(H.Use_Previous_Weights_but,'value',1);
  
  set(H.In_training_ptr,'userdata',0);
  set(fig,'userdata',H,'pointer','arrow');
  figure(fig);
  
elseif strcmp(cmd,'stop_sim')
  fig2=findall(0,'type','figure','tag','nnidentdata');
  if size(fig2,1)==0, fig2=0; end
  f2=get(fig2,'userdata');
  f2.stop=1;
  set(fig2,'UserData',f2);
  return;
       
elseif (strcmp(cmd,'apply') | strcmp(cmd,'ok')) & (fig)
  if get(H.In_training_ptr,'userdata')~=0
     return
  end
  
  arg1=get(H.gcbh_ptr,'userdata');
  
  S1=get(H.S1_ptr,'userdata');
  sim_file=get(H.sim_file_ptr,'userdata');
  Ts=get(H.Ts_ptr,'userdata');
  Ni=get(H.Ni_ptr,'userdata');
  Nj=get(H.Nj_ptr,'userdata');
  Use_Previous_Weights = get(H.Use_Previous_Weights_ptr,'userdata');
  Use_Validation=get(H.Use_Validation_but,'value');
  Use_Testing=get(H.Use_Testing_but,'value');
  max_i=get(H.max_i_ptr,'userdata');
  min_i=get(H.min_i_ptr,'userdata');
  max_i_int=get(H.max_i_int_ptr,'userdata');
  min_i_int=get(H.min_i_int_ptr,'userdata');
  sam_training=get(H.sam_training_ptr,'userdata');
  epochs=get(H.epochs_ptr,'userdata');
  
  parent_function=get(H.parent_function_ptr,'userdata');
  if strcmp(parent_function,'narma_l2')
    IW1_1=get(H.IW1_1_ptr,'userdata');
    IW3_2=get(H.IW3_2_ptr,'userdata');
    IW5_3=get(H.IW5_3_ptr,'userdata');
    LW2_1=get(H.LW2_1_ptr,'userdata');
    LW4_3=get(H.LW4_3_ptr,'userdata');
    LW5_4=get(H.LW5_4_ptr,'userdata');
    LW6_5=get(H.LW6_5_ptr,'userdata');
    LW6_2=get(H.LW6_2_ptr,'userdata');
    B1=get(H.B1_ptr,'userdata');
    B2=get(H.B2_ptr,'userdata');
    B3=get(H.B3_ptr,'userdata');
    B4=get(H.B4_ptr,'userdata');
    
    set_param(arg1,'IW1_1',mat2str(IW1_1,20));  
    set_param(arg1,'IW3_2',mat2str(IW3_2,20));  
    set_param(arg1,'IW5_3',mat2str(IW5_3,20));  
    set_param(arg1,'LW2_1',mat2str(LW2_1,20));  
    set_param(arg1,'LW4_3',mat2str(LW4_3,20));  
    set_param(arg1,'LW5_4',mat2str(LW5_4,20));  
    set_param(arg1,'LW6_5',mat2str(LW6_5,20));  
    set_param(arg1,'LW6_2',mat2str(LW6_2,20));  
    set_param(arg1,'B1',mat2str(B1,20));  
    set_param(arg1,'B2',mat2str(B2,20));  
    set_param(arg1,'B3',mat2str(B3,20));  
    set_param(arg1,'B4',mat2str(B4,20));  
  else
    IW=get(H.IW_ptr,'userdata');
    LW2_1=get(H.LW2_1_ptr,'userdata');
    LW1_2=get(H.LW1_2_ptr,'userdata');
    B1=get(H.B1_ptr,'userdata');
    B2=get(H.B2_ptr,'userdata');
    
    set_param(arg1,'IW',mat2str(IW,20));  
    set_param(arg1,'LW1_2',mat2str(LW1_2,20));  
    set_param(arg1,'LW2_1',mat2str(LW2_1,20));  
    set_param(arg1,'B1',mat2str(B1,20));  
    set_param(arg1,'B2',mat2str(B2,20));  
  end
 
  minp=get(H.minp_ptr,'userdata');
  maxp=get(H.maxp_ptr,'userdata');
  mint=get(H.mint_ptr,'userdata');
  maxt=get(H.maxt_ptr,'userdata');
  Normalize=get(H.Normalize_ptr,'userdata');
  Limit_output=get(H.Limit_output_data,'value');
  max_out=get(H.max_out_ptr,'userdata');
  min_out=get(H.min_out_ptr,'userdata');
  
  set_param(arg1,'S1',num2str(S1)); 
  set_param(arg1,'sim_file',sim_file); 
  set_param(arg1,'Ts',num2str(Ts)); 
  set_param(arg1,'Ni',num2str(Ni)); 
  set_param(arg1,'Nj',num2str(Nj)); 
  set_param(arg1,'Use_Previous_Weights',num2str(Use_Previous_Weights));     
  set_param(arg1,'Use_Validation',num2str(Use_Validation)); 
  set_param(arg1,'Use_Testing',num2str(Use_Testing)); 
  set_param(arg1,'max_i',num2str(max_i)); 
  set_param(arg1,'min_i',num2str(min_i));
  set_param(arg1,'max_i_int',num2str(max_i_int)); 
  set_param(arg1,'min_i_int',num2str(min_i_int));
  set_param(arg1,'sam_training',num2str(sam_training));
  set_param(arg1,'epochs',num2str(epochs)); 
  set_param(arg1,'minp',num2str(minp,20));  
  set_param(arg1,'maxp',num2str(maxp,20));  
  set_param(arg1,'mint',num2str(mint,20));  
  set_param(arg1,'maxt',num2str(maxt,20));  
  set_param(arg1,'Normalize',num2str(Normalize));  
  set_param(arg1,'limit_output',num2str(Limit_output));  
  set_param(arg1,'max_output',num2str(max_out));  
  set_param(arg1,'min_output',num2str(min_out));  
  
  if strcmp(cmd,'ok')
    if ~strcmp(parent_function,'narma_l2')
      arg2=get(H.gcb_ptr,'userdata');
      feval(parent_function,'',arg1,arg2,'nnident');
    end
    delete(fig)
    if exist(cat(2,tempdir,'nnidentdata.mat'))
       delete(cat(2,tempdir,'nnidentdata.mat'));
    end
  end
end

function present_error(fig,H,text_field,field_value,field_type,message)

if H.Data_Available
   set(H.Start_but,'enable','on')
end
if H.Training_done
   set(H.OK_but,'enable','on')
   set(H.Apply_but,'enable','on')
   set(H.Handles.Menus.File.Save_NN,'enable','on')
   set(H.Handles.Menus.File.Save_Exit_NN,'enable','on')
end
set(H.Cancel_but,'enable','on');
if text_field~=0
   if field_type      % Number
      set(text_field,'string',num2str(field_value));
   else               % ASCII or No change.
      set(text_field,'string',field_value);
   end
else
   text_field=0;
end   
set(H.error_messages,'string',message);
errordlg(message,'Plant Identification Warning','modal');
set(fig,'pointer','arrow');