function [a,h,v,d] = dwt2(x,varargin)
%DWT2 Single-level discrete 2-D wavelet transform.
%   DWT2 performs a single-level 2-D wavelet decomposition
%   with respect to either a particular wavelet ('wname',
%   see WFILTERS for more information) or particular wavelet filters
%   (Lo_D and Hi_D) you specify.
%
%   [CA,CH,CV,CD] = DWT2(X,'wname') computes the approximation
%   coefficients matrix CA and details coefficients matrices 
%   CH, CV, CD, obtained by a wavelet decomposition of the 
%   input matrix X.
%   'wname' is a string containing the wavelet name.
%
%   [CA,CH,CV,CD] = DWT2(X,Lo_D,Hi_D) computes the 2-D wavelet
%   decomposition as above given these filters as input:
%   Lo_D is the decomposition low-pass filter.
%   Hi_D is the decomposition high-pass filter.
%   Lo_D and Hi_D must be the same length.
%
%   Let SX = size(X) and LF = the length of filters; then
%   size(CA) = size(CH) = size(CV) = size(CD) = SA where
%   SA = CEIL(SX/2), if the DWT extension mode is set to
%   periodization. SA = FLOOR((SX+LF-1)/2) for the other
%   extension modes. For the different DWT extension modes, 
%   see DWTMODE.
%
%   [CA,CH,CV,CD] = DWT2(...,'mode',MODE) computes the wavelet 
%   decomposition with the extension mode MODE you specify.
%   MODE is a string containing the extension mode.
%   Example: 
%     [ca,ch,cv,cd] = dwt2(x,'db1','mode','sym');
%
%   See also DWTMODE, IDWT2, WAVEDEC2, WAVEINFO.

%   M. Misiti, Y. Misiti, G. Oppenheim, J.M. Poggi 12-Mar-96.
%   Last Revision: 19-May-2003.
%   Copyright 1995-2004 The MathWorks, Inc.
% $Revision: 1.15.4.2 $

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
shift   = DWT_Attribute.shift2D; % Default: Shift.
for k = next:2:nbIn-1
    switch varargin{k}
      case 'mode'  , dwtEXTM = varargin{k+1};
      case 'shift' , shift   = mod(varargin{k+1},2);
    end
end

% Compute sizes.
lf = length(Lo_D);
sx = size(x);

% Extend, Decompose &  Extract coefficients.
first = 2-shift;
flagPer = isequal(dwtEXTM,'per');
if ~flagPer
    sizeEXT = lf-1; last = sx+lf-1;
else
    sizeEXT = lf/2; last = 2*ceil(sx/2);
end
y = wextend('addcol',dwtEXTM,x,sizeEXT);
z = wconv2('row',y,Lo_D,'valid');
a = convdown(z,Lo_D,dwtEXTM,sizeEXT,first,last);
h = convdown(z,Hi_D,dwtEXTM,sizeEXT,first,last);
z = wconv2('row',y,Hi_D,'valid');
v = convdown(z,Lo_D,dwtEXTM,sizeEXT,first,last);
d = convdown(z,Hi_D,dwtEXTM,sizeEXT,first,last);

%-------------------------------------------------------%
% Internal Function(s)
%-------------------------------------------------------%
function y = convdown(x,F,dwtEXTM,lenEXT,first,last)

y = x(:,first(2):2:last(2));
y = wextend('addrow',dwtEXTM,y,lenEXT);
y = wconv2('col',y,F,'valid');
y = y(first(1):2:last(1),:);
%-------------------------------------------------------%
