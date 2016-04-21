%function [v,y,u] = sdtrsp(sys,K,input,h,tfinal,int,x0,z0,texthan)
%
%  Calculates the time response of a sampled data feedback
%  interconnection.  This is functionally equivalent to
%
%	v = starp(sys,K) * input,
%
%  where SYS is the continuous time plant and K is the discrete
%  time controller.  Y is the input to the controller and U is
%  the controller output.  The other arguments are:
%
%      SYS:	Continuous plant (SYSTEM or CONSTANT).
%      K:       Discrete time controller (SYSTEM or CONSTANT),
%      INPUT:	VARYING input vector or constant.
%      H:       Sample period of discrete controller.
%      TFINAL:	final time value
%	          (optional, default = input final time).
%      INT:	integration step
%		  (optional, default based on input & SYS. it
%		   is recommended that the user specify this,
%		   since the interval selected by SDTRSP is often
%		   quite small, and can make the calculation
%		   take a long time).  The program will force
%		   int = h/n, with integer n, n >= 1.
%      X0:	initial state of continuous plant
%	          (optional, default = 0).
%      Z0:	initial state of discrete controller.
%	          (optional, default = 0).
%      TEXTHAN: handle of uicontrol text object for update information.
%                this is only used with SIMGUI.
%
%   If INT is specified as 0 SDTRSP works out a suitable
%   integration step. The output is generated at the selected
%   integration step size.  To reduce the number of output points
%   the user is referred to the function VDCMATE.
%
%   See Also: DHFNORM, DHFSYN, SDHFNORM, SDHFSYN, TRSP, DTRSP,
%              SAMHLD, SIMGUI,  TUSTIN, VINTERP, and VDCMATE.

%   Copyright 1991-2004 MUSYN Inc. and The MathWorks, Inc.
% $Revision: 1.9.2.3 $

% added fast ZOH code, not using LTITR just yet though
% GJW  09 Mar 1997

function [v,y,u] = sdtrsp(sys,K,input,h,tfinal,int,x0,z0,texthan)

if nargin < 4,
    disp('usage: function [v,y,u] = sdtrsp(sys,K,input,h,tfinal,int,x0,z0,texthan)')
    return
    end

[systype,nysys,nusys,nx] = minfo(sys);
if systype == 'syst',
    if nargin < 7,
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
    	    error(' Incorrect initial state vector dimension')
            return
       	    end
        end
        if nargin < 8
                texthan = [];
        end
    [As,Bs,Cs,Ds] = unpck(sys);
elseif systype ~= 'cons',
    error(' The continuous system is not in packed or constant form')
    return
    end

if ~isempty(texthan)
        tparent = get(texthan,'parent');
        sguivar('STOPFLAG',0,tparent);
        GUIFLG = 1;
else
        GUIFLG = 0;
end

[Ktype,nu,ny,nz] = minfo(K);	% u & y are w.r.t plant.
if Ktype == 'syst',
    if nargin < 8,
        z0 = zeros(nz,1);
    else
        [m,n] = size(z0);
        if m == 1 & n == 1,
             if z0 == 0,
                 z0 = zeros(nz,1);
                 [m,n] = size(z0);
                 end
             end
        if m ~= nz | n ~= 1,
    	    error(' Incorrect initial state vector dimension')
            return
       	    end
        end
    [Ak,Bk,Ck,Dk] = unpck(K);
elseif Ktype ~= 'cons',
    error(' The discrete controller is not in packed or constant form')
    return
    end

%	set up the dimensions: w is the input vector, v is the
%	system output, y is the output to the controller and
%	u is the input from the controller.

nw = nusys - nu;
nv = nysys - ny;
if nv <= 0 | nw <= 0,
    error(' Interconnection is dimensionally incorrect')
    return
    end

%       check that the input vector is compatible and extract
%       the data.

[typew,nrw,ncw,nwpts] = minfo(input);
if typew == 'vary' & ncw == 1,
    [wdat,wptr,wt] = vunpck(input);
elseif typew == 'cons' & ncw == 1,
    nwpts = 1;
    wdat = input;
    wt = 0;
else
    error(' Invalid input time vector')
    return
    end

if nrw ~= nw,
    error(' Incompatible input vector dimension')
    return
    end

%       if an integration step size is supplied interpolate the
%       input to this stepsize.  If one is not supplied then calculate
%       a stepsize.

if length(h) > 1,
    error('H must be a scalar')
    return
    end

h = abs(h);

if nargin < 6,
    int = 0;
    end
intstep = max(0,int);
if intstep == 0,
    if nwpts > 1,
        wtnzdiff = diff(wt);
        wtnzdiff = wtnzdiff(find(abs(wtnzdiff) > eps));
        if isempty(wtnzdiff),
            minstep = 1;
        else
            minstep = min(abs(wtnzdiff));
            end
    else
        minstep = 1;
        end
    if systype == 'syst'
        maxeig = max(abs(spoles(sys)));
        if maxeig < eps,		% arbitrary in case system
            intstep = 1;		% is all integrators.
                txtandy = ['WARNING: All continuous poles at ZERO, '];
                txtandy = [txtandy  'manually reset integration step size '];
                txtandy = [txtandy  'if appropriate '];
                disp(txtandy);
        else
            intstep = 0.1/maxeig;
            end
    else
        intstep = minstep;
        end
    intstep = min(intstep,minstep);
    intstep = min(intstep,h/5);     % give at least five points
    end				     % between controller samples.


%	Now check that that the integration step and controller
%	sample time are integer related.  Find that integer, N,
%	for indexing later on.  N >=2 so that we always calculate
% 	over one controller sample period.

teps = intstep*1e-8;
N = max(2,ceil(h/intstep-teps));
intstep = h/N;

if intstep ~= int,
    disp(['integration step size: ' num2str(intstep)])
    end

%       an epsilon value for time interval calculation is created.
% check the timing of the response
	if ~isempty(texthan)
		atmp = rand(nx+nz);
		btmp = rand(nx+nz,nusys);
		ctmp = rand(nysys,nx+nz);
                utmp = randn(nusys,10);
                tic;xtmp=ltitr(atmp,btmp,utmp')';ytmp=ctmp*xtmp;comptime=toc;
                comptime = 0.1*comptime*tfinal/intstep;
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

%       Now check (or select) a final time and create the output
%       time vector.  Force the simulation to start and end
%	with a h sample.

if nargin < 5,
    tfinal = max(wt);
elseif tfinal < min(wt),
    error(' Final time less than initial time')
    return
    end
nKpts = ceil((tfinal-wt(1))/h)+1;	% number of controller calcs.
tfinal = h*(nKpts-1) + wt(1);
vt = [wt(1):intstep:tfinal].';
npts = length(vt);

%       Check if the final time is less than (to a tolerance of
%       the integration step size) the maximum time in the input.
%       If it is truncate the input.  Doing this now can save a
%       lot of time in the interpolation.

if max(wt) - vt(npts) > teps,
    nwpts = max(find(wt <= vt(npts)+teps));
    wt = wt(1:nwpts);
    wdat = wdat(1:wptr(nwpts)+nw-1,:);
    end

%       Now interpolate the input vector to the integration
%       step size.   The only case where this is not necessary
%       is when the stepsize is equal the spacing of a
%       regular input vector.

interflg = 0;
if npts ~= nwpts,
    interflg = 1;
elseif max(abs(vt - wt)) > teps,
    interflg = 1;
end

if ~isempty(texthan)
	stopflag = gguivar('STOPFLAG',tparent);
	if stopflag == 1
		sguivar('STOPFLAG',0,tparent);
		y = [];
		return
	end
end

wdat = reshape(wdat,nw,nwpts);

if interflg == 1,
  wint = zeros(nw,npts);
  disp('interpolating input vector (zero order hold)')
  if nwpts == 1,
      wint = wdat*ones(1,npts);
  else
      [csum,indx] = sort([wt; vt]);
      csum = ones(nwpts+npts,1);
      inew = find(indx > nwpts);
      csum(inew) = zeros(npts,1);
      csum = cumsum(csum);
      wint(:,1:npts) = wdat(:,csum(inew));
  end
  wdat = wint;
end

%	Discretize the system - the controller is already
%	discrete.

if systype == 'syst',
  ABs = [As*intstep Bs*intstep;zeros(nw+nu,nx+nw+nu)];
  eABs = expm(ABs);
  As = eABs(1:nx,1:nx);
  B1 = eABs(1:nx,nx+1:nx+nw);
  B2 = eABs(1:nx,nx+nw+1:nx+nw+nu);
  C1 = Cs(1:nv,:);
  C2 = Cs(nv+1:nv+ny,:);
else
  Ds = sys;			% constant system
  end
if Ktype == 'cons',
  Dk = K;
  end

%	select out the appropriate parts of the D terms to
%	make the following calculations more obvious.

D11 = Ds(1:nv,1:nw);
D12 = Ds(1:nv,nw+1:nw+nu);
D21 = Ds(nv+1:nv+ny,1:nw);
D22 = Ds(nv+1:nv+ny,nw+1:nw+nu);

X = eye(nu) - Dk*D22;
if rank(X) < nu,
  error(' Interconnection is ill-posed.  Check infinite freq. gains')
  return
  end
X = inv(X);

v = zeros(npts*nv+1,2);

%---------------------------------------------------------------------------%
if GUIFLG == 0  % Non-GUI TRSP, no displaying of progress of time response
%---------------------------------------------------------------------------%

  if systype == 'syst' & Ktype == 'syst',
    yTmat = [(D22*X*Dk + eye(ny))*C2 , ... % x(k) term
             D22*X*Ck , ...                % z(k) term
             (D22*X*Dk + eye(ny))*D21 ];   % w(k) term
    uTmat = [X*Dk*C2 , ...                 % x(k) term
             X*Ck , ...                    % z(k) term
             X*Dk*D21 ];                   % w(k) term
    x = [x0 zeros(length(x0),npts-1)];
    z = [z0 zeros(length(z0),nKpts-1)];
    y = yTmat*[x(:,1);z(:,1);wdat(:,1)];	% initial y
    udat = zeros(nu,npts);		% bug fix: RSS, 31/May/95
    udat(:,1) = uTmat*[x(:,1);z(:,1);wdat(:,1)];	% and u.

    for i = 0:nKpts-2,
        for j = 1:N-1,
            udat(:,N*i+1+j) = udat(:,N*i+1);  % replicate u
            x(:,N*i+1+j) = As*x(:,N*i+j) + B1*wdat(:,N*i+j) ...
				+ B2*udat(:,N*i+j);
            end
        z(:,i+2) = Ak*z(:,i+1) + Bk*y;
        x(:,N*(i+1)+1) = As*x(:,N*(i+1)) + B1*wdat(:,N*(i+1)) ...
				+ B2*udat(:,N*(i+1));
        udat(:,N*(i+1)+1) = uTmat*[x(:,N*(i+1)+1);z(:,i+2);wdat(:,N*(i+1)+1)];
        y = yTmat*[x(:,N*(i+1)+1);z(:,i+2);wdat(:,N*(i+1)+1)];
        end
    v(1:nv*npts,1) = reshape(C1*x + [D11,D12]*[wdat;udat],nv*npts,1);
    y = zeros(npts*ny+1,2);
    y(1:ny*npts,1) = reshape(C2*x + [D21,D22]*[wdat;udat],ny*npts,1);

  elseif systype == 'syst' & Ktype == 'cons',
    uTmat = [X*Dk*C2 , ...                 % x(k) term
             X*Dk*D21 ];                   % w(k) term
    x = [x0, zeros(length(x0),npts-1)];
    udat = zeros(nu,npts);		% bug fix: RSS, 31/May/95
    udat(:,1) = uTmat*[x(:,1);wdat(:,1)];	% initial u.

    for i = 0:nKpts-2,
        for j = 1:N-1,
            udat(:,N*i+1+j) = udat(:,N*i+1);  % replicate u
            x(:,N*i+1+j) = As*x(:,N*i+j) + B1*wdat(:,N*i+j) ...
				+ B2*udat(:,N*i+j);
            end
        x(:,N*(i+1)+1) = As*x(:,N*(i+1)) + B1*wdat(:,N*(i+1)) ...
				+ B2*udat(:,N*(i+1));
        udat(:,N*(i+1)+1) = uTmat*[x(:,N*(i+1)+1);wdat(:,N*(i+1)+1)];
        end
    v(1:nv*npts,1) = reshape(C1*x + [D11,D12]*[wdat;udat],nv*npts,1);
    y = zeros(npts*ny+1,2);
    y(1:ny*npts,1) = reshape(C2*x + [D21,D22]*[wdat;udat],ny*npts,1);

  elseif systype == 'cons' & Ktype == 'syst',
    yTmat = [D22*X*Ck , ...                % z(k) term
             (D22*X*Dk + eye(ny))*D21 ];   % w(k) term
    uTmat = [X*Ck , ...                    % z(k) term
             X*Dk*D21 ];                   % w(k) term
    z = [z0 zeros(length(z0),nKpts-1)];
    udat = zeros(nu,npts);		% bug fix: RSS, 31/May/95
    y = yTmat*[z(:,1);wdat(:,1)];	% initial y
    udat(:,1) = uTmat*[z(:,1);wdat(:,1)];	% and u.

    for i = 0:nKpts-2,
        for j = 1:N-1,
            udat(:,N*i+1+j) = udat(:,N*i+1);  % replicate u
            end
        z(:,i+2) = Ak*z(:,i+1) + Bk*y;
        udat(:,N*(i+1)+1) = uTmat*[z(:,i+2);wdat(:,N*(i+1)+1)];
        y = yTmat*[z(:,i+2);wdat(:,N*(i+1)+1)];
        end
    v(1:nv*npts,1) = reshape([D11,D12]*[wdat;udat],nv*npts,1);
    y = zeros(npts*ny+1,2);
    y(1:ny*npts,1) = reshape(C2*x + [D21,D22]*[wdat;udat],ny*npts,1);

  else		% both are constants
    vTmat = [D11 + D12*X*Dk*D21 ];         % w(k) term
    uTmat = [X*Dk*D21 ];                   % w(k) term
    udat = zeros(nu,npts);
    udat(:,1) = uTmat*wdat(:,1);  	   % initial u.

    for i = 0:nKpts-2,
        for j = 1:N-1,
            udat(:,N*i+1+j) = udat(:,N*i+1);  % replicate u
            end
        udat(:,N*(i+1)+1) = uTmat*wdat(:,N*(i+1)+1);
        end
    v(1:nv*npts,1) = reshape([D11,D12]*[wdat;udat],nv*npts,1);
    y = zeros(npts*ny+1,2);
    y(1:ny*npts,1) = reshape([D21,D22]*[wdat;udat],ny*npts,1);

    end
%------------------------------------------------------------------------------%
else            % GUI TRSP, display of time response progress
%------------------------------------------------------------------------------%

  if systype == 'syst' & Ktype == 'syst',
    yTmat = [(D22*X*Dk + eye(ny))*C2 , ... % x(k) term
             D22*X*Ck , ...                % z(k) term
             (D22*X*Dk + eye(ny))*D21 ];   % w(k) term
    uTmat = [X*Dk*C2 , ...                 % x(k) term
             X*Ck , ...                    % z(k) term
             X*Dk*D21 ];                   % w(k) term
    x = [x0, zeros(length(x0),npts-1)];
    z = [z0, zeros(length(z0),nKpts-1)];
    y = yTmat*[x(:,1);z(:,1);wdat(:,1)];	% initial y

	if ~isempty(texthan)
        	drawnow
        	stopflag = gguivar('STOPFLAG',tparent);
        	if stopflag == 1
                	sguivar('STOPFLAG',0,tparent);
                	y = [];
                	return
        	end
	end

    udat = zeros(nu,npts);			% bu
    udat(:,1) = uTmat*[x(:,1);z(:,1);wdat(:,1)];	% and u.

    innercnt = 20;
    cnt1 = floor((nKpts-2)/innercnt);
    % replacing this: for i = 0:nKpts-2,
    for ii = 1:cnt1
    	icnt = innercnt*(ii-1);
        for jj=1:innercnt
         	i = jj+icnt-1; % old i
        	for j = 1:N-1,
            		udat(:,N*i+1+j) = udat(:,N*i+1);  % replicate u
            		x(:,N*i+1+j) = As*x(:,N*i+j) + B1*wdat(:,N*i+j) ...
					+ B2*udat(:,N*i+j);
            	end
        	z(:,i+2) = Ak*z(:,i+1) + Bk*y;
        	x(:,N*(i+1)+1) = As*x(:,N*(i+1)) + B1*wdat(:,N*(i+1)) ...
					+ B2*udat(:,N*(i+1));
        	udat(:,N*(i+1)+1) = ...
			    uTmat*[x(:,N*(i+1)+1);z(:,i+2);wdat(:,N*(i+1)+1)];
        	y = yTmat*[x(:,N*(i+1)+1);z(:,i+2);wdat(:,N*(i+1)+1)];
        end
	if ~isempty(texthan)
		set(texthan,'string',[agv2str(tfinal*i/nKpts) '/' agv2str(tfinal)]);
        	drawnow
        	stopflag = gguivar('STOPFLAG',tparent);
        	if stopflag == 1
        		sguivar('STOPFLAG',0,tparent);
        		y = [];
        		return
        	end
        end
     end
     for i = (cnt1*innercnt):nKpts-2
	      for j = 1:N-1,
        	udat(:,N*i+1+j) = udat(:,N*i+1);  % replicate u
        	x(:,N*i+1+j) = As*x(:,N*i+j) + B1*wdat(:,N*i+j) ...
        			+ B2*udat(:,N*i+j);
        end
        z(:,i+2) = Ak*z(:,i+1) + Bk*y;
        x(:,N*(i+1)+1) = As*x(:,N*(i+1)) + B1*wdat(:,N*(i+1)) ...
        			+ B2*udat(:,N*(i+1));
        udat(:,N*(i+1)+1) = ...
        		uTmat*[x(:,N*(i+1)+1);z(:,i+2);wdat(:,N*(i+1)+1)];
        y = yTmat*[x(:,N*(i+1)+1);z(:,i+2);wdat(:,N*(i+1)+1)];
      end

    v(1:nv*npts,1) = reshape(C1*x + [D11,D12]*[wdat;udat],nv*npts,1);
    y = zeros(npts*ny+1,2);
    y(1:ny*npts,1) = reshape(C2*x + [D21,D22]*[wdat;udat],ny*npts,1);

  elseif systype == 'syst' & Ktype == 'cons',
    uTmat = [X*Dk*C2 , ...                 % x(k) term
             X*Dk*D21 ];                   % w(k) term
    x = [x0, zeros(length(x0),npts-1)];
    udat = zeros(nu,npts);		% bug fix: RSS, 31/May/95
    udat(:,1) = uTmat*[x(:,1);wdat(:,1)];	% initial u.

    innercnt = 20;
    cnt1 = floor((nKpts-2)/innercnt);
    % replacing this: for i = 0:nKpts-2,
    for ii = 1:cnt1
    	icnt = innercnt*(ii-1);
        for jj=1:innercnt
         	i = jj+icnt-1; % old i
        	for j = 1:N-1,
        		udat(:,N*i+1+j) = udat(:,N*i+1);  % replicate u
        		x(:,N*i+1+j) = As*x(:,N*i+j) + B1*wdat(:,N*i+j) ...
        				+ B2*udat(:,N*i+j);
            	end
        	x(:,N*(i+1)+1) = As*x(:,N*(i+1)) + B1*wdat(:,N*(i+1)) ...
					+ B2*udat(:,N*(i+1));
        	udat(:,N*(i+1)+1) = uTmat*[x(:,N*(i+1)+1);wdat(:,N*(i+1)+1)];
        end
	if ~isempty(texthan)
		set(texthan,'string',[agv2str(tfinal*i/nKpts) '/' agv2str(tfinal)]);
        	drawnow
        	stopflag = gguivar('STOPFLAG',tparent);
        	if stopflag == 1
        		sguivar('STOPFLAG',0,tparent);
        		y = [];
        		return
        	end
        end
     end
     for i = (cnt1*innercnt):nKpts-2
	for j = 1:N-1,
        	udat(:,N*i+1+j) = udat(:,N*i+1);  % replicate u
        	x(:,N*i+1+j) = As*x(:,N*i+j) + B1*wdat(:,N*i+j) ...
        			+ B2*udat(:,N*i+j);
        end
        x(:,N*(i+1)+1) = As*x(:,N*(i+1)) + B1*wdat(:,N*(i+1)) ...
				+ B2*udat(:,N*(i+1));
        udat(:,N*(i+1)+1) = uTmat*[x(:,N*(i+1)+1);wdat(:,N*(i+1)+1)];
      end

    v(1:nv*npts,1) = reshape(C1*x + [D11,D12]*[wdat;udat],nv*npts,1);
    y = zeros(npts*ny+1,2);
    y(1:ny*npts,1) = reshape(C2*x + [D21,D22]*[wdat;udat],ny*npts,1);

  elseif systype == 'cons' & Ktype == 'syst',
    yTmat = [D22*X*Ck , ...                % z(k) term
             (D22*X*Dk + eye(ny))*D21 ];   % w(k) term
    uTmat = [X*Ck , ...                    % z(k) term
             X*Dk*D21 ];                   % w(k) term
    z = [z0, zeros(length(z0),nKpts-1)];
    udat = zeros(nu,npts);		% bug fix: RSS, 31/May/95
    y = yTmat*[z(:,1);wdat(:,1)];	% initial y
    udat(:,1) = uTmat*[z(:,1);wdat(:,1)];	% and u.

    innercnt = 20;
    cnt1 = floor((nKpts-2)/innercnt);
    % replacing this: for i = 0:nKpts-2,
    for ii = 	1:cnt1
    	icnt = innercnt*(ii);
        for jj=1:innercnt
         	i = jj+icnt-1; % old i
        	for j = 1:N-1,
        		udat(:,N*i+1+j) = udat(:,N*i+1);  % replicate u
            	end
        	z(:,i+2) = Ak*z(:,i+1) + Bk*y;
        	udat(:,N*(i+1)+1) = uTmat*[z(:,i+2);wdat(:,N*(i+1)+1)];
        	y = yTmat*[z(:,i+2);wdat(:,N*(i+1)+1)];
        end
	if ~isempty(texthan)
		set(texthan,'string',[agv2str(tfinal*i/nKpts) '/' agv2str(tfinal)]);
        	drawnow
        	stopflag = gguivar('STOPFLAG',tparent);
        	if stopflag == 1
        		sguivar('STOPFLAG',0,tparent);
        		y = [];
        		return
        	end
        end
     end
     for i = (cnt1*innercnt):nKpts-2
	for j = 1:N-1,
        	udat(:,N*i+1+j) = udat(:,N*i+1);  % replicate u
        end
        z(:,i+2) = Ak*z(:,i+1) + Bk*y;
        udat(:,N*(i+1)+1) = uTmat*[z(:,i+2);wdat(:,N*(i+1)+1)];
        y = yTmat*[z(:,i+2);wdat(:,N*(i+1)+1)];
      end

    v(1:nv*npts,1) = reshape([D11,D12]*[wdat;udat],nv*npts,1);
    y = zeros(npts*ny+1,2);
    y(1:ny*npts,1) = reshape([D21,D22]*[wdat;udat],ny*npts,1);

  else		% both are constants
    vTmat = [D11 + D12*X*Dk*D21 ];         % w(k) term
    uTmat = [X*Dk*D21 ];                   % w(k) term
    udat = zeros(nu,npts);		% bug fix: RSS, 31/May/95
    udat(:,1) = uTmat*wdat(:,1);  	   % initial u.

    for i = 0:nKpts-2,
        for j = 1:N-1,
            udat(:,N*i+1+j) = udat(:,N*i+1);  % replicate u
            end
        udat(:,N*(i+1)+1) = uTmat*wdat(:,N*(i+1)+1);
        end
    v(1:nv*npts,1) = reshape([D11,D12]*[wdat;udat],nv*npts,1);
    y = zeros(npts*ny+1,2);
    y(1:ny*npts,1) = reshape([D21,D22]*[wdat;udat],ny*npts,1);

    end
end
%------------------------------------------------------------------------------%

v(1:npts,2) = vt;
v((nv*npts)+1,2) = inf;
v((nv*npts)+1,1) = npts;

%	bug fixed on the y and u dimensions. RSS 2/27/93.

y(1:npts,2) = vt;
y((ny*npts)+1,2) = inf;
y((ny*npts)+1,1) = npts;

u = zeros(npts*nu+1,2);
u(1:nu*npts,1) = reshape(udat,nu*npts,1);
u(1:npts,2) = vt;
u((nu*npts)+1,2) = inf;
u((nu*npts)+1,1) = npts;
%
%