function x = waverec2(c,s,varargin)
%WAVEREC2  Multilevel 2-D wavelet reconstruction.
%   WAVEREC2 performs a multilevel 2-D wavelet reconstruction
%   using either a specific wavelet ('wname', see WFILTERS) or
%   specific reconstruction filters (Lo_R and Hi_R).
%
%   X = WAVEREC2(C,S,'wname') reconstructs the matrix X
%   based on the multi-level wavelet decomposition structure
%   [C,S] (see WAVEDEC2).
%
%   For X = WAVEREC2(C,S,Lo_R,Hi_R),
%   Lo_R is the reconstruction low-pass filter and
%   Hi_R is the reconstruction high-pass filter.
%
%   See also APPCOEF2, IDWT2, WAVEDEC2.

%   M. Misiti, Y. Misiti, G. Oppenheim, J.M. Poggi 12-Mar-96.
%   Last Revision: 14-May-2003.
%   Copyright 1995-2004 The MathWorks, Inc.
% $Revision: 1.11.4.2 $

% Check arguments.
nbIn = nargin;
if nbIn < 3
  error('Not enough input arguments.');
elseif nbIn > 4
  error('Too many input arguments.');
end

x = appcoef2(c,s,varargin{:},0);
