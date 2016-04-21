function nndbpm
% NNDBPM Makes data files NNBP1.MAT, NNBP2.MAT, NNBP3.MAT.

% Copyright 1994-2002 PWS Publishing Company and The MathWorks, Inc.
% First Version, 8-31-95.
% $Revision: 1.6 $


%==================================================================

disp('Starting...')

for option = 1:3

  % CONSTANTS
  W1 = [10; 10];
  b1 = [-5;5];
  W2 = [1 1];
  b2 = [-1];
  P = -2:0.1:2;
  T = logsig(W2*logsig(W1*P,b1),b2);

  if option == 1
    range1 = [-5 15];
    range2 = [-5 15];
    levels = [0 0.1 0.3 0.6 1.5 3 5 7 9];
    optx = 10;
    opty = 1;
    v1 = 'W1(1,1)';
    v2 = 'W2(1,1)';
    vw = [-37.5+180 50];
  elseif option == 2
    range1 = [-10 30];
    range2 = [-25 15];
    levels = [0 0.02 0.1 0.3 0.6 1.0 1.3 1.6 1.9];
    optx = 10;
    opty = -5;
    v1 = 'W1(1,1)';
    v2 = 'b1(1)';
    vw = [-37.5+90 50];
  else
    range1 = [-10 10];
    range2 = [-10 10];
    levels = [0 0.02 0.1 0.2 0.3 0.5 0.7 0.9 1.1 1.3];
    optx = -5;
    opty = 5;
    v1 = 'b1(1)';
    v2 = 'b1(2)';
    vw = [-37.5+90 50];
  end

  % CALCULATE SURFACE #1
  pts = 15;
  param1 = linspace(range1(1),range1(2),pts);
  param2 = linspace(range2(1),range2(2),pts);
  E = zeros(pts,pts);
  for i=1:pts
    if option == 1
      W1(1,1) = param1(i);
    elseif option == 2
      W1(1,1) = param1(i);
    else
      b1(1) = param1(i);
    end

    for j=1:pts
      if option == 1
        W2(1,1) = param2(j);
      elseif option == 2
        b1(1) = param2(j);
      else
        b1(2) = param2(j);
      end

      A2 = logsig(W2*logsig(W1*P,b1),b2);
      E(j,i) = sumsqr(T-A2);
    end
  end
  x1 = param1;
  y1 = param2;
  E1 = E;

  % CALCULATE SURFACE #2
  pts = 30;
  param1 = linspace(range1(1),range1(2),pts);
  param2 = linspace(range2(1),range2(2),pts);
  E = zeros(pts,pts);
  for i=1:pts
    if option == 1
      W1(1,1) = param1(i);
    elseif option == 2
      W1(1,1) = param1(i);
    else
      b1(1) = param1(i);
    end

    for j=1:pts
      if option == 1
        W2(1,1) = param2(j);
      elseif option == 2
        b1(1) = param2(j);
      else
        b1(2) = param2(j);
      end

      A2 = logsig(W2*logsig(W1*P,b1),b2);
      E(j,i) = sumsqr(T-A2);
    end
  end
  x2 = param1;
  y2 = param2;
  E2 = E;

  % SAVE SURFACES
  if option == 1
    save nndbp1 range1 range2 x1 y1 E1 x2 y2 E2 levels optx opty v1 v2 vw
    disp('Finished: NNDBP1.MAT')
  elseif option == 2
    save nndbp2 range1 range2 x1 y1 E1 x2 y2 E2 levels optx opty v1 v2 vw
    disp('Finished: NNDBP2.MAT')
  else
    save nndbp3 range1 range2 x1 y1 E1 x2 y2 E2 levels optx opty v1 v2 vw
    disp('Finished: NNDBP3.MAT')
  end
end

disp('Done')
