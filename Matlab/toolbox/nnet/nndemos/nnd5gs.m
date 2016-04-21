function nnd5gs(cmd)
%NND5GS Gram-Schmidt demonstration.

% Copyright 1994-2002 PWS Publishing Company and The MathWorks, Inc.
% $Revision: 1.6 $

% BRING UP FIGURE IF IT EXISTS

me = 'nnd5gs';
fig = nndfgflg(me);
if length(get(fig,'children')) == 0, fig = 0; end
if nargin == 0, cmd = ''; end

% CREATE FIGURE ========================================================

if fig == 0

  % STANDARD DEMO FIGURE
  
  fig = nndemof(me,'DESIGN','Gram-Schmidt','','Chapter 5');
  
  % UNLOCK AND GET HANDLES
  
  set(fig,'nextplot','add')
  H = get(fig,'userdata');
  fig_axis = H(1);
  desc_text = H(2);
  
  % ICON
  
  nndicon(5,458,363,'shadow')
  
  % LEFT AXES
  
  left_axes = nnsfo('a2','Original Vectors','','');
  set(left_axes, ...
    'xlim',[-1.3 1.3], ...
    'ylim',[-1.3 1.3]);
  nndrawax

  % RIGHT AXES

  right_axes = nnsfo('a3','Orthogonalized Vectors','','');
  set(right_axes, ...
    'xlim',[-1.3 1.3], ...
    'ylim',[-1.3 1.3]);
  nndrawax
  
  % CREATE BUTTONS
  set(nnsfo('b0','Start'), ...
    'callback',nncallbk(me,'start'))
  set(nnsfo('b1','Title'), ...
    'callback',nncallbk(me,'title'))
  set(nnsfo('b4','Contents'), ...
    'callback','nndtoc')
  set(nnsfo('b5','Close'), ...
    'callback',nncallbk(me,'close'))
    
  % SAVE HANDLES, LOCK FIGURE, AND RETURN
  
  H = [fig_axis desc_text left_axes right_axes];
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
left_axis = H(3);
right_axis = H(4);

% COMMAND: START

cmd = lower(cmd);
if strcmp(cmd,'start')

  % CLEAR AXES
  
  axes(right_axis), cla, nndrawax
  axes(left_axis), cla, nndrawax

  % FIRST CLICK
  
  nnsettxt(desc_text, ...
    'Click twice in the left graph to create two vectors, y1 and y2.', ...
    'The vectors should not be parallel.')

  done = 0;
  while ~done
    [x1,y1] = nngetclk('< CLICK ON ME >');
    done = (abs(x1) < 1.3) & (abs(y1) < 1.3);
  end
  x1 = nnpin(x1,-1,1,0.1);
  y1 = nnpin(y1,-1,1,0.1);
  nndrwvec(x1,y1,2,0.1,nnred,'y1')
  
  % SECOND CLICK

  nnsettxt(desc_text,...
    'Click once more in the left graph to create a second vector, y2.')

  done = 0;
  while ~done
    [x2,y2] = nngetclk('< ONCE MORE >');
    done = (abs(x2) < 1.3) & (abs(y2) < 1.3);
  end
  x2 = nnpin(x2,-1,1,0.1);
  y2 = nnpin(y2,-1,1,0.1);
  nndrwvec(x2,y2,2,0.1,nnred,'y2')
  
  if (x1), slope1 = y1/x1; else slope1 = 12.34; end
  if (x2), slope2 = y2/x2; else slope2 = 56.78; end
  pause(1);
  
  % SPECIAL CASE: VECTOR AT ORIGIN
  
  if (~x1 & ~y1) | (~x2 & ~y2)
    nnsettxt(desc_text, ...
      'WHOOPS!  You entered a zero vector.', ...
      '',...
      'Click on [Start] to try again.');
  
  % SPECIAL CASE: PARALLEL VECTORS

  elseif (slope1 == slope2 | ~(x1 | x2))
    nnsettxt(desc_text, ...
      'WHOOPS!  You entered parallel vectors.', ...
      'Parallel vectors cannot be orthogonalized.', ...
      '',...
      'Click on [Start] to try again.');
  
  % SPECIAL CASE: ORTHOGONAL VECTORS

  elseif (slope1 == -1/slope2) | (~x1 & ~y2) | (~y1 & ~x2)
    nnsettxt(desc_text, ...
      'WOW!  The vectors you entered are already orthogonal.', ...
      '',...
      'Click on [Start] to try again.');
  
  %  PERFORM GRAM-SCHMIDT ORTHOGONALIZATION

  else
    y =[x1 x2;y1 y2];
    v1 = [x1; y1];
    v2 = [x2; y2];
    a = (v1'*v2)/(v1'*v1);
    proj = a*v1;
    v2 = v2-proj;
    
    nx1=v1(1);ny1=v1(2);
    nx2=v2(1);ny2=v2(2);
    nx3=proj(1);ny3=proj(2);

    axes(left_axis)
    nndrwvec(nx3,ny3,1,0,nndkblue)
    nndrwvec([nx3 x2],[ny3 y2],1,0,nndkblue)

    axes(right_axis)
    nndrwvec(nx1,ny1,2,0.1,nngreen,'v1')
    nndrwvec(nx2,ny2,2,0.1,nngreen,'v2')
    nnsettxt(desc_text, ...
      'The first orthogonal vector, v1, is chosen to be the first', ...
      'original vector, y1.', ...
      '', ...
      'To obtain the second orthogonal vector, v2, the projection of', ...
      'y2 onto the first orthogonal vector, v1, is subtracted from y2.', ...
      '',...
      'Click on [Start] to try again.');
  end

% COMMAND: TITLE

elseif strcmp(cmd,'title')
  nnsettxt(desc_text, ...
    'GRAM-SCHMIDT ORTHOGONALIZATION', ...
    '', ...
    'This demonstration shows how Gram-Schmidt orthogonalization can be',...
    'applied to two vectors.', ...
    '', ...
    'Push [Start] to begin.')
    
% COMMAND: CLOSE

elseif strcmp(cmd,'close')
  delete(gcf);
  return
end

% LOCK FIGURE

set(gcf,'nextplot','new')
