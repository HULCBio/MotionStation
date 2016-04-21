function [h,delta,result] = cfirpm(M, edges, filt_str, varargin)
%CFIRPM Complex and nonlinear phase equiripple FIR filter design.
%  CFIRPM allows arbitrary frequency-domain constraints to be specified for
%  the design of a possibly complex FIR filter.  The Chebyshev (or minimax)
%  filter error is optimized, producing equiripple FIR filter designs.
%
%  B = CFIRPM(N,F,A,W) returns a length N+1 FIR filter which has the best
%  approximation to the desired frequency response described by F and A in
%  the minimax sense. 
%
%  where:
%  N is the filter order.
%  F is the vector of frequency band edges which must appear monotonically
%    between -1 and +1, where 1 is the Nyquist frequency. The frequency
%    bands span F(k) to F(k+1) for k odd; the intervals F(k+1) to F(k+2)
%    for k odd are "transition bands" or "don't care" regions during
%    optimization.
%  A is a real vector the same size as F which specifies the desired
%    amplitude of the frequency response of the resultant filter B. The
%    desired response is the line connecting the points (F(k),A(k)) and
%    (F(k+1),A(k+1)) for odd k.  
%  W is a vector of real, positive weights, one per band, for use during
%    optimization.  W is optional; if not specified, it is set to unity.
%
%  For filters with a gain other than zero at Fs/2, e.g., highpass and
%  bandstop filters, N must be even. Otherwise, N will be incremented by
%  one.
%  
%  B = CFIRPM(N,F,'fresp',W) returns a length N+1 FIR filter which has the
%  best approximation to the desired frequency response as returned by
%  function 'fresp'.  The function is called from within CFIRPM using the
%  syntax:
%                    [DH,DW] = fresp(N,F,GF,W);
%  where:
%  N, F, and W are as defined above.
%  GF is a vector of grid points which have been linearly interpolated over
%    each specified frequency band by CFIRPM, and determines the frequency 
%    grid at which the response function will be evaluated.
%  DH and DW are the desired complex frequency response and optimization
%    weight vectors, respectively, evaluated at each frequency in grid GF.
%
%  B = CFIRPM(N,F,{'fresp',P1,P2,...},W) specifies optional arguments P1,
%  P2, etc., to be passed to the response function 'fresp'.
%
%  Predefined frequency response functions for 'fresp' include:
%       'lowpass'  'bandpass' 'multiband'      'hilbfilt'
%       'highpass' 'bandstop' 'differentiator' 'invsinc'
%  See the help for PRIVATE/LOWPASS, etc., for more information.
%
%  B = CFIRPM(N,F,{'multiband',A},W) is a synonym for B = CFIRPM(N,F,A,W).
% 
%  B = CFIRPM(..., SYM) imposes a symmetry constraint on the impulse
%  response of the design, where SYM may be one of the following:
%          'none' - Default if any negative band edge frequencies are
%                   passed, or if 'fresp' does not supply a default.
%          'even' - Impulse response will be real and even.  This is
%                   the default for highpass, lowpass, bandpass, bandstop,
%                   and multiband designs.
%           'odd' - Impulse response will be real and odd.  This is the
%                   default for Hilbert and differentiator designs.  Gain
%                   at DC MUST be zero.
%          'real' - Impose conjugate symmetry on frequency response.
%
%  Each frequency response function 'fresp' provides a default value for
%  SYM; see help on private/lowpass, etc., for more information. If any SYM
%  option other than 'none' is specified, the band edges should only be
%  specified over positive frequencies; the negative frequency region will
%  be filled in from symmetry.
%
%  Any user-supplied 'fresp' function should return a valid SYM string when
%  it is passed the string 'defaults' as the filter order N.
%
%  B = CFIRPM(..., 'skip_stage2') disables the second-stage optimization
%  algorithm, which executes only when CFIRPM determines that an optimal
%  solution has not been reached by the standard Remez error-exchange.
%  Disabling this algorithm may increase the speed of computation, but with
%  a reduction in accuracy.  By default, the second-stage optimization is
%  enabled.
%
%  B = CFIRPM(..., DEBUG) enables the display of intermediate results
%  during the filter design, where DEBUG may be one of 'trace', 'plots',
%  'both', or 'off'.  By default, DEBUG is set to 'off'.
%
%  B = CFIRPM(...,{LGRID}), where {LGRID} is a one-by-one cell array
%  containing an integer, controls the density of the frequency grid. The
%  frequency grid  size is roughly 2^nextpow2(LGRID*N).  LGRID defaults to
%  25.
%
%  Note that any combination of the SYM, DEBUG, 'skip_stage2', and {LGRID}
%  options may be specified.
%
%  [B,ERR] = CFIRPM(...) returns the maximum ripple height ERR.
%
%  [B,ERR,RES] = CFIRPM(...) returns a structure RES of optional results
%  computed by CFIRPM, and contains the following fields:
%
%     RES.fgrid: vector containing the frequency grid used in
%                the filter design optimization
%       RES.des: desired response on fgrid
%        RES.wt: weights on fgrid
%         RES.H: actual frequency response on the grid
%     RES.error: error at each point on the frequency grid
%     RES.iextr: vector of indices into fgrid of extremal frequencies
%     RES.fextr: vector of extremal frequencies
%
%  EXAMPLE #1: 
%    % Design a 31-tap, complex lowpass filter
%    b = cfirpm(30,[-1 -.5 -.4 .7 .8 1],'lowpass');
%    fvtool(b); % View filter response.
% 
%  EXAMPLE #2: 
%     % Real lowpass filter with an inverse-sinc passband response.
%     [b,del,res] = cfirpm(64,[0 0.3 0.4 1],{'invsinc',3},[1,1],'even');
%     fvtool(b); 
%
%  EXAMPLE #3: 
%     % Design a 31-tap, complex multiband filter.
%     b = cfirpm(30,[-1 -.5 -.4 .7 .8 1],{'multiband',[0 0 1 2 0 0]});
%     fvtool(b); 
% 
%  See also FIRPM, FIR1, FIRLS, FILTER,  PRIVATE/LOWPASS, PRIVATE/HIGHPASS,
%  PRIVATE/BANDPASS, PRIVATE/BANDSTOP, PRIVATE/MULTIBAND,  PRIVATE/INVSINC,
%  PRIVATE/HILBFILT, PRIVATE/DIFFERENTIATOR.

%   Authors: L. Karam, J. McClellan
%   Revised: October 1996, D. Orofino
%
%   Copyright 1988-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2004/04/13 00:17:35 $

% NOTE: This algorithm is equivalent to Remez for real B
%       when the filter specs are exactly linear phase.

% Declare globals:
global DES_CRMZ WT_CRMZ GRID_CRMZ TGRID_CRMZ IFGRD_CRMZ

if nargin<3, error('Not enough input arguments.'); end

L         = M+1;             % convert ORDER to LENGTH
edges     = edges/2;         % compensate for [-1,1) frequency normalization
num_bands = length(edges)/2; % # of frequency bands specified

% Some quick checks on band edge vector:
if (num_bands ~= floor(num_bands)),
  error('F must contain an even number of band edge entries.');
end
if any(diff(edges) <= 0),
   error('Band edges must be monotonically increasing.')
end

% Assign default parameter values:
wgts         = ones(1, num_bands);
h_sym        = 'unspecified';
plot_flag    = 'off';
allow_stage2 = 1;
grid_density = 25;

plot_opts = {'plots','trace','both','off'};
sym_opts  = {'even','odd','real','none'};
for ii=1:length(varargin),
  if iscell(varargin{ii})
     grid_density = varargin{ii}{1};
  elseif ~isstr(varargin{ii}),
     if ii==1,
       wgts = varargin{ii};
     else
       error('Expecting a string argument.');
     end
  else
    ppv = lower(varargin{ii});
    switch ppv
    case plot_opts
      plot_flag = ppv;      % plot option
    case sym_opts
      h_sym = ppv;          % symmetry option
    case 'skip_stage2'
      allow_stage2 = 0;     % skip 2nd stage optimization
    otherwise
      error(['Invalid argument "' ppv '" specified.']);
    end
  end
end

PLOTS = any(strcmp(plot_flag,{'plots','both'}));
TRACE = any(strcmp(plot_flag,{'trace','both'}));

% Force function name into a cell-array:
if ~iscell(filt_str)
   if isstr(filt_str)
      % Function name passed:
      filt_str = {filt_str};
   else
      % User passed a non-string, non-cell -- assume it to be a
      % magnitude vector.  Pass this to multiband:
      filt_str = {'multiband', filt_str};
   end
end
filt_call    = lower(filt_str{1});  % string name of function
other_params = filt_str(2:end);     % cell_array of additional args

% Determine symmetry options:
h_sym = lower(h_sym);
if strcmp(h_sym,'unspecified'),

   % If symmetry was not specified, AND there are negative freqencies
   % passed in the edge vector, use 'none':
   if any(edges < 0),
     h_sym = 'none';
   else
     % If symmetry was not specified, call the fresp function
     % with 'defaults' string and a cell-array of the actual
     % function call arguments to query the default value.
     try
         h_sym = feval(filt_call, 'defaults', ...
                  {M, 2*edges, [], wgts, other_params{:}} );
         if ~ischar(h_sym), h_sym = 'none', end
     catch
        % If the fresp function does not support 'defaults' 
        warning(['Frequency response function does not support the '...
            ' ''default'' symmetry query.  Assuming symmetry=''none''']);
        h_sym = 'none';
     end
     if ~any(strcmp(h_sym,sym_opts)),
       error(['Invalid default symmetry option "' h_sym '" returned ' ...
              'from response function "' filt_call '".  Must be one ' ...
              'of ''none'',''real'',''even'', or ''odd''']);
     end
  end
end

if TRACE,
  disp(['   Symmetry option: ' h_sym]);
end

if any(strcmp(h_sym,{'real','none'})),
  fdomain = 'whole';     % [-0.5,0.5)
  sym = 0;               % h_sym = 'real' or 'none'
else
  fdomain = 'half';      % [0,0.5]
  if strcmp(h_sym,'even')
    sym = 1;           % h_sym = 'even'
  else
    sym = 2;           % h_sym = 'odd'
  end
end

% Check domain before generating frequency grid:
if strcmp(fdomain, 'whole'),
  % Domain is [-1,+1) for user input, [-0.5,0.5) internally
  if any(edges < -0.5 | edges > 0.5),
    error(['Frequency band edges must be in the range [-1,+1] for ' ...
           'designs with SYM=''' h_sym '''.']);
  end
else
  % Domain is [0,+1] for user input, [0,.5] internally
  if any(edges < 0 | edges > 0.5),
    error(['Frequency band edges must be in the range [0,+1] for ' ...
           'designs with SYM=''' h_sym '''.']);
  end
end

[Lfft, indx_edges, vec_edges] = eval_grid (edges, num_bands, M, L, ...
    fdomain, wgts, grid_density, filt_call, other_params);

% Check for odd order with zero at f = +-0.5
if rem(M,2) == 1
    sk1 = find(abs(GRID_CRMZ-0.5) < eps);
    sk2 = find(abs(GRID_CRMZ+0.5) < eps);
    sk = [sk1; sk2];
    if any(abs(DES_CRMZ(sk)) > sqrt(eps)) 
        str = ['Odd order FIR filters must have a gain of zero at +- '...
        'the Nyquist frequency. The order is being increased by one.'];
        disp(str);
        M = M + 1;
        L = M + 1;
        [Lfft, indx_edges, vec_edges] = eval_grid (edges, num_bands, M, L, ...
            fdomain, wgts, grid_density, filt_call, other_params);
    end
end

% Check for a zero at DC for odd-symmetric filters
if strcmp(h_sym, 'odd')
    sk = find(abs(GRID_CRMZ) < eps);
    if any (abs(DES_CRMZ(sk)) > sqrt (eps))
        error('Odd symmetric (antisymmetric) filters must have a zero gain at DC.');
    end
end
     
if strcmp(h_sym,'real') & all(edges >= 0)
   % We need to make DES and WT conjugate symmetric
   %error(['Frequency band edges must be specified over the entire ' ...
   %       'interval [-1,+1) for designs with SYM=''' h_sym '''.']);

   % crmz_grid moved the band edge grid points, so do the same
   % when constructing symmetric spectrum:
   len = length(TGRID_CRMZ);
   % If the DC term is included in the band edges, remove it:
   if any(indx_edges==len/2+1),
     indx_edges(1)=[]; % Throw away DC point
   end
   q = len+2-flipud(indx_edges(:));
   TGRID_CRMZ(flipud(q)) = -TGRID_CRMZ(indx_edges);
   % Adjust other grid vectors accordingly:
   indx_edges = [q; indx_edges(:)];
   IFGRD_CRMZ = [len+2-fliplr(IFGRD_CRMZ) IFGRD_CRMZ];
   GRID_CRMZ  = TGRID_CRMZ(IFGRD_CRMZ);
   % Now, impose conjugate symmetry:
   DES_CRMZ   = [conj(flipud(DES_CRMZ)); DES_CRMZ];
   WT_CRMZ    = [conj(flipud(WT_CRMZ));  WT_CRMZ];
end

% Complex Remez Stage:
[h,a,delta,not_optimal,iext,HH,EE,M_str,HH_str,h_str,Lf,Lb,Ls,Lc,A] = ...
             crmz( L, sym, Lfft, indx_edges, PLOTS, TRACE ); 
if PLOTS,
  plot_struct.L          = L;
  plot_struct.HH         = HH;
  plot_struct.EE         = EE;
  plot_struct.iext       = iext;
  plot_struct.indx_edges = indx_edges;
  plot_struct.sym        = sym;
  plot_struct.delta      = delta;
  plot_struct.plot       = 'plot-result';
  crmz( plot_struct );   % generate final plot
end

if not_optimal & allow_stage2,
  % Ascent-descent Stage:

  if TRACE,
     disp('           ***********************************************');
     disp('           *****    Invoking Second Ascent Stage      ****');
     disp('           ***********************************************');
  end

  [h,a,delta,HH,EE] = ...
       adesc( L, Lf, Lb, Ls, Lc, sym, Lfft, indx_edges, iext, HH, EE, a,...
	      M_str, HH_str, h_str, A, delta, PLOTS, TRACE );
  if PLOTS,
    plot_struct.L          = L;
    plot_struct.HH         = HH;
    plot_struct.EE         = EE;
    plot_struct.iext       = iext;
    plot_struct.indx_edges = indx_edges;
    plot_struct.sym        = sym;
    plot_struct.delta      = delta;
    plot_struct.plot       = 'plot-result';
    crmz( plot_struct );   % generate final plot
  end
end

% Return a row-vector, and remove imag part if it's small:
h = h(:).';
if ~isreal(h) & (norm(imag(h)) < 1E-12*norm(real(h))),
  h = real(h);
end

% A 'real' filter was "forced" by making DES and WT conjugate symmetric (above).
% The optimization is done in the complex domain, even if 'real' was specified.
% Remove the imaginary part that was caused by roundoff errors during optimization
% Similar argument for 'even' and 'odd'
if strcmp(h_sym,'real') | strcmp(h_sym, 'even') | strcmp(h_sym, 'odd')
    h = real(h);
end

if nargout>2,
  result.fgrid = 2*GRID_CRMZ;
  result.des   = DES_CRMZ;
  result.wt    = WT_CRMZ;
  result.H     = HH(IFGRD_CRMZ);
  result.error = EE;
  result.iextr = iext;
  result.fextr = 2*GRID_CRMZ(iext);
end

clear global DES_CRMZ WT_CRMZ GRID_CRMZ TGRID_CRMZ IFGRD_CRMZ

%--------------------------------------------------------------------------
function [grid,Ngrid,edge_vec,edge_idx] = crmz_grid(edge_pairs, L, fdomain, ...
                                                grid_density)
% CRMZ_GRID Generate grid for Remez exchange.
%
%   [Grid, Ngrid, V_edges, Indx_edges] = ...
%                    CRMZ_GRID(Edge_Pairs, L, fdomain, grid_density)
%           Grid: frequencies on the fine grid
%          Ngrid: number of grid pts if whole domain used [-1,+1]
%       edge_vec: specified edges reshaped into a vector of adjacent edge-pairs
%       edge_idx: index of specified band-edges within grid array
%
%     edge_pairs: specified band-edges, [Nbands X 2] array
%              L: filter length
%        fdomain: domain for frequency approximation
%                 default is [0,0.5] called 'half'
%                 'whole' means [-0.5,0.5), 
%   grid_density: density of grid

error(nargchk(3,4,nargin));

if (edge_pairs(1) == -0.5) & (edge_pairs(end) == 0.5),
   % -pi and +pi are the same point - move one a little:
   new_freq = 0.5 - 1/(50*L);
   if new_freq <= edge_pairs(end-1),
     % Last two freq points are too close to move - try first two:
     new_freq = -new_freq;
     if (new_freq >= edge_pairs(2)),
       error(['Both -1 and 1 have been specified as frequencies ' ...
              'in F, and the frequency spacing is too close to ' ...
              'move either of them toward its neighbor.']);
     else
       edge_pairs(1) = new_freq;
     end
   else
     edge_pairs(end) = new_freq;
   end
end

Ngrid = 2.^nextpow2(L*grid_density);
if (Ngrid/2) > 20*L,
   Ngrid = Ngrid/2;
end

del_f    = 1./Ngrid;
edge_vec = edge_pairs';  % M-by-2 to 2-by-M
edge_vec = edge_vec(:);  % single column of adjacent edge-pairs

switch fdomain
case 'whole'
  grid = (0:Ngrid-1)./Ngrid - 0.5;             % uniform grid points [-.5,.5)
  edge_idx = 1 + round((edge_vec+0.5)*Ngrid);  % closest indices in grid
case 'half'
  grid = (0:Ngrid/2)./Ngrid;                   % uniform grid points [0,.5]
  edge_idx = 1 + round(edge_vec*Ngrid);        % closest indices in grid
otherwise
  error('Internal error: domain must be "whole" or "half".');
end
edge_idx(end) = min(length(grid), edge_idx(end));  % Clip last index

% Fix repeated edges:
% This determines not only if
%         i(1)==i(2) and i(3)==i(4),
% but also if
%         i(2)==i(3), etc.
m = find(edge_idx(1:end-1) == edge_idx(2:end));
if ~isempty(m),
  % Replace REPEATED band edges with the uniform grid points
  % Could be a problem if [-1 -1] (if whole) or [0 0] (if half) specified
  edge_idx(m) = edge_idx(m) - 1;   % move 1 index lower
  edge_vec(m) = grid(edge_idx(m)); % change user's band edge accordingly
  m = m + 1;
  edge_idx(m) = edge_idx(m) + 1;
  edge_vec(m) = grid(edge_idx(m));
end

% Replace closest grid points with exact band edges:
grid(edge_idx) = edge_vec;

% end of crmz_grid

%--------------------------------------------------------------------------
function [Lfft, indx_edges, vec_edges] = eval_grid (edges, num_bands, M, L, ...
    fdomain, wgts, grid_density, filt_call, other_params)
% EVAL_GRID Evaluate the frequency response function to generate grid data
%
%   [Grid, Ngrid, V_edges, Indx_edges] = ...
%                    CRMZ_GRID(Edge_Pairs, L, fdomain, grid_density)
%           Grid: frequencies on the fine grid
%          Ngrid: number of grid pts if whole domain used [-1,+1]
%       edge_vec: specified edges reshaped into a vector of adjacent edge-pairs
%       edge_idx: index of specified band-edges within grid array
%
%     edge_pairs: specified band-edges, [Nbands X 2] array
%              L: filter length
%        fdomain: domain for frequency approximation
%                 default is [0,0.5] called 'half'
%                 'whole' means [-0.5,0.5), 
%   grid_density: density of grid

% Declare globals:
global DES_CRMZ WT_CRMZ GRID_CRMZ TGRID_CRMZ IFGRD_CRMZ

% Generate frequency grid:
edge_pairs = reshape(edges, 2, num_bands)';

[tgrid, Lfft, vec_edges, indx_edges] = ...
               crmz_grid(edge_pairs, L, fdomain, grid_density);

%  Input: indx_edges = [a1 a2 a3 a4 ...]
% Output: IFGRD_CRMZ = [a1:a2 a3:a4 ...]
IFGRD_CRMZ = [];
for jj = 1:2:length(indx_edges),
  IFGRD_CRMZ = [IFGRD_CRMZ indx_edges(jj):indx_edges(jj+1)];
end

% Get just those points from the full grid (tgrid) which correspond
% to the frequency band intervals delimited by indx_edges (i.e., by
% edge_pairs, quantized to grid indices):
TGRID_CRMZ = tgrid(:);
GRID_CRMZ  = TGRID_CRMZ( IFGRD_CRMZ );
if (max(GRID_CRMZ) > edges(end)) | (min(GRID_CRMZ) < edges(1)),
  error('Internal error: Grid frequencies out of range.')
end

% Get desired frequency characteristics at the frequency points
% in the specified frequency band intervals:
%
% NOTE! The user needs to see normalized frequencies in the range
% [-1,+1], and not [-0.5,+0.5] as we use internally.
[DES_CRMZ, WT_CRMZ] = feval(filt_call, ...
                            M, 2*edges, 2*GRID_CRMZ, wgts, other_params{:}); 
% Cleanup the results, and check sizes:
DES_CRMZ = DES_CRMZ(:);
WT_CRMZ  = WT_CRMZ(:);
if ~isequal(size(DES_CRMZ), size(GRID_CRMZ)) | ...
   ~isequal(size(WT_CRMZ),  size(GRID_CRMZ)),
  str = ['Incorrect size of results from response function "' ...
         filt_call '".  Sizes must be the same size as the ' ...
         'frequency grid GF.'];
  error(str);
end

% end of eval_grid

% [EOF]
