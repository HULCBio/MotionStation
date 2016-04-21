function [a,d] = dwt(x,varargin)
%DWT Single-level discrete 1-D wavelet transform.
%   DWT performs a single-level 1-D wavelet decomposition
%   with respect to either a particular wavelet ('wname',
%   see WFILTERS for more information) or particular wavelet filters
%   (Lo_D and Hi_D) that you specify.
%
%   [CA,CD] = DWT(X,'wname') computes the approximation
%   coefficients vector CA and detail coefficients vector CD,
%   obtained by a wavelet decomposition of the vector X.
%   'wname' is a string containing the wavelet name.
%
%   [CA,CD] = DWT(X,Lo_D,Hi_D) computes the wavelet decomposition
%   as above given these filters as input:
%   Lo_D is the decomposition low-pass filter.
%   Hi_D is the decomposition high-pass filter.
%   Lo_D and Hi_D must be the same length.
%
%   Let LX = length(X) and LF = the length of filters; then
%   length(CA) = length(CD) = LA where LA = CEIL(LX/2),
%   if the DWT extension mode is set to periodization.
%   LA = FLOOR((LX+LF-1)/2) for the other extension modes.  
%   For the different signal extension modes, see DWTMODE. 
%
%   [CA,CD] = DWT(...,'mode',MODE) computes the wavelet 
%   decomposition with the extension mode MODE you specify.
%   MODE is a string containing the extension mode.
%   Example: 
%     [ca,cd] = dwt(x,'db1','mode','sym');
%
%   See also DWTMODE, IDWT, WAVEDEC, WAVEINFO.

%   M. Misiti, Y. Misiti, G. Oppenheim, J.M. Poggi 12-Mar-96.
%   Last Revision: 19-May-2003.
%   Copyright 1995-2004 The MathWorks, Inc.
%   $Revision: 1.15.4.2 $

% Check arguments.
nbIn = nargin;
if nbIn < 2
  error('Not enough input arguments.');
elseif nbIn > 7
  error('Too many input arguments.');
end
if ischar(varargin{1})
    [Lo_D,Hi_D] = wfilters(varargin{1},'d'); next = 2;
else
    Lo_D = varargin{1}; Hi_D = varargin{2};  next = 3;
end

% Check arguments for Extension and Shift.
global DWT_Attribute
if isempty(DWT_Attribute)
    DWT_Attribute = dwtmode('get');
end
dwtEXTM = DWT_Attribute.extMode; % Default: Extension.
shift   = DWT_Attribute.shift1D; % Default: Shift.
for k = next:2:nbIn-1
    switch varargin{k}
      case 'mode'  , dwtEXTM = varargin{k+1};
      case 'shift' , shift   = mod(varargin{k+1},2);
    end
end

% Compute sizes and shape.
lf = length(Lo_D);
lx = length(x);

% Extend, Decompose &  Extract coefficients.
first = 2-shift;
flagPer = isequal(dwtEXTM,'per');
if ~flagPer
    lenEXT = lf-1; last = lx+lf-1;
else
    lenEXT = lf/2; last = 2*ceil(lx/2);
end
y = wextend('1D',dwtEXTM,x,lenEXT);

% Compute coefficients of approximation.
z = wconv1(y,Lo_D,'valid'); 
a = z(first:2:last);

% Compute coefficients of detail.
z = wconv1(y,Hi_D,'valid'); 
d = z(first:2:last);
