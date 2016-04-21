function out = applymattrc_inv(in, MatTRC)
%APPLYMATTRC_INV converts from device space to ICC profile connection space
%   OUT = APPLYMATTRC_INV(IN, MatTRC) converts from ICC profile space
%   to device space, i.e., BtoA using the Matrix-based model.  The only 
%   Profile Connection Space supported by this model type is 16 bit XYZ.
%   MatTRC is a sub structure of an in matlab representation of an ICC
%   profile (see iccread). Both IN and OUT are n x 3 vectors.  OUT can be
%   either uint8 or unit16.  IN is a unit16 encoding of ICC CIEXYZ.

%   Copyright 1993-2003 The MathWorks, Inc.
%   $Revision: 1.1.6.3 $  $Date: 2003/08/23 05:53:32 $
%   Author:  Scott Gregory, 10/20/02
%   Revised: Toshia McCabe 12/3/02

% Check input arguments
checknargin(2,2,nargin,'applymattrc_inv');
checkinput(in,{'uint16'},{'real','2d','nonsparse','finite'},...
           'applymattrc_inv','IN',1);
if size(in,2) ~= 3
    eid = 'Images:applymattrc_inv:invalidInputData';
    msg = 'Incorrect number of columns in IN.';
    error(eid,'%s',msg');
end

% Check the MatTRC
checkinput(MatTRC,{'struct'},{'nonempty'},'applymattrc_fwd','MATTRC',2);

%cast inputs to double and scale to 1
xyz = (double(in) / hex2dec('8000'));

% construct matrix and evaluate
mat = [MatTRC.RedColorant;
       MatTRC.GreenColorant;
       MatTRC.BlueColorant];
rgb = xyz * inv(mat);

% apply RGB non-linearity
rows_in = size(MatTRC.GreenTRC,1);
if rows_in == 1,   % gamma trc
    rgb(:,1) = rgb(:,1) .^(1/MatTRC.RedTRC);
    rgb(:,2) = rgb(:,2) .^(1/MatTRC.GreenTRC);
    rgb(:,3) = rgb(:,3) .^(1/MatTRC.BlueTRC);
else
    TRC = double([MatTRC.RedTRC MatTRC.GreenTRC MatTRC.BlueTRC])/65535;
    tmp1=linspace(0,1,rows_in);
    samples =  repmat(tmp1',1,3);
    
    % Clip rgb values to the range [0, 1] before calling interp1.
    rgb = max(rgb, 0);
    rgb = min(rgb, 1);
    for i=1:3,
        rgb(:,i) = interp1(TRC(:,i),samples(:,i),rgb(:,i),'spline'); 
    end
end

% encode as uint16
out = uint16(round(65535 * rgb));