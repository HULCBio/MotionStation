function out = applyclut(varargin)
%APPLYCLUT converts DATA using ICC CLUT based transform
%   OUT = APPLYCLUT(IN,LUTTAG,ISXYZ) converts to and from ICC profile 
%   connection space and device space, i.e., AtoB and BtoA using the 
%   CLUT-based model.  The LUTTAG is a sub structure of an in matlab
%   representation of an ICC profile (see iccread). Both IN and OUT
%   are p x n vectors.  Where p is the number of data points to be
%   transformed and n either 3 or 4.  Only rgb and cmyk device spaces are
%   supported in this inplementation.  IN and Out are to be pass in one   
%   of the standard ICC encodings for device or device independent color
%   spaces and represented as either a uint8 or a unit16. ISXYZ (optional)
%   may be set to 1 if IN is XYZ data. The default for ISXYZ is 0.

%   Copyright 1993-2003 The MathWorks, Inc.
%   $Revision.4 $  $Date: 2003/08/23 05:53:30 $
%   Author:  Scott Gregory, 10/20/02
%   Revised: Scott Gregory, Toshia McCabe 12/17/02

% Check input arguments
checknargin(2,3,nargin,'applyclut');

in = varargin{1};
checkinput(in,{'uint8','uint16'},{'real','2d','nonsparse','finite'},...
           'applyclut','IN',1);

% Check the luttag
luttag = varargin{2};
checkinput(luttag,{'struct'},{'nonempty'},'applyclut','LUTTAG',1);

%  Check that input data matches num input channels
if (size(in,2) ~= size(luttag.InputTables,2)) || ...
      (size(in,2) ~= 3 && size(in,2) ~= 4)
    eid = 'Images:applyclut:private:invalidInputData';
    msg = 'Incorrect number of channels in IN.';
    error(eid,'%s',msg');
end

% Check the input colorspace
if nargin == 3
    isxyz = varargin{3};
end

% Set scale
if luttag.MFT==1
    scale=255;
else
    scale=65535;
end

%Check that incoming data matches the MFT type
if (isa(in,'uint8') && luttag.MFT==2) || (isa(in,'uint16') && luttag.MFT==1)
    eid = sprintf('Images:%s:invalidInputDataType',mfilename);            
    error(eid,'%s','input data type does not match clut type')
end

%cast inputs to double
in = double(in);

% pass data through matrix if input space is XYZ
if isxyz
    in = in * luttag.E';    
end

% pass data through Input Tables
[rows_in,chan_in]=size(luttag.InputTables);

% Check to make sure the luttag is 3 or 4 chans 
if chan_in ~= 3 && chan_in ~= 4
    eid = sprintf('Images:%s:invalidNumberOfChannels',mfilename);            
    error(eid,'%s','Number of input channels not supported. Only 3 or 4 channels are allowed.');
end

%define input sample points that correspond to the function values
%found in the input tables.
tmp1=linspace(0,scale,rows_in);
samples =  (ones(chan_in,1) * tmp1)';

% evalutate the function at the points given by IN.
grid_index = zeros(size(in));
% Clip input values before calling interp1 to make sure it doesn't return
% NaNs.
in = min(in, scale);
in = max(in, 0);
for i=1:chan_in,
    grid_index(:,i) = interp1(samples(:,i),double(luttag.InputTables(:,i)),in(:,i)); 
end

% pass through grid tables
[rows_out,chan_out]=size(luttag.OutputTables);
clutsize = size(luttag.CLUT,1);
tmp1 = linspace(0,scale,clutsize);
outtable_index = zeros(size(in,1),chan_out);

% Clip grid_index values before calling interpn to make sure it doesn't
% return NaNs.
grid_index = min(grid_index, scale);
grid_index = max(grid_index, 0);

if chan_in==3
    [samples1,samples2,samples3] = ndgrid(tmp1, tmp1, tmp1);
    for i=1:chan_out,
        % evaluate the function at the points given by "grid_index"
        outtable_index(:,i) = interpn(samples1,samples2,samples3,double(luttag.CLUT(:,:,:,i)),...
                                      grid_index(:,3),grid_index(:,2),grid_index(:,1));
    end
else   % CMYK input
    [samples1,samples2,samples3,samples4] = ndgrid(tmp1, tmp1, tmp1,tmp1);
    for i=1:chan_out,
        % evaluate the function at the points given by "grid_index"
        outtable_index(:,i) = interpn(samples1,samples2,samples3,samples4,...
                                      double(luttag.CLUT(:,:,:,:,i)),...
                                      grid_index(:,4),grid_index(:,3),...
                                      grid_index(:,2),grid_index(:,1));
    end
end

% pass through output tables

tmp1=linspace(0,scale,rows_out);
samples = (ones(chan_out,1) * tmp1)';
out = zeros(size(outtable_index));

% Clip outtable_index values before calling interp1 to make sure it
% doesn't return NaNs.
outtable_index = min(outtable_index, scale);
outtable_index = max(outtable_index, 0);

for i=1:chan_out,
    % evaluate the function at the points given by outtable_index.
    out(:,i) = interp1(samples(:,i),double(luttag.OutputTables(:,i)),outtable_index(:,i));
end

if luttag.MFT==1
    out = uint8(round(out));
else
    out = uint16(round(out));
end
