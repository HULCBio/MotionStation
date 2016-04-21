function out = applymattrc_fwd(in, MatTRC)
%APPLYMATTRC_FWD converts from device space to ICC profile connection space
%   OUT = APPLYMATTRC_FWD(IN, MatTRC) converts from device space to ICC 
%   profile space, i.e., AtoB using the Matrix-based model.  The only 
%   Profile Connection Space supported by this model type is 16 bit XYZ.
%   MatTRC is a sub structure of an in matlab representation of an ICC
%   profile (see iccread). Both IN and OUT are n x 3 vectors.  IN can be
%   either uint8 or unit16.  Out is a unit16 encoding of ICC CIEXYZ.

%   Copyright 1993-2003 The MathWorks, Inc.
%   $Revision: 1.1.6.3 $  $Date: 2003/08/23 05:53:31 $
%   Author:  Scott Gregory, 10/20/02
%   Revised: Toshia McCabe, 12/04/02

% Check input arguments
checknargin(2,2,nargin,'applymattrc_fwd');
checkinput(in,{'uint8','uint16'},{'real','2d','nonsparse','finite'},...
           'applymattrc_fwd','IN',1);
if size(in,2) ~= 3
    eid = 'Images:applymattrc_fwd:invalidInputData';
    msg = 'Incorrect number of columns in IN.';
    error(eid,'%s',msg');
end

% Check the MatTRC
checkinput(MatTRC,{'struct'},{'nonempty'},'applymattrc_fwd','MATTRC',2);

%cast inputs to double and scale to 1
rgb = im2double(in);

% linearize RGB
rows_in = size(MatTRC.GreenTRC,1);
if rows_in == 1,   % gamma trc
    rgb(:,1) = rgb(:,1) .^(MatTRC.RedTRC);
    rgb(:,2) = rgb(:,2) .^(MatTRC.GreenTRC);
    rgb(:,3) = rgb(:,3) .^(MatTRC.BlueTRC);
else
    TRC = double([MatTRC.RedTRC MatTRC.GreenTRC MatTRC.BlueTRC])/65535;
    tmp1=linspace(0,1,rows_in);
    samples =  repmat(tmp1',1,3);

    % Clip rgb values to the range [0, 1] before calling interp1.
    rgb = max(rgb, 0);
    rgb = min(rgb, 1);
    for i=1:3,
        rgb(:,i) = interp1(samples(:,i),TRC(:,i),rgb(:,i),'spline'); 
    end
end

% construct matrix and evaluate
mat = [MatTRC.RedColorant;
       MatTRC.GreenColorant;
       MatTRC.BlueColorant];
out = rgb * mat;

% encode as 16 bit ICC CIEXYZ, uint16
out = uint16(65535 * out / (1 + (32767/32768)));