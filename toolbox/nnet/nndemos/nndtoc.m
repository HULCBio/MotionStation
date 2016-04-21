function [res1,res2,res3] = nndtoc(cmd,arg1)
% NNDTOC Neural Network Design table of contents.

%  NNDTOC -or- NNDTOC('init')
%  Create TOC window.
%
%  NNDTOC('menus',vector)
%  Display demo menus for up to four chapter numbers (1-19).
%
%  [name,demos,funcs] = NNDTOC('chap',number)
%  Get chapter name, demo titles, and demo functions for
%  a chapter number (1-19).
%
%  NNDTOC('min')
%  Miniturize TOC window.
%
%  NNDTOC('max')
%  Maximize TOC window.
%
%  NNDTOC('close')
%  Close TOC windows.

% Copyright 1994-2002 PWS Publishing Company and The MathWorks, Inc.
% First Version, 8-31-95.
% $Revision: 1.9 $

%==================================================================

% DEFAULTS
if nargin == 0, cmd = 'init'; else cmd = lower(cmd); end

% CONSTANTS
me = 'nndtoc';

% FIND WINDOW IF IT EXISTS
fig = nndfgflg(me);
if length(get(fig,'children')) == 0, fig = 0; end

% GET WINDOW DATA IF IT EXISTS
if fig
  H = get(fig,'userdata');
  fig_axis = H(1);            % window axis
  icon_ptr = H(2);            % handles of icon plots
  text_ptr = H(3);            % four handles to chapter names
  menu_ptr = H(4);            % four handles to popup menus
end

%==================================================================
% Initialize the TOC window.
%
% NNDTOC() or NNDTOC('init')
%==================================================================

if strcmp(cmd,'init') & (fig)
  if strcmp(get(fig,'visible'),'off')
    windows = get(0,'children');
    ok = 0;
    for i=1:length(windows)
      if strcmp(get(windows(i),'userdata'),'minitoc'), ok = 1; end
    end
    if ok
      nndtoc('max');
    else
      delete(fig);
      nndtoc('init');
    end
  else
    figure(fig)
  end

elseif strcmp(cmd,'init') & (~fig)

  % START WITH STANDARD TITLE FIGURE

  fig = nntocf(me,'DESIGN','Table of Contents', ...
    'International Thomson','Publishing','1-800-347-7707');
    
  % UNLOCK AND GET HANDLES
  
  set(fig,'nextplot','add')
  H = get(fig,'userdata');
  fig_axis = H(1);
  
  % MENUS
  icons = [];
  texts = zeros(1,4);
  menus = zeros(1,4);
  
  for i=1:4
    offset = 60*i;
    icons = [icons; nndicon(0,115,360-offset,'shadow')];
    texts(i) = text(150,372-offset,'Signal & Weight Vector Spaces', ...
      'fontsize',12, ...
      'fontweight','bold', ...
      'color',nndkblue,...
      'visible','off');
    menus(i) = uicontrol( ...
      'units','points',...
      'userdata','ch4', ...
      'position',[150 338-offset 200 20], ...
      'style','popupmenu', ...
      'string','', ...
      'back',[1 1 1],...
      'visible','off', ...
      'callback',sprintf('nndtoc(''select'',%g)',i));
  end
  
  % BUTTONS
  set(nnsfo('b11','2-5'),...
    'callback','nndtoc(''menus'',[2 3 4 5])')
  set(nnsfo('b12','6-9'),...
    'callback','nndtoc(''menus'',[6 7 8 9])')
  set(nnsfo('b13','10-13'),...
    'callback','nndtoc(''menus'',[10 11 12 13])')
  set(nnsfo('b14','14-17'),...
    'callback','nndtoc(''menus'',[14 15 16 17])')
  set(nnsfo('b7','18'),...
    'callback','nndtoc(''menus'',[18])')
  set(nnsfo('b9','Textbook Info'),...
    'callback','nnd',...
    'pos',[150 10 130 20])
  set(nnsfo('b10','Close'),...
    'callback','nndtoc(''close'')');
  
  % DATA POINTERS
  icon_ptr = nnsfo('data'); set(icon_ptr,'userdata',icons);
  text_ptr = nnsfo('data'); set(text_ptr,'userdata',texts);
  menu_ptr = nnsfo('data'); set(menu_ptr,'userdata',menus);
  
  % SAVE DATA
  H = [fig_axis icon_ptr text_ptr menu_ptr];
  set(fig,'userdata',H);
  
  % LOCK FIGURE
  set(fig,'nextplot','new');
  
  % SETUP MENUS
  nndtoc('menus',[2 3 4 5]);

  nnchkfs;

%==================================================================
% Get chapter info.
%
% [name,demos,funcs] = NNDTOC('chap',number)
% Returns chapter name, demo titles, and demo functions
% given a chapter number (1-19).
%==================================================================

elseif strcmp(cmd,'chap') & (nargin == 2)
  if arg1 == 1
    res1 = 'Introduction';
    res2 = '';
    res3 = '';
  elseif arg1 == 2
    res1 = 'Neuron Model & Network Architectures';
    res2 = 'One-input neuron|Two-input neuron';
    res3 = str2mat('nnd2n1','nnd2n2');
  elseif arg1 == 3
    res1 = 'An Illustrative Example';
    res2 = 'Perceptron classification|Hamming classification|Hopfield classification';
    res3 = str2mat('nnd3pc','nnd3hamc','nnd3hopc');
  elseif arg1 == 4
    res1 = 'Perceptron Learning Rule';
    res2 = 'Decision boundaries|Perceptron rule';
    res3 = str2mat('nnd4db','nnd4pr');
  elseif arg1 == 5
    res1 = 'Signal & Weight Vector Spaces';
    res2 = 'Gram-Schmidt|Reciprocal basis';
    res3 = str2mat('nnd5gs','nnd5rb');
  elseif arg1 == 6
    res1 = 'Linear Transformations for N. Networks';
    res2 = 'Linear transformations|Eigenvector game';
    res3 = str2mat('nnd6lt','nnd6eg');
  elseif arg1 == 7
    res1 = 'Supervised Hebb';
    res2 = 'Supervised Hebb';
    res3 = str2mat('nnd7sh');
  elseif arg1 == 8
    res1 = 'Performance Surfaces & Optimum Points';
    res2 = 'Taylor series #1|Taylor series #2|Directional derivatives|Quadratic function';
    res3 = str2mat('nnd8ts1','nnd8ts2','nnd8dd','nnd8qf');
  elseif arg1 == 9
    res1 = 'Performance Optimization';
    res2 = 'Steepest descent for Quadratic|Method comparison|Newton''s method|Steepest descent';
    res3 = str2mat('nnd9sdq','nnd9mc','nnd9nm','nnd9sd');
  elseif arg1 == 10
    res1 = 'Widrow-Hoff Learning';
    res2 = 'Adaptive noise cancellation|EEG noise cancellation|Linear classification';
    res3 = str2mat('nnd10nc','nnd10eeg','nnd10lc');
  elseif arg1 == 11
    res1 = 'Backpropagation';
    res2 = 'Network Function|Backpropagation Calculation|Function Approximation|Generalization';
    res3 = str2mat('nnd11nf','nnd11bc','nnd11fa','nnd11gn');
  elseif arg1 == 12
    res1 = 'Variations on Backpropagation';
    res2 = ['Steepest Descent #1|Steepest Descent #2|Momentum|Variable Learning Rate|',...
            'C.G. Line Search|Conjugate Gradient|Marquardt Step|Marquardt'];
    res3 = str2mat('nnd12sd1','nnd12sd2','nnd12mo','nnd12vl','nnd12ls','nnd12cg','nnd12ms','nnd12m');
  elseif arg1 == 13
    res1 = 'Associative Learning';
    res2 = 'Unsupervised Hebb|Effects of Decay Rate|Hebb with Decay|Graphical Instar|Instar|Outstar';
    res3 = str2mat('nnd13uh','nnd13edr','nnd13hd','nnd13gis','nnd13is','nnd13os');
  elseif arg1 == 14
    res1 = 'Competitive Networks';
    res2 = ['Competitive Classification|Competitive Learning|1-D Feature Map|',...
            '2-D Feature Map|LVQ1|LVQ2'];
    res3 = str2mat('nnd14cc','nnd14cl','nnd14fm1','nnd14fm2','nnd14lv1','nnd14lv2');
  elseif arg1 == 15
    res1 = 'Grossberg Network';
    res2 = ['Leaky Integrator|Shunting Network|Grossberg Layer 1|', ...
            'Grossberg Layer 2|Adaptive Weights'];
    res3 = str2mat('nnd15li','nnd15sn','nnd15gl1','nnd15gl2','nnd15aw');
  elseif arg1 == 16
    res1 = 'Adaptive Resonance Theory';
    res2 = 'ART1 Layer 1|ART1 Layer 2|Orienting Subsystem|ART1 Algorithm';
    res3 = str2mat('nnd16al1','nnd16al2','nnd16os','nnd16a1');
  elseif arg1 == 17
    res1 = 'Stability';
    res2 = 'Dynamical system';
    res3 = 'nnd17ds';
  elseif arg1 == 18
    res1 = 'Hopfield Network';
    res2 = 'Hopfield Network';
    res3 = 'nnd18hn';
  else
    res1 = 'Not a chapter';
    res2 = '';
    res3 = '';
  end

%==================================================================
% Set up the demo menus.
%
% NNDTOC('menus',X)
% Displays demo menus in TOC window given a vector of up to
% four chapter numbers.
%==================================================================

elseif strcmp(cmd,'menus') & (nargin == 2) & (fig)
  
  % GET DATA
  icons = get(icon_ptr,'userdata');
  texts = get(text_ptr,'userdata');
  menus = get(menu_ptr,'userdata');
  
  chapters = min(4,length(arg1));
  delete(icons);
  set(texts,'visible','off');
  set(menus,'visible','off');
  drawnow

  for i=1:chapters,
    chapter = arg1(i);
    [name,demos] = nndtoc('chap',chapter);
    set(texts(i),'string',name);
    menu_str = sprintf('Chapter %g demos',chapter);
    if length(demos)
      menu_str = [menu_str '|' demos];
    end
    set(menus(i),'string',menu_str);
    set(menus(i),'userdata',chapter);
  end

  icons = [];
  for i=1:chapters,
    chapter = arg1(i);
    offset = 60*i;
    icons = [icons; nndicon(chapter,115,360-offset,'shadow')];
  end

  set(texts(1:chapters),'visible','on');
  set(menus(1:chapters),'visible','on');

  % SAVE DATA
  set(icon_ptr,'userdata',icons);

%==================================================================
% Respond to menu selection.
%
% NNDTOC('select',menu_number)
% Runs the appropriate demo from one of the four menus (1-4).
%==================================================================

elseif strcmp(cmd,'select') & (nargin == 2) & (fig)

  % GET DATA
  menus = get(menu_ptr,'userdata');
  
  chapter = get(menus(arg1),'userdata');
  demo = get(menus(arg1),'value')-1;
  set(menus(arg1),'value',1);  

  if (demo)
    [name,demos,funcs] = nndtoc('chap',chapter);
    func = deblank(funcs(demo,:));
    fig = nndfgflg(func);
    if (fig)
      figure(fig)
    else
      eval(func);
    end
  end

%==================================================================
% Close TOC window.
%
% NNDTOC('close')
%==================================================================

elseif strcmp(cmd,'close') & (fig)

  delete(fig)
end

