function nnd5rb(cmd)
%NND5RB Reciprocal basis demonstration.

% Copyright 1994-2002 PWS Publishing Company and The MathWorks, Inc.
% $Revision: 1.8 $

% INITIALIZE

arrow_size=0.2;
not_first_tm=0;

% BRING UP FIGURE IF IT EXISTS

me = 'nnd5rb';
fig = nndfgflg(me);
if length(get(fig,'children')) == 0, fig = 0; end
if nargin == 0, cmd = ''; end

% CREATE FIGURE ========================================================

if fig == 0

  % START WITH STANDARD DEMO FIGURE
  
  fig = nndemof(me,'DESIGN','Reciprocal Basis','','Chapter 5');
  
  % UNLOCK AND GET HANDLES
  
  set(fig,'nextplot','add')
  H = get(fig,'userdata');
  fig_axis = H(1);
  desc_text = H(2);
  
  % ICON
  
  nndicon(5,458,363,'shadow')
  
  % LEFT AXIS
  left = nnsfo('a2','Basis Vectors','','');
  set(left, ...
    'xlim',[-2.3 2.3], ...
    'xtick',[-2 -1 0 1 2], ...
    'ytick',[-2 -1 0 1 2], ...
    'ylim',[-2.3 2.3])
  nndrawax
  nndrwvec(1,0,2,0.1,nndkblue,'s1')
  nndrwvec(0,1,2,0.1,nndkblue,'s2')
  
  % RIGHT AXIS
  right = nnsfo('a3','Vector Expansion','','');
  set(right, ...
    'xlim',[-2.3 2.3], ...
    'xtick',[-2 -1 0 1 2], ...
    'ytick',[-2 -1 0 1 2], ...
    'ylim',[-2.3 2.3])
  nndrawax

  
  % CREATE BUTTONS
  set(nnsfo('b0','Start'), ...
    'callback',nncallbk(me,'start'))
  set(nnsfo('b1','Expand'), ...
    'callback',nncallbk(me,'expand'))
  set(nnsfo('b2','Title'), ...
    'callback',nncallbk(me,'title'))

  set(nnsfo('b4','Contents'), ...
    'callback','nndtoc')
  set(nnsfo('b5','Close'), ...
    'callback',nncallbk(me,'close'))
    
  % SAVE HANDLES, LOCK FIGURE
  
  H = [fig_axis desc_text left right];
  set(fig,'userdata',H,'nextplot','new','color',nnltgray)

  % TITLE TEXT & RETURN
  
  eval(nncallbk(me,'title'));

  nnchkfs;

  return
end

% SERVICE COMMANDS =======================================================

% UNLOCK FIGURE AND GET HANDLES
set(fig,'nextplot','add')
H = get(fig,'userdata');
desc_text = H(2);
left = H(3);
right = H(4);

% COMMAND: START

cmd = lower(cmd);
if strcmp(cmd,'start')

  % CLEAR AXES
  
  axes(right), cla, nndrawax

  axes(left), cla, nndrawax
  %nndrwvec(1,0,2,arrow_size,nndkblue,'s1')
  %nndrwvec(0,1,2,arrow_size,nndkblue,'s2')


  % FIRST CLICK
  
  nnsettxt(desc_text, ...
    'Click twice in the left graph to create two basis vectors', ...
    'v1 and v2. The vectors should not be parallel.')

  done = 0;
  while ~done
    [x1,y1] = nngetclk('< CLICK ON ME >');
    done = (abs(x1) < 2.3) & (abs(y1) < 2.3);
  end
  x1 = nnpin(x1,-2,2,0.1);
  y1 = nnpin(y1,-2,2,0.1);
  nndrwvec(x1,y1,2,arrow_size,nnred,'v1')
  
  % SECOND CLICK

  nnsettxt(desc_text, ...
    'Click once more in the left graph to create a second vector v2.')

  done = 0;
  while ~done
    [x2,y2] = nngetclk('< ONCE MORE >');
    done = (abs(x2) < 2.3) & (abs(y2) < 2.3);
  end
  x2 = nnpin(x2,-2,2,0.1);
  y2 = nnpin(y2,-2,2,0.1);
  nndrwvec(x2,y2,2,arrow_size,nnred,'v2')
  nndrwvec(1,0,2,arrow_size,nndkblue,'s1')
  nndrwvec(0,1,2,arrow_size,nndkblue,'s2')
  
  if (x1), slope1 = y1/x1; else slope1 = 1e10; end
  if (x2), slope2 = y2/x2; else slope2 = 1e11; end
  pause(1);
  
  % SPECIAL CASE: VECTOR AT ORIGIN
  
  if (~x1 & ~y1) | (~x2 & ~y2)
    nnsettxt(desc_text, ...
      'WHOOPS!  You entered a zero vector.', ...
      '',...
      'Click on [Start] to try again.');
    
  % THIRD CLICK

  else
    nnsettxt(desc_text, ...
      'Click once more to create a vector x to be expanded.')

    done = 0;
    while ~done
      [x3,y3] = nngetclk('< ONCE MORE >');
      done = (abs(x3) < 2.3) & (abs(y3) < 2.3);
    end
    x3 = nnpin(x3,-2,2,0.1);
    y3 = nnpin(y3,-2,2,0.1);

  %  CALCULATE THE VECTOR EXPANSION

    b=[x1 x2;y1 y2];
    x=[x3;y3];
    xv=inv(b)*x;
    xv1=xv(1);
    xv2=xv(2);

    axes(left)
    %plot([xv1*x1,x3,xv2*x2],[xv1*y1,y3,xv2*y2],'-','color',nndkblue)
    %nndrwvec(xv1*x1,xv1*y1,2,0.1,nndkblue,'')
    %nndrwvec(xv2*x2,xv2*y2,2,0.1,nndkblue,'')
    nndrwvec(x3,y3,2,arrow_size,nngreen,'x')
    nndrwvec(1,0,2,arrow_size,nndkblue,'s1')
    nndrwvec(0,1,2,arrow_size,nndkblue,'s2')
  
    axes(right)
    nndrwvec(x1,y1,2,arrow_size,nnred,'v1')
    nndrwvec(x2,y2,2,arrow_size,nnred,'v2')
    nndrwvec(x3,y3,2,arrow_size,nngreen,'x')
    %nndrwvec(xv1*x1,xv1*y1,2,arrow_size,nndkblue)
    %nndrwvec([xv1*x1 x3],[xv1*y1 y3],2,arrow_size,nndkblue)
    nndrwvec(xv1*x1,xv1*y1,1,arrow_size,nnred)
    nndrwvec([xv1*x1 x3],[xv1*y1 y3],1,arrow_size,nnred)

    nnsettxt(desc_text, ...
      'Your vector x is:', ...
      '',...
      sprintf('      x = %7.3g*s1 + %7.3g*s2',x3,y3), ...
      '', ...
      'The expansion for x in terms of v1 and v2 is:', ...
      '',...
      sprintf('      x = %7.3g*v1 + %7.3g*v2',xv1,xv2), ...
      '', ...
      'Click on [Expand] to expand a new vector, or', ...
      'click on [Start] to start over with a new basis set.');

    % SET FLAG 
    if (length(H)<5)
      path1_ptr = uicontrol('visible','off','userdata',[x1 y1 x2 y2]);
      H=[H path1_ptr];
      set(fig,'userdata',H);
    else
      H=get(fig,'userdata');
      set(H(5),'userdata',[x1 y1 x2 y2]);
    end

  end

% COMMAND: EXPAND

elseif strcmp(cmd,'expand')
  if (length(H)==5)
    H=get(fig,'userdata');
    data=get(H(5),'userdata');
    x1=data(1);y1=data(2);x2=data(3);y2=data(4);
    axes(right), cla, nndrawax
    axes(left), cla, nndrawax
    nndrwvec(x1,y1,2,arrow_size,nnred,'v1')
    nndrwvec(x2,y2,2,arrow_size,nnred,'v2')
    nndrwvec(1,0,2,arrow_size,nndkblue,'s1')
    nndrwvec(0,1,2,arrow_size,nndkblue,'s2')
    nnsettxt(desc_text, ...
      'Click in the left graph to create a vector x to be expanded.')
    [x3,y3] = nngetclk('< CLICK ON ME >');
    x3 = nnpin(x3,-2,2,0.1);
    y3 = nnpin(y3,-2,2,0.1);

  %  CALCULATE THE VECTOR EXPANSION

    b=[x1 x2;y1 y2];
    x=[x3;y3];
    xv=inv(b)*x;
    xv1=xv(1);
    xv2=xv(2);

    axes(left)
    nndrwvec(x3,y3,2,arrow_size,nngreen,'x')
    nndrwvec(1,0,2,arrow_size,nndkblue,'s1')
    nndrwvec(0,1,2,arrow_size,nndkblue,'s2')
  
    axes(right)
    nndrwvec(x1,y1,2,arrow_size,nnred,'v1')
    nndrwvec(x2,y2,2,arrow_size,nnred,'v2')
    nndrwvec(x3,y3,2,arrow_size,nngreen,'x')
    nndrwvec(xv1*x1,xv1*y1,1,arrow_size,nnred)
    nndrwvec([xv1*x1 x3],[xv1*y1 y3],1,arrow_size,nnred)
    nnsettxt(desc_text, ...
      'Your vector x is:', ...
      '',...
      sprintf('      x = %7.3g*s1 + %7.3g*s2',x3,y3), ...
      '', ...
      'The expansion for x in terms of v1 and v2 is:', ...
      '',...
      sprintf('      x = %7.3g*v1 + %7.3g*v2',xv1,xv2), ...
      '', ...
      'Click on [Expand] to expand a new vector, or', ...
      'click on [Start] to start over with a new basis set.');
  else
    nnsettxt(desc_text, ...
      '', ...
      'Click on [Start] to create basis vectors.',...
      '', ...
      '');
  end
 

% COMMAND: TITLE

elseif strcmp(cmd,'title')
  nnsettxt(desc_text, ...
    'VECTOR EXPANSION WITH RECIPROCAL BASIS VECTORS', ...
    '', ...
    'In this demonstration a vector x is expanded in terms of', ...
    'two basis vectors v1 and v2. Reciprocal basis vectors are', ...
    'used to find the coefficients of the expansion.', ...
    '', ...
    '', ...
    'Push [Start] to begin.')
    
% COMMAND: CLOSE

elseif strcmp(cmd,'close')
  delete(gcf);
  return
end

% LOCK FIGURE

set(gcf,'nextplot','new')
