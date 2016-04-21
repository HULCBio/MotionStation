function view_mdlrefs(modelName,varargin)
% VIEW_MDLREFS Display the model reference dependency graph
%
%   Input: 
%      modelName - Name of a Simulink model
%
%   view_mdlrefs('modelName') will display the model reference dependency 
%   graph for a model. The nodes in the graph represent Simulink models. 
%   The directed lines indicate model dependencies. For more information,
%   see the mdlref_depgraph demo.
%
%   Known limitations:
%     - Do not save the figure as a MATLAB figure (*.fig). Some of the 
%       callbacks may not work.
%
%
  
%   Copyright 1994-2004 The MathWorks, Inc.
%   $Revision: 1.1.4.2 $
  
%   Inputs for internal use only:
%      inCurrFig - If true, display the graph in the current figure.
%                  Otherwise a new figure is created to show the graph. 
%
%      skipLicenseCheck - If true, skip license check.   
  
%% Check inputs
if ~(nargin > 0 &&  nargin < 4)
  error('usage: view_mdlrefs(ModelName)');
end

if ~ischar(modelName),
  % must be a handle to an open model
  if ~ishandle(modelName),
    error('view_mdlrefs: the first input must be a model name');
  end
  modelName = get_param(modelName,'Name');
else
  % load the model if it is not loaded
  load_system(modelName);
end

% For internal use only. Display the graph in the current figure or not
nvarargs = nargin - 1;
inCurrFig = false;
if (nvarargs > 0) 
  inCurrFig = varargin{1};
  isOk = islogical(inCurrFig);
  if ~isOk
    error('view_mdlrefs: the second input must be true/{false}');
  end
end

% For internal use only. Skip license check or not.
nvarargs = nargin - 1;
skipLicenseCheck = false;
if (nvarargs > 1) 
   skipLicenseCheck = varargin{2};
  isOk = islogical(skipLicenseCheck);
  if ~isOk
    error('view_mdlrefs: the third input must be true/{false}');
  end
end

% do not disp backtraces when reporting warning
wStates = [warning; warning('query','backtrace')];
warning off backtrace;
warning on;

try
  % Call graphviz to generate modelName.dot file
  coordinateFile = gen_coordiante_file_l(modelName, skipLicenseCheck);
  
  % Read the coordinate file
  grp = read_coordinate_file_l(coordinateFile);
  
  % Prepare a figure to display the graph
  ss  = construct_fig_and_struct_l(modelName, grp, inCurrFig); 
  
  % Create axes, nodes and lines
  ss = create_axes_nodes_and_lines_l(ss, grp);
  
  % Display the graph
  view_graph_l(ss);
catch
  cleanup_l(wStates);
  rethrow(lasterror)
end
cleanup_l(wStates);
%endfunction

% ========================================================================
function cleanup_l(wStates)
warning(wStates);
%endfunction

% ========================================================================
% Create axes, and draw nodes and lines
function ss = create_axes_nodes_and_lines_l(ss, grp)
  
  % Generate the width and height of the graph, and create corresponding
  % axis to show it. Note that Y-axis is reversed to display the graph 
  % top down. The width and height is set to be a little bit larger than 
  % original size to avoid cutting off the circles at boundaries.
  ax  = axes('parent', ss.hg.fig, 'ydir', 'reverse', ...
             'units','points','visible','off');
  [xLimits, yLimits] = find_best_limits(grp);
  set(ax,'xlim', [xLimits(1) xLimits(2)], 'ylim', [yLimits(1)  yLimits(2)]);
  
  % Add annotation at the bottom of the graph (at the position of x-label)
  xlableH = xlabel('Click on a node to open the model', ...
                   'fontname', 'times', 'fontunits','points', ...
                   'fontsize', 14, 'color', 'k', 'visible', 'on'); 
  
  % Draw nodes
  % Get the biggest font size possible
  biggestFontsize = find_biggest_font_size(grp.nodes);
  % Draw node by node
  
  % Preallocate r and l (mlint warning)
  r = zeros(1, length(grp.nodes));
  t = zeros(1, length(grp.nodes));
  for i = 1:length(grp.nodes)
    node  = grp.nodes(i);  
    x     = node.location(1);
    y     = node.location(2);
    w     = node.location(3);
    h     = node.location(4);
    r(i)  = rectangle('pos', [x-w/2 y-h/2 w h], ...
                      'curvature', [1 1],'tag', node.name{1},'LineWidth',2);
    
    t(i)  = text(x,y, node.name,'vert','middle', ...
                 'horiz','center', 'fontname', 'times', 'fontunits','points', ...
                 'interp','none', 'fontsize', biggestFontsize);
    set(t(i), 'fontunits', 'norm');
  end
  
  % Draw edges
  if  isempty(grp.edge)
    l = []; a = [];
  else
    for i = 1:length(grp.edge)
      edge  = grp.edge(i);
      [l(i) a(i)] = draw_edge_l(grp, edge);
    end
  end
  
  % Store the node, edge, and axes info.
  ss.hg.nodes  = r;
  ss.hg.texts  = t;
  ss.hg.lines  = l;
  ss.hg.arrows = a;
  ss.hg.xlabel = xlableH;
  ss.hg.axes   = ax;
  set(ss.hg.fig, 'userdata', ss);
%endfunction

% ========================================================================
function [xLimits, yLimits] = find_best_limits(grp)
% Some of the info in dot is not accurate. For example, here is the
% location of a node: 
%  R: [0.486 0.361 0.990 0.500] [xCenter, yCenter, Width, Height]
% 
%  In this case, 0.486 -  0.990/2 = -0.0090
%
% Therefore, some part of the node may not be displayed if the
% xlim starts from 0. Therefore, xlim and ylim must be adjusted properly

xMin = 0; 
xMax = grp.graphWidth;

yMin = 0;
yMax = grp.graphHeight;

for i = 1:length(grp.nodes)
  node  = grp.nodes(i);  
  xC  = node.location(1);
  yC  = node.location(2);
  w   = node.location(3);
  h   = node.location(4);
  
  xLeft = (xC - w/2);
  xRight = (xC + w/2);
  
  xMin = min(xMin, xLeft);
  xMax = max(xMax, xRight);
  
  yButtom = (yC - h/2);
  yTop    = (yC + h/2);
  
  yMin = min(yMin, yButtom);
  yMax = max(yMax, yTop);
end
%% Should we add an extra offset?
xLimits = [xMin  xMax];
yLimits = [yMin  yMax];

%endfunction

  
% ========================================================================
function ss = construct_fig_and_struct_l(modelName, grp, inCurrFig)
% Create a figure or use existing figure to display Model reference
% dependency graph
  
if ~inCurrFig  %Creat a new figure 
  hfig = figure;
  hfig = setup_figure(modelName, hfig);
  
  % Modify menu bar            
  hfig = modify_menu_l(hfig);
  
  set(0,'units','points');
  scrsz   = get(0,'ScreenSize'); % [l, b, w, h]
    
  % figure related data coordinate initialization
  ss = create_default_struct();
  
  % Put the figure at the right position on screen and choose the 
  % right figure size.
  % If either graph's width is larger than 3/4 of the screen width, 
  % or the graph's height is larger than 3/4 of the screen height,
  % shrink the graph size so that the longest side is equal to 3/4
  % of the corresponding screen size. Otherwisej, use the orginal 
  % graph size.   
  % Note: Multiplication of 72 converts unit from 'inche' to 'point'. 
  % bottomMargin is used to accormodate the annotation.

  
  if  ((72*grp.graphHeight) > (3/4)*scrsz(4)) || ...
        ((72*grp.graphWidth) > (3/4)*scrsz(3))
    [oH, oW] = fit_rect_inside_rect_l(((3/4)*scrsz(4)), ...
                                      ((3/4)*scrsz(3)), ...
                                      grp.graphHeight, ...
                                      grp.graphWidth);
  else  % Use original graph size
    oH = 72*grp.graphHeight;
    oW = 72*grp.graphWidth;
  end
  
  h = oH + ss.hg.bottomMargin + ss.hg.topMargin;
  w = oW + ss.hg.xMargin;
  R = [ss.hg.figxMargin (scrsz(4)-h-ss.hg.figtopMargin) w h];
  
  set(hfig, 'Position', R);
else
  % Reset the current figure 'hfig', and setup the figure for 
  % Model reference dependency graph
  %
  hfig = gcf;
  clf(hfig, 'reset');
  hfig = setup_figure(modelName, hfig);
end

% figure initialization
ss = create_default_struct();
ss.modelName = modelName;
ss.hg.fig    = hfig;
ss.graph     = grp;

% Prepare the text handle for display highlight text 
ss.focusText    = text(0,0,0,'unset','visible','off', ...
                       'color','blue', ...
                       'VerticalAlignment', 'middle', ...
                       'HorizontalAlignment','center', ...
                       'fontname', 'times', ...
                       'fontunits','normalized', ...
                       'Interpreter','none');
% Turn off the axis. Otherwise, focusText causes the figure to have axis
axis off;
ss.highlightColor   = [0 .95 .95];

% persist statestruct 
set(ss.hg.fig, 'userdata', ss);
%endfunction

% ========================================================================
function ss = view_graph_l(ss)
% Display the graph
%
figPos  = get(ss.hg.fig, 'pos');

% Adjust the size of graph to make full use of the figure size
X   = 0;
Y   = 0;
W   = figPos(3);
H   = figPos(4);
xlim    = get(ss.hg.axes, 'xlim');
ylim    = get(ss.hg.axes, 'ylim');
axPos  = fit_rect_inside_rect_with_bound_l([X Y W H], ...
                                            ylim(2)-ylim(1), ...
                                            xlim(2)-xlim(1), ...
                                            ss.hg.xMargin, ...
                                            ss.hg.topMargin, ...
                                            ss.hg.bottomMargin);
set(ss.hg.axes, 'pos', axPos);

% Increase the width of figure if it cannot hold the entire annotation.
extent  = get(ss.hg.xlabel, 'extent');
requiredW = (extent(3) / (xlim(2) - xlim(1))) * axPos(3) + 2*ss.hg.xMargin;
if (requiredW > W)   % length of xlabel is longer than fig width
    newFigPos   = [figPos(1) figPos(2)  requiredW figPos(4)];
    set(ss.hg.fig, 'pos', newFigPos);
end

drawnow;
set(ss.hg.fig, 'visible','on');
%endfunction

% ========================================================================
function hfig = setup_figure(modelName, hfig)
% Set up the figure
%
  set(hfig, 'windowbuttonmotion', @mouse_move_l, ...
            'windowbuttondown',   @mouse_down_l, ...
            'windowbuttonup',     @mouse_up_l, ... 
            'resizefcn',          @resize_l, ...
            'tag', '_MRDG_',...
            'color','w','numbertitle','off', ...
            'Name', ['Model Reference Dependency Graph: ' modelName], ...
            'visible', 'off', ...
            'doublebuffer','on', ...
            'units','points');
  set(hfig, 'PaperPositionMode', 'auto');
%endfunction  

% ========================================================================
function hfig = modify_menu_l(hfig)
% Restructure the menu bar  
%
pushTool    = findall(hfig, 'type', 'uitoolbar');
delete(pushTool);
menuName    = {'&Window', '&Desktop', '&Tools','&Insert', ...
            '&View', '&Edit'}; 
for i=1:length(menuName)          
  tmpH  = findall(hfig, 'type', 'uimenu', 'label', menuName{i});
  delete(tmpH);
end

% Get rid of some entries in the 'help' menu
%%    '&About MATLAB'
%%    '&Demos'
%%    'Check for &Updates'
%%    '&Web Resources'
%%    '&Printing and Exporting'
%%    '&Annotating Graphs'
%%    '&Plotting Tools'
%%    '&Graphics Help'
keepItems = {'&Demos','&About MATLAB'};
menuEntryName   = '&Help';
[entryH, childEntryH] = modify_menu_entry_l(hfig, menuEntryName,keepItems);

% Get rid of some entries in the 'file' menu
%
%% '&Exit MATLAB'
%% '&Print...'
%k 'Print Pre&view...'
%k 'Print Set&up...'
%k 'Pa&ge Setup...'
%% 'Expo&rt Setup...'
%% 'Pre&ferences...'
%% 'Save &Workspace As...'
%% '&Import Data...'
%% 'Generate &M-File...'
%k 'Save &As...'
%% '&Save'
%k '&Close'
%k '&Open...'
%% '&New'
keepItems = {'&Open...','&Close','Save &As...','Pa&ge Setup...','&Print...'};
menuEntryName   = '&File';
[entryH, childEntryH]   = modify_menu_entry_l(hfig, menuEntryName,keepItems);

% Add entry 'refresh' 
uimenu(entryH, 'position', 4, 'label', '&Refresh', 'Separator', ...
       'on', 'Callback',  {@refresh_mdlref_l});

% Add entry 'Model Explorer'   
uimenu(entryH, 'position', 5, 'label', 'Open Model &Explorer', 'Separator', ...
       'on', 'Callback',  {@model_explorer_l});

% Add entry 'Save all referenced models'
uimenu(entryH, 'position', 6, 'label', 'Save All Models', 'Separator', ...
       'on', 'Callback',  {@save_all_ref_mdl_l});
   
% Add entry 'Open all referenced models'
uimenu(entryH, 'position', 7, 'label', 'Open All Models', 'Separator', ...
       'off', 'Callback',  {@open_all_ref_mdl_l});

% Add entry 'Close all referenced models'
uimenu(entryH, 'position', 8, 'label', 'Close All Models', 'Separator', ...
       'off', 'Callback',  {@close_all_ref_mdl_l});
set(childEntryH(5), 'Separator', 'on');
%endfunction

% ========================================================================
function [menuEntryH, entryH] = modify_menu_entry_l(hfig, menuEntryName,keepItems)
% Get rid of some entries in the menu
menuEntryH  = findall(hfig, 'type', 'uimenu', 'label', menuEntryName);
entryH  = allchild(menuEntryH);

entryHLabels = get(entryH,'label');

num = length(keepItems);
numTotal = length(entryHLabels);
deleteFlags = ones(1,numTotal);
for idx = 1:num
  fIdx = strmatch(keepItems{idx}, entryHLabels);
  if isempty(fIdx)
    error(['Internal error: cannot find ', keepItems{idx}, ' in the File menu']);
  end
  deleteFlags(fIdx) = 0;
end
deleteItems = find(deleteFlags);
delete(entryH(deleteItems));


% ========================================================================
function [l a]   = draw_edge_l(grp, edge)
%
% Draw one edge
%
% Find the srcNode and dstNode;
srcNode = find_node_by_name_l(grp, edge.src);
dstNode = find_node_by_name_l(grp, edge.dst);

if ~isempty(srcNode) && ~isempty(dstNode)
  xdata = edge.xdata;
  ydata = edge.ydata;
  %% Self loop is not allowed
  %
  %                     | [X2,Y2]
  %                    /|\          
  %                   /|||\         
  %                  //|||\\        
  %                 ///|||\\\       
  %                ////|||\\\\      
  %               /////|||\\\\\     
  %              //////|||\\\\\\
  %             ///////|||\\\\\\\
  %        [X3,Y3]    [X,Y]    [X1,Y1]
  %
  if length(xdata) > 1 && length(ydata) > 1
    % The points on edge reported in the .plain file are always in 
    % the top-down order. 
    % So if the position of dstNode is lower than that of srcNode, add 
    % the arrow at the end of edge. Otherwise, the arrow should point
    % upwards and be added at the beginning of the edge.
    fromSrcToDst   = is_top_down_l(srcNode, dstNode, edge);

    if fromSrcToDst
      last2X    = xdata((end-1):end);
      last2Y    = ydata((end-1):end);        	
    else
      last2X    = [xdata(2) xdata(1)];
      last2Y    = [ydata(2) ydata(1)];
    end
    
    X   = last2X(2);
    Y   = last2Y(2);
    dx  = last2X(2) - last2X(1);
    dy  = last2Y(2) - last2Y(1);    	
    dd  = .09;
    theta   = atan2(dy,dx);
    dxx = dd*cos(theta);
    dyy = dd*sin(theta);      
    % compute arrowHead tip location
    X2  = X+dxx;
    Y2  = Y+dyy;            

    % compute arrow head legs.
    gamma   = pi/9;
    rotateRight = [cos(gamma) sin(gamma); -sin(gamma) cos(gamma)];
    rotateLeft  = [cos(-gamma) sin(-gamma); -sin(-gamma) cos(-gamma)];
    arrowV(1,1) = -dxx;
    arrowV(2,1) = -dyy;    
    rightLeg    = rotateRight*arrowV;
    leftLeg     = rotateLeft*arrowV;
    X1  = X2 + rightLeg(1);
    Y1  = Y2 + rightLeg(2);
    X3  = X2 + leftLeg(1);
    Y3  = Y2 + leftLeg(2);
    arrowX  = [X1 X2 X3];
    arrowY  = [Y1 Y2 Y3];    
 
    % draw the arrow
    a   = line('xdata', arrowX, 'ydata', arrowY, 'linewidth', 1);
    patch(arrowX, arrowY, 'k');
    
    % draw the edge using spline curve
    if fromSrcToDst
        entireLineX = [xdata X2];
        entireLineY = [ydata Y2];
    else
        entireLineX = [X2 xdata];
        entireLineY = [Y2 ydata];
    end
    entireLine  = [entireLineX; entireLineY];
    c   = spcrv_l(entireLine(:, [1 1 1 1 1 1 1 1 1 1 : ...
                        end end end end end end end end end end]), 10);
    l   = line('xdata', c(1,:), 'ydata', c(2,:),  'linewidth', 1.5);
  end
end
%endfunction


% ========================================================================
function fromSrcToDst = is_top_down_l(srcNode, dstNode, edge)
% fromSrcToDst = true if edge points is from srcNode to dstNode. False otherwise.
%
% We use the distances between the ending/starting point and the center of 
% dstNode to determine whether the edge points is from srcNode to dstNode 
% More specifically, if the ending point is closer to the dstNode than the 
% starting point, we infer that the edge points are from srcNode to
% dstNode, and vice versa.
%
% Because the shape of dstNode are ellipse, following formula is used to 
% compute the distance between a point and the node.
%
% Ellipse (node) width and height: [nh, nw]
%
%
%             (x^2)   (y^2)
%   c(x,y) = ------ + -----  
%             (nw^2)  (nh^2)
%
% For given [x1,y1] and [x2, y2], if c(x1,y1) < c(x2, y2), [x1,y1] is closer
% to the node than [x2, y2].
%

% Find node eclipse's heigth and width
dW   = dstNode.location(3);
dH   = dstNode.location(4);

xdata = edge.xdata;
ydata = edge.ydata;

x1  = xdata(1) - dstNode.location(1);
y1  = ydata(1) - dstNode.location(2);
x2  = xdata(end) - dstNode.location(1);
y2  = ydata(end) - dstNode.location(2);

%compute 
c1 = (x1*x1) / (dW * dW) + (y1*y1) / (dH*dH);
c2 = (x2*x2) / (dW * dW) + (y2*y2) / (dH * dH);

if c1 > c2 % [x1, y1] is closer to srcNode than the dstNode
    fromSrcToDst   = true;
else
    fromSrcToDst   = false;
end
%endfunction

% ========================================================================
function curve = spcrv_l(x,k)
% This is from matlab/toolbox/splines/spcrv.m
  y = x; kntstp = 1;
  [d,n] = size(x);
  if n<k
    error(['Internal error: the number of points, %.0f, should be ', ...
           'at least as \n',...
           'big as the given order, k = %.0f'],n,k);
  elseif k<2
    error('Internal error: The order, k = %.0f, should be at least 2.',k);
  else
   if k>2
     maxpnt = 100; 
     while n<maxpnt
       kntstp = 2*kntstp; m = 2*n; yy(:,2:2:m) = y; yy(:,1:2:m) = y;
       for r=2:k
            yy(:,2:m) = (yy(:,2:m)+yy(:,1:m-1))*.5;
       end
       y = yy(:,k:m); n = m+1-k;
     end
   end
  end
  curve = y;
%endfunction
  
% ========================================================================
function mouse_move_l(fig, arg)
%
% Callback function of mouse moving
%
ss  = get(fig, 'userdata');
broadcast_l(ss, 'MM');
   
% ========================================================================
function mouse_down_l(fig, arg)
%
% Callback function for mouse down
%
ss = get(fig, 'userdata');
broadcast_l(ss, 'MD');
  
% ========================================================================
function mouse_up_l(fig,arg)
%
% Callback function for mouse up
%
ss = get(fig, 'userdata'); 
broadcast_l(ss, 'MU');
  
% ========================================================================
function broadcast_l(ss, event, arg)
% Events:
%   MM ==> Mouse Motion
%   MD ==> Mouse Down
%   MU ==> Mouse Up
% 
%
switch (ss.state),
 case 'Idle',
  switch event,
   case 'MM', ss = update_focus_state_l(ss);
   case 'MU', 
    switch ss.focusState,
     case 'Node',
      if ss.focusInd > 0
        open_system(ss.graph.nodes(ss.focusInd).name);   
      end
     otherwise
    end
   otherwise     
    % do nothing 
  end
 case 'Rendering', % do nothing during renders.
 otherwise
end
% Persist statestructure
set(ss.hg.fig, 'userdata', ss);
%endfunction

% ========================================================================
function ss = update_focus_state_l(ss)
% Update the focus state 
%

ss.focusState = 'None';
p   = get(ss.hg.axes, 'currentpoint');

% Get the coordidate of mouse (Current point is a matrix of 2x3).
x   = p(1);
y   = p(3);

% Attempt to find the node id if mouse is pointing on
focusInd = 0;                  % Assume invalid index
for i = 1:length(ss.hg.nodes)
  r     = ss.hg.nodes(i);
  pos   = get(r, 'pos');
  if x > pos(1) && x < pos(1)+pos(3) && ...
        y > pos(2) && y < pos(2)+pos(4)
    focusInd      = i;
    ss.focusState = 'Node';
    break;
  end;
end;

% If over something new hightlight it.
if focusInd > 0
  if focusInd ~= ss.focusInd
    % De-highlight all nodes
    set(ss.hg.nodes, 'facecolor', 'none');
    ss.focusInd = focusInd;
    set(ss.hg.nodes(focusInd), 'facecolor', ss.highlightColor);
    
    % now set focus text
    t   = ss.hg.texts(focusInd);
    update_focus_text_l(ss.focusText, t)
  end;
else
  % if you're over nothing, dehighlight all
  set(ss.hg.nodes, 'facecolor', 'none');
  ss.focusInd = 0; %% invalid index
  update_focus_text_l(ss.focusText, []);
end
%endfunction

% ========================================================================
function resize_l(fig, arg)
% Figure has been resized. Update graph pos while maintainging 
% data aspect ratio.
%
ss = get(fig, 'userdata');
if isempty(ss)
  return; 
end

figPos  = get(ss.hg.fig, 'pos');

figW    = figPos(3);
figH    = figPos(4);
  
% Make axes as big as possible inside figPos such that it's aspect
% ratio is not compromised.
grp     = ss.graph;

% For the first time resize, ss.graph is empty so no action is required
r = fit_rect_inside_rect_with_bound_l([0 0 figW figH], ...
                                      grp.graphHeight, grp.graphWidth, ...
                                      ss.hg.xMargin, ss.hg.topMargin, ...
                                      ss.hg.bottomMargin);

if (r(3) > 0) && (r(4) > 0)
  %% Width and height must be > 0
  set(ss.hg.axes, 'pos', r);
end
%endfunction

% ========================================================================
function matchNode = find_node_by_name_l(grp, name)
%
% Locate the node of 'name'
%
matchNode   = [];
for i = 1:length(grp.nodes),
  node  = grp.nodes(i);
  if isequal(node.name, name),
    matchNode = node;
    return;
  end;
end;

% ========================================================================
function oR = fit_rect_inside_rect_with_bound_l(iR, h, w, xMargin,...
    topMargin, bottomMargin)
%                            ________________
%                           |  ------------  |
%      ______               | |            | |
%     h|    |             H | |           oH |
%      |____|               | |________oW__| |
%        w                  | [oX, oY]       |
%                           |----------------|
%                        [X Y]      W
%
%  hw = h/w
%  iR:[X Y W H] (left, buttom, width, height)
%
% Maximumly use the size of (ratio * graph-size). Leave bottomMargin as blank 
% at the bottom of the graph
%
X   = iR(1);
Y   = iR(2);
W   = iR(3);
H   = iR(4);

if  H > topMargin + bottomMargin
  H = H - topMargin - bottomMargin; 
  Y = Y + bottomMargin;
end

if  W > xMargin
  W = W - 2*xMargin;
  X = X + xMargin;
end

[oH, oW] = fit_rect_inside_rect_l(H,W,h,w);

oX = X + (W - oW)/2;
oY = Y + (H - oH)/2;

oR = [oX oY oW oH];
%endfunction

% ========================================================================
function [oH, oW] = fit_rect_inside_rect_l(H,W,h,w)
  rw = W/w;
  rh = H/h;
  
  minr = min(rw, rh);
  
  oW = minr*w;
  oH = minr*h;

% ========================================================================
function update_focus_text_l(focusT, t)
% Input: focusT and t are text objects.
% If t is not empty => set focus to t.
%    focusT which is a global variable, get all 
%    properities of t, and become visiable. UserData of focusT will store
%    t's handle.
% If t is empty => reset what focusT is pointing to
  
if isempty(t)
  % de-highlight what focusT is pointing to
  set(focusT, 'Visible','off');
  oldT  = get(focusT, 'userdata');
  if ~isempty(oldT),
    set(oldT, 'Visible','on');
  end
else
  % hilight t
  oldT  = get(focusT, 'userdata');
  if ~isempty(oldT) && ~isequal(oldT, t)
    set(oldT, 'visible','on');
  end
  set(t,'fontunits', 'points');
  fs    = get(t, 'fontsize');
  set(t,'fontunits', 'normal');
  fsN   = get(t, 'fontsize');
  
  minFS = 10;
  if (fs < minFS)
    set(focusT, 'fontunits', 'points', 'fontsize', minFS);
  else
    set(focusT, 'fontunits','normal', 'fontsize', fsN);
  end
  
  set(focusT, 'parent', get(t,'parent'), 'string', get(t, 'string'), ...
              'pos', get(t, 'pos'), 'userdata', t);
  set(t, 'visible','off');
  set(focusT, 'visible','on');
end
%endfunction

% ==================================================================
function biggestFontsize = find_biggest_font_size(nodes)
% Note that the longest string does not necessarily determine the 
% biggest font size since the node box size is different for 
% different length of strings.
  maxName = '';
  maxIdx  = -1;
  for i = 1:length(nodes) 
    if length(maxName) < length(nodes(i).name{1})
      maxName = nodes(i).name{1};
      maxIdx = i;
    end
  end
  
  % Find biggest font size (from font 5 to 30) that can fit all boxesq
  MAX_FONT_SIZE = 30;

  hText = text(0, 0, '', 'vert','middle', 'horiz', ...
               'center','visible', 'off', 'fontname', ...
               'times', 'fontunits', 'points');
  
  % Find the biggest font size possible
  node  = nodes(maxIdx);
  w = node.location(3);
  h = node.location(4);
  curFontsize = 5;
  lastFontsize = 5;
  set(hText, 'string', maxName, 'fontsize', curFontsize);
  t = get(hText, 'extent');

  while is_rect_inside_curve_l(t(4), t(3), h, w) &&  ...
        curFontsize < (MAX_FONT_SIZE +1)
    lastFontsize = curFontsize;
    curFontsize = curFontsize + 1;
    set(hText, 'fontsize', curFontsize);
    t = get(hText, 'extent');    
  end
  biggestFontsize = lastFontsize;
%endfunction
  
% =============================================================================
function retVal = is_rect_inside_curve_l(th, tw, nh, nw)
% Text width and height:           [tw, th]
% Ellipse (node) width and height: [nh, nw]
%
% Ellipse:
%
%             (x^2)   (y^2)
%   c(x,y) = ------ + -----  = 1
%             (nw^2)  (nh^2)
%
% For a given [x,y], if c(x,y) < 1, [x,y] is inside the ellipse
%
retVal = false;
c = ((tw*tw)/(nw*nw)) + ((th*th)/(nh*nh));
if c < 1
  retVal = true;
end
%endfunction

% =============================================================================
% Call callgraphviz to generate coordinate file (model.plain)  from 
% model.dot file
function coordinateFile = gen_coordiante_file_l(modelName, skipLicenseCheck)
% Generates modelName.dot
mdls = find_mdlrefs(modelName,true,true);
if length(mdls) == 1
    coordinateFile  = gen_single_node_coordinate_file_l(modelName);
else
    coordinateFile  = gen_coordinate_file_using_graphviz_l(modelName, ...
        skipLicenseCheck);
end
%endfunction

% =========================================================================
function coordinateFile  = gen_coordinate_file_using_graphviz_l(modelName, ...
        skipLicenseCheck)
  % Call callgraphviz to generate coordinate file (model.plain)  from 
  % model.dot file
  cr  = sprintf('\n');
  if ~skipLicenseCheck
    status = callgraphviz('simulink','GetLicenseAcceptedStatus');
    if ~status
      licenseText = sprintf(callgraphviz('simulink','GetLicense'));
      msg = ['VIEW_MDLREFS uses GraphViz ("AT&T software") ', cr,...
             'to find the coordinates of nodes and lines in the model ', cr,...
             'reference dependency graph. Please read the following', cr, ...
             'information about the AT&T software license agreement: ', cr,cr];
      fullmsg = [msg, licenseText];
      response = questdlg(fullmsg, 'Attention:', ...
                          'Accept license', 'Cancel', 'Cancel');
      
      if isempty(response) || strcmp(response, 'Cancel')
        error(['view_mdlrefs: Viewing model reference dependency ', ...
               'graph was canceled by user']);
      else
        callgraphviz('simulink','SetLicenseAcceptedStatus', true);
      end    
    end
  end

  % Generate coordinate file
  dotModelName = [modelName, '.dot'];
  plainModelName = [modelName, '.plain'];
  promptLicense = 'PromptLicense';
  status = callgraphviz('simulink', promptLicense,'dot','-Tplain', ...
                        dotModelName,'-o',plainModelName);
  if status ~= 0
    error(['view_mdlrefs: Error occurred while generating ', ...
           'file ''', dotModelName, '''. ']);
  end
  
  % Check the existence of .plain file
  coordinateFile  = [modelName,'.plain'];
  if exist(coordinateFile) ~= 2
    error(['Internal error: file ', coordinateFile, ' does not exist']);
  end
%endfunction

% =========================================================================
function coordinateFile = gen_single_node_coordinate_file_l(modelName)
% If the model does not use any referenced models, 
% generate a coordiante file with a single node.
%
coordinateFile  = [modelName,'.plain'];
[fid, errmsg] = fopen(coordinateFile, 'w');
if fid == -1
  error(['Error creating file ''', coordinateFile, ''': ', errmsg]);
end

% Set box height and graph height to some default value (in inches)
nh       = 0.5; % all nh in .plain files is 0.5
ylim     = 2; 
xlim     = 1;
fontSize = 18; 

nw  = infer_node_width(xlim, ylim, modelName, nh, fontSize);
xlim = max(xlim, nw);

cr  = sprintf('\n');
msg = ['graph 1.000 ', num2str(xlim), ' ', num2str(ylim), cr,      ...
       'node ', modelName, ' ', num2str(xlim/2),                   ...
       ' ', num2str(ylim/2), ' ', num2str(nw), ' ',                ...
       ' ', num2str(nh), ' ', modelName,                           ...
       ' solid ellipse black lightgrey', cr,                       ...
       'stop', cr];
fwrite(fid, msg);
fclose(fid);
%endfunction

% =========================================================================
function nw = infer_node_width(xlim, ylim, modelName, nh, fontSize)
%  Infer the required width of node for showing the model name.
%

% Set up an ax with scale [0 xlim] and [0 ylim]
tempfigure = figure;
ax  = axes('parent', tempfigure, 'units','points','visible','off');
set(ax,'xlim', [0 xlim], 'ylim', [0 ylim]);

% Write the modelName, and get its size
h   = text(0, 0, modelName, 'fontsize', fontSize, 'vis', 'off', 'fontunits', 'point');
extent  = get(h, 'extent');

% Find the actual size (height and wdith) of text.
% Note: Divided by 72 to convert unit from point to inch
axPos   = get(ax, 'pos');
tw  = (extent(3) / xlim) * axPos(3) /72;
th  = (extent(4) / ylim) * axPos(4) /72;

% Copmputer the required node width assuming node is displayed as a ellipse
nw  = tw / sqrt(1 - (th *th)/ (nh*nh));

delete(tempfigure);
%endfunction  

% =============================================================================
function grp = read_coordinate_file_l(fileName)
  % Return a structure containing the following fields:
  % 
  % grp.graphScaleFactor
  % grp.graphWidth
  % grp.graphHeight
  % grp.hwRatio
  %
  % grp.nodes(:).name
  % grp.nodes(:).location
  %
  % grp.edge(:).src
  % grp.edge(:).dst
  % grp.edge(:).N
  % grp.edge(:).xdata
  % grp.edge(:).ydata
    
  f=fopen(fileName,'r');
  %initialize grp
  grp.edge  = [];
  grp.nodes = [];
  
  l=fgetl(f);
  [graphScaleFactor,graphWidth, graphHeight] = ...
      strread(l,['graph %n %n %n'],'delimiter',' ');
  grp.graphScaleFactor = graphScaleFactor;
  grp.graphWidth = graphWidth;
  grp.graphHeight = graphHeight;
  
  doRead=true;
  idx = 1;
  firstedge = true;
  while doRead && (~feof(f))
    l=fgetl(f);
    entryType = strread(l,'%4c',1,'delimiter',' ');
    switch entryType
     case 'node'
      [nodeName xlocation ylocation xsize ysize t1 t2 tt3 t4] = ...
	  strread(l,'node %s %n %n %n %n %s %s %s %s',1);
      
      ylocation = grp.graphHeight - ylocation;  %move origin to upper left.
      grp.nodes(idx).name   = nodeName;
      grp.nodes(idx).location   = [xlocation,ylocation,xsize,ysize];
      idx = idx + 1;
     
     case 'edge'
      if firstedge
        idx = 1;
        firstedge = false;
      end
      [src dst N] =  strread(l,'edge %s %s %n', 1);  
      grp.edge(idx).src = src;
      grp.edge(idx).dst = dst;
      grp.edge(idx).N = N;
      
      % get rid of first 4 tokens that have already been processed
      r = l;
      for i=1:1:4
        [t r] = strtok(r);
      end

      %grp.edge(idx).xdata = [t1 t3 t5 t7];
      %grp.edge(idx).ydata = grp.graphHeight - [t2 t4 t6 t8];
      for i= 1:1:N
        [t1 r] = strtok(r);
        [t2 r] = strtok(r);
        t11 = str2double(t1);
        t22 = str2double(t2);
        grp.edge(idx).xdata(i) = t11;
        grp.edge(idx).ydata(i) = t22;
      end
      grp.edge(idx).ydata = grp.graphHeight - grp.edge(idx).ydata;
      idx = idx + 1;
      
     case 'stop'
      doRead = false;
     otherwise
      warning(['Invalid token ''', entryType, ''' not recognized.']);
    end % case
  end;% while
  if doRead
    error('Internal error: unexpected end of file in ''%s''.',fileName);
  end
  fclose(f);
  
  grp.hwRatio = grp.graphHeight / grp.graphWidth;
%endfunction 

% =============================================================================
function ss = create_default_struct
% Figure will have one axes

ss.modelName = '';

ss.hg.fig    = [];
ss.hg.axes   = []; 
ss.hg.nodes  = []; 
ss.hg.texts  = []; 
ss.hg.lines  = [];
ss.hg.arrows = [];

ss.state            = 'Idle';
ss.focusInd         = 0; % Invalid index
ss.graph            = []; 
ss.focusText        = [];
ss.highlightColor   = [];

ss.hg.bottomMargin = 50;
ss.hg.topMargin    = 10;
ss.hg.xMargin      = 10;

ss.hg.figxMargin   = 10;
ss.hg.figtopMargin = 50;

%endfunction

% =============================================================================
function refresh_mdlref_l(m, arg)

  ss = get(gcf, 'userdata');
  modelName = ss.modelName;
  
  view_mdlrefs(modelName,true);  
%endfunction

% =============================================================================
function model_explorer_l(m, arg)

  ss = get(gcf, 'userdata');
  modelName = ss.modelName;
  
  hda   = daexplr;
  open_system(modelName);
  mh = get_param(modelName,'object');
  hda.view(mh);
  %hide(hda);
%endfunction

% =============================================================================
function save_all_ref_mdl_l(m, arg)
% Save all modified referenced model
%
  
ss = get(gcf, 'userdata');
nodes = ss.graph.nodes;

% Retrieve the list of all models that are open in the system
openMdls = find_system('SearchDepth',0, 'type','block_diagram');
for i = 1:length(nodes)
  thisMdl = nodes(i).name{1};
  fIdx = strmatch(thisMdl,openMdls,'exact');
  if ~isempty(fIdx)
    isDirty   = get_param(thisMdl,'dirty');
    if strcmp(isDirty, 'on')
      save_system(thisMdl);
    end
  end 
end
%endfunction

% =============================================================================
function open_all_ref_mdl_l(m, arg)
% Open all modified referenced model
%
  
ss = get(gcf, 'userdata');
nodes = ss.graph.nodes;

for i = 1:length(nodes)
  open_system(nodes(i).name{1});
end
%endfunction

% =============================================================================
function close_all_ref_mdl_l(m, arg)
% Close all 'clean' referenced models. Leave the modified models alone
% and let users decide.

ss = get(gcf, 'userdata');
nodes = ss.graph.nodes;

% Retrieve the list of all models that are open in the system
openMdls = find_system('SearchDepth',0, 'type','block_diagram');
for i = 1:length(nodes)
  thisMdl = nodes(i).name{1};
  fIdx = strmatch(thisMdl,openMdls,'exact');
  if ~isempty(fIdx)
    isDirty   = get_param(thisMdl,'dirty');
    if strcmp(isDirty, 'off')
      close_system(nodes(i).name{1}, 0);
    else  %model is modified, ask user what to do
      cr    = sprintf('\n');
      msg  = ['The "', nodes(i).name{1}, '" model has unsaved ', ...
              'changes. Select: ', cr, ...
              '- "Save and Close" to save and close the model.', cr, ...
              '- "Close" to close the model without saving it.', cr, ...
              '- "Cancel" to leave the model open.'];

      ButtonName=questdlg(msg, ...
          'Attention:', ...
          'Save and Close','Close','Cancel', 'Save and Close');
      switch ButtonName,
        case 'Save and Close', 
            close_system(nodes(i).name{1}, 1);
        case 'Close',
            close_system(nodes(i).name{1}, 0);
        case 'Leave open',
            % do nothing
      end % switch
    end
  end 
end

%endfunction
