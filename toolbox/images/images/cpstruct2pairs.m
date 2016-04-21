function [input_points,base_points] = cpstruct2pairs(varargin);
%CPSTRUCT2PAIRS Convert CPSTRUCT to valid pairs of control points.
%   [INPUT_POINTS, BASE_POINTS] = CPSTRUCT2PAIRS(CPSTRUCT) takes a CPSTRUCT
%   (produced by CPSELECT) and returns the coordinates of valid control
%   point pairs in INPUT_POINTS and BASE_POINTS.  CPSTRUCT2PAIRS eliminates
%   unmatched points and predicted points.
%
%   Example
%   -------
%   Start cpselect.
%
%       aerial = imread('westconcordaerial.png');
%       cpselect(aerial(:,:,1),'westconcordorthophoto.png')
%
%   Using CPSELECT, pick control points in the images.  Select "Save To
%   Workspace" from the File menu to save the points to the workspace.
%   On the "Save" dialog box, check the "Structure with all points"
%   checkbox and uncheck "Input points" and "Base points."  Click OK.
%   Use CPSTRUCT2PAIRS to extract the input and base points from the
%   CPSTRUCT.
%
%       [input_points,base_points] = cpstruct2pairs(cpstruct);
%
%  See also CP2TFORM, CPSELECT, IMTRANSFORM.

%   Copyright 1993-2003 The MathWorks, Inc. 
%   $Revision: 1.10.4.2 $  $Date: 2003/05/03 17:50:22 $

% INPUT_POINTS is M-by-2
% BASE_POINTS is M-by-2

checknargin(1,1,nargin,mfilename);

input_points = [];
base_points = [];

cpstruct = varargin{1};
if ~iscpstruct(cpstruct)
    error(sprintf('Images:%s:invalidCpStruct',mfilename),'Invalid CPSTRUCT.');
end

if length(cpstruct) ~= 1
    error(sprintf('Images:%s:onlyOneCpStructCanBeProcessed',mfilename),...
                  'Only one CPSTRUCT can be processed.');
end

if ~isempty(cpstruct.inputBasePairs)
    predicted_input = cpstruct.isInputPredicted(cpstruct.inputBasePairs(:,1));
    predicted_base = cpstruct.isBasePredicted(cpstruct.inputBasePairs(:,2));
    predicted_pairs = predicted_input | predicted_base;

    valid_pairs = cpstruct.inputBasePairs(~predicted_pairs,:);
    input_points = cpstruct.inputPoints(valid_pairs(:,1),:);
    base_points = cpstruct.basePoints(valid_pairs(:,2),:);
end
