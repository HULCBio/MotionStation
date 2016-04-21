function [success] = ...
    cppredict(inputBasePairsVector,inputPointsVector,basePointsVector,pick,...
              inputImage,baseImage)
%CPPREDICT Predict match for a new control point.
%   CPPREDICT is called from Java to do control point prediction.
%
% success = 1 when a new point was added.
% success = 0 when no point was added.

%   Copyright 1993-2003 The MathWorks, Inc.
%   $Revision: 1.5.4.5 $  $Date: 2003/08/23 05:53:37 $

success = 0;

% validate input
error(nargchk(6,6,nargin,'struct'));

% assertions if Java code not calling cppredict correctly
if ~isa(inputBasePairsVector,'java.util.Vector')
    eid = sprintf('Images:%s:invalidInputBasePairsVector',mfilename);                
    error(eid,'%s','inputBasePairsVector must be a java.util.Vector.')
end

if ~isa(inputPointsVector,'java.util.Vector')
    eid = sprintf('Images:%s:invalidInputPointsVector',mfilename);                
    error(eid,'%s','inputPointsVector must be a java.util.Vector.')
end

if ~isa(basePointsVector,'java.util.Vector')
    eid = sprintf('Images:%s:invalidBasePointsVector',mfilename);                
    error(eid,'%s','basePointsVector must be a java.util.Vector.')
end

if ~isa(pick,'com.mathworks.toolbox.images.cpselect.ControlPoint')
    eid = sprintf('Images:%s:invalidPick',mfilename);                
    error(eid,'%s','pick must be a com.mathworks.toolbox.images.ControlPoint.')
end

if ~isa(inputImage,'java.awt.Image')
    eid = sprintf('Images:%s:invalidInputImage',mfilename);                
    error(eid,'%s','inputImage must be a java.awt.Image.')
end

if ~isa(baseImage,'java.awt.Image')
    eid = sprintf('Images:%s:invalidBaseImage',mfilename);                
    error(eid,'%s','baseImage must be a java.awt.Image.')
end

import java.util.Vector;
import com.mathworks.toolbox.images.cpselect.ControlPoint;
import com.mathworks.toolbox.images.cpselect.ControlPointPair;

% Find all valid pairs.
% Valid pairs have both an inputPoint and a basePoint, and both have
% been "accepted" so that previous predictions that were not
% validated do not influence the next prediction.

npairs = inputBasePairsVector.size;
inputPoints = zeros(npairs,2);
basePoints = zeros(npairs,2);
ivalid = 0;

for i = 0:(npairs-1)
    pair = inputBasePairsVector.elementAt(i);
    if ( pair.hasInputPoint && pair.hasBasePoint && isempty(pair.getPredictedPoint))
        ivalid = ivalid + 1;
        inputPoint = pair.getInputPoint;
        basePoint = pair.getBasePoint;    
        inputPoints(ivalid,:) = [inputPoint.x inputPoint.y];
        basePoints(ivalid,:) = [basePoint.x basePoint.y];       
    end
end

nvalidpairs = ivalid;

inputPoints(ivalid+1:npairs,:) = [];
basePoints(ivalid+1:npairs,:) = [];

if nvalidpairs < 2
    % this is an assertion in case Java code sends over too few pairs
    wid = sprintf('Images:%s:tooFewPairs',mfilename);                
    warning(wid,'%s','Too few pairs, no method for predicting points.');    
else
    % predict
    switch nvalidpairs
      case 2
        method = 'linear conformal';
      case 3
        method = 'affine';
      otherwise
        method = 'projective';
    end

    t = cp2tform(inputPoints,basePoints,method);

    pickPair = pick.getPair;
    xy = [pick.x pick.y];
    if pickPair.isInput(pick) % predict base
        predictVector = basePointsVector;    
        isBasePredicted = 1;
        predicted = tformfwd(xy,t);
        predicted = clipPredicted(predicted,baseImage);        
    else                          % predict input
        predictVector = inputPointsVector;
        isBasePredicted = 0;
        predicted = tforminv(xy,t);
        predicted = clipPredicted(predicted,inputImage);
    end

    updatePointPairs(predicted,pickPair,predictVector,isBasePredicted,...
                     inputPointsVector,basePointsVector)    
    success = 1;    
end

%
%-------------------------------------------------
%
function clipped_predicted = clipPredicted(predicted,img)
  
clipped_predicted = predicted;

x = predicted(1);
y = predicted(2);

imageWidth = img.getWidth([]);
imageHeight = img.getHeight([]);
                 
if ( (x < 1) || (x > imageWidth) || (y < 1) || (y > imageHeight) ) 
    clipped_predicted(1) = max(1,min(x,imageWidth));
    clipped_predicted(2) = max(1,min(y,imageHeight));    
end

%
%-------------------------------------------------
%
function updatePointPairs(predicted,pickPair,predictVector,isBasePredicted,...
                          inputPointsVector,basePointsVector)

import java.util.Vector;
import com.mathworks.toolbox.images.cpselect.ControlPoint;
import com.mathworks.toolbox.images.cpselect.ControlPointPair;

% make point    
x = predicted(1);
y = predicted(2);
p = ControlPoint(x,y);

% tell point its pair
p.setPair(pickPair);

% add point to its vector
predictVector.addElement(p);

% tell pair its predicted point
pickPair.setPredictedPoint(p);    

% tell pair its input/base point
if (isBasePredicted)

    % check to see if a stray point got added
    if (pickPair.getBasePoint ~= 0)
      basePointsVector.removeElement(pickPair.getBasePoint);
    end
    
    pickPair.setBasePoint(p);

else
    % check to see if a stray point got added
    if (pickPair.getInputPoint ~= 0)
      inputPointsVector.removeElement(pickPair.getInputPoint);
    end
    
    pickPair.setInputPoint(p);        

end



