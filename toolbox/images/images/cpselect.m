function h = cpselect(varargin)
%CPSELECT Control point selection tool. 
%   CPSELECT is a graphical user interface that enables you to select
%   control points from two related images.
%
%   CPSELECT(INPUT,BASE) returns control points in CPSTRUCT. INPUT is the
%   image that needs to be warped to bring it into the coordinate system of
%   the BASE image. INPUT and BASE can be either variables that contain
%   grayscale images or strings that identify files containing grayscale
%   images.
%
%   CPSELECT(INPUT,BASE,CPSTRUCT_IN) starts CPSELECT with an initial set of
%   control points that are stored in CPSTRUCT_IN. This syntax allows you to
%   restart CPSELECT with the state of control points previously saved in
%   CPSTRUCT_IN.
%
%   CPSELECT(INPUT,BASE,XYINPUT_IN,XYBASE_IN) starts CPSELECT with
%   a set of initial pairs of control points. XYINPUT_IN and XYBASE_IN are
%   M-by-2 matrices that store the INPUT and BASE coordinates respectively.
%
%   H = CPSELECT(INPUT,BASE,...) returns a handle H to the tool. CLOSE(H)
%   closes the tool.
%
%   Class Support
%   -------------
%   The input images can be of class uint8, uint16, double, or logical.
%
%   Examples
%   --------
%   Start tool with saved images:
%       aerial = imread('westconcordaerial.png');
%       cpselect(aerial(:,:,1),'westconcordorthophoto.png')
%
%   Start tool with workspace images and points:
%       I = checkerboard;
%       J = imrotate(I,30);
%       base_points = [11 11; 41 71];
%       input_points = [14 44; 70 81];
%       cpselect(J,I,input_points,base_points);
%
%   Notes on Platform Support
%   -------------------------
%   CPSELECT requires Java and is not available on any platform that does
%   not support Java. In addition, CPSELECT is not available on the
%   Macintosh platform even with Java.
%
%   Notes on Memory Usage
%   ---------------------
%   To increase the amount of memory available to CPSELECT, you must put a
%   file called 'java.opts' in your startup directory. See IMVIEW for
%   details.
%
%   See also CPCORR, CP2TFORM, CPSTRUCT2PAIRS, IMTRANSFORM, IMVIEW.

%   Copyright 1993-2003 The MathWorks, Inc.
%   $Revision: 1.24.4.9 $  $Date: 2003/12/13 02:42:48 $

%   Input-output specs
%   ------------------ 
%   INPUT,BASE:   filenames each containing a grayscale or truecolor image
%
%                OR 
%
%                real, full matrix
%                can be intensity: 2-D
%                uint8, uint16, double, or logical
%
%        Note: INPUT can be a filename while BASE is a variable or vice versa.
%
%   CPSTRUCT:    structure containing control point pairs with fields:
%                   inputPoints
%                   basePoints
%                   inputBasePairs
%                   ids
%                   inputIdPairs
%                   baseIdPairs
%                   isInputPredicted
%                   isBasePredicted
%
%   XYINPUT_IN, XYBASE_IN: M-by-2 matrices with control point coordinates.
%                         real, full, finite

global DEBUG_CPSELECT

if DEBUG_CPSELECT & strcmpi(computer,'sgi') %#ok
    disp('Inside cpselect, about to call javachk.');
end 

% Don't run on platforms with incomplete Java support
if ~IsJavaAvailable
  eid = sprintf('Images:%s:cpselectNotAvailableOnThisPlatform',mfilename);
  error(eid,'%s','CPSELECT is not available on this platform.');
end

% should have failed by now on SGI
if DEBUG_CPSELECT & strcmpi(computer,'sgi') %#ok
    disp('Inside cpselect, just called javachk.');
end 

[input, base, cpstruct] = ParseInputs(varargin{:});

% get names to label images
inputImageName = get_image_title(varargin{1},inputname(1));
baseImageName = get_image_title(varargin{2},inputname(2));

inputImage2D = im2java2d(input);
baseImage2D  = im2java2d(base);

% import Java classes used here
import com.mathworks.toolbox.images.cpselect.ControlPointSelectionTool;

hh = ControlPointSelectionTool(inputImageName,baseImageName,...
                               inputImage2D,baseImage2D); 

legendFrame = hh.getLegendFrame;
legendSize = legendFrame.getSize;
legendLocation = hh.getLocation;
legendLocation.translate(-legendSize.width,0);

% clip legendLocation to be on screen
screen_size = get(0,'ScreenSize');
screen_width = screen_size(3);
screen_height = screen_size(4);
legendLocation.x = max(0,min(legendLocation.x,screen_width- ...
                             legendSize.width));
legendLocation.y = max(0,min(legendLocation.y,screen_height- ...
                             legendSize.height));

legendFrame.setLocation(legendLocation);
legendFrame.show; % show legend after tool is showing
legendFrame.setVisible(true);

hh.toFront;

if ~isempty(cpstruct)
    [inputBasePairs,inputPoints,basePoints] = cpstruct2java(cpstruct);
    hh.loadControlPoints(inputBasePairs,inputPoints,basePoints);
end

% preload m-code. Does not noticably speed up code. Maybe problem is with JMI
try 
    cpsave;
    cppredict;
catch
    % do not error
end

if (nargout > 0)
  % Only return handle if caller requested it.
  h = hh;
end

%-------------------------------
% Function  ParseInputs
%
function [input, base, cpstruct] = ParseInputs(varargin)

% defaults
cpstruct = [];

checknargin(2,4,nargin,mfilename);

input = parseImage(varargin{1},1,'INPUT');
base = parseImage(varargin{2}, 2,'BASE');

switch nargin
  case 2
    % CPSTRUCT = CPSELECT(INPUT,BASE)
    return;
    
  case 3
    % CPSTRUCT = CPSELECT(INPUT,BASE,CPSTRUCT)

    % TO DO: add more validation on cpstruct
    if iscpstruct(varargin{3})
        cpstruct = varargin{3};
    else
      eid = sprintf('Images:%s:CPSTRUCTMustBeStruct',mfilename);
      msg = sprintf('%s: CPSTRUCT must be a structure.',upper(mfilename));
      error(eid,msg);
    end
        
  case 4
    % CPSTRUCT = CPSELECT(INPUT,BASE,XYINPUT_IN,XYINPUT_OUT)    

    xyinput_in = varargin{3};
    xybase_in = varargin{4};
    
    checkinput(xyinput_in,{'double'},{'real','nonsparse','finite','2d'},mfilename,'XYINPUT_IN',3);
    checkinput(xybase_in, {'double'},{'real','nonsparse','finite','2d'},mfilename,'XYBASE_IN',4);
    
    eid = sprintf('Images:%s:expectedMby2',mfilename);
    msg = sprintf('%s: XYINPUT_IN and XYBASE_IN must be M-by-2.',upper(mfilename));
    
    if size(xyinput_in,1) ~= size(xybase_in,1) || ...
          size(xyinput_in,2) ~= 2 || size(xybase_in,2) ~= 2  
        error(eid,msg);
    end
    
    cpstruct = xy2cpstruct(xyinput_in,xybase_in);
    
end

%-------------------------------
% Function  ParseImage
%
function [img] = parseImage(arg,argnumber,argname)

img = [];

if ischar(arg)
    try 
        info = imfinfo(arg);
        if strmatch(info.ColorType,'indexed')
            eid = sprintf('Images:%s:imageMustBeGrayscale',mfilename);
            msg = sprintf('%s: %s must be a grayscale image.',upper(mfilename),arg);
            error(eid,msg);
        end
        img = imread(arg);
    catch
        eid = sprintf('Images:%s:imageNotValid',mfilename);
        msg = sprintf('%s: %s must be a valid image file.',upper(mfilename),arg);
        error(eid,msg);
    end
else 
    img = arg;
end

checkinput(img,{'uint8','uint16','double','logical'},{'real','nonsparse','2d'},...
           mfilename,argname,argnumber);

%-------------------------------
% Function xy2cpstruct
%
function cpstruct = xy2cpstruct(xyinput_in,xybase_in)

% Create a cpstruct given two lists of equal numbers of points.

M = size(xyinput_in,1);
ids = (0:M-1)';
isPredicted = zeros(M,1);

% assign fields to cpstruct
cpstruct.inputPoints = xyinput_in;
cpstruct.basePoints = xybase_in;
cpstruct.inputBasePairs = repmat((ids+1),1,2);
cpstruct.ids = ids;
cpstruct.inputIdPairs = cpstruct.inputBasePairs;
cpstruct.baseIdPairs = cpstruct.inputBasePairs;
cpstruct.isInputPredicted = isPredicted;
cpstruct.isBasePredicted = isPredicted;

%
%-------------------------------
%
function [inputBasePairsVector, inputPointsVector, basePointsVector] = ...
  cpstruct2java(cpstruct)

import java.util.Vector;
import com.mathworks.toolbox.images.cpselect.CPVector;
import com.mathworks.toolbox.images.cpselect.ControlPoint;
import com.mathworks.toolbox.images.cpselect.ControlPointPair;

% initialize empty vectors
inputPointsVector = CPVector;
basePointsVector = CPVector;
inputBasePairsVector = Vector;

inputPointsVector = fillPointsVector(cpstruct.inputPoints);
basePointsVector = fillPointsVector(cpstruct.basePoints);

nPairs = length(cpstruct.ids);
for i = 1:nPairs
    inputBasePairsVector.addElement(ControlPointPair(cpstruct.ids(i)))
end


% loop over inputIdPairs to setInputPoint for pairs
nPairs = size(cpstruct.inputIdPairs,1);
for i = 1:nPairs
    [p,pair,input_index] = getPointPair(i,inputBasePairsVector,cpstruct.inputIdPairs,...
                              cpstruct.ids,inputPointsVector);
    pair.setInputPoint(p);
    if cpstruct.isInputPredicted(input_index)
        setPredictedPoint(pair,p);
    end
end

% loop over baseIdPairs to setBasePoint for pairs
nPairs = size(cpstruct.baseIdPairs,1);
for i = 1:nPairs
    [p,pair,base_index] = getPointPair(i,inputBasePairsVector,cpstruct.baseIdPairs,...
                                         cpstruct.ids,basePointsVector);
    pair.setBasePoint(p);
    if cpstruct.isBasePredicted(base_index)
        setPredictedPoint(pair,p);
    end
end

%
%-----------------------------------------------------
%
function setPredictedPoint(pair,p)

if isempty( pair.getPredictedPoint )
    pair.setPredictedPoint(p);
else
  wid = sprintf('Images:%s:predictedAlreadySet',mfilename);
  msg = sprintf('%s: Predicted point was already set for this pair.',upper(mfilename));
  warning(wid,msg);
end

%
%-----------------------------------------------------
%
function [point,pair,point_index] = getPointPair(i,inputBasePairsVector,pointIdPairs,ids,pointsVector)

import com.mathworks.toolbox.images.cpselect.ControlPoint;

id_index = pointIdPairs(i,2);
point_index = pointIdPairs(i,1);
id = ids(id_index);
pair = inputBasePairsVector.elementAt(id);
point = pointsVector.elementAt(point_index-1);
point.setPair(pair);

%
%-----------------------------------------------------
%
function [pointsVector] = fillPointsVector(points)

import com.mathworks.toolbox.images.cpselect.ControlPoint;
import com.mathworks.toolbox.images.cpselect.CPVector;

pointsVector = CPVector;

nPoints = size(points,1);
for i = 1:nPoints
    x = points(i,1) - 1; % subtract 1 to account for
    y = points(i,2) - 1; % zero-based Java coordinates 
    pointsVector.addElement(ControlPoint(x,y))
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function java_available = IsJavaAvailable

java_available = false;
ismac = strcmpi(computer,'mac'); % disable on Mac

if isempty(javachk('swing')) && ~ismac
  java_available = true;
end
