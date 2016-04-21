function nnexport(cmd,arg1,arg2,arg3)
%NNEXPORT Neural Network Export GUI for the Neural Network Controller Toolbox.
%
%  Synopsis
%
%    nnexport(cmd,arg1,arg2,arg3)
%
%  Warning!!
%
%    This function may be altered or removed in future
%    releases of the Neural Network Toolbox. We recommend
%    you do not write code which calls this function.
%    This function is generally being called from a Simulink block.

% Orlando De Jesus, Martin Hagan, 1-25-00
% Copyright 1992-2002 The MathWorks, Inc.
% $Revision: 1.5 $ $Date: 2002/04/14 21:10:52 $


% CONSTANTS
tag= 'Export_NN_Par_fig';

% DEFAULTS
if nargin == 0, cmd = ''; else cmd = lower(cmd); end

% FIND WINDOW IF IT EXISTS
fig=findall(0,'type','figure','tag',tag);
if (size(fig,1)==0), fig=0; end

if length(get(fig,'children')) == 0, fig = 0; end

if fig
   ud = get(fig,'userdata');
end

if strcmp(cmd,'init')
  if fig==0  
    StdColor = get(0,'DefaultFigureColor');
    PointsToPixels = 72/get(0,'ScreenPixelsPerInch');
    StdUnit = 'points';
    ud.Handles.parent=arg1;
    ud.Handles.type_net=arg2;

    if strcmp(ud.Handles.type_net,'nnpredict')
       me = 'Export Neural Network Plant Parameters';
    else
       me = 'Export Neural Network Plant-Controller Parameters';
    end
    
%---Open an Export figure
    fig = figure('Color',StdColor, ...
     'Interruptible','off', ...
     'BusyAction','cancel', ...
     'HandleVis','Callback', ...
    'MenuBar','none', ...
     'Visible','on',...
     'Name',me, ...
     'IntegerHandle','off',...
     'NumberTitle','off', ...
     'Resize', 'off', ...
     'WindowStyle','modal',...
     'Position',[193 127 305 250], ...
    'Tag',tag);

%---Add the Export List controls
    b = uicontrol('Parent',fig, ...
    'Units',StdUnit, ...
      'BackgroundColor',StdColor, ...
      'Position',PointsToPixels*[5 78 295 149], ...
     'Style','frame');
    b = uicontrol('Parent',fig, ...
    'Units',StdUnit, ...
      'BackgroundColor',StdColor, ...
    'Position',PointsToPixels*[106 215 56 19], ...
    'String','Select', ...
    'Style','text');
    ud.Handles.allv = uicontrol('Parent',fig, ...
      'Units',StdUnit, ...
    'BackgroundColor',StdColor, ...
     'Callback','nncontrolutil(''nnexport'',''allv'',gcbf);',...
    'ListboxTop',0, ...
    'Position',PointsToPixels*[14 188 120 20], ...
    'String','All Variables', ...
    'Style','radiobutton', ...
     'ToolTipStr','If selected, all variables of the neural network controller block will be exported.',...
     'Tag','Radiobutton1');
    if ~strcmp(ud.Handles.type_net,'nnpredict')
       ud.Handles.nncontrol = uicontrol('Parent',fig, ...
       'Units',StdUnit, ...
       'BackgroundColor',StdColor, ...
       'ListboxTop',0, ...
       'Position',PointsToPixels*[14 155 199 20], ...
       'String','Neural Network Controller Weights', ...
       'Style','radiobutton', ...
        'Tag','Radiobutton1', ...
        'ToolTipStr','If selected, the neural network controller weights will be exported.',...
        'Value',1);
       ud.Handles.nncontroledit = uicontrol('Parent',fig, ...
       'Units','points', ...
         'BackgroundColor',[1 1 1], ...
       'ListboxTop',0, ...
       'Position',PointsToPixels*[200 155 90 20], ...
       'String','netn_contr', ...
       'Style','edit', ...
        'ToolTipStr','You can select the name for the neural network controller object.',...
       'Tag','EditText1');
    end
    ud.Handles.nnplant = uicontrol('Parent',fig, ...
    'Units',StdUnit, ...
    'BackgroundColor',StdColor, ...
    'ListboxTop',0, ...
    'Position',PointsToPixels*[14 121 204 20], ...
    'String','Neural Network Plant Weights', ...
    'Style','radiobutton', ...
    'Tag','Radiobutton1', ...
     'ToolTipStr','If selected, the neural network plant weights will be exported.',...
     'Value',1);
    ud.Handles.nnplantedit = uicontrol('Parent',fig, ...
    'Units','points', ...
    'BackgroundColor',[1 1 1], ...
    'ListboxTop',0, ...
    'Position',PointsToPixels*[200 121 90 20], ...
    'String','netn_plant', ...
    'Style','edit', ...
     'ToolTipStr','You can select the name for the neural network plant object.',...
    'Tag','EditText1');
    ud.Handles.nnobject = uicontrol('Parent',fig, ...
    'Units',StdUnit, ...
    'BackgroundColor',StdColor, ...
     'Callback','nncontrolutil(''nnexport'',''obj_def'',gcbf);',...
    'ListboxTop',0, ...
    'Position',PointsToPixels*[14 88 204 20], ...
    'String','Use Neural Network Object Definition', ...
    'Style','checkbox', ...
    'Tag','checkbox1', ...
     'ToolTipStr','If selected, the neural network controller and plant will be exported using the network object definition, otherwise an independent variable will be created for each weight.',...
     'Value',1);

  %---Add the window buttons
    b = uicontrol('Parent',fig, ...
    'Units',StdUnit, ...
    'BackgroundColor',StdColor, ...
    'Position',PointsToPixels*[5 5 295 70], ...
    'Style','frame');
    ud.Handles.DiskButton = uicontrol('Parent',fig, ...
    'Units',StdUnit, ...
    'Position',PointsToPixels*[14 41 130 20], ...
     'Callback','nncontrolutil(''nnexport'',''disk'',gcbf);',...
    'String','Export to Disk', ...
     'ToolTipStr','Export the selected variables to a file.',...
    'Tag','DiskButton');
    ud.Handles.WorkspaceButton = uicontrol('Parent',fig, ...
    'Units',StdUnit, ...
    'Position',PointsToPixels*[14 14 130 20], ...
     'Callback','nncontrolutil(''nnexport'',''workspace'',gcbf);',...
    'String','Export to Workspace', ...
     'ToolTipStr','Export the selected variables to the MATLAB workspace.',...
    'Tag','WorkspaceButton');
    ud.Handles.SimulinkButton = uicontrol('Parent',fig, ...
    'Units',StdUnit, ...
    'Position',PointsToPixels*[160 41 130 20], ...
     'Callback','nncontrolutil(''nnexport'',''simulink'',gcbf);',...
    'String','Export to Simulink', ...
     'ToolTipStr','Export the selected variables into a new Simulink block (only valid for NN objects).',...
    'Tag','SimulinkButton');
    ud.Handles.HelpButton= uicontrol('Parent',fig, ...
    'Units',StdUnit, ...
    'Position',PointsToPixels*[160 14 60 20], ...
     'Callback','nncontrolutil(''nnexport'',''windowstyle'',gcbf,''normal'');nncontrolutil(''nnexporthelp'',''main'',gcbf);',...
    'String','Help', ...
     'ToolTipStr','Call the Export Network help window.',...
    'Tag','HelpButton');
    ud.Handles.CancelButton = uicontrol('Parent',fig, ...
    'Units',StdUnit, ...
     'Position',PointsToPixels*[230 14 60 20], ...
     'Callback','nncontrolutil(''nnexport'',''cancel'',gcbf);',...
    'String','Cancel', ...
     'ToolTipStr','Discard the export action and close this menu.',...
    'Tag','CancelButton');

  end
  set(fig,'UserData',ud,'visible','on','WindowStyle','modal')
  
elseif strcmp(cmd,'cancel')
   delete(fig)
   return;
   
elseif strcmp(cmd,'windowstyle')
   set(fig,'visible','on','WindowStyle',arg2)
   return;
   
elseif strcmp(cmd,'obj_def')
   if get(ud.Handles.nnobject,'value')
      if ~strcmp(ud.Handles.type_net,'nnpredict')
         set(ud.Handles.nncontroledit,'enable','on');
      end
      set(ud.Handles.nnplantedit,'enable','on');
      set(ud.Handles.SimulinkButton,'enable','on');
   else
      if ~strcmp(ud.Handles.type_net,'nnpredict')
         set(ud.Handles.nncontroledit,'enable','off');
      end
      set(ud.Handles.nnplantedit,'enable','off');
      set(ud.Handles.SimulinkButton,'enable','off');
   end
   
elseif strcmp(cmd,'allv')
    allv=get(ud.Handles.allv,'value');
    if allv
       if ~strcmp(ud.Handles.type_net,'nnpredict')
          set(ud.Handles.nncontrol,'enable','off');
       end
       set(ud.Handles.nnplant,'enable','off');
    else
       if ~strcmp(ud.Handles.type_net,'nnpredict')
          set(ud.Handles.nncontrol,'enable','on');
       end
       set(ud.Handles.nnplant,'enable','on');
    end
    
elseif strcmp(cmd,'workspace') | strcmp(cmd,'simulink') | strcmp(cmd,'disk')
    % We check if some option selected.
   allv=get(ud.Handles.allv,'value');
   if ~strcmp(ud.Handles.type_net,'nnpredict')
      nnco=get(ud.Handles.nncontrol,'value');
   else
      nnco=0;
   end
   nnpl=get(ud.Handles.nnplant,'value');
   if allv==0 & nnco==0 & nnpl==0,
      warndlg('There are no variables to export.','Export Warning','modal');
      return      
   end
   
   overwrite=0;
   w = evalin('base','whos');
   Wname = {w.name};
   
   nnob=get(ud.Handles.nnobject,'value');
   
   figure_variables=get(ud.Handles.parent,'userdata');
   parent_simulink=get(figure_variables.gcbh_ptr,'userdata');
      
   % We check for Controller and object structure.
   if (nnco | nnpl | allv) & nnob
      mint=str2num(get_param(parent_simulink,'mint'));
      maxt=str2num(get_param(parent_simulink,'maxt'));
      minp=str2num(get_param(parent_simulink,'minp'));
      maxp=str2num(get_param(parent_simulink,'maxp'));
      Nj=str2num(get_param(parent_simulink,'Nj'));
      Ni=str2num(get_param(parent_simulink,'Ni'));
  
      S2=1;
      f1 = 'tansig';
      f2 = 'purelin';
      if strcmp(ud.Handles.type_net,'narma_l2')
         S1=str2num(get_param(parent_simulink,'S1'));
         
         IW1_1=eval(strvcat(get_param(parent_simulink,'IW1_1')));
         IW3_2=eval(strvcat(get_param(parent_simulink,'IW3_2')));
         IW5_3=eval(strvcat(get_param(parent_simulink,'IW5_3')));
         LW2_1=eval(strvcat(get_param(parent_simulink,'LW2_1')));
         LW4_3=eval(strvcat(get_param(parent_simulink,'LW4_3')));
         LW5_4=eval(strvcat(get_param(parent_simulink,'LW5_4')));
         LW6_5=eval(strvcat(get_param(parent_simulink,'LW6_5')));
         LW6_2=eval(strvcat(get_param(parent_simulink,'LW6_2')));
         B1=eval(strvcat(get_param(parent_simulink,'B1')));
         B2=eval(strvcat(get_param(parent_simulink,'B2')));
         B3=eval(strvcat(get_param(parent_simulink,'B3')));
         B4=eval(strvcat(get_param(parent_simulink,'B4')));
      
         mM=[mint maxt];
         for k=1:Nj-1
            mM=[mM;mint maxt];
         end
         for k=1:Ni-1
            mM=[mM;minp maxp];
         end
         if (nnco | allv) & nnob
            netn_contr = newff(mM,[S1 S2 S1 S2 1],{f1,f2,f1,'netinv',f2},'trainlm');
  
            netn_contr.numInputs=2;
            netn_contr.numInputs=3;
            netn_contr.inputs{2}.size=netn_contr.inputs{1}.size;
            netn_contr.inputs{2}.range=mM;  
            netn_contr.inputs{3}.range=[mint maxt];
            netn_contr.biasConnect(5)=0;
            netn_contr.inputConnect(3,2)=1;
            netn_contr.inputConnect(5,3)=1;
            netn_contr.layerConnect(3,2)=0;
            netn_contr.layerConnect(5,2)=1;
 
            netn_contr.IW{1,1}=IW1_1;
            netn_contr.b{1}=B1;
            netn_contr.IW{3,2}=IW3_2;
            netn_contr.IW{5,3}=1;
            netn_contr.LW{2,1}=-LW2_1;
            netn_contr.b{2}=-B2;       % This creates -f(x)
            netn_contr.LW{4,3}=LW4_3;
            netn_contr.b{3}=B3;
            netn_contr.b{4}=B4;
            netn_contr.LW{5,4}=LW6_5*LW5_4*IW5_3;
            netn_contr.LW{5,2}=LW6_2;
            
            name_netn_contr=get(ud.Handles.nncontroledit,'string');
            if ~isempty(strmatch(name_netn_contr,...
               Wname,'exact')),
               overwrite=1;
            end
         end
         if (nnpl | allv) & nnob
            netn_plant = newff(mM,[S1 S2 S1 S2 1 1],{f1,f2,f1,f2,f2,f2},'trainlm');
  
            netn_plant.numInputs=2;
            netn_plant.numInputs=3;
            netn_plant.inputs{2}.size=netn_plant.inputs{1}.size;
            netn_plant.inputs{2}.range=mM;  
            netn_plant.inputs{3}.range=[minp maxp];
            netn_plant.biasConnect(5:6)=0;
            netn_plant.layers{5}.netInputFcn='netprod';
            netn_plant.inputConnect(3,2)=1;
            netn_plant.inputConnect(5,3)=1;
            netn_plant.layerConnect(6,2)=1;
            netn_plant.layerConnect(3,2)=0;
 
            netn_plant.IW{1,1}=IW1_1;
            netn_plant.IW{3,2}=IW3_2;
            netn_plant.IW{5,3}=IW5_3;
            netn_plant.LW{2,1}=LW2_1;
            netn_plant.LW{4,3}=LW4_3;
            netn_plant.LW{5,4}=LW5_4;
            netn_plant.LW{6,5}=LW6_5;
            netn_plant.LW{6,2}=LW6_2;
            netn_plant.b{1}=B1;
            netn_plant.b{2}=B2;
            netn_plant.b{3}=B3;
            netn_plant.b{4}=B4;
            
            name_netn_plant=get(ud.Handles.nnplantedit,'string');
            if ~isempty(strmatch(name_netn_plant,...
               Wname,'exact')),
               overwrite=1;
            end
         end
      else   % nnpredict or nn_modref
         if (nnco | allv) & nnob & ~strcmp(ud.Handles.type_net,'nnpredict')
            min_r=str2num(get_param(parent_simulink,'min_r'));
            max_r=str2num(get_param(parent_simulink,'max_r'));
            Njc=str2num(get_param(parent_simulink,'Njc')); 
            Nic=str2num(get_param(parent_simulink,'Nic')); 
            Nrc=str2num(get_param(parent_simulink,'Nrc')); 
            mM=[min_r max_r];
            S1c=str2num(get_param(parent_simulink,'S1c'));
            netn_contr = newff(mM,[S1c S2],{f1,f2},'trainlm');
   
            IW_y = eval(strvcat(get_param(parent_simulink,'IW_y')));
            IW_r = eval(strvcat(get_param(parent_simulink,'IW_r')));
            IW_u = eval(strvcat(get_param(parent_simulink,'IW_u')));
            LW_c = eval(strvcat(get_param(parent_simulink,'LW_c')));
            B1_c = eval(strvcat(get_param(parent_simulink,'B1_c')));
            B2_c = eval(strvcat(get_param(parent_simulink,'B2_c')));
      
            netn_contr.layerConnect(1,2)=1;
            netn_contr.layerWeights{1,2}.delays=[1:Nic];
            netn_contr.LW{1,2}=IW_u;
            netn_contr.inputWeights{1,1}.delays=[0:Nrc-1];
            netn_contr.IW{1,1}=IW_r;
            netn_contr.b{1}=B1_c;
            netn_contr.b{2}=B2_c;
            netn_contr.LW{2,1}=LW_c;
            netn_contr.numInputs=2;
            netn_contr.inputConnect=[1 1;0 0];
            netn_contr.inputWeights{1,2}.delays=[0:Njc-1];
            netn_contr.IW{1,2}=IW_y;
            
            name_netn_contr=get(ud.Handles.nncontroledit,'string');
            if ~isempty(strmatch(name_netn_contr,...
               Wname,'exact')),
               overwrite=1;
            end
         end
         if (nnpl | allv) & nnob
            mM=[minp maxp];
            S1=str2num(get_param(parent_simulink,'S1'));
            netn_plant = newff(mM,[S1 S2],{f1,f2},'trainlm');
          
            IW=eval(strvcat(get_param(parent_simulink,'IW')));
            LW2_1=eval(strvcat(get_param(parent_simulink,'LW2_1')));
            LW1_2=eval(strvcat(get_param(parent_simulink,'LW1_2')));
            B1=eval(strvcat(get_param(parent_simulink,'B1')));
            B2=eval(strvcat(get_param(parent_simulink,'B2')));
 
            netn_plant.inputWeights{1,1}.delays=[0:Ni-1];
            netn_plant.IW{1,1}=IW;
            netn_plant.layerConnect(1,2)=1;
            netn_plant.layerWeights{1,2}.delays=[1:Nj];
            netn_plant.LW{1,2}=LW1_2;
            netn_plant.LW{2,1}=LW2_1;
            netn_plant.b{1}=B1;
            netn_plant.b{2}=B2;
            
            name_netn_plant=get(ud.Handles.nnplantedit,'string');
            if ~isempty(strmatch(name_netn_plant,...
               Wname,'exact')),
               overwrite=1;
            end
         end
      end
   end
   
   ExportVal=0;
   if allv
      MaskNames=get_param(parent_simulink,'MaskNames');
      ExportVal=size(MaskNames,1);
   elseif (nnpl | nnco) & ~nnob
      if nnpl
         MaskNames{1}='IW';
         MaskNames{2}='LW1_2';
         MaskNames{3}='LW2_1';
         MaskNames{4}='B1';
         MaskNames{5}='B2';
         ExportVal=5;
      end
      if nnco
         MaskNames{ExportVal+1}='IW_u';
         MaskNames{ExportVal+2}='IW_y';
         MaskNames{ExportVal+3}='IW_r';
         MaskNames{ExportVal+4}='LW_c';
         MaskNames{ExportVal+5}='B1_c';
         MaskNames{ExportVal+6}='B2_c';
         ExportVal=ExportVal+6;
      end
   end
   if strcmp(cmd,'workspace')
      for CheckName = 1:ExportVal,
         if ~isempty(strmatch(MaskNames{CheckName},...
             Wname,'exact')),
             overwrite=1;
             break
         end % if ~isempty...
      end % for CheckName
      
      if overwrite
         switch questdlg(...
              {'At least one of the items you are exporting to'
               'the workspace already exists.'
               ' ';
               'Exporting will overwrite the existing variables.'
               ' '
               'Do you want to continue?'},...
               'Variable Name Conflict','Yes','No','No');
            
        case 'Yes'
           overwriteOK = 1;
        case 'No'
           overwriteOK = 0;
        end % switch questdlg
      else
        overwriteOK = 1;
      end % if/else overwrite
      
      if overwriteOK 
        for k = 1:ExportVal
           temp=get_param(parent_simulink,MaskNames{k});
           if sum(isletter(temp))==0
              temp=eval(strvcat(get_param(parent_simulink,MaskNames{k})));
           end
           assignin('base',MaskNames{k},temp);
        end % for k
        if (nnco | allv) & nnob& ~(strcmp(ud.Handles.type_net,'nnpredict'))
           assignin('base',name_netn_contr,netn_contr);
        end
        if (nnpl | allv) & nnob
           assignin('base',name_netn_plant,netn_plant);
        end
        delete(fig)   
      end
   elseif strcmp(cmd,'disk')
      fname = '*';
      fname=[fname,'.mat']; % Revisit for CODA -- is a .mat extension already provide
      [fname,p]=uiputfile(fname,'Export to Disk');
      if fname,
         fname = fullfile(p,fname);
         if ExportVal
            temp=get_param(parent_simulink,MaskNames{1});
            if sum(isletter(temp))==0
               temp=eval(strvcat(get_param(parent_simulink,MaskNames{1})));
            end
            eval([MaskNames{1},'=temp;']);
            save(fname,MaskNames{1});
            for k = 2:ExportVal,
               temp=get_param(parent_simulink,MaskNames{k});
               if sum(isletter(temp))==0
                  temp=eval(strvcat(get_param(parent_simulink,MaskNames{k})));
               end
               eval([MaskNames{k},'=temp;']);
               save(fname,MaskNames{k},'-append');
            end
            if (nnco | allv) & nnob & ~strcmp(ud.Handles.type_net,'nnpredict')
               eval([name_netn_contr '= netn_contr;']);
               save(fname,name_netn_contr,'-append');
            end
            if (nnpl | allv) & nnob
               eval([name_netn_plant '= netn_plant;']);
               save(fname,name_netn_plant,'-append');
            end
         else
            if (nnco | allv) & nnob & ~strcmp(ud.Handles.type_net,'nnpredict')
               eval([name_netn_contr '= netn_contr;']);
               save(fname,name_netn_contr);
               if (nnpl | allv) & nnob
                  eval([name_netn_plant '= netn_plant;']);
                  save(fname,name_netn_plant,'-append');
               end
            else
               eval([name_netn_plant '= netn_plant;']);
               save(fname,name_netn_plant);
            end
         end
         delete(fig)   
      end
   else    % Simulink
      Ts=get_param(parent_simulink,'Ts');
      if allv | nnpl
         gensim(netn_plant,Ts);
      end
      if (allv | nnco) & ~(strcmp(ud.Handles.type_net,'nnpredict'))
         gensim(netn_contr,Ts);
      end
      delete(fig)   
   end
   
end
