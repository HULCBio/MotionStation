function out = compand(in, param, V, method)
%COMPAND Source code mu-law or A-law compressor or expander.
%   OUT = COMPAND(IN, PARAM, V) computes mu-law compressor with mu given
%   in PARAM and the peak magnitude given in V.
%
%   OUT = COMPAND(IN, PARAM, V, METHOD) computes mu-law or A-law
%   compressor or expander computation with the computation method given
%   in METHOD. PARAM provides the mu or A value. V provides the input
%   signal peak magnitude. METHOD can be chosen as one of the following:
%   METHOD = 'mu/compressor' mu-law compressor.
%   METHOD = 'mu/expander'   mu-law expander.
%   METHOD = 'A/compressor'  A-law compressor.
%   METHOD = 'A/expander'    A-law expander.
%
%   The prevailing values used in practice are mu=255 and A=87.6.
%
%   See also QUANTIZ, DPCMENCO, DPCMDECO.
%

%   Copyright 1996-2002 The MathWorks, Inc.
%   $Revision: 1.11 $

if nargin < 3
    error('Not enough input parameters.');
elseif nargin < 4
    method = 'mu/compressor';
else
    if ~isstr(method)
        error('Parameter METHOD in COMPAND must be a string.');
    end
    method = lower(method);
end

if ~isempty(findstr(method, 'mu'))
    % it is a mu-law case
    if ~isempty(findstr(method, 'com'))
        % mu-law compressor
        out = V / log(1 + param) * log(1 + param / V * abs(in)) .* sign(in);
    else
        % mu-law expandor
        out = V / param * (exp(abs(in) * log(1 + param) / V) - 1) .* sign(in);
    end
else
    % it is an A-law case
    lnAp1 = log(param) + 1;
    VdA   = V / param;
    if ~isempty(findstr(method, 'com'))
        % A-law compressor
        indx = find(abs(in) <= VdA);
        if ~isempty(indx)
            out(indx) = param / lnAp1 * abs(in(indx)) .* sign(in(indx));
        end
        indx = find(abs(in) >  VdA);
        if ~isempty(indx)
            out(indx) = V / lnAp1 * (1 + log(abs(in(indx)) / VdA)) .* sign(in(indx));
        end
    else
        % A-law expandor
        VdlnAp1 = V / lnAp1;
        indx = find(abs(in) <= VdlnAp1);
        if ~isempty(indx)
            out(indx) = lnAp1 / param * abs(in(indx)) .* sign(in(indx));
        end
        indx = find(abs(in) >  VdlnAp1);
        if ~isempty(indx)
            out(indx) = VdA * exp(abs(in(indx)) / VdlnAp1 - 1) .* sign(in(indx));
        end
    end
end
% -- end of compand ---
