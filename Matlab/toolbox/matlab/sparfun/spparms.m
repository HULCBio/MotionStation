function [return1,return2] = spparms(arg1,arg2)
%SPPARMS Set parameters for sparse matrix routines.
%   SPPARMS('key',value) sets one or more of the "tunable" parameters 
%   used in the sparse routines, particularly the minimum degree
%   orderings, COLMMD and SYMMMD and sparse / and \.
%
%   SPPARMS, by itself, prints a description of the current settings.
%
%   If no input argument is present, values = SPPARMS returns a
%   vector whose components give the current settings.
%   [keys,values] = SPPARMS returns that vector, and also returns
%   a character matrix whose rows are the keywords for the parameters.
%
%   SPPARMS(values), with no output argument, sets all the parameters
%   to the values specified by the argument vector.
%
%   value = SPPARMS('key') returns the current setting of one parameter.
%
%   SPPARMS('default') sets all the parameters to their default settings.
%   SPPARMS('tight') sets the minimum degree ordering parameters to their 
%   "tight" settings, which may lead to orderings with less fill-in, but 
%   which makes the ordering functions themselves use more execution time.
%
%   The parameters with the default and "tight" values are:
%
%                    keyword       default       tight
%
%      values(1)     'spumoni'      0
%      values(2)     'thr_rel'      1.1          1.0
%      values(3)     'thr_abs'      1.0          0.0
%      values(4)     'exact_d'      0            1
%      values(5)     'supernd'      3            1
%      values(6)     'rreduce'      3            1
%      values(7)     'wh_frac'      0.5          0.5
%      values(8)     'autommd'      1            
%      values(9)     'autoamd'      1
%      values(10)    'piv_tol'      0.1
%      values(11)    'bandden'      0.5
%      values(12)    'umfpack'      1
%
%   The meanings of the parameters are
%
%      spumoni:  The Sparse Monitor Flag controls diagnostic output;
%                0 means none, 1 means some, 2 means too much.
%      thr_rel,
%      thr_abs:  Minimum degree threshold is thr_rel*mindegree + thr_abs.
%      exact_d:  Nonzero to use exact degrees in minimum degree,
%                Zero to use approximate degrees.
%      supernd:  If > 0, MMD amalgamates supernodes every supernd stages.
%      rreduce:  If > 0, MMD does row reduction every rreduce stages.
%      wh_frac:  Rows with density > wh_frac are ignored in COLMMD.
%      autommd:  Nonzero to use SYMMMD and COLMMD orderings with \ and /.
%      autoamd:  Nonzero to use COLAMD ordering with UMFPACK in \ and /.
%      piv_tol:  Pivot tolerance used by LU-based (UMFPACK) \ and /.
%      bandden:  Backslash uses band solver if band density is > bandden.
%                If bandden = 1.0, never use band solver.
%                If bandden = 0.0, always use band solver.
%      umfpack:  Nonzero to use UMFPACK instead of the v4 LU-based solver in \ and /.
%
%   Note:
%   Solving symmetric positive definite matrices within \ and /:
%      The CHOL-based solver uses SYMMMD.
%   Solving general square matrices within \ and /:
%      The UMFPACK LU-based solver uses a modified COLAMD.
%      The v4 LU-based solver uses COLMMD.
%   Solving rectangular matrices within \ and /:
%      The QR-based solver uses COLMMD.
%   All of these algorithms respond to SPPARMS('autommd') except for the
%   UMFPACK LU-based solver, which responds to SPPARMS('autoamd').
%
%   See also COLMMD, SYMMMD, COLAMD, SYMAMD, UMFPACK.

%   Copyright 1984-2004 The MathWorks, Inc. 
%   $Revision: 5.14.4.5 $  $Date: 2004/03/24 03:05:40 $

% The following are "constants".

allkeys = ['spumoni'
           'thr_rel'
           'thr_abs'
           'exact_d'
           'supernd'
           'rreduce'
           'wh_frac'
           'autommd'
           'autoamd'
           'piv_tol'
           'bandden'
           'umfpack'];
nparms = size(allkeys,1);
spuparmrange = 1:1;   % Which parameters pertain to SPUMONI?
mmdparmrange = 2:7;   % Which parameters pertain to minimum degree?
bslparmrange = 8:12;  % Which parameters pertain to sparse backslash?
defaultparms = [0 1.1 1.0 0 3 3 0.5 1 1 0.1 0.5 1]';
tightmmdparms   = [1.0 0.0 1 1 1 0.5]';

% First find out what the current parameters are.

oldvalues = zeros(nparms,1);
oldvalues(spuparmrange) = sparsfun('spumoni');
oldvalues(mmdparmrange) = sparsfun('mmdset');
oldvalues(bslparmrange) = sparsfun('slashset');

% No input args, no output args:  Describe current settings.
if nargin == 0 && nargout == 0
    a = num2str(oldvalues(1));
    if oldvalues(1) 
        disp(['SParse MONItor output level ' a '.'])
    else 
        disp('No SParse MONItor output.')
    end
    a = num2str(oldvalues(2));
    b = num2str(oldvalues(3));
    disp(['mmd: threshold = ' a ' * mindegree + ' b ','])
    if oldvalues(4) 
        disp('     using exact degrees in A''*A,')
    else 
        disp('     using approximate degrees in A''*A,')
    end
    s = int2str(oldvalues(5));
    if oldvalues(5)
        disp(['     supernode amalgamation every ' s ' stages,'])
    else
        disp('     no supernode amalgamation,')
    end
    s = int2str(oldvalues(6));
    if oldvalues(6) 
        disp(['     row reduction every ' s ' stages,'])
    else
        disp('     no row reduction,')
    end
    a = num2str(100*oldvalues(7));
    if oldvalues(7)
        disp(['     withhold rows at least ' a '% dense in colmmd.'])
    else
        disp('     no row withholding in colmmd.')
    end
    if oldvalues(8)
        disp('Minimum degree orderings used with chol, v4 lu and qr in \ and /.')
    else
        disp('No automatic orderings used with chol, v4 lu and qr in \ and /.')
    end
    if oldvalues(9)
        disp('Approximate minimum degree orderings used with UMFPACK in \ and /.')
    else
        disp('No automatic orderings used with UMFPACK in \ and /.')
    end
    a = num2str(oldvalues(10));
    disp(['Pivot tolerance of ' a ' used by UMFPACK in \ and /.'])
    a = num2str(oldvalues(11));
    disp(['Backslash uses band solver if band density is > ' a])
    if oldvalues(12)
        disp('UMFPACK used for lu in \ and /.')
    else
        disp('v4 algorithm used for lu in \ and /.')
    end
    return;

% No input args, one or two output args:  Return current settings.
elseif nargin == 0 && nargout > 0
    if nargout <= 1
        return1 = oldvalues;
    else
        return1 = allkeys;
        return2 = oldvalues;
    end
    return;

% One input arg of suitable size:  Reset all parameters.
elseif nargin == 1 && length(arg1) == nparms && min(size(arg1)) == 1
    if nargout > 0 
        error ('MATLAB:spparms:TooManyOutputs', 'Too many output arguments.')
    end
    sparsfun('spumoni',arg1(spuparmrange));
    sparsfun('mmdset',arg1(mmdparmrange));
    sparsfun('slashset',arg1(bslparmrange));
    return;

% Input arg 'tight':  Reset minimum degree parameters.
elseif nargin == 1 && strcmpi(arg1,'tight')
    if nargout > 0
        error ('MATLAB:spparms:TooManyOutputs', 'Too many output arguments.')
    end
    newvalues = oldvalues;
    newvalues(mmdparmrange) = tightmmdparms;
    spparms(newvalues);
    return;

% Input arg 'default':  Reset all parameters.
elseif nargin == 1 && strcmpi(arg1,'default')
    if nargout > 0
        error ('MATLAB:spparms:TooManyOutputs', 'Too many output arguments.')
    end
    spparms(defaultparms);
    return;

% One input arg:  Return one current setting.
elseif (nargin == 1)
    if ~ischar(arg1)
        error ('MATLAB:spparms:OptionNotString', 'Option argument must be a string.')
    end
    if nargout > 1
        error ('MATLAB:spparms:TooManyOutputs', 'Too many output arguments.')
    end
    if size(arg1,1) > 1
        error ('MATLAB:spparms:TooManyParamsPerKeyword',...
               'Must query one parameter by keyword at a time.')
    end
    key = lower(arg1);
    for i = 1:nparms
        if strcmp (key, allkeys(i,:))
            return1 = oldvalues(i);
            return;
        end
    end
    error ('MATLAB:spparms:UnknownKeyword',['Unknown keyword parameter "' key '".']);

% Two input args:  Reset some parameters.
elseif (nargin == 2)
    if ~ischar(arg1)
        error ('MATLAB:spparms:OptionNotString', 'Option argument must be a string.')
    end
    if nargout > 0
        error ('MATLAB:spparms:TooManyOutputs', 'Too many output arguments.')
    end
    if size(arg1,1) ~= length(arg2)
        error ('MATLAB:spparms:ParamsMismatchKeywords',...
               'Number of parameters and keywords must agree.')
    end
    newvalues = oldvalues;
    for k = 1:size(arg1,1)
        key = lower(arg1(k,:));
        value = arg2(k);
        found = 0;
        for i = 1:nparms
            if strcmp (key, allkeys(i,:))
                newvalues(i) = value;
                found = 1;
                break
            end
        end
        if ~found
            disp (['Warning:  Unknown keyword parameter "' key '" in SPPARMS.']);
        end
    end
    spparms(newvalues);
    return;
   
% No error is possible here.
else
    error ('MATLAB:spparms:InvalidArgs', 'Invalid arguments.')
end








