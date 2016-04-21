function varargout = iswt2(varargin)
%ISWT2 Inverse discrete stationary wavelet transform 2-D.
%   ISWT2 performs a multilevel 2-D stationary wavelet 
%   reconstruction using either a specific orthogonal wavelet  
%   ('wname', see WFILTERS for more information) or specific
%   reconstruction filters (Lo_R and Hi_R).
%
%   X = ISWT2(SWC,'wname') or X = ISWT2(A,H,V,D,'wname') 
%   or X = ISWT2(A(:,:,end),H,V,D,'wname') reconstructs the 
%   matrix X, based on the multilevel stationary wavelet   
%   decomposition structure SWC or [A,H,V,D] (see SWT2).
%
%   For X = ISWT2(SWC,Lo_R,Hi_R) or X = ISWT2(A,H,V,D,Lo_R,Hi_R) 
%   or X = ISWT2(A(:,:,end),H,V,D,Lo_R,Hi_R): 
%   Lo_R is the reconstruction low-pass filter.
%   Hi_R is the reconstruction high-pass filter.
%
%   See also IDWT2, SWT2, WAVEREC2.

%   M. Misiti, Y. Misiti, G. Oppenheim, J.M. Poggi 08-Dec-97.
%   Last Revision: 14-May-2003.
%   Copyright 1995-2004 The MathWorks, Inc.
%   $Revision: 1.5.4.2 $  $Date: 2004/03/15 22:40:55 $

% Check arguments.
nbIn = nargin;
switch nbIn
  case {0,1} , error('Not enough input arguments.');
  case 4     , error('Invalid number of input arguments.');
  case {2,3,5,6} , 
  otherwise , error('Too many input arguments.');
end
switch nbIn
    case 2 , argstr = 1; argnum = 2;
    case 3 , argstr = 0; argnum = 2;
    case 5 , argstr = 1; argnum = 5;
    case 6 , argstr = 0; argnum = 5;
end

% Compute decomposition filters.
if argstr
    [lo_R,hi_R] = wfilters(varargin{argnum},'r');
else
    lo_R = varargin{argnum}; hi_R = varargin{argnum+1};
end

% Set DWT_Mode to 'per'.
old_modeDWT = dwtmode('status','nodisp');
modeDWT = 'per';
dwtmode(modeDWT,'nodisp');

% Get inputs.
if argnum==2
    p = size(varargin{1},3);
    if rem(p,3)==1 , n = (p-1)/3;
    else
        errargt(mfilename,'Invalid size for the first argument!','msg');
        error('*');
    end
    h = varargin{1}(:,:,1:n);
    v = varargin{1}(:,:,n+1:2*n);
    d = varargin{1}(:,:,2*n+1:3*n);
    a = varargin{1}(:,:,3*n+1:p);
else
    a = varargin{1};
    h = varargin{2};
    v = varargin{3};
    d = varargin{4};
end

a = a(:,:,size(a,3));
[rx,cx,n] = size(h);
for k = n:-1:1
    step = 2^(k-1);
    last = step;
    for first = 1:last
        iRow = first:step:rx;
        lR   = length(iRow);
        iCol = first:step:cx;
        lC   = length(iCol);
 
        sR   = iRow(1:2:lR);
        sC   = iCol(1:2:lC);
        x1   = idwt2LOC(a(sR,sC),h(sR,sC,k),v(sR,sC,k),d(sR,sC,k), ...
                     lo_R,hi_R,[lR lC],[0,0]);
        sR   = iRow(2:2:lR);
        sC   = iCol(2:2:lC);
        x2   = idwt2LOC(a(sR,sC),h(sR,sC,k),v(sR,sC,k),d(sR,sC,k), ...
                     lo_R,hi_R,[lR lC],[-1,-1]);
        a(iRow,iCol) = 0.5*(x1+x2);
    end
end
varargout{1} = a;

% Restore DWT_Mode.
dwtmode(old_modeDWT,'nodisp');


%===============================================================%
% INTERNAL FUNCTIONS
%===============================================================%
function y = idwt2LOC(a,h,v,d,lo_R,hi_R,sy,shift)

y = upconvLOC(a,lo_R,lo_R,sy)+ ... % Approximation.
    upconvLOC(h,hi_R,lo_R,sy)+ ... % Horizontal Detail.
    upconvLOC(v,lo_R,hi_R,sy)+ ... % Vertical Detail.
    upconvLOC(d,hi_R,hi_R,sy);     % Diagonal Detail.

if shift(1)==-1 , y = y([end,1:end-1],:); end
if shift(2)==-1 , y = y(:,[end,1:end-1]); end
%---------------------------------------------------------------%
function y = upconvLOC(x,f1,f2,s)

lf = length(f1);
y  = dyadup(x,'mat',0,1);
y  = wextend('2D','per',y,[lf/2,lf/2]);
y  = wconv2('col',y,f1);
y  = wconv2('row',y,f2);
y  = wkeep2(y,s,[lf lf]);
%===============================================================%
