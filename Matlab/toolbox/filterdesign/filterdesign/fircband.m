function varargout = fircband(varargin)
%FIRCBAND Constrained-band equiripple FIR filter design.
%   FIRCBAND designs equiripple FIR filters while constraining one or more
%   bands of the filter to have a maximum ripple value.
%   
%   B = FIRCBAND(N,F,A,W,C) returns a length N+1 linear phase (real,
%   symmetric coefficients) FIR filter that approximates the desired
%   frequency response described by F and A. For more information on F and
%   A see the help for FIRPM. W is a vector containing either weights or
%   constraints as described by C. W must have one entry per band. C is a
%   cell array of strings of the same length as W.  The entries of C must
%   be either 'c' to indicate that the corresponding element in W is a
%   constraint (the ripple for that band cannot exceed that value) or 'w'
%   to indicate that the corresponding entry in W is a weight.  There must
%   be at least one unconstrained band, i.e., C must contain at least one
%   'w' entry. For instance, EXAMPLE 1 below uses a weight of one in the
%   passband, and constrains the stopband ripple not to exceed 0.2. 
%
%   A hint regarding constrained values: if the resulting filter does not
%   touch the constraints, increase the weighting for the unconstrained
%   bands.
%
%   B = FIRCBAND(N,F,A,S,W,C) is used to design filters with special
%   properties at certain frequency points. S is a cell array of strings
%   and must be the same  length as F and A.  The entries of S must be one
%   of:
%
%      'n' - normal frequency point. Nothing new about this point.
%      's' - single-point band. The frequency "band" is given by a single point.
%            The corresponding gain at this frequency point must be
%            specified in A.
%      'f' - forced frequency point.  The gain at the specified frequency
%            band edge is forced to be the value specified.
%      'i' - indeterminate frequency point.  It is used when adjacent bands
%            touch (no transition region).
%
%   B = FIRCBAND(...,'1') designs a type 1 filter (even-order symmetric).
%   One can also specify type 2 (odd-order symmetric), type 3 (even-order 
%   antisymmetric), and type 4 (odd-order antisymmetric) filters.
%   Note that there are restrictions on A at f=0 or f=1 for types 2 to 4.
%
%   B = FIRCBAND(...,'minphase') designs a minimum-phase FIR filter.  There
%   is also 'maxphase'.
%
%   B = FIRCBAND(..., 'check') produces a warning if there are potential
%   transition-region anomalies.
%
%   B = FIRCBAND(...,{LGRID}), where {LGRID} is a scalar cell array
%   containing an integer, controls the density of the frequency grid. 
%
%   [B,ERR] = FIRCBAND(...) returns the unweighted approximation error
%   magnitudes. ERR has one element for each independent approximation
%   error.
% 
%   [B,ERR,RES] = FIRCBAND(...) returns a structure RES of optional results
%   computed by FIRCBAND, and contains the following fields:
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
%
%   EXAMPLE 1:
%      % 12-th order constrained lowpass filter
%      B = fircband(12,[0 0.4 0.5 1], [1 1 0 0], [1 0.2], {'w' 'c'});
%
%   EXAMPLE 2:
%      % Two filters of different order with stopband constrained to 60 dB. 
%      % The excess order in the second filter is used solely to improve the 
%      % passband ripple.
%      B1=fircband(60,[0 .2 .25 1],[1 1 0 0],[1 .001],{'w','c'});
%      B2=fircband(80,[0 .2 .25 1],[1 1 0 0],[1 .001],{'w','c'});
%      fvtool(B1,1,b2)
%
%   See also FIRPM, FIRCBANDDEMO, CFIRPM, FIRLS, FIRGR, IIRLPNORM, 
%   IIRLPNORMC, IIRGRPDELAY, IIRNOTCH, IIRPEAK.

%   Author(s): J. Schickler
%   Copyright 1999-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.5 $  $Date: 2004/04/12 23:25:23 $ 

% Suppress the Depricated Feature warning.
ignoreID = 'filterdesign:firgr:DepricatedFeature';
w = warning('off', ignoreID);

[wstr, wid] = lastwarn('');

try,
    
    % Call FIRGR
    [varargout{1:nargout}] = firgr(varargin{:});
catch
    
    % If FIRGR errors we need to reset the warning states and rethrow the
    % error so it looks like it is coming from FIRCBAND.
    [lstr, lid] = lastwarn;
    if strcmpi(lid, ignoreID),
        lastwarn(wstr, wid);
    end
    
    warning(w);
    
    [estr, eid] = lasterr;
    if isempty(eid), error(cleanerrormsg(estr));
    else,            error(eid, cleanerrormsg(estr)); end
end

% If the last warning was the suppressed warning remove it from LASTWARN.
[lstr, lid] = lastwarn;
if strcmpi(lid, ignoreID),
    lastwarn(wstr, wid);
end

warning(w);

% [EOF]
