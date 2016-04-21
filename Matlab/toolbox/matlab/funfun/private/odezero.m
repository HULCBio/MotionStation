function [tout,yout,iout,vnew,stop] = ...
    odezero(ntrpfun,eventfun,eventargs,v,t,y,tnew,ynew,t0,varargin)
%ODEZERO Locate any zero-crossings of event functions in a time step.
%   ODEZERO is an event location helper function for the ODE Suite.  ODEZERO
%   uses Regula Falsi and information passed from the ODE solver to locate
%   any zeros in the half open time interval (T,TNEW] of the event functions
%   coded in eventfun.
%   
%   See also ODE45, ODE23, ODE113, ODE15S, ODE23S, ODE23T, ODE23TB.

%   Mark W. Reichelt, Lawrence F. Shampine, 6-13-94
%   Copyright 1984-2004 The MathWorks, Inc.
%   $Revision: 1.26.4.4 $  $Date: 2004/04/16 22:06:50 $

% Initialize.
tol = 128*max(eps(t),eps(tnew));
tol = min(tol, abs(tnew - t));
tout = [];
yout = [];
iout = [];
tdir = sign(tnew - t);
stop = 0;
rmin = realmin;

% Set up tL, tR, yL, yR, vL, vR, isterminal and direction.
tL = t;
yL = y;
vL = v;
[vnew,isterminal,direction] = feval(eventfun,tnew,ynew,eventargs{:});
if isempty(direction)
  direction = zeros(size(vnew));   % zeros crossings in any direction
end
tR = tnew;
yR = ynew;
vR = vnew;

% Initialize ttry so that we won't extrapolate if vL or vR is zero.
ttry = tR;

% Find all events before tnew or the first terminal event.
while 1
  
  lastmoved = 0;
  while 1
    % Events of interest shouldn't have disappeared, but new ones might
    % be found in other elements of the v vector.
    indzc = find((sign(vL) ~= sign(vR)) & (direction .* (vR - vL) >= 0));
    if isempty(indzc)
      if lastmoved ~= 0
        error('MATLAB:odezero:LostEvent',...
              'odezero: an event disappeared (internal error)');
      end
      return;
    end
    
    % Check if the time interval is too short to continue looking.
    delta = tR - tL;
    if abs(delta) <= tol
      break;
    end
    
    if (tL == t) && any(vL(indzc) == 0 & vR(indzc) ~= 0)
      ttry = tL + tdir*0.5*tol;
      
    else
      % Compute Regula Falsi change, using leftmost possibility.
      change = 1;
      for j = indzc(:)'
        % If vL or vR is zero, try using old ttry to extrapolate.
        if vL(j) == 0
          if (tdir*ttry > tdir*tR) && (vtry(j) ~= vR(j))
            maybe = 1.0 - vR(j) * (ttry-tR) / ((vtry(j)-vR(j)) * delta);
            if (maybe < 0) || (maybe > 1)
              maybe = 0.5;
            end
          else
            maybe = 0.5;
          end
        elseif vR(j) == 0.0
          if (tdir*ttry < tdir*tL) && (vtry(j) ~= vL(j))
            maybe = vL(j) * (tL-ttry) / ((vtry(j)-vL(j)) * delta);
            if (maybe < 0) || (maybe > 1)
              maybe = 0.5;
            end
          else
            maybe = 0.5;
          end
        else
          maybe = -vL(j) / (vR(j) - vL(j)); % Note vR(j) ~= vL(j).
        end
        if maybe < change
          change = maybe;
        end
      end
      change = change * abs(delta);

      % Enforce minimum and maximum change.
      change = max(0.5*tol, min(change, abs(delta) - 0.5*tol));

      ttry = tL + tdir * change;
    end
    
    % Compute vtry.
    ytry = feval(ntrpfun,ttry,t,y,tnew,ynew,varargin{:});
    vtry = feval(eventfun,ttry,ytry,eventargs{:});

    % Check for any crossings between tL and ttry.
    indzc = find((sign(vL) ~= sign(vtry)) & (direction .* (vtry - vL) >= 0));
    if ~isempty(indzc)
      % Move right end of bracket leftward, remembering the old value.
      tswap = tR; tR = ttry; ttry = tswap;
      yswap = yR; yR = ytry; ytry = yswap;
      vswap = vR; vR = vtry; vtry = vswap;
      % Illinois method.  If we've moved leftward twice, halve
      % vL so we'll move closer next time.
      if lastmoved == 2
        % Watch out for underflow and signs disappearing.
        maybe = 0.5 * vL;
        i = find(abs(maybe) >= rmin);
        vL(i) = maybe(i);
      end
      lastmoved = 2;
    else
      % Move left end of bracket rightward, remembering the old value.
      tswap = tL; tL = ttry; ttry = tswap;
      yswap = yL; yL = ytry; ytry = yswap;
      vswap = vL; vL = vtry; vtry = vswap;
      % Illinois method.  If we've moved rightward twice, halve
      % vR so we'll move closer next time.
      if lastmoved == 1
        % Watch out for underflow and signs disappearing.
        maybe = 0.5 * vR;
        i = find(abs(maybe) >= rmin);
        vR(i) = maybe(i);
      end
      lastmoved = 1;
    end
  end

  j = ones(length(indzc),1);
  tout = [tout; tR(j)];
  yout = [yout, yR(:,j)];
  iout = [iout; indzc];
  if any(isterminal(indzc))
    if tL ~= t0
      stop = 1;
    end
    break;
  elseif abs(tnew - tR) <= tol
    %  We're not going to find events closer than tol.
    break;
  else
    % Shift bracket rightward from [tL tR] to [tR+0.5*tol tnew].
    ttry = tR; ytry = yR; vtry = vR;
    tL = tR + tdir*0.5*tol;
    yL = feval(ntrpfun,tL,t,y,tnew,ynew,varargin{:});
    vL = feval(eventfun,tL,yL,eventargs{:});
    tR = tnew; yR = ynew; vR = vnew;
  end
end
