function nnd9mc(cmd,data)
%NND9MC Method comparison demonstration.

% $Revision: 1.6 $
% Copyright 1994-2002 PWS Publishing Company and The MathWorks, Inc.
% First Version, 8-31-95.

%==================================================================

% BRING UP FIGURE IF IT EXISTS

me = 'nnd9mc';
fig = nndfgflg(me);
if length(get(fig,'children')) == 0, fig = 0; end
if nargin == 0, cmd = ''; end

% CONSTANTS

xlim = [-2 2]; dx = 0.2;
ylim = [-2 2]; dy = 0.2;
zlim = [0 12];
xpts = xlim(1):dx:xlim(2);
ypts = ylim(1):dy:ylim(2);
[X,Y] = meshgrid(xpts,ypts);
xtick = [-2 0 2];
ytick = [-2 0 2];
ztick = [0 6 12];
circle_size = 10;

a=[2 1;1 2];
b=[0 0];
c=0;

% CREATE FIGURE ========================================================

if fig == 0

  % CONSTANTS
  lr = 0.03;
  lr_min = 0;
  lr_max = 0.2;
  F = (a(1,1)*X.^2 + (a(1,2)+a(2,1))*X.*Y + a(2,2)*Y.^2)/2 ...
         + b(1)*X + b(2)*Y +c;

  % STANDARD DEMO FIGURE
  fig = nndemof(me,'DESIGN','Comparison of Methods','','Chapter 9');
  str = [me '(''down'',get(0,''pointerloc''))'];
  set(fig,'windowbuttondownfcn',str);
  
  % UNLOCK AND GET HANDLES
  
  set(fig,'nextplot','add','pointer','watch')
  H = get(fig,'userdata');
  fig_axis = H(1);
  desc_text = H(2);
  
  % ICON
  
  nndicon(9,458,363,'shadow')
    
  % LEFT AXES
  left = nnsfo('a2','Steepest Descent','x(1)','x(2)');
  set(left, ...
    'xlim',xlim,'xtick',xtick, ...
    'ylim',ylim,'ytick',ytick,...
    'colororder',[nnblack; nnred; nngreen]);

  contour(xpts,ypts,F,[1.01 2 3 4 6 8 10]);
  text(0,1.7,'< CLICK ON ME >',...
    'horiz','center', ...
    'fontweight','bold',...
    'color',nndkblue);
  
  % RIGHT AXES
  right = nnsfo('a3','Conjugate Gradient','x(1)','x(2)');
  set(right, ...
    'xlim',xlim,'xtick',xtick, ...
    'ylim',ylim,'ytick',ytick,...
    'colororder',[nnblack; nnred; nngreen]);

  contour(xpts,ypts,F,[1.01 2 3 4 6 8 10]);
  text(0,1.7,'< CLICK ON ME >',...
    'horiz','center', ...
    'fontweight','bold',...
    'color',nndkblue);

  % TEXT
  nnsettxt(desc_text, ...
    'COMPARISON OF METHODS',...
    '',...
    'Click in either graph to create an initial search point.',...
    'Then watch the two algorithms attempt to find the minima.',...
    '',...
    'The two algorithms are:',...
    '',...
    '    Steepest Descent using line search',...
    '',...
    '    Conjugate Gradient using line search')


  % CREATE BUTTONS
  drawnow % Let everything else appear before buttons
  
  set(nnsfo('b4','Contents'), ...
    'callback','nndtoc')
  nnsfo('b5','Close');

  % DATA POINTERS
  path1_ptr = uicontrol('visible','off','userdata',[]);
  path2_ptr = uicontrol('visible','off','userdata',[]);
  
  % SAVE HANDLES, LOCK FIGURE
  H = [fig_axis desc_text left right path1_ptr path2_ptr];
  set(fig,'userdata',H)
  
  % LOCK FIGURE AND RETURN
  set(fig,'nextplot','new','pointer','arrow','color',nnltgray)

  nnchkfs;

  return
end

% SERVICE COMMANDS =======================================================

% UNLOCK FIGURE AND GET HANDLES
set(fig,'nextplot','add','pointer','watch')
H = get(fig,'userdata');
desc_text = H(2);
left = H(3);
right = H(4);
path1_ptr = H(5);
path2_ptr = H(6);

% COMMAND: DOWN

cmd = lower(cmd);
if strcmp(cmd,'down')

  % FIND CLICK POSITION
  axes(left)
  click_pt = get(left,'currentpoint');
  x = click_pt(1);
  y = click_pt(3);
  if (x >= xlim(1)) & (x <= xlim(2)) & (y >= ylim(1)) & (y <= ylim(2))
    clicked = 1;
  else
    click_pt = get(right,'currentpoint');
    x = click_pt(1);
    y = click_pt(3);
    if (x >= xlim(1)) & (x <= xlim(2)) & (y >= ylim(1)) & (y <= ylim(2))
      clicked = 1;
    else
      clicked = 0;
    end
  end
 
  if clicked
    
    % REMOVE PATHS
    path1 = get(path1_ptr,'userdata');
    path2 = get(path2_ptr,'userdata');
    delete(path1);
    delete(path2);

    % CIRCLES
    axes(left)
    path1 = plot(x,y,'o',...
      'markersize',circle_size);
    axes(right)
    path2 = plot(x,y,'o',...
      'markersize',circle_size);

    % OPTIMIZE
    x1 = [x; y];                    % Steepest descent point
    x2 = x1;                        % Conjugate gradient point
    F1 = 0.5*x1'*a*x1 + b*x1 + c;;  % Steepest descent error
    %F2 = F;                         % Conjugate gradient error

    % STEEPEST DESCENT
    axes(left)
    for i=1:5
      grad = a*x1+b';
      p = -grad;
      hess = a;
      lr = -grad'*p/(p'*hess*p);
      dx1 = -lr*grad;
      nx1 = x1 + dx1;
      h1 = plot([x1(1) nx1(1)],[x1(2) nx1(2)],...
        'color',nnred);
      h2 = plot([x1(1) nx1(1)],[x1(2) nx1(2)],'o',...
        'color',nndkblue);
      x1 = nx1;
      path1 = [path1; h1; h2];
    end

    % CONJUGATE GRADIENT
    axes(right)
    for i=1:2
      if (i==1)
        grad = a*x2+b';
        p = -grad;
      else
        grad_old = grad;
        grad = a*x2+b';
        beta = (grad'*grad)/(grad_old'*grad_old);
        p = -grad + beta*p;
      end
      hess=a;
      lr = -grad'*p/(p'*hess*p);
      dx2 = lr*p;
      nx2 = x2 + dx2;
      h1 = plot([x2(1) nx2(1)],[x2(2) nx2(2)],...
        'color',nnred);
      h2 = plot([x2(1) nx2(1)],[x2(2) nx2(2)],'o',...
        'color',nndkblue);
      x2 = nx2;
      path2 = [path2; h1; h2];
    end

    % SAVE PATHS
    set(path1_ptr,'userdata',path1);
    set(path2_ptr,'userdata',path2);
  end
end

% LOCK FIGURE
set(fig,'nextplot','new','pointer','arrow')
