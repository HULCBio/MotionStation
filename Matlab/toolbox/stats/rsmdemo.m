function rsmdemo(action,figarg)
%RSMDEMO Demo of design of experiments and surface fitting.
%   RSMDEMO Creates a GUI that simulates a chemical reaction.
%   To start, you have a budget of 13 test reactions. Try to find out how
%   changes in each reactant affect the reaction rate. Determine the 
%   reactant settings that maximize the reaction rate. Estimate the
%   run-to-run variability of the reaction.
%
%   Now run a designed experiment using the model popup. Compare your
%   previous results with the output from response surface modeling or
%   nonlinear modeling of the reaction.
%
%   The GUI has the following elements:
%   1) A RUN button to perform one reactor run at the current settings.
%   2) An Export button to export the X and Y data to the base workspace.
%   3) Three sliders with associated data entry boxes to control the 
%      partial pressures of the chemical reactants: Hydrogen, n-Pentane,
%      and Isopentane.
%   4) A text box to report the reaction rate.
%   5) A text box to keep track of the number of test reactions you have
%      left.
%
%   See also CORDEXCH, RSTOOL, NLINTOOL, HOUGEN.

%   Copyright 1993-2004 The MathWorks, Inc. 
%   $Revision: 2.27.4.3 $  $Date: 2004/03/09 16:17:05 $

if nargin < 1
    action = 'start';
end

%On recursive calls get all necessary handles and data.
if ~strcmp(action,'start')
   if (nargin>1 && length(figarg)==3)
      fact_fig = figarg(1);
      data_fig = figarg(2);
      doe_fig = figarg(3);
   else
      fact_fig = findobj(0,'Tag','control');
      data_fig = findobj(0,'Tag','data1');
      doe_fig  = findobj(0,'Tag','data2');
   end
end

if ~strcmp(action,'start') && ~strcmp(action,'close')
  p1field = findobj(fact_fig,'Tag','p1f');
  p1slider = findobj(fact_fig,'Tag','p1s');
  
  p2field = findobj(fact_fig,'Tag','p2f');
  p2slider = findobj(fact_fig,'Tag','p2s');
  
  p3field = findobj(fact_fig,'Tag','p3f');
  p3slider = findobj(fact_fig,'Tag','p3s');

  out_field = findobj(fact_fig,'Tag','of');
  runs_field = findobj(fact_fig,'Tag','rf');
  run_btn   = findobj(fact_fig,'Tag','rb');
  reset_btn = findobj(fact_fig,'Tag','rs');   

  if ~isempty(data_fig);
     p1_popup   = findobj(data_fig,'Tag','popup1');
  end

  if ~isempty(doe_fig);
     p2_popup   = findobj(doe_fig,'Tag','popup2');
  end
  plat = computer;
  if strcmp(plat(1:2),'PC')
     fs = 8;
  else
     fs = 9;
  end
end

if strcmp(action,'start')
   
   plat = computer;
   if strcmp(plat(1:2),'PC')
      fs = 8;
   else
      fs = 9;
   end
   fpadj = -50;

% Initialize data values.
p1   = 200;
p1hi = 470;
p1lo = 100;
p2   = 150;
p2hi = 300;
p2lo = 80;

p3   = 50;
p3hi = 120;
p3lo = 10;

% Define graphics objects
fcolor  = [0.5 0.5 0.5];
fieldp1 = [120 80 80 20];
slidep1 = fieldp1 + [85 -60 -65 80];
textp1  = fieldp1 + [0 20 0 0];
fieldp2 = [240 80 80 20];
slidep2 = fieldp2 + [85 -60 -65 80];
textp2  = fieldp2 + [0 20 0 0];
fieldp3 = [360 80 80 20];
slidep3 = fieldp3 + [85 -60 -65 80];
textp3  = fieldp3 + [0 20 0 0];
outfieldp = [240 150 80 20];
textout   = outfieldp + [-10 20 20 0];

% Create Reaction Simulator Figure
set(0,'Units','pixels')
ss = get(0,'ScreenSize');
pos1 = [10 ss(4)-210+fpadj 480 200];
fact_fig = figure('Units','pixels','Position',pos1);
drawnow;
%movegui(fact_fig);
pos1 = get(fact_fig, 'Position');
opos = get(fact_fig, 'OuterPosition');

posdy = opos(4) - pos1(4);
posdx = opos(3) - pos1(3);

pos2 = [pos1(1) (pos1(2)-posdy-200) 355 200];
data_fig = figure('Visible','off','Units','pixels',...
                  'Position',pos2,'BusyAction','cancel');
%movegui;

pos3 = [(pos2(1)+pos2(3)+posdx) pos2(2) 355 200];
doe_fig = figure('Visible','off','Units','pixels',...
                 'Position',pos3,'BusyAction','cancel');
%movegui;

figlist = ['[' int2str(fact_fig) ',' int2str(data_fig) ...
           ',' int2str(doe_fig) '])'];
set(0,'CurrentFigure',fact_fig);

set(fact_fig,'Color',fcolor,'Backingstore','off','Resize','off',...
    'Name','Reaction Simulator','Tag','control','BusyAction','cancel');

uicontrol('Style','edit','Units','pixels','Position',fieldp1,...
         'BackgroundColor','white','String',num2str(p1),'Tag','p1f',...
       'Callback',['rsmdemo(''setp1field'',' figlist]);
         
uicontrol('Style','slider','Units','pixels','Position',slidep1,...
        'Value',p1,'Max',p1hi,'Min',p1lo,...
        'Callback',['rsmdemo(''setp1slider'',' figlist],'Tag','p1s');

uicontrol('Style','text','Units','pixels','Position',textp1,...
        'BackgroundColor',fcolor,...
        'ForegroundColor','white','String','Hydrogen');

uicontrol('Style','edit', 'Units','pixels','Position',fieldp2,...
       'BackgroundColor','white','String',num2str(p2),'Tag','p2f',...
      'Callback',['rsmdemo(''setp2field'',' figlist]);

         
uicontrol('Style','slider','Units','pixels','Position',slidep2,...
        'Value',p2,'Max',p2hi,'Min',p2lo,...
        'Callback',['rsmdemo(''setp2slider'',' figlist],'Tag','p2s');
                           
uicontrol('Style','text','Units','pixels','Position',textp2,...
        'BackgroundColor',fcolor,...
        'ForegroundColor','white','String','n-Pentane');

uicontrol('Style','edit','Units','pixels','Position',fieldp3,...
         'BackgroundColor','white','String',num2str(p3),'Tag','p3f',...
       'Callback',['rsmdemo(''setp3field'',' figlist]);
         
uicontrol('Style','slider','Units','pixels','Position',slidep3,...
       'Value',p3,'Max',p3hi,'Min',p3lo,...
        'Callback',['rsmdemo(''setp3slider'',' figlist],'Tag','p3s');
                           
uicontrol('Style','text','Units','pixels','Position',textp3,...
        'BackgroundColor',fcolor,...
        'ForegroundColor','white','String','Isopentane');

uicontrol('Style','text','Units','pixels',...
          'BackgroundColor','white','Position',outfieldp,'Tag','of');

uicontrol('Style','text','Units','pixels','Position',textout,...
        'BackgroundColor',fcolor,'ForegroundColor','white','String','Reaction Rate');

uicontrol('Style','text','Units','pixels','String',num2str(13),...
         'BackgroundColor','white','Position',[25 150 70 20],'Tag','rf');

uicontrol('Style','text','Units','pixels','Position',[25 170 75 20],...
        'BackgroundColor',fcolor,'ForegroundColor','white','String','Runs Left');

uicontrol('Style','Pushbutton','Units','pixels',...
          'Position',[25 125 75 20],...
          'Callback',['rsmdemo(''reset'',' figlist],...
          'Visible','off','Tag','rs','String','Reset');

uicontrol('Style','Pushbutton','Units','pixels',...
          'Position',[25 80 75 20],'Tag','rb',...
          'Callback',['rsmdemo(''run'',' figlist],...
          'String','Run');

uicontrol('Style','Pushbutton','Units','pixels',...
          'Position',[25 55 75 20],...
          'Callback',['rsmdemo(''output'',' figlist],'String','Export...');

uicontrol('Style','Pushbutton','Units','pixels',...
          'Position',[375 170 100 20],...
          'Callback',['rsmdemo(''help'',' figlist],...
          'String','Help');

uicontrol('Style','Pushbutton','Units','pixels','Position',[25 10 75 20],...
          'Callback',['rsmdemo(''close'',' figlist],'String','Close');
set(fact_fig,'DeleteFcn',['rsmdemo(''close'',',figlist]);

% Create Trial and Error Data View
set(0,'CurrentFigure',data_fig);
uicontrol('Style','Pushbutton','Units','pixels','Position',[2 2 100 20],...
             'Callback',['rsmdemo(''analyze'',' figlist],'String','Analyze');

uicontrol(data_fig,'Style','Popup','String',...
              'Plot|Hydrogen vs. Rate|n-Pentane vs. Rate|Isopentane vs. Rate',...
              'Units','pixels','Position',[120 2 140 20],...
              'CallBack',['rsmdemo(''plot1'',' figlist],'Tag','popup1');

set(data_fig,'DeleteFcn',['rsmdemo(''close'',',figlist]);
set(data_fig,'Color','w','Name','Trial and Error Data','Tag','data1','Resize','off');
data_axes = axes;
set(data_axes,'Units','pixels','Position',[0 0 300 200],...
    'DrawMode','fast','Visible','off','Xlim',[1 300],'Ylim',[1 200]);   
z = [2 50 110 170 230];
h = zeros(5,1);
colheads = str2mat('Run #','Hydrogen','n-Pentane','Isopentane','Reaction Rate');
for k = 1:5
  h(k)=text(z(k),182,colheads(k,:));
  set(h(k),'FontName','Geneva','FontSize',fs);
  set(h(k),'Color','k');
end

% Create Designed Experiment Data View
set(doe_fig,'Color','w','Name','Experimental Data','Tag','data2','Resize','off');
set(0,'CurrentFigure',doe_fig);
set(doe_fig,'DeleteFcn',['rsmdemo(''close'',',figlist]);
uicontrol('Style','Pushbutton','Units','pixels','Position',[1 178 150 20],...
             'Callback',['rsmdemo(''doe'',' figlist],...
             'String','Do Experiment','Tag','doe_button');

uicontrol('Style','Pushbutton','Units','pixels','Position',[1 2 110 20],...
             'Callback',['rsmdemo(''fit1'',' figlist],...
             'String','Response Surface');

uicontrol('Style','Pushbutton','Units','pixels','Position',[115 2 110 20],...
             'Callback',['rsmdemo(''fit2'',' figlist],...
             'String','Nonlinear Model');

uicontrol(doe_fig,'Style','Popup','String',...
              'Plot|Hydrogen vs. Rate|n-Pentane vs. Rate|Isopentane vs. Rate',...
              'Units','pixels','Position',[230 2 120 20],...
              'CallBack',['rsmdemo(''plot2'',' figlist],'Tag','popup2');

doe_axes = axes;
set(doe_axes,'Units','pixels','Position',[1 1 300 200],'Visible','off','DrawMode','fast',...
             'Xlim',[1 300],'Ylim',[1 200]);   
z = [2 50 110 170 230];
h = zeros(5,1);
for k = 1:5
  h(k)=text(z(k),165,colheads(k,:));
  set(h(k),'FontName','Geneva','FontSize',fs);
  set(h(k),'Color','k');
end

set(doe_fig,'Visible','on','HandleVisibility','callback')
set(data_fig,'Visible','on','HandleVisibility','callback')
set(fact_fig,'Visible','on','UserData',0,'HandleVisibility','callback')
% Bring Up Help Screen
str = rsmdemohelp;
helpwin(str,'Reaction Simulation','RSMDEMO Help Facility')
figure(fact_fig);
% Initialization Complete

% Callback for Hydrogen Slider
elseif strcmp(action,'setp1slider')
  p1 = get(p1slider,'Value');
  set(p1field,'String',num2str(p1));

% Callback for n-Pentane Slider
elseif strcmp(action,'setp2slider')
  p2 = get(p2slider,'Value');
  set(p2field,'String',num2str(p2));

% Callback for Isopentane Slider
elseif strcmp(action,'setp3slider')
  p3 = get(p3slider,'Value');
  set(p3field,'String',num2str(p3));

% Callback for Hydrogen Data Entry Field
elseif strcmp(action,'setp1field')
   p1 = str2double(get(p1field,'String'));
   if p1 > get(p1slider,'Max') || p1 < get(p1slider,'Min')
      p1max = get(p1slider,'Max');
      p1min = get(p1slider,'Min');
      s = ['You can only set this value between ' num2str(p1min) ' and ' num2str(p1max) '.'];
      warndlg(s);
      p1 = get(p1slider,'Value');
      set(p1field,'String',num2str(p1));
   else
      set(p1slider,'Value',p1);
   end
   
% Callback for n-Pentane Data Entry Field
elseif strcmp(action,'setp2field')
   p2 = str2double(get(p2field,'String'));
   if p2 > get(p2slider,'Max') || p2 < get(p2slider,'Min')
      p2max = get(p2slider,'Max');
      p2min = get(p2slider,'Min');
      s = ['You can only set this value between ' num2str(p2min) ' and ' num2str(p2max) '.'];
      warndlg(s);
      p2 = get(p2slider,'Value');
      set(p2field,'String',num2str(p2));
   else
      set(p2slider,'Value',p2);
   end
   
% Callback for Isopentane Data Entry Field
elseif strcmp(action,'setp3field')
   p3 = str2double(get(p3field,'String'));
   if p3 > get(p3slider,'Max') || p3 < get(p3slider,'Min')
      p3max = get(p3slider,'Max');
      p3min = get(p3slider,'Min');
      s = ['You can only set this value between ' num2str(p3min) ' and ' num2str(p3max) '.'];
      warndlg(s);
      p3 = get(p3slider,'Value');
      set(p3field,'String',num2str(p3));
   else
      set(p3slider,'Value',p3);
   end
   
% Callback for Run Button
elseif strcmp(action,'run')
   if isempty(data_fig)
       % Create No Data Figure Dialog.
       warndlg('The data figure is gone. Restart rsmdemo to run more tests.');
       return;
   end
   
   data = get(data_fig,'UserData');
   [m,n] = size(data);
   if m >= 12
       % Create Reset Button Dialog.
       warndlg('Press the Reset button to get another 13 runs');
       set(reset_btn,'Visible','on');
   end
   if m == 13
       set(run_btn,'Enable','off');
       return;
   end
   set(runs_field,'String',num2str(13-m-1));
   p1 = get(p1slider,'Value');
   p2 = get(p2slider,'Value');
   p3 = get(p3slider,'Value');
   y  = 1.25*(p2 - p3/1.5183)./(1+0.064*p1+0.0378*p2+0.1326*p3)*normrnd(1,0.05);
   set(out_field,'String',num2str(y));
   data = [data;p1 p2 p3 y];
   set(data_fig,'UserData',data);
   set(0,'CurrentFigure',data_fig);
   z = [24 90 155 215 285];
   x = 180 - 10*(m+1);
   row = [m+1 p1 p2 p3 y];
   for k = 1:5
       if k < 5,
          h(k) = text(z(k),x,sprintf('%4i',round(row(k))));
          set(h(k),'HorizontalAlignment','right');
          set(h(k),'FontName','Geneva','FontSize',fs);
       else
          h(k) = text(z(k),x,sprintf('%6.2f',row(k)));
          set(h(k),'HorizontalAlignment','right');
          set(h(k),'FontName','Geneva','FontSize',fs);
       end

      set(h(k),'Color','k');
   end
   set(0,'CurrentFigure',fact_fig);

% Callback for Do Experiment Button
elseif strcmp(action,'doe')
   % Do Designed Experiment.  
   data = get(doe_fig,'UserData');
   if ~isempty(data),
      doe_axes = get(doe_fig,'CurrentAxes');
      txt = findobj(doe_axes,'Type','text');
      delete(txt(1:end-5));
   end

   settings = cordexch(3,13,'q');
   mr = [285 190 65];
   mr = mr(ones(13,1),:);

   hr = [185 110 55];
   hr = hr(ones(13,1),:);
   settings = settings.*hr + mr;
   y = zeros(13,1);
   p1 = settings(:,1);
   p2 = settings(:,2);
   p3 = settings(:,3);
   z = [24 90 155 215 285];
   for k = 1:13
     x = 160 - 10*k;
     row = [k p1(k) p2(k) p3(k) y(k)];
     for k1 = 1:4
        set(0,'CurrentFigure',doe_fig);
        h(k1) = text(z(k1),x,sprintf('%4i',round(row(k1))));
        set(h(k1),'HorizontalAlignment','right');  
        set(h(k1),'FontName','Geneva','FontSize',fs);
        set(h(k1),'Color','k');
     end
     figure(fact_fig);
	 pause(0.5);
     set(p1slider,'Value',p1(k));
     set(p1field,'String',num2str(p1(k)));

     set(p2slider,'Value',p2(k));
     set(p2field,'String',num2str(p2(k)));

     set(p3slider,'Value',p3(k));
     set(p3field,'String',num2str(p3(k)));

     y(k)  = 1.25*(p2(k) - p3(k)/1.5183)./(1+0.064*p1(k)+0.0378*p2(k)+0.1326*p3(k))*normrnd(1,0.05);
     set(out_field,'String',num2str(y(k)));
     set(doe_fig,'UserData',data);
     set(0,'CurrentFigure',doe_fig);
     x = 160 - 10*k;
     row = [k p1(k) p2(k) p3(k) y(k)];
     h(5) = text(z(5),x,sprintf('%6.2f',row(5)));
     set(h(5),'HorizontalAlignment','right');
     set(h(5),'FontName','Geneva','FontSize',fs);
     set(h(5),'Color','k');
     pause(1);
     set(runs_field,'String',num2str(13-k));   
   end
   data = [settings y];
   set(doe_fig,'UserData',data);
   set(reset_btn,'Visible','on');
   set(run_btn,'Enable','off');

% Callback for Analyze Button
elseif strcmp(action,'analyze')
      data = get(data_fig,'UserData');
   
      if size(data,1) < 6
       % Create Not Enough Data Dialog.
       warndlg('Not enough data. Please do more test reactions.');
       return;
     end
      x = data(:,1:3);
      y = data(:,4);
      xname = str2mat('Hydrogen','n-Pentane','Isopentane');
      yname = 'Reaction Rate';
      try
         rstool(x,y,[],[],xname,yname);
      catch
         warndlg(sprintf(...
             '%s\nTry more reactions with different parameter values',...
             lasterr));
      end

% Callback for Trial and Error Figure Plot Menu
elseif strcmp(action,'plot1')
      data = get(data_fig,'UserData');
      if size(data,1) < 2
         % Create Not Enough Data Dialog.
         warndlg('Not enough data. Please do more test reactions.');
         return;
      end
      if get(p1_popup,'Value') == 2
         figure,
         plot(data(:,1),data(:,4),'+');
         if any(diff(sort(data(:,1)))) > 0
            lsline;
         end
         xlabel('Hydrogen');
         ylabel('Rate');
      elseif get(p1_popup,'Value') == 3
         figure,
         plot(data(:,2),data(:,4),'+');
         if any(diff(sort(data(:,2)))) > 0
            lsline;
         end
         xlabel('n-Pentane');
         ylabel('Rate');
      elseif get(p1_popup,'Value') == 4
         figure,
         plot(data(:,3),data(:,4),'+');
         if any(diff(sort(data(:,3)))) > 0
            lsline;
         end
         xlabel('Isopentane');
         ylabel('Rate');
      else
         return;
      end
      set(p1_popup,'Value',1);     

% Callback for DOE Figure Plot Menu
elseif strcmp(action,'plot2')
      data = get(doe_fig,'UserData');
      if size(data,1) < 1
         % Create Not Enough Data Dialog.
         warndlg('No data. Please press "Do Experiment" Button.');
         return;
      end
     if get(p2_popup,'Value') == 2
        figure,
        plot(data(:,1),data(:,4),'+');
        lsline;
        xlabel('Hydrogen');
        ylabel('Rate');
     elseif get(p2_popup,'Value') == 3
        figure,
        plot(data(:,2),data(:,4),'+');
        lsline;
        xlabel('n-Pentane');
        ylabel('Rate');
     elseif get(p2_popup,'Value') == 4
        figure,
        plot(data(:,3),data(:,4),'+');
        lsline;
        xlabel('Isopentane');
        ylabel('Rate');
     else
        return;
     end
     set(p2_popup,'Value',1);     

% Callback for Response Surface Button 
elseif strcmp(action,'fit1')
      data = get(doe_fig,'UserData');
   
      if size(data,1) < 1
         % Create Not Enough Data Dialog.
         warndlg('No data. Please press "Do Experiment" Button.');
         return;
      end
   
      x = data(:,1:3);
      y = data(:,4);
      xname = str2mat('Hydrogen','n-Pentane','Isopentane');
      yname = 'Reaction Rate';
      rstool(x,y,'quadratic',[],xname,yname);

% Callback for Nonlinear Model Button 
elseif strcmp(action,'fit2')
      data = get(doe_fig,'UserData');
      if size(data,1) < 6
         % Create Not Enough Data Dialog.
         warndlg('No data. Please press "Do Experiment" Button.');
         return;
      end
   
      x = data(:,1:3);
      y = data(:,4);
      xname = str2mat('Hydrogen','n-Pentane','Isopentane');
      yname = 'Reaction Rate';
      beta0 = [1.2 0.1 0.01 0.1 1.5];
      nlintool(x,y,'hougen',beta0,0.05,xname,yname);

% Callback for Help Button 
elseif strcmp(action,'help')
   str = rsmdemohelp;
   helpwin(str,'Reaction Simulation','RSMDEMO Help Facility')


% Callback for Close Button 
elseif strcmp(action,'close')
   if ishandle(fact_fig), delete(fact_fig); end
   if ishandle(data_fig), delete(data_fig); end
   if ishandle(doe_fig),  delete(doe_fig);  end
 
% Callback for Reset Button 
elseif strcmp(action,'reset')
   set(run_btn,'Enable','on');
   data_axes = get(data_fig,'CurrentAxes');
   t = get(data_axes,'Children');
   
   delete(t(1:length(t)-5));
   set(runs_field,'String',num2str(13));
   set(reset_btn,'Visible','off');
   set(data_fig,'Userdata',[]);
   
% Callback for Export Button 
elseif strcmp(action,'output')
   if isempty(data_fig)
      warndlg('The data is gone. Restart rsmdemo to generate more data.');
      return;
   end
   data1 = get(data_fig,'UserData');

   if ~isempty(doe_fig)
      data2 = get(doe_fig,'UserData');
   else
      data2 = [];
   end

   if isempty(data1) && isempty(data2),
      warndlg('There is no data. Please do some test reactions.');
      return;
   elseif ~isempty(data1) && isempty(data2)
      x1 = data1(:,1:3);
      y1 = data1(:,4);
      labels = {'Trial and error reactants', 'Trial and error rate'};
      items = {x1, y1};
      varnames = {'trial_reactants', 'trial_rate'};
   elseif isempty(data1) && ~isempty(data2)
      x2 = data2(:,1:3);
      y2 = data2(:,4);
      labels = {'Experimental design reactants', 'Experimental design rate'};
      items = {x2, y2};
      varnames = {'doe_reactants', 'doe_rate'};
   elseif ~isempty(data1) && ~isempty(data2)
      x1 = data1(:,1:3);
      y1 = data1(:,4);
      x2 = data2(:,1:3);
      y2 = data2(:,4);
      items = {x1, y1, x2, y2};
      labels = {'Trial and error reactants', 'Trial and error rate', ...
                'Experimental design reactants', 'Experimental design rate'};
      varnames = {'trial_reactants', 'trial_rate','doe_reactants', 'doe_rate'};
   end
   export2wsdlg(labels, varnames, items, 'Export to Workspace');
end

function str = rsmdemohelp
%RSMDEMOHELP  Display Help for Reaction Simulator
%
%   See Also CORDEXCH RSTOOL NLINTOOL HOUGEN

str = cell(8, 2);
str{1,1} = 'Reaction Simulation';
str{1,2} = {
'Demonstration of DOE, RSM, and Empirical Modeling.'
' '
'RSMDEMO is a graphic user interface for learning about three new '
'capabilities of the MATLAB Statistics Toolbox. They are:'
'   *  Designed Experiments.'
'   *  Response Surface methods.'
'   *  Nonlinear modeling.'
' '
'The interface has three figure windows:'
'*  Reaction Simulator '
'*  Trial and Error Data '
'*  Experimental Design Data '
' '
'The Reaction Simulator figure has several controls for running a '
'virtual chemical reaction. There are three sliders with associated data'
'entry boxes to control the partial pressures of the chemical'
'reactants: Hydrogen, n-Pentane, and Isopentane.'
'The RUN button performs one reactor run at the current settings.'
' '
'Exercise 1: Trial and Error Optimization '
'Do several processing runs. The results of each run will appear in the'
'Trial and Error Data figure. After each run change one or more slider '
'settings. Try to learn how changes in each reactant affect the reaction'
'rate. See if you can find the settings that maximize the reaction rate'
'over the allowable ranges of the reactants.'
' '
'After doing several runs you can plot your results using the plot menu '
'at the bottom of the Trial and Error Data figure. You can also analyze '
'your data using the Analyze button in this figure.'
' '
'Exercise 1: Questions '
'What are the settings of the optimal process? What reaction rate do you '
'predict at these settings? How comfortable are you with your predictions?'
' '
'Exercise 2: Optimization Using a Designed Experiment '
'Now press the Do Experiment button in the Experimental Design Data '
'figure. After a short wait you will see a table of reactant settings '
'appear in the figure.The Reaction Simulator will then perform all of '
'these processing runs automatically and record the results in the '
'Reaction Rate column.'
' '
'After doing the experimental runs you can plot your results using the '
'plot menu at the bottom of the figure. You can also analyze your data '
'using either the Response Surface or the Nonlinear Model buttons.'
' '
'Exercise 2: Questions '
'How do the Response Surface and Nonlinear models compare? Do they agree '
'on the settings of the optimal process? What reaction rate do you '
'predict at these settings? How precise are your answers compared to the '
'results of the Trial and Error approach?'
};

str{2,1} = 'Designed Experiments';
str{2,2} = {
'Design of Experiments (DOE)'
' '
'The MATLAB Statistics Toolbox supports factorial and d-optimal design of '
'experiments.In the reaction simulator you can run a d-optimal experiment '
'by pressing the Do Experiment button in the Designed Experiments Figure.'
'The command in RSMDEMO is below: '
'      settings = cordexch(3,13,''quadratic'');'
'This generates the matrix SETTINGS which is 3 by 13. That is, there are '
'13 runs for three variables. The string variable, ''quadratic'' indicates '
'that you wish to fit a full quadratic model in three variables.'
' '
'The form of this model is:'
'y = b0 + b1*x1 + b2*x2 + b3*x3 + ...        (linear terms)'
'    b12*x1*x2 + b13*x1*x3 + b23*x2*x3 + ... (interaction terms)'
'    b11*x1.^2 + b22*x2.^2 + b33*x3.^2       (quadratic terms)'
};

str{3,1} = 'Response Surface Methods';
str{3,2} = {
'Response Surface Methodology (RSM)'
' '
'Response Surface Methodology is a tool for understanding the '
'quantitative relationship between multiple input variables and one '
'output variable. Consider one output, z, as a polynomial function of two '
'inputs, x and y. z = f(x,y) describes a two dimensional surface in the '
'space (x,y,z). Of course, you can have as many input variables as you '
'want and the resulting surface becomes a hyper-surface.'
' '
'It is difficult to visualize a k-dimensional surface in k+1 dimensional '
'space when k>2. The function RSTOOL is a GUI designed to make this '
'visualization more intuitive.'
};

str{4,1} = 'Nonlinear Modeling';
str{4,2} = {
'Nonlinear Modeling '
' '
'In some cases, we may have a relevant theory that allows us to make a '
'mechanistic model. Often such models are nonlinear in the unknown parameters.'
'This is in contrast to RSM, which is an empirical modeling approach using'
'polynomials as local approximations to the true input/output relationship.'

'The data generated by the reaction simulator actually does not come'
'from a polynomial model. The model describes the reaction rate as a '
'function of hydrogen, n-pentane and isopentane partial pressure is the '
'Hougen-Watson model. It is difficult to visualize a k-dimensional '
'nonlinear surface in k+1 dimensional space when  k > 2. The function '
'NLINTOOL is a GUI designed to make this visualization more intuitive.'
};

str{5,1} = 'CORDEXCH';
str{5,2} = {
'Coordinate Exchange M-file Help '
' '
'CORDEXCH D-Optimal design of experiments.'
'CORDEXCH(NFACTORS,NRUNS,MODEL)  creates a d-optimal experimental design '
'using the coordinate exchange algorithm.'
' '
'[SETTINGS, X] = CORDEXCH(NFACTORS,NRUNS,MODEL) generates the factor '
'settings matrix, SETTINGS, and the associated design matrix, X. The '
'number of factors, NFACTORS, and desired number of runs, NRUNS. The '
'optional string input, MODEL, controls the order of the regression '
'model. By default, CORDEXCH returns the design matrix for a linear '
'additive model with a constant term. MODEL can be following strings:'
' 	interaction - includes constant, linear, and cross product terms.'
' 	quadratic - interactions plus squared terms.'
' 	purequadratic - includes constant, linear and squared terms.'
};

str{6,1} = 'RSTOOL';
str{6,2} = {
'RSTOOL M-file Help '
' '
'RSTOOL Interactive fitting and visualization of a response surface.'
' '
'RSTOOL(X,Y,MODEL,ALPHA) is a prediction plot that provides a multiple '
'input polynomial fit to (X,y) data. It plots a 100(1 - ALPHA) percent '
'global confidence interval for predictions as two red curves. The '
'default model is linear. MODEL can be following strings:'
' '
'interaction   - includes constant, linear, and cross product terms.'
'quadratic     - interactions plus squared terms.'
'purequadratic - includes constant, linear and squared terms.'
' '
'The default value for ALPHA is 0.05, which produces 95% confidence '
'intervals.'
' '
'RSTOOL(X,Y,MODEL,ALPHA,XNAME,YNAME) The optional inputs XNAME and YNAME '
'contain strings for the X and Y variables respectively.'
' '
'Drag the dotted white reference line and watch the predicted values '
'update simultaneously. Alternatively, you can get a specific prediction '
'by typing the "X" value into an editable text field.'
'Use the pop-up menu labeled Model to interactively change the model.'
'Use the pop-up menu labeled Export to move specified variables to the '
'base workspace.'
};

str{7,1} = 'NLINTOOL';
str{7,2} = {
'NLINTOOL M-file Help '
' '
'NLINTOOL Fits a nonlinear equation to data and displays an interactive graph.'
'	'
'NLINTOOL(X,Y,MODEL,BETA0,ALPHA) is a prediction plot that provides a '
'nonlinear curve fit to (x,y) data. It plots a 100(1 - ALPHA) percent '
'global confidence interval for predictions as two red curves. BETA0 is a '
'vector containing initial guesses for the parameters. The default value '
'for ALPHA is 0.05, which produces 95% confidence intervals.'
'	'
'NLINTOOL(X,Y,MODEL,BETA0,ALPHA,XNAME,YNAME) The optional inputs XNAME'
'  '
'and YNAME contain strings for the X and Y variables respectively. You '
'can drag the dotted white reference line and watch the predicted values '
'update simultaneously. Alternatively, you can get a specific prediction '
'by typing the "X" value into an editable text field.'
'	'
'Use the pop-up menu labeled Export to move specified variables to the '
'base workspace.'
};

str{8,1} = 'Help for HOUGEN';
str{8,2} = {
'HOUGEN M-file Help '
' '
'HOUGEN Hougen-Watson model for reaction kinetics.'
'YHAT = HOUGEN(BETA,X) gives the predicted values of the reaction rate,'
'YHAT, as a function of the vector of parameters, BETA, and the matrix of '
'data, X. BETA must have 5 elements and X must have three columns.'
' '
'The model form is:'
' 	y = (b1*x2 - x3/b5)./(1+b2*x1+b3*x2+b4*x3)'
'	'
'Here b1, b2,...,b5 are the unknown parameters and x1, x2, and x3 are'
'the three input variables.'
' '
'Reference:'
'[1]  Bates, Douglas, and Watts, Donald, "Nonlinear Regression Analysis '
};

   for k = 1:8,
      str{k,2} = char(str{k,2});
   end
