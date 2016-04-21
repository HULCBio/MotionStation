function x = idwt(a,d,varargin)
%IDWT Single-level inverse discrete 1-D wavelet transform.
%   IDWT performs a single-level 1-D wavelet reconstruction
%   with respect to either a particular wavelet
%   ('wname', see WFILTERS for more information) or particular wavelet
%   reconstruction filters (Lo_R and Hi_R) that you specify.
%
%   X = IDWT(CA,CD,'wname') returns the single-level
%   reconstructed approximation coefficients vector X
%   based on approximation and detail coefficients
%   vectors CA and CD, and using the wavelet 'wname'.
%
%   X = IDWT(CA,CD,Lo_R,Hi_R) reconstructs as above,
%   using filters that you specify:
%   Lo_R is the reconstruction low-pass filter.
%   Hi_R is the reconstruction high-pass filter.
%   Lo_R and Hi_R must be the same length.
%
%   Let LA = length(CA) = length(CD) and LF the length
%   of the filters; then length(X) = LX where LX = 2*LA
%   if the DWT extension mode is set to periodization.
%   LX = 2*LA-LF+2 for the other extension modes.
%   For the different DWT extension modes, see DWTMODE. 
%
%   X = IDWT(CA,CD,'wname',L) or X = IDWT(CA,CD,Lo_R,Hi_R,L)
%   returns the length-L central portion of the result
%   obtained using IDWT(CA,CD,'wname'). L must be less than LX.
%
%   X = IDWT(...,'mode',MODE) computes the wavelet
%   reconstruction using the specified extension mode MODE.
%
%   X = IDWT(CA,[], ... ) returns the single-level
%   reconstructed approximation coefficients vector X
%   based on approximation coefficients vector CA.
%   
%   X = IDWT([],CD, ... ) returns the single-level
%   reconstructed detail coefficients vector X
%   based on detail coefficients vector CD.
% 
%   See also DWT, DWTMODE, UPWLEV.

%   M. Misiti, Y. Misiti, G. Oppenheim, J.M. Poggi 12-Mar-96.
%   Last Revision: 19-May-2003.
%   Copyright 1995-2004 The MathWorks, Inc.
% $Revision: 1.14.4.2 $

% Check arguments.
nbIn = nargin;
if nbIn<3 ,
    error('Not enough input arguments.');
elseif nbIn>9 ,
    error('Too many input arguments.');
end
if isempty(a) && isempty(d) , x = []; return; end
if ischar(varargin{1})
    [Lo_R,Hi_R] = wfilters(varargin{1},'r'); next = 2;
else
    Lo_R = varargin{1}; Hi_R = varargin{2};  next = 3;
end

% Check arguments for Length, Extension and Shift.
global DWT_Attribute
if isempty(DWT_Attribute)
    DWT_Attribute = dwtmode('get');
end
dwtEXTM = DWT_Attribute.extMode; % Default: Extension.
shift   = DWT_Attribute.shift1D; % Default: Shift.
lx = [];
k = next;
while k<=length(varargin)
    if ischar(varargin{k})
        switch varargin{k}
           case 'mode'  , dwtEXTM = varargin{k+1};
           case 'shift' , shift = mod(varargin{k+1},2);
        end
        k = k+2;
    else
        lx = varargin{k};
        k = k+1;
    end
end

% Reconstructed Approximation and Detail.
x = upsconv1(a,Lo_R,lx,dwtEXTM,shift) + upsconv1(d,Hi_R,lx,dwtEXTM,shift);
