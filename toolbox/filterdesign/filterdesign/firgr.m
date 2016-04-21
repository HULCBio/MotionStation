function [h,err,res] = firgr(order, ff1, aa, varargin)
%FIRGR Generalized Remez FIR filter design.
%   FIRGR is a minimax filter design algorithm that can be used to design
%   the following types of real FIR filters: types 1-4 linear phase,
%   minimum phase, maximum phase, minimum order (even or odd), extra
%   ripple, maximal ripple, constrained ripple, single-point band (notching
%   and peaking), forced gain and arbitrarily shaped filters.
%
%   B = FIRGR(N,F,A,W) returns a length N+1 linear phase FIR filter which
%   has the best approximation to the desired frequency response described
%   by F and A in the minimax sense.  W is a vector of weights, one per
%   band. If W is omitted, all bands are weighted equally.  For more
%   information on the input arguments see the FIRPM help entry.
%
%   B = FIRGR(N,F,A,'Hilbert') and B = FIRGR(N,F,A,'differentiator')
%   design FIR Hilbert transformers and differentiators respectively.  For
%   more information on the design of these filters see the FIRPM help
%   entry. 
%
%   B = FIRGR(M,F,A,R) where M is either 'minorder', 'mineven' or
%   'minodd', designs filters repeatedly until the minimum order filter (as
%   specified in M) that meets the specifications is found.  R is a vector
%   containing the peak ripple per frequency band.  R must be specified.
%   If 'mineven' or 'minodd' is specified, the minimum even or odd order
%   filter is found.  A maximum of 50 different filter orders are
%   attempted.  If M is 'estorder', B is simply the estimated order of the
%   filter and the filter is not designed.
%
%   B = FIRGR({M,NI},F,A,R) where M is either 'minorder', 'mineven' or
%   'minodd', uses NI as the initial estimate of the filter order.  NI is
%   optional for common filter designs, but it must be specified for 
%   designs in which FIRPMORD cannot be used, such as the design of
%   differentiators or Hilbert transformers.
%
%   B = FIRGR(N,F,A,W,E) specifies independent approximation errors for
%   different bands and is used to design extra ripple or maximal ripple
%   filters.  These filters have interesting properties such as having the
%   minimum transition width. E is a cell array of strings indicating the
%   approximation errors to use and its length must equal the number of
%   bands.  The entries of E must of the form 'e#' where # indicates which
%   approximation error to use for the corresponding band. For example, if
%   E = {'e1','e2','e1'}, the first and third bands use the same
%   approximation error whereas the second band uses a different one.  Note
%   that if all bands use the same approximation error, i.e.,
%   {'e1','e1','e1',...} then it is equivalent to not specifying E at all,
%   as in B = FIRGR(N,F,A,W). 
%
%   B = FIRGR(N,F,A,S) is used to design filters with special properties
%   at certain frequency points. S is a cell array of strings and must be
%   the same length as F and A.  The entries of S must be one of: 'n' -
%   normal frequency point. Nothing new about this point. 's' -
%   single-point band. The frequency "band" is given by a single point.
%   The corresponding gain at this frequency point must be specified in A.
%   'f' - forced frequency point.  The gain at the specified frequency band
%   edge is forced to be the value specified.
%   'i' - indeterminate frequency point.  It is used when adjacent bands
%   touch (no transition region).
%   For instance, EXAMPLE 2 below designs a filter with two zero-valued
%   single-point bands (notches) at 0.25 and 0.55. EXAMPLE 3 below designs
%   a highpass filter whose gain at 0.06 is forced to be zero.  The band
%   edge at 0.055 is indeterminate since the first two bands actually
%   touch.  The other band edges are normal.
%
%   B = FIRGR(N,F,A,S,W,E) specifies weights and independent approximation
%   errors for filters with special properties in vectors W and E.  It is
%   sometimes necessary to use independent approximation errors to get
%   designs with forced values to converge.  For instace, see EXAMPLE 4
%   below.
%
%   B = FIRGR(...,'1') designs a type 1 filter (even-order symmetric).
%   One can also specify type 2 (odd-order symmetric), type 3 (even-order 
%   antisymmetric), and type 4 (odd-order antisymmetric) filters.
%   Note that there are restrictions on A at f=0 or f=1 for types 2 to 4.
%
%   B = FIRGR(...,'minphase') designs a minimum-phase FIR filter.  There
%   is also 'maxphase'.
%
%   B = FIRGR(..., 'check') produces a warning if there are potential
%   transition-region anomalies.
%
%   B = FIRGR(...,{LGRID}), where {LGRID} is a scalar cell array
%   containing an integer, controls the density of the frequency grid. 
%
%   [B,ERR] = FIRGR(...) returns the unweighted approximation error
%   magnitudes. ERR has one element for each independent approximation
%   error.
% 
%   [B,ERR,RES] = FIRGR(...) returns a structure RES of optional results
%   computed by FIRGR, and contains the following fields:
% 
%      RES.fgrid: vector containing the frequency grid used in
%                 the filter design optimization
%        RES.des: desired response on fgrid
%         RES.wt: weights on fgrid
%          RES.H: actual frequency response on the grid
%      RES.error: error at each point on the frequency grid (desired - actual)
%      RES.iextr: vector of indices into fgrid of extremal frequencies
%      RES.fextr: vector of extremal frequencies
%      RES.order: filter order
%  RES.edgeCheck: transition-region anomaly check.  One element per band edge:
%                 1 = OK
%                 0 = probable transition-region anomaly
%                -1 = edge not checked
%                 Only computed if the 'check' option is specified.
% RES.iterations: number of Remez iterations for the optimization
%      RES.evals: number of function evaluations for the optimization
% RES.returnCode: indicates if design converged.  Useful when FIRGR is
%                 invoked from another M-file
%                 0  = convergence
%                 -1 = computed err was a NaN
%                 -2 = computed err decreased during iteration.
%                      should be monotonically increasing.
%
%   FIRGR is also a "function function", allowing you to write a
%   function that defines the desired frequency response. 
% 
%   B = FIRGR(N,F,'fresp',W) returns a length N+1 FIR filter which
%   has the best approximation to the desired frequency response as
%   returned by function 'fresp'.  The function is called from within
%   FIRGR using the syntax:
%                    [DH,DW] = fresp(N,F,GF,W);
%   where:
%   N is the filter order.
%   F is the vector of frequency band edges which must appear
%     monotonically between 0 and 1, where 1 is the Nyquist
%     frequency.  The frequency bands span F(k) to F(k+1) for k odd;
%     the intervals  F(k+1) to F(k+2) for k odd are "transition bands"
%     or "don't care" regions during optimization.
%   GF is a vector of grid points which have been chosen over
%     each specified frequency band by FIRGR, and determines the
%     frequency grid at which the response function will be evaluated.
%   W is a vector of real, positive weights, one per band, for use
%     during optimization.  W is optional; if not specified, it is set
%     to unity weighting before being passed to 'fresp'.
%   DH and DW are the desired frequency response and optimization 
%     weight vectors, respectively, evaluated at each frequency
%     in grid GF.
%
%   The predefined frequency response function 'fresp' for FIRGR is
%   named 'firpmfrf2', but you can write your own based on the simpler
%   'firpmfrf'. See the help for PRIVATE/FIRPMFRF for more information.
%
%   B = FIRGR(N,F,{'fresp',P1,P2,...},W) specifies optional arguments
%   P1, P2, etc., to be passed to the response function 'fresp'.
%
%   B = FIRGR(N,F,A,W) is a synonym for B = FIRGR(N,F,{'firpmfrf2',A},W),
%   where A is a vector of response amplitudes at each band edge in F.
%
%   By default, FIRGR designs symmetric (even) FIR filters. B =
%   FIRGR(...,'h')  and B = FIRGR(...,'d') design antisymmetric (odd)
%   filters. Each frequency  response function 'fresp' can tell FIRGR to
%   design either an even or odd filter in the absense of the 'h' or 'd'
%   flags.  This is done with
%         SYM = fresp('defaults',{N,F,[],W,P1,P2,...})
%   FIRGR expects 'fresp' to return SYM = 'even' or SYM = 'odd'.
%   If 'fresp' does not support this call, FIRGR assumes 'even' symmetry.
%
%   EXAMPLE 1:
%      % Design of filter with two single-band notches at .25 and .55
%      B = firgr(42,[0 0.2 0.25 0.3 0.5 0.55 0.6 1],[1 1 0 1 1 0 1 1],...
%      {'n' 'n' 's' 'n' 'n' 's' 'n' 'n'});
%
%   EXAMPLE 2:
%      % Highpass filter whose gain at 0.06 is forced to be zero. The gain
%      % at 0.055 is indeterminate since it should abut the band
%      B = firgr(82,[0 0.055 0.06 0.1 0.15 1],[0 0 0 0 1 1],...
%      {'n' 'i' 'f' 'n' 'n' 'n'});
%
%   EXAMPLE 3:
%      % Highpass filter with forced values and independent approx. errors
%      B = firgr(82,[0 0.055 0.06 0.1 0.15 1], [0 0 0 0 1 1], ...
%      {'n' 'i' 'f' 'n' 'n' 'n'}, [10 1 1] ,{'e1' 'e2' 'e3'});     
%
%   See also FIRPM, FIRGRDEMO, CFIRPM, FIRCBAND, FIRLS, IIRLPNORM, 
%   IIRLPNORMC, IIRGRPDELAY, IIRNOTCH, IIRPEAK.

%   Author(s): D. Shpak
%   Copyright 1999-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.3 $  $Date: 2004/04/12 23:25:26 $ 

%   References:
%     Shpak, D. and A. Antoniou, A Generalized Remez Method for the Design
%     of FIR Digital filters, IEEE Trans. Circ. & Sys, vol 37, No 2, 1990.

if (nargin < 3)
    error('Incorrect number of input arguments.')
end
%
% Define default values for input arguments:
%
ftype = 'f';
lgrid = 16;   % Grid density (should be at least 16)
%
% parse inputs and alter defaults
%
%  First find cell array and remove it if present
%  This cell array is used for changing lgrid
%
%  Also, check for any features that are new in the 
%  C-mex version.  If no new features are used,
%  we will use the new Remez in "legacy" mode for
%  maximum compatibility with the FORTRAN version.
params.newFeatures = 0;  % Legacy mode

minOrder = 0;
estOrder = 0;
ordstring = [];
% If we have a character string for the order, we will
% need to call firpmord to estimate the order
if ischar(order)
	estOrder = 1;
	ordstring = order;
	%params.newFeatures = 1;
end
if iscell(order)
	%params.newFeatures = 1;
	ordstring = order{1};
	if length(order) == 2  
		% An estimate of the order has been specified
		order = order{2};
	else
		estOrder = 1;
		order = 0;
	end
end		

% If we have a string for the order, parse it	
if ~isempty(ordstring)
	if strncmp(ordstring, 'minorder', 5)
		minOrder = 1;
	elseif strncmp(ordstring, 'mineven', 5)
		minOrder = 2;
	elseif strncmp(ordstring, 'minodd', 5)
		minOrder = 3;
    elseif strncmp(ordstring, 'estorder', 5)
        minOrder = 4;
        estOrder = 1;
	else
		error ('Unrecognizable string argument for filter order');
	end
end
params.minOrder = minOrder;

% If we have a cell array argument in varargin
% containing one scalar, it is the grid density specification.
% Use this value and remove it from varargin
for i=1:length(varargin)
	if (iscell(varargin{i}) & length(varargin{i}) == 1 & isnumeric(varargin{i}{:}))
		lgrid = varargin{i}{:};
        if lgrid < 16,
            warning('Grid density should be at least 16.');
        end
        if lgrid < 1,
            error('Grid density should be positive.');
        end
		varargin(i) = [];
		break
	end
end
 
% If the first varargin is a cell array, then it must be
% a cell array of characters specifying band edge properties
edge_prop = [];
if length(varargin) > 0 & iscell(varargin{1})
   edge_prop = varargin{1};
   varargin(1) = [];
   params.newFeatures = 1;
end

% The default is a vanilla linear-phase filter
% and no checking for transition-region anomalies
params.minPhase = 0;
params.check = 0;
wtx = [];
wtx_prop = [];
for i=1:length(varargin)
	if ischar(varargin{i})
		% We have a string argument, so look for text-based options
		str = lower(varargin{i});
		if length(varargin{i}) == 1
			ftype = varargin{i};
		elseif strncmp(str, 'minphase', 5)
			params.minPhase = 1;
		elseif strncmp(str, 'maxphase', 5)
			params.minPhase = 2;
		elseif strcmp (str, 'hilbert')
			ftype = 'h';
		elseif strcmp (str, 'differentiator')
			ftype = 'd';
		elseif strcmp (str, 'check')
			params.check = 1;
      end
	elseif iscell(varargin{i})
      % If there is a cell array remaining, 
      % it must be the weight properties
		wtx_prop = varargin{i}; 
		params.newFeatures = 1;
        if any(strcmpi(wtx_prop{1}, {'w', 'c'})),
            warning(generatemsgid('DepricatedFeature'), ...
                'Constrained error magnitudes are no longer support by FIRGR.  Please use FIRCBAND instead.');
        end
   else
      % Otherwise it's the error weights for the bands
		wtx = varargin{i};
	end
end

if params.check ~= 0 | params.minPhase ~= 0
	params.newFeatures = 1;
end

% To get accurate location for stopband zeros, minPhase filter
% need more grid points
if params.minPhase
   if lgrid < 64; lgrid = 64; end
end

if length(ftype)==0, ftype = 'f'; end

if length(ftype) == 1 & ftype(1)=='m'
    error('M-file version of this function is not available.');
end

if ~estOrder & (fix(order) ~= order | order < 3)
    error('Filter order must be 3 or more.')
end
%
% Error checking
%
% Need to frequencies and band-edge properties
[ff,aa,free_edges] = firpmedge(ff1, aa, edge_prop);
if isempty(wtx)
   if minOrder ~= 0
      error ('When designing a minimum-order filter, you must specify the required deviations.');
   end
   wtx = ones(fix((1+length(ff))/2),1);
end
wtx1 = wtx;

if rem(length(ff),2)
    error('The number of frequency points must be even.');
end
% Error check the band-edge frequencies
if any((ff < 0) | (ff > 1))
    error('Frequencies must lie between 0 and 1.');
end
df = diff(ff);
if (any(df < 0))
    error('Frequencies must be non-decreasing.');
end
if length(wtx) ~= fix((1+length(ff))/2)
    error('There should be one weight per band.');       
end

if (any(sign(wtx) == 1) & any(sign(wtx) == -1)) | any(sign(wtx) == 0),
    error('All weights must be positive greater than zero.');
end

nbands = length(ff)/2;

%
% Determine "Frequency Response Function" (frf)
% by inspecting the amplitude specification
%
if ischar(aa)
	% We have a user-specified frf
    frf = aa;
    frf_params = {};
elseif iscell(aa)
    frf = aa{1};
    frf_params = aa(2:end);
else
    % We have a standard bandwise filter design
    frf = 'firpmfrf2';
	% A differentiator gets a special weighting function
    frf_params = { aa, strcmp(lower(ftype(1)),'d') };
end
%
% Determine symmetry of filter
%
nfilt = order + 1;        % filter length
nodd = rem(nfilt,2);      % nodd == 1 ==> filter length is odd
                          % nodd == 0 ==> filter length is even
sign_val = 1; % Signs of coefficients get changed for a Differentiator

% Support the existing filter types 'hilbert' and 'differentiator'
% but also let the user specify types 1, 2, 3, or 4
hilbert = 0;
switch (lower(ftype(1)))
case 'h'
   ftype = 3;  % Hilbert transformer
   hilbert = 1;
	if (rem(order, 2) == 1)
		ftype = 4;
	end		
case 'd'
   ftype = 4;  % Differentiator
	sign_val = -1;
	if (rem(order, 2) == 0)
		ftype = 3;
	end
case '1'
	ftype = 1;
	if (nodd == 0)
		error('Type 1 filters must have even order (odd length)');
	end
case '2'
	ftype = 2;
	if (nodd == 1)
		error('Type 2 filters must have odd order (even length)');
	end
case '3'
	ftype = 3;
	if (nodd == 0)
		error('Type 3 filters must have even order (odd length)');
	end
case '4'
	ftype = 4;
	if (nodd == 1)
		error('Type 4 filters must have odd order (even length)');
	end
otherwise
    % If symmetry was not specified, call the fresp function
    % with 'defaults' string and a cell-array of the actual
    % function call arguments to query the default value.
	if strcmp(frf, 'firpmfrf2')
		h_sym = 'even';
	else 
		h_sym = eval(...
		  'feval(frf, ''defaults'', {order, ff, [], wtx, frf_params{:}} )',...
		  '''even''');
	end

    if ~any(strcmp(h_sym,{'even' 'odd'})),
      error(['Invalid default symmetry option "' h_sym '" returned ' ...
             'from response function "' frf '".  Must be either ' ...
             '''even'' or ''odd''.']);
    end
    
    switch h_sym
    case 'even' % Symmetric filter
       ftype = new_ftype(1, nfilt, ff, aa);
    case 'odd'		% Odd (antisymmetric) filter
       ftype = new_ftype(3, nfilt, ff, aa);  
    end
end

if (ftype == 3 | ftype == 4)
	neg = 1;  % neg == 1 ==> antisymmetric imp resp,
else
   neg = 0;  % neg == 0 ==> symmetric imp resp
end


% Make sure that we can find the mex file
if (exist('gremezmex') ~= 3) 
	error('Can''t find executable gremezmex.');
end

% Estimate the filter order with firpmord?
if estOrder
   % We can only estimate the order using firpmord if it's
   % a typical multiband filter.
   % Otherwise, we'll use start with the order that was
   % specified in the call to firpm
   if strcmp(frf, 'firpmfrf2') == 0
      error ('Can only estimate order for symmetric filters');
   end
   if any(diff(aa(1:2:end)-aa(2:2:end))) ~= 0.0
      error('Can only estimate order if the magnitude is constant in each band');
   end
   if ff(1) ~= 0 | ff(end) ~= 1
      error('Can only estimate order if F(1)=0 and F(end)=1');
   end
   
   % If we are designing with an estimated minimum order, need to call the frf
   % to pre-process the specifications
   grid = [ff(1):ff(2)];
   [des,wt,wtx1,ff,free_edges,devs,constr,banderr,lb,ub,errindex] = ...
      feval(frf, order, ff, free_edges, grid, wtx, wtx_prop, ...
      	params.minPhase, minOrder, frf_params{:});
   
   nfilt = firpmord(ff(2:end-1), aa(1:2:end), devs, 2);
   if (params.minPhase & rem(nfilt,2) == 0)
      nfilt = nfilt + 1;
   end
   if nfilt < 3
      % disp('Estimated filter order was < 3.  Trying order=3.');
      nfilt = 3;
   end
   if minOrder == 4
       h = nfilt - 1;
       err = 0;       res = 0;
       return;
   end
elseif params.minPhase
   if rem(nfilt, 2) == 0
      error ('Minimum- and maximum-phase filters must have even order');
   end
end

% For minOrder designs the minimum increment of the order is 1 unless
% the filter is specified to be even-order, odd-order, or minphase
minOrderInc = 1;
if minOrder
   if params.minPhase
      minOrderInc = 2; % Because order is doubled
   % If even or odd order is requested, make it so.
   elseif minOrder == 2  % Even-order (odd-length) design
      if rem(nfilt,2) == 0 nfilt = nfilt + 1; end
      minOrderInc = 2;
   elseif minOrder == 3 % Odd-order design
      if rem(nfilt,2) == 1 nfilt = nfilt + 1; end
      minOrderInc = 2;
   end
end
% If the minimum order design is not yet bracketed by two designs,
% we want to increase (or decrease) the order by a multiplicative factor
if minOrder
    orderFactor = [0.3 0.1];
    orderDirection = 1;  % 1=increase, -1=decrease
    % Both orderHigh and orderLow must become true to bracket the solution
    orderHigh = false;  lowErr = 0;
    orderLow = false;   highErr = 0;
    saveit = [];        tried = [];
    orderSlow = false;
end

% Try up to 50 different orders if we are finding the minimum order
done = false;
valid = false;
for tries=1:50
   if done break; end; 
	%
	% Create grid of frequencies on which to perform firpm exchange iteration
	%
	% We use the new grid function even in legacy mode since
	% the results are more accurate
	grid = firpmgrid(nfilt,lgrid,ff,ftype,free_edges);
	while length(grid)<=nfilt
		lgrid = lgrid*4;  % need more grid points
		grid = firpmgrid(nfilt,lgrid,ff,ftype,free_edges);
	end

	% 
	% Get desired frequency characteristics at the frequency points
	% in the specified frequency band intervals.
	%
	% NOTE! The frf needs to see normalized frequencies in the range [0,1].
	%
	% Unconstrained designs have empty constraints lb and ub
	lb = [];
	ub = [];
	errindex = ones(length(grid),1);
	banderr = ones(nbands, 1);

	try
	   % First we'll see if the "frf" returns the maximum nargout
		[des,wt,wtx1,ff,free_edges,devs,constr,banderr,lb,ub,errindex] = ...
         feval(frf, order, ff, free_edges, grid, wtx, wtx_prop, ...
         	params.minPhase, minOrder, frf_params{:});
	catch
	   if strcmp(frf, 'firpmfrf2')
		  error('Cannot evaluate filter specifications');
	   end
		% Otherwise we must be using a user-supplied legacy frf
		[des,wt] = feval(frf, order, ff, grid, wtx, frf_params{:});
	end

	ftype = new_ftype(ftype, nfilt, ff, aa);

	if (nfilt < 100) 
		params.fast = 1;  % Use fast Vandermonde solver
	else 
		params.fast = 0; 
	end	

	params.dof = max(errindex);		
	res = [];

	if params.minPhase
	  % Minimum-phase designs start with a filter of twice the order
	  nfilt2 = 2*(nfilt-1) + 1;
      % We also need to square the weights, constraints, and the desired values
      k = find(des == 0);
      wt(k) = wt(k).^2;
      k = find(des > 0);
      wt(k) = des(k).*wt(k)/2;
      %wt(k) = sqrt(wt(k));
		lb = lb.^2;
		ub = ub.^2;
      des = des.^2;
    else
      nfilt2 = nfilt;
    end

    %if minOrder disp(sprintf('Trying filter of order %d', nfilt-1));  end
    
	params.ftype = ftype;
	% Call MEX-file
	[h,err,iext,ret_code,checks,iters,zero] = gremezmex(nfilt2,ff,grid,des,wt,wtx1, ...
	       free_edges,lb,ub,errindex,params);
       
    if ret_code == -3 || ret_code == -4
        break;
    end

    if ~minOrder && ret_code == -2        
        msg1 = '  *** FAILURE TO CONVERGE ***';
        msg2 = '  Possible cause is machine rounding error';
        msg3 = '  but please check your filter specifications.';
        msg4 = '  Number of iterations = ';
        msg5 = '  If the number of iterations exceeds 3, the design may';
        msg6 = '  be correct, but should be verified with freqz.';
        msg7 = '  If err is very small, filter order may be too high.';
        warning(sprintf('%s\n%s\n%s\n%s%d\n%s\n%s\n%s', ...
                msg1, msg2, msg3, msg4, iters(1), msg5, msg6, msg7));
    end

	if minOrder
		% Check if we met specs
        if ret_code == 0
            ok = metSpecs (nbands, constr, err, banderr, wtx1, devs, ret_code);
        else
            ok = false;
        end
        
        if ok
            % Found a filter with sufficient order
            orderHigh = true;
			orderDirection = -1;
            % Save what might be the desired solution
			saveit = {h, err, iext, checks, iters, zero, ftype, nfilt, grid, des, wt};
			valid = 1;
			done = true;
            lowErr = err;    highNfilt = nfilt;
        elseif abs(err(1)) > 1 
            % Found a filter with insufficient order
            orderLow = true;
            orderDirection = 1;
            highErr = err;    lowNfilt = nfilt;
        elseif orderLow && orderHigh && highNfilt-nfilt == minOrderInc
            orderLow = true;  lowNfilt = nfilt;
        end
   
		if ~ok && ~isempty(saveit) && highNfilt-lowNfilt == minOrderInc
			% Restore the previous design
			h=saveit{1};		err=saveit{2};		iext=saveit{3};
			checks = saveit{4};	iters=saveit{5};
			zero=saveit{6};     ftype = saveit{7};	nfilt = saveit{8};
			grid=saveit{9};		des=saveit{10};		wt=saveit{11};
			ret_code = 0;
			valid = 1;
			done = true;
        end  
        lastNfilt = nfilt;
        % Must have solution bracketed by the minimum order increment
        if ~orderLow || ~orderHigh || highNfilt-lowNfilt > minOrderInc
            done = false;
        elseif done
            break;
        end
        
        if any(tried == nfilt2) orderSlow = true; end
        if orderSlow
            % Avoid a limit cycle in the order
            nfilt = nfilt + orderDirection * minOrderInc;
        elseif orderLow && orderHigh && isfinite(err)
            % The solution is bracketed. Interpolate the approximation
            % errors to get the next order estimate
            lowErr = saveit{2};
            dOrder = (abs(err(1)) - 1) / (abs(highErr(1)) - abs(lowErr(1))) ...
                    * (saveit{8} - lowNfilt);
            signum = sign(dOrder);
            dOrder = round(dOrder);
            if abs(dOrder) < minOrderInc 
                dOrder = minOrderInc * signum;
            elseif minOrderInc == 2 && mod(dOrder,2) 
                dOrder = dOrder + 1; 
            end
            if abs(dOrder) > nfilt/2 dOrder = round(sign(dOrder)*nfilt/2); end
            nfilt = nfilt + dOrder;
        else
            % Solution is not bracketed.  Extend the interval.
            if abs(err(1)) < 0.5 || abs(err(1)) > 2.0
                dOrder = round(nfilt * orderFactor(1));
            else 
                dOrder = round(nfilt * orderFactor(2));
            end
            if dOrder > minOrderInc 
                if minOrderInc == 2 && mod(dOrder,2) 
                    dOrder = dOrder + 1; 
                end
            else
                dOrder = minOrderInc;
            end
            nfilt = nfilt + orderDirection*dOrder;
        end
        
        if nfilt < 4
                error ('Cannot design a filter with an order < 3.');
        end
        tried = [tried nfilt2];
		ftype = new_ftype(ftype, nfilt, ff, aa);
	else
		done = true;
		if ret_code == 0
			valid = 1;
		end
	end
end

if valid == 0
    if minOrder
        msg1 = 'Final filter order of ';
        msg2 = ' is probably too ';
        msg3 = ' to meet the constraints.';
        msg4 = ' to optimally meet the constraints.';
        if err(1) > 1.0
            msg = sprintf('%s%d%slow%s', msg1, lastNfilt, msg2 ,msg3);
        else
            msg = sprintf('%s%d%shigh%s', msg1, lastNfilt, msg2 ,msg4);
        end
        warning(msg);
    else
        if ret_code == -3
            warning('Did not fix enough band edges');
        elseif ret_code == -4
            warning('Design is overly-constrained');
        else
            msg=['Design did not converge.\n', ...
             '1) Check the specifications.\n', ...
             '2) Filter order may be too large or too small.\n', ...
             '3) For multiband filters, make the transition region ', ...
              'widths more similar.'];
            warning(sprintf(msg));
        end
    end
end

% For minimum-phase filters, we now find the required half-order polynomial
if params.minPhase
    h = firminphase(h, zero, 'angles');
	err = sqrt(abs(err));
	% Handle maximum phase
	if params.minPhase == 2
		h = fliplr(h);
	end
else
	err = abs(err);
end

% Correct the sign for a differentiator
h = h * sign_val;

%
% arrange 'results' structure
%
if nargout > 2 
    res.order = nfilt - 1;
    res.fgrid = grid(:);
    res.H = freqz(h,1,res.fgrid*pi);
    if neg  % asymmetric impulse response
        linphase = exp(sqrt(-1)*(res.fgrid*pi*(res.order/2) - pi/2));
    else
        linphase = exp(sqrt(-1)*res.fgrid*pi*(res.order/2));
    end
    if hilbert == 1  % hilbert
        res.error = real(des(:) + res.H.*linphase);
    elseif ~params.minPhase
        res.error = real(des(:) - res.H.*linphase);
    else
        res.error = des(:) - abs(res.H);
    end
    if params.minPhase
        res.des = sqrt(des(:));
        res.wt = sqrt(wt(:));
    else
        res.des = des(:);
        res.wt = wt(:);
    end
    res.iextr = iext(1:end);
    res.fextr = grid(res.iextr);  % extremal frequencies
    res.fextr = res.fextr(:);
	res.iterations = iters(1);
	res.evals = iters(2);
	res.edgeCheck = checks;
    res.returnCode = ret_code;
end

if params.check
	k = find(checks == 0);
	if ~isempty(k)
		warning ('Probable transition-region anomalies.  Verify with freqz.');
	end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% Set up the grid of frequency points for the approximation 
% on a compact subset of the interval [0, pi]
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function grid = firpmgrid(nfilt,lgrid,ff,ftype,free_edges);
nfcns = fix(nfilt/2);
if ftype == 1
    nfcns = nfcns + 1;
end
nbands = length(ff) / 2;
ngrid = lgrid*nfcns;

% Sum the parts of the frequency axis that are
% used (i.e., exclude "don't care" regions
fsum = 0.0;
for i=1:nbands
	fsum = fsum + (ff(2*i) - ff(2*i-1));
end

if (fsum == 0)
    error('At least one frequency band must have a finite width.');
end
grid = [];
delf = fsum / ngrid;

if (nbands == 1) 
	grid = ff(1) + (0:ngrid-2)*delf;
	grid(ngrid) = ff(2);
else
	% Double the number of grid points near internal band edges
	% This results in more accurate designs with a small increase
	% in computational effort
	for i=1:nbands
		if free_edges(2*i-1) == 1
			if i == 1
				left = 0;
			else
				left = ff(2*i-2) + delf;
			end
		else
			left = ff(2*i - 1);
		end
		if free_edges(2*i) == 1
			if i == nbands
				right = 1;
			else
				right = ff(2*i + 1);
			end
		else
			right = ff(2*i);
		end
		% Don't duplicate grid points
		if (i > 1)
			if (grid(end) == left) 
				if (length(grid) > 1)
					grid = grid(1:end-1);
				else
					grid = [];
				end
			end
		end
		ngrid = 2*round((right - left) / delf);
		delf1 = (right - left) / (ngrid-1);
		if (ngrid <= 1)
			% One grid point
			grid = [grid 0.5*(left+right)];
		elseif (ngrid <= 3*lgrid)
			% Not many ripples in the band
			grid = [grid left:2*delf1:right];
			grid(end) = right;
		elseif (i == 1)
			% Normal spacing
			stop = right - lgrid*(2*delf1);
			grid = [grid left:2*delf1:stop];
			% Narrow spacing
			grid = [grid(1:end-1) grid(end):delf1:right+eps];
			grid(end) = right;
		elseif (i == nbands)
			% Narrow spacing
			stop = left + lgrid*(2*delf1);
			grid = [grid left:delf1:stop;];
			% Normal spacing
			grid = [grid(1:end-1) grid(end):2*delf1:right+eps];
			grid(end) = right;
		else
			% Narrow spacing
			stop = left + lgrid*(1.3*delf1);
			grid = [grid left:delf1:stop];
			% Normal spacing
			stop = right - lgrid*(1.3*delf1);	
			grid = [grid(1:end-1) grid(end):2*delf1:stop];
			% Narrow spacing
			grid = [grid(1:end-1) grid(end):delf1:right+eps];
			grid(end) = right;
		end
	end
end

% If the filter has odd symmetry, the value at f=0
% is constrained to be zero and the first grid point
% must not be at zero.
if (ftype == 3 | ftype == 4) & (grid(1) < delf)
    grid = grid(2:end);
end
% If the filter has even length, the value at f=1
% is constrained to be zero and the last grid
% point must not be at 1.0.
if (ftype == 2 | ftype == 3) & grid(end) > (1 - delf)
	grid = grid(1:end-1);
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% Check if the filter meets the specifications when we
% are finding the lowest-order filter
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function ok = metSpecs (nbands, constr, err, banderr, wtx, des, rc)
ok = true;
if rc ~= 0
   ok = false;
else 
   for m=1:nbands
      if ~constr(m) & abs(err(banderr(m)))/wtx(m) > des(m)
         ok = false;
      end
   end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 
% Since the order can change when finding the lowest filter
% order, the filter type can change too.
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function newtype = new_ftype(ftype, nfilt, ff, aa)
switch ftype
case {1, 2}
   if rem(nfilt, 2)
      newtype = 1;
   else
      newtype = 2;
      if iscell(aa) return; end
      if (ff(end) == 1 & aa(end) ~= 0)
         warning ('Type 2 filters must be zero at f=1');
      end
   end
case {3, 4}
   if rem(nfilt, 2)
      newtype = 3;
      if iscell(aa) return; end
      if (ff(1) == 0 & aa(1) ~= 0) | (ff(end) == 1 & aa(end) ~= 0)
         warning ('Type 3 filters must be zero at f=0 and f=1');
      end
      
   else
      newtype = 4;
      if iscell(aa) return; end
      if (ff(1) == 0 & aa(1) ~= 0)
         warning ('Type 4 filters must be zero at f=0');
      end
   end
end




   
