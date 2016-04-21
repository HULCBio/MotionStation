%function y = dtrsp(sys,input,T,tfinal,x0,texthan)
%
%  Time response of a discrete system:
%	SYS:	packed form A,B,C,D system or constant.
%	INPUT:	varying format input vector or constant.
%	T:	sample time.
%	TFINAL:	final time value
%		(optional, default = input final time).
%	X0:	initial state
%		(optional, default = 0).
%       TEXTHAN: handle of uicontrol text object for update information.
%                this is only used with SIMGUI.
%
%   See also: TRSP, SAMHLD, SIMGUI, TUSTIN, VINTERP, and VDCMATE.

%   Copyright 1991-2004 MUSYN Inc. and The MathWorks, Inc.
% $Revision: 1.8.2.3 $

% added fast ZOH code, also use LTITR rather than a for loop
% GJW  09 Mar 1997

function y = dtrsp(sys,input,T,tfinal,x0,texthan)
if nargin == 0,
    disp('usage: y = dtrsp(sys,input,T,tfinal,x0)')
    return
    end

if nargin < 3,
    error('insufficient number of input arguments')
    return
    end

[type,ny,nu,nx] = minfo(sys);
if type == 'syst',
    if nargin < 5,
        x0 = zeros(nx,1);
    else
        [m,n] = size(x0);
        if m ~= nx | n ~= 1,
            error('incorrect initial state vector dimension')
            return
       	    end
        end
        if nargin < 6
                texthan = [];
        end
    [a,b,c,d] = unpck(sys);
elseif type ~= 'cons',
    error('the system is not in packed or constant form')
    return
    end

if ~isempty(texthan)
        tparent = get(texthan,'parent');
        sguivar('STOPFLAG',0,tparent);
        GUIFLG = 1;
else
        GUIFLG = 0;
end

%       check that the input vector is compatible.

[typeu,nru,ncu,nupts] = minfo(input);
if typeu == 'vary' & ncu == 1,
    [udat,uptr,ut] = vunpck(input);
elseif typeu == 'cons' & ncu == 1,
    nupts = 1;
    udat = input;
    ut = 0;
else
    error('invalid input time vector')
    return
    end

if nru ~= nu,
    error('incompatible input vector dimension')
    return
    end

% 	an epsilon value for time interval calculation is created.

teps = T*1e-8;
if nargin < 4
	tfinal = max(ut);
end

% check the timing of the response
        if ~isempty(texthan)
                atmp = rand(nx);
                btmp = rand(nx,nu);
                ctmp = rand(ny,nx);
                utmp = randn(nu,10);
                tic;xtmp=ltitr(atmp,btmp,utmp')';ytmp=ctmp*xtmp;comptime=toc;
                comptime = 0.1*comptime*tfinal/T;
                stringmes = ['Simulation will take approx. ' int2str(round(comptime))];
                stringmes = [ stringmes ' seconds: check Sample Time'];
                if comptime>180                   % takes longer than 3 minutes;
                        set(texthan,'string',stringmes);
                        drawnow;
			pause(2);
			stopflag = gguivar('STOPFLAG',tparent);
			if stopflag == 1
				sguivar('STOPFLAG',0,tparent);
				y = [];
				return
			end

                end
        end

%       The time vector is created.  The final time is derived from
%       this in case the user did not specify an integer number of
%       time steps.

if nargin < 4,
    yt = [ut(1):T:max(ut)].';
elseif tfinal < min(ut),
    error('final time less than initial time')
    return
else
    yt = [ut(1):T:tfinal].';
    end
tfinal = max(yt);
nypts = length(yt);


%       Check if the final time is less than the maximum time in the input.
%       If it is truncate the input.  Doing this now can save a
%       lot of time if the interpolation is required.

if max(ut) - tfinal > teps,
	nupts = max(find(ut <= tfinal+teps));
	ut = ut(1:nupts);
	udat = udat(1:uptr(nupts)+nru-1,:);
	end

%        If the input and output time vectors do not
%        match interpolate the input.

interflg = 0;
if nypts ~= nupts,
    interflg = 1;
elseif max(abs(yt - ut)) > teps,
    interflg = 1;
end

%       reshape the input so that the matrix multiplications
%       line up.  At this point yt should correspond to ut.
%       Do it before interpolating.. makes life easier GJW
udat = reshape(udat,nru,nupts);

% Moved interpolation outside of GUI loop..
% it's no longer the bottleneck  GJW
%
if interflg == 1,
  uint = zeros(nru,nypts);
  disp('interpolating input vector (zero order hold)')
  if nupts == 1,
      uint = udat*ones(1,nypts);
  else                                  % fast ZOH, GJW
      [csum,indx] = sort([ut; yt]);
      csum = ones(nupts+nypts,1);
      inew = find(indx > nupts);
      csum(inew) = zeros(nypts,1);
      csum = cumsum(csum);
      uint(:,1:nypts) = udat(:,csum(inew));
  end
  udat = uint;
end

%       the input vector has now been expanded to a matrix: u
%       constant systems are treated by a multiplication call

y = zeros(nypts*ny+1,2);
if type == 'syst',
  x = [x0 zeros(length(x0),nypts-1)];
end

%---------------------------------------------------------------------------%
if GUIFLG == 0  % Non-GUI TRSP, no displaying of progress of time response
%---------------------------------------------------------------------------%

  %       First, the single time point case is dealt with.  Here
  %       only the d term of a system and x0 affect the output.

  if nypts == 1,
    if type == 'syst',
        y(1:ny,1) = c*x + d*udat;
    else
        y(1:ny,1) = sys*udat;
    end

  %       Now the multiple timepoint case is treated.  Here
  %       a check is made to determine if the system has dynamics.
  %       The no dynamics case can be handled by a simple multiplication.

  elseif type == 'syst',
    x = ltitr(a,b,udat',x0)';
    y(1:ny*nypts,1) = reshape(c*x + d*udat,ny*nypts,1);
  else
    y(1:ny*nypts,1) = reshape(sys*udat,ny*nypts,1);
  end

%------------------------------------------------------------------------------%
else            % GUI TRSP, display of time response progress
%------------------------------------------------------------------------------%

  %       First, the single time point case is dealt with.  Here
  %       only the d term of a system and x0 affect the output.

  if ~isempty(texthan)
        stopflag = gguivar('STOPFLAG',tparent);
        if stopflag == 1
                sguivar('STOPFLAG',0,tparent);
                y = [];
                return
        end
  end

  if nypts == 1,
    if type == 'syst',
        y(1:ny,1) = c*x + d*udat;
    else
        y(1:ny,1) = sys*udat;
    end

  %       Now the multiple timepoint case is treated.  Here
  %       a check is made to determine if the system has dynamics.
  %       The no dynamics case can be handled by a simple multiplication.

  elseif type == 'syst',
    innercnt = 200;
    cnt1 = floor((nypts-1)/innercnt);
    cnt2 = nypts-1 - cnt1*innercnt;
    xinit = x0;                         % only drawback of ltitr is final state.
    for ii=1:cnt1
        ix1 = innercnt*(ii-1)+1;
        ix2 = ix1+innercnt-1;
        x(:,ix1:ix2) = ltitr(a,b,udat(:,ix1:ix2)',xinit)';
        xinit = a*x(:,ix2) + b*udat(:,ix2);                 % so we recompute
        if ~isempty(texthan)
        	set(texthan,'string',[agv2str(T*ix2) '/' agv2str(tfinal)]);
                stopflag = gguivar('STOPFLAG',tparent);
                if stopflag == 1
                        sguivar('STOPFLAG',0,tparent);
                        y = [];
                        return
                end
                drawnow;
        end
    end
    ww = innercnt*cnt1+1;
    x(:,ww:nypts) = ltitr(a,b,udat(:,ww:nypts)',xinit)';

    if ~isempty(texthan)
    	set(texthan,'string','Done...');
    	drawnow;
    end
    y(1:ny*nypts,1) = reshape(c*x + d*udat,ny*nypts,1);
  else
    y(1:ny*nypts,1) = reshape(sys*udat,ny*nypts,1);
    end
end
%------------------------------------------------------------------------------%

%       In the case of only a single
%       time point, a varying matrix is still created.  This is
%       after all, assumed to be a time response.

y(1:nypts,2) = yt;
y((ny*nypts)+1,2) = inf;
y((ny*nypts)+1,1) = nypts;

if ~isempty(texthan)
        set(texthan,'string',' ');
        sguivar('STOPFLAG',0,tparent);
        drawnow;
end
%-----------------------------------------------------------------------------