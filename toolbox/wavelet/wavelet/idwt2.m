function x = idwt2(a,h,v,d,varargin)
%IDWT2  Single-level inverse discrete 2-D wavelet transform.
%   IDWT2 performs a single-level 2-D wavelet reconstruction
%   with respect to either a particular wavelet
%   ('wname', see WFILTERS for more information) or particular wavelet
%   reconstruction filters (Lo_R and Hi_R) you specify.
%
%   X = IDWT2(CA,CH,CV,CD,'wname') uses the wavelet 'wname'
%   to compute the single-level reconstructed approximation
%   coefficients matrix X, based on approximation matrix CA
%   and (horizontal, vertical, and diagonal) details matrices
%   CH, CV and CD.
%
%   X = IDWT2(CA,CH,CV,CD,Lo_R,Hi_R) reconstructs as above,
%   using filters you specify:
%   Lo_R is the reconstruction low-pass filter.
%   Hi_R is the reconstruction high-pass filter.
%   Lo_R and Hi_R must be the same length.
%
%   Let SA = size(CA) = size(CH) = size(CV) = size(CD) and
%   LF the length of the filters; then size(X) = SX where
%   SX = 2*SA if the DWT extension mode is set to periodization.
%   SX = 2*SA-LF+2 for the other extension modes.
%
%   X = IDWT2(CA,CH,CV,CD,'wname',S) and
%   X = IDWT2(CA,CH,CV,CD,Lo_R,Hi_R,S) return the size-S
%   central portion of the result obtained using
%   IDWT2(CA,CH,CV,CD,'wname'). S must be less than SX.
%
%   X = IDWT2(...,'mode',MODE) computes the wavelet
%   reconstruction using the specified extension mode MODE.
%
%   X = IDWT2(CA,[],[],[], ... ) returns the single-level
%   reconstructed approximation coefficients matrix X
%   based on approximation coefficients matrix CA.
%   
%   X = IDWT2([],CH,[],[], ... ) returns the single-level
%   reconstructed detail coefficients matrix X
%   based on horizontal detail coefficients matrix CH.
%
%   The same result holds for X = IDWT2([],[],CV,[], ... ) and
%   X = IDWT2([],[],[],CD, ... ).
%
%   More generally, X = IDWT2(AA,HH,VV,DD, ... ) returns the single-level
%   reconstructed matrix X where AA can be CA or [], and so on.
%
%   See also DWT2, DWTMODE, UPWLEV2.

%   M. Misiti, Y. Misiti, G. Oppenheim, J.M. Poggi 12-Mar-96.
%   Last Revision: 19-May-2003.
%   Copyright 1995-2004 The MathWorks, Inc.
% $Revision: 1.15.4.2 $

% Check arguments.
nbIn = nargin;
if nbIn<5 ,
    error('Not enough input arguments.');
elseif nbIn>11 ,
    error('Too many input arguments.');
end
if isempty(a) && isempty(h) && isempty(v) && isempty(d), x = []; return; end
if ischar(varargin{1})
    [Lo_R,Hi_R] = wfilters(varargin{1},'r'); next = 2;
else
    Lo_R = varargin{1}; Hi_R = varargin{2};  next = 3;
end

% Check arguments for Size, Shift and Extension.
global DWT_Attribute
if isempty(DWT_Attribute)
    DWT_Attribute = dwtmode('get');
end
dwtEXTM = DWT_Attribute.extMode; % Default: Extension.
shift   = DWT_Attribute.shift2D; % Default: Shift.
sx = [];
k = next;
while k<=length(varargin)
    if ischar(varargin{k})
        switch varargin{k}
           case 'mode'  , dwtEXTM = varargin{k+1};
           case 'shift' , shift = mod(varargin{k+1},2);
        end
        k = k+2;
    else
        sx = varargin{k};
        k = k+1;
    end
end
      
x = upsconv2(a,{Lo_R,Lo_R},sx,dwtEXTM,shift)+ ... % Approximation.
    upsconv2(h,{Hi_R,Lo_R},sx,dwtEXTM,shift)+ ... % Horizontal Detail.
    upsconv2(v,{Lo_R,Hi_R},sx,dwtEXTM,shift)+ ... % Vertical Detail.
    upsconv2(d,{Hi_R,Hi_R},sx,dwtEXTM,shift);     % Diagonal Detail.
