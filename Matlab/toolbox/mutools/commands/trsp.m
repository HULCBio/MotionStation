%function y = trsp(sys,input,tfinal,int,x0,texthan)
%
%  Calculates the time response of a SYSTEM matrix:
%      SYS:	SYSTEM or CONSTANT matrix.
%      INPUT:	VARYING input vector or constant.
%      TFINAL:	final time value
%	          (optional, default = input final time).
%      INT:	integration step
%		  (optional, default based on input & SYS. it
%		   is recommended that the user specify this,
%		   since the interval selected by TRSP is often
%		   quite small, and can make the calculation
%		   take a long time).
%      X0:	initial state
%	          (optional, default = 0).
% TEXTHAN:	handle of uicontrol text object for update information.
%		this is only used with SIMGUI.
%
%   If INT is specified as 0 TRSP works out a suitable
%   integration step. The output is generated at the selected
%   integration step size.  To reduce the number of output points
%   the user is referred to the function VDCMATE.
%
%   See also: DTRSP, SAMHLD, SIMGUI, TUSTIN, VINTERP, and VDCMATE.

%   Copyright 1991-2004 MUSYN Inc. and The MathWorks, Inc.
%   $Revision: 1.10.2.3 $

% added fast ZOH code, also use LTITR rather than a for loop
% GJW  09 Mar 1997

function y = trsp(sys,input,tfinal,int,x0,texthan)

if nargin == 0,
    disp('usage: y = trsp(sys,input,tfinal,int,x0)')
    return
    end

[type,ny,nu,nx] = minfo(sys);
if type == 'syst',
    if nargin < 5,
        x0 = zeros(nx,1);
    else
        [m,n] = size(x0);
        if m == 1 & n == 1,
             if x0 == 0,
                 x0 = zeros(nx,1);
                 [m,n] = size(x0);
                 end
             end
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

%       check that the input vector is compatible and extract
%       the data.

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

%       if an integration step size is supplied interpolate the
%       input to this stepsize.  If one is not supplied then calculate
%       a stepsize.

if nargin < 4,
    int = 0;
    end
intstep = max(0,int);
if intstep == 0,
    if nupts > 1,
        utnzdiff = diff(ut);
        utnzdiff = utnzdiff(find(abs(utnzdiff) > eps));
        if isempty(utnzdiff),
            minstep = 1;
        else
            minstep = min(abs(utnzdiff));
            end
    else
        minstep = 1;
        end
    if type == 'syst'
        maxeig = max(abs(eig(a)));
	if maxeig<eps
		intstep = minstep;
		txtandy = ['WARNING: All poles at ZERO, '];
		txtandy = [txtandy  'manually reset integration step size '];
		txtandy = [txtandy  'if appropriate '];
		disp(txtandy);
	else
        	intstep = min(minstep,0.1/maxeig);
	end
    else
        intstep = minstep;
        end
    end

if intstep ~= int,
    disp(['integration step size: ' num2str(intstep)])
    end

%       an epsilon value for time interval calculation is created.

teps = intstep*1e-8;

%       Now check (or select) a final time and create the output
%       time vector.

if nargin < 3,
    tfinal = max(ut);
elseif tfinal < min(ut),
    error('final time less than initial time')
    return
    end

% check the timing of the response
	if ~isempty(texthan)
		atmp = rand(nx);
		btmp = rand(nx,nu);
		ctmp = rand(ny,nx);
                utmp = randn(nu,10);
                tic;xtmp=ltitr(atmp,btmp,utmp')';ytmp=ctmp*xtmp;comptime=toc;
                comptime = 0.1*comptime*tfinal/intstep;
		if comptime>180			% takes longer than 3 minutes;
			stringmes = ['Simulation will take approx. ' ...
					int2str(round(comptime))];
			stringmes = [ stringmes ...
				' seconds: check Integration Step Size'];
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

yt = [ut(1):intstep:tfinal].';
nypts = length(yt);

%       Check if the final time is less than (to a tolerance of
%       the integration step size) the maximum time in the input.
%       If it is truncate the input.  Doing this now can save a
%       lot of time in the interpolation.

if max(ut) - yt(nypts) > teps,
    nupts = max(find(ut <= yt(nypts)+teps));
    ut = ut(1:nupts);
    udat = udat(1:uptr(nupts)+nru-1,:);
    end

if ~isempty(texthan)
	drawnow
	stopflag = gguivar('STOPFLAG',tparent);
	if stopflag == 1
		sguivar('STOPFLAG',0,tparent);
		y = [];
		return
	end
end

%       Now interpolate the input vector to the integration
%       step size.   The only case where this is not necessary
%       is when the stepsize is equal the spacing of a
%       regular input vector.

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
  else					% fast ZOH, GJW
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
%       For a,b,c,d quadruples a digitization is done.

y = zeros(nypts*ny+1,2);
if type == 'syst',
  x = [x0 zeros(length(x0),nypts-1)];
end

%------------------------------------------------------------------------------%
if GUIFLG == 0	% Non-GUI TRSP, no displaying of progress of time response
%------------------------------------------------------------------------------%
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
    ab = [a*intstep b*intstep;zeros(nu,nx+nu)];
    eab = expm(ab);
    ad = eab(1:nx,1:nx);
    bd = eab(1:nx,nx+1:nx+nu);
    x = ltitr(ad,bd,udat',x0)';
    y(1:ny*nypts,1) = reshape(c*x + d*udat,ny*nypts,1);
  else
    y(1:ny*nypts,1) = reshape(sys*udat,ny*nypts,1);
    end
%------------------------------------------------------------------------------%
else		% GUI TRSP, display of time response progress
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
    ab = [a*intstep b*intstep;zeros(nu,nx+nu)];
    eab = expm(ab);
    ad = eab(1:nx,1:nx);
    bd = eab(1:nx,nx+1:nx+nu);
    innercnt = 200;
    cnt1 = floor((nypts-1)/innercnt);
    cnt2 = nypts-1 - cnt1*innercnt;
    xinit = x0;				% only drawback of ltitr is final state..
    for ii=1:cnt1
      ix1 = innercnt*(ii-1)+1;
      ix2 = ix1+innercnt-1;
      x(:,ix1:ix2) = ltitr(ad,bd,udat(:,ix1:ix2)',xinit)';
      xinit = ad*x(:,ix2) + bd*udat(:,ix2);			% so we recompute it
      if ~isempty(texthan)
 	set(texthan,'string',...
          [agv2str(intstep*ix2) '/' agv2str(tfinal)]);
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

    x(:,ww:nypts) = ltitr(ad,bd,udat(:,ww:nypts)',xinit)';

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

%       The output is reshaped into the usual varying format and
%       the time is packed with it.  In the case of only a single
%       time point, a varying matrix is still created.  This is
%       after all, assumed to be a time response.

y(1:nypts,2) = yt;
y((ny*nypts)+1,2) = inf;
y((ny*nypts)+1,1) = nypts;
%-----------------------------------------------------------------------------