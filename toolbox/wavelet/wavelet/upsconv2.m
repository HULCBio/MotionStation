function y = upsconv2(x,f,s,dwtARG1,dwtARG2)
%UPSCONV2 Upsample and convolution.
%
%   Y = UPSCONV2(X,{F1_R,F2_R},S,DWTATTR) returns the size-S
%   central portion of the one step dyadic interpolation 
%   (upsample and convolution) of matrix X using filter F1_R 
%   for rows and filter F2_R for columns. The upsample and 
%   convolution attributes are described by DWTATTR.

%   M. Misiti, Y. Misiti, G. Oppenheim, J.M. Poggi 06-May-2003.
%   Last Revision: 21-May-2003.
%   Copyright 1995-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2004/03/15 22:42:01 $

% Special case.
if isempty(x) , y = 0; return; end

% Check arguments for Extension and Shift.
switch nargin
    case 3 , 
        perFLAG  = 0;  
        dwtSHIFT = [0 0];
    case 4 , % Arg4 is a STRUCT
        perFLAG  = isequal(dwtARG1.extMode,'per');
        dwtSHIFT = mod(dwtARG1.shift2D,2);
    case 5 , 
        perFLAG  = isequal(dwtARG1,'per');
        dwtSHIFT = mod(dwtARG2,2);
end

% Define Size.
sx = 2*size(x);
lf = length(f{1});
if isempty(s)
    if ~perFLAG , s = sx-lf+2; else , s = sx; end
end

% Compute Upsampling and Convolution.
y = x;
if ~perFLAG
    y = wconv2('col',dyadup(y,'row',0),f{1});
    y = wconv2('row',dyadup(y,'col',0),f{2});
    y = wkeep2(y,s,'c',dwtSHIFT);
else
    y = dyadup(y,'row',0,1);
    y = wextend('addrow','per',y,lf/2);
    y = wconv2('col',y,f{1});
    y = y(lf:lf+s(1)-1,:);
    %-------------------------------------------
    y = dyadup(y,'col',0,1);
    y = wextend('addcol','per',y,lf/2);
    y = wconv2('row',y,f{2});
    y = y(:,lf:lf+s(2)-1);
    %-------------------------------------------
    if dwtSHIFT(1)==1 , y = y([2:end,1],:); end
    if dwtSHIFT(2)==1 , y = y(:,[2:end,1]); end
    %-------------------------------------------
end