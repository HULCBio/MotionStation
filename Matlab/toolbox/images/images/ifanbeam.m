function [I,H] = ifanbeam(varargin)
%IFANBEAM Compute inverse fan-beam transform.
%   I = ifanbeam(F,D) reconstructs the image I from projection data in the
%   two-dimensional array F. Each column of F contains fan-beam projection
%   data at one rotation angle. IFANBEAM assumes that the center of rotation
%   is the center point of the projections, which is defined as
%   ceil(size(F,1)/2).  
%
%   The fan-beam spread angles are assumed to be the same increments as the
%   input rotation angles split equally on either side of zero. The input
%   rotation angles are spaced equally to cover [0:359] degrees.
%
%   D is the distance in pixels from the fan-beam vertex to the center of
%   rotation.
%
%   I = IFANBEAM(...,PARAM1,VAL1,PARAM2,VAL2,...)
%   specifies parameters that control various aspects of the ifanbeam
%   reconstruction. Parameter names can be abbreviated, and case does not
%   matter. Default values are in braces like this: {default}.
%
%   Parameters include:
%
%   'FanCoverage'           String specifying the range through which the
%                           beams are rotated.
%                           {'cycle'} - [0,360).
%                           'minimal' - input rotation angle range is the
%                           minimal necessary to fully represent the
%                           object.
%                        
%   'FanRotationIncrement'  Positive real scalar.
%                           {1}
%                           See FANBEAM for details.
%
%   'FanSensorGeometry'     String specifying how sensors are positioned.
%                           {'arc'}, 'line'
%                           See FANBEAM for details.
%                           
%   'FanSensorSpacing'      Positive real scalar specifying the spacing
%                           of the fan beam sensors. Interpretation of
%                           the value depends on the setting of 
%                           'FanSensorGeometry'.
%                           {1}
%                           See FANBEAM for details.
%   'Filter'                String specifying filter.
%                           {'Ram-Lak'}, 'Shepp-Logan', 'Cosine', 'Hamming',
%                           'Hann' See IRADON for details.
%                           
%   'FrequencyScaling'      Positive scalar.
%                           See IRADON for details.
%                           
%   'Interpolation'         String specifying interpolation method.
%                           {'linear'}, 'nearest', 'spline'
%                           See IRADON for details.
%                                                      
%   'OutputSize'            Positive scalar specifying the number of rows 
%                           and columns in the reconstructed image. 
%                           
%                           If 'OutputSize' is not specified, IFANBEAM 
%                           determines the size automatically. 
%                           
%                           If you specify 'OutputSize', IFANBEAM
%                           reconstructs a smaller or larger portion of the
%                           image, but does not change the scaling of the
%                           data.
%                           
%                           Note: If the projections were calculated with the
%                           FANBEAM function, the reconstructed image may not
%                           be the same size as the original image.  
%                           
%   [I,H] = IFANBEAM(...) returns the frequency response of the filter
%   in the vector H.
%
%   Notes
%   -----
%   IFANBEAM converts the fan-beam data to parallel beam projections
%   and then uses the filtered backprojection algorithm to perform
%   the inverse Radon transform.  The filter is designed directly 
%   in the frequency domain and then multiplied by the FFT of the 
%   projections.  The projections are zero-padded to a power of 2 
%   before filtering to prevent spatial domain aliasing and to 
%   speed up the FFT.
%
%   Class Support
%   -------------
%   All numeric input arguments must be of class double.  The output
%   arguments are of class double.
%
%   Example
%   -------
%       ph = phantom(128);
%       d = 100;
%       F = fanbeam(ph,d);
%       I = ifanbeam(F,d,'FanSensorSpacing',0.5);
%       imview(ph); imview(I);
%
%   See also FAN2PARA, FANBEAM, IRADON, PARA2FAN, PHANTOM, RADON.

%   Copyright 1993-2003 The MathWorks, Inc.  
%   $Revision: 1.1.6.3 $  $Date: 2003/12/13 02:43:08 $

%   References: 
%      A. C. Kak, Malcolm Slaney, "Principles of Computerized Tomographic
%      Imaging", IEEE Press 1988.

checknargin(2,18,nargin,mfilename);

F = varargin{1};
d = varargin{2};

checkinput(F, {'double'}, ...
           {'real', '2d', 'nonsparse'}, ...
           mfilename, 'F', 1);

checkinput(d, {'double'},...
           {'real', '2d', 'nonsparse', 'positive'}, ...
           mfilename, 'D', 2);

% defaults
args.FanSensorGeometry    = 'arc';
args.FanSensorSpacing     = [];
args.Interpolation        = [];
args.Filter               = [];
args.FrequencyScaling     = [];
args.OutputSize           = [];
args.FanCoverage          = 'cycle';
args.FanRotationIncrement = [];

valid_params = {'FanSensorGeometry',...
                'FanSensorSpacing',...
                'Filter',...       
                'Interpolation',...
                'FrequencyScaling',...
                'OutputSize',...      
                'FanCoverage',...
                'FanRotationIncrement'};

num_pre_param_args = 2;
args = check_fan_params(varargin(3:nargin),args,valid_params,...
                        mfilename,num_pre_param_args);

if ~isempty(args.Interpolation)
    params = varargin(3:2:nargin-1);
    start = regexpi(params, ['^i']); % find which param is 'Interpolation'
    if ~iscell(start)
        start = {start};
    end
    matches = ~cellfun('isempty',start);
    idx = find(matches);
    interp_value_arg = 2*idx + num_pre_param_args;

    args.Interpolation = checkstrs(args.Interpolation, ...
                                   {'nearest','linear','spline'},...
                                   mfilename, 'VALUE',...
                                   interp_value_arg);
end

if strcmp(args.FanCoverage,'minimal')
    if isempty(args.FanRotationIncrement)
        eid = sprintf('Images:%s:mustSpecifyDtheta',mfilename);
        error(eid,'%s%s','Must specify ''FanRotationIncrement'' when ',...
             '''FanCoverage'' is ''minimal''.');
    end
end

[P,oploc,optheta] = fan2para(F,d,...
                             'FanSensorSpacing',args.FanSensorSpacing,...
                             'ParallelSensorSpacing',1,...
                             'FanSensorGeometry',args.FanSensorGeometry,...
                             'Interpolation','spline',...
                             'FanCoverage',args.FanCoverage,...
                             'FanRotationIncrement',args.FanRotationIncrement);

optional_args = {args.Interpolation, args.Filter, args.FrequencyScaling,...
                 args.OutputSize};
optional_args(cellfun('isempty',optional_args)) = [];

[I,H] = iradon(P,optheta,optional_args{:});

