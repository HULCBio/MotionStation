function varargout = quantize(u, varargin)
%QUANTIZE Quantize except numbers within eps of 1 for UNITQUANTIZE object
%   QUANTIZE(Q,...) when Q is a UNITQUANTIZER object works the same as
%   QUANTIZE except that numbers within eps(q) of one are made exactly equal
%   to 1. 
%
%   See also QUANTIZER, QUANTIZER/QUANTIZE, QUANTIZER/UNITQUANTIZE

%   Thomas A. Bryan, 11 August 1999
%   Copyright 1999-2002 The MathWorks, Inc.
%   $Revision: 1.8 $  $Date: 2002/04/14 15:35:59 $

% Convert to a regular quantizer object first.
qj = get(u,'quantizer');
q = quantizer(qj);
[varargout{1:max(nargout,1)}] = unitquantize(q,varargin{:});
% Set the states of the unitquantizer from the quantizer
u = set(u,get(q,'quantizer'));

