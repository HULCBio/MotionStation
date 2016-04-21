function outbounds = findbounds(varargin)
%FINDBOUNDS Find output bounds for spatial transformation.
%   OUTBOUNDS = FINDBOUNDS(TFORM,INBOUNDS) estimates the output bounds
%   corresponding to a given spatial transformation and a set of input
%   bounds.  TFORM is a spatial transformation structure as returned by
%   MAKETFORM or CP2TFORM.  INBOUNDS is 2-by-NUM_DIMS matrix.  The first row
%   of INBOUNDS specifies the lower bounds for each dimension, and the
%   second row specifies the upper bounds. NUM_DIMS has to be consistent
%   with the ndims_in field of TFORM.
%
%   OUTBOUNDS has the same form as INBOUNDS.  It is an estimate of the
%   smallest rectangular region completely containing the transformed
%   rectangle represented by the input bounds.  Since OUTBOUNDS is only an
%   estimate, it may not completely contain the transformed input rectangle.
%
%   Notes
%   -----
%   IMTRANSFORM uses FINDBOUNDS to compute the 'OutputBounds' parameter
%   if the user does not provide it.
%
%   If TFORM contains a forward transformation (a nonempty forward_fcn
%   field), then FINDBOUNDS works by transforming the vertices of the input
%   bounds rectangle and then taking minimum and maximum values of the
%   result.
%
%   If TFORM does not contain a forward transformation, then FINDBOUNDS
%   estimates the output bounds using the Nelder-Mead optimization
%   function FMINSEARCH.  If the optimization procedure fails, FINDBOUNDS
%   issues a warning and returns OUTBOUNDS=INBOUNDS.
%
%   Example
%   -------
%       inbounds = [0 0; 1 1]
%       tform = maketform('affine',[2 0 0; .5 3 0; 0 0 1])
%       outbounds = findbounds(tform, inbounds)
%
%   See also CP2TFORM, IMTRANSFORM, MAKETFORM, TFORMARRAY, TFORMFWD, TFORMINV.

%   Copyright 1993-2003 The MathWorks, Inc.
%   $Revision: 1.6.4.1 $  $Date: 2003/01/26 05:55:20 $

% I/O details
% -----------
% tform     - valid TFORM structure; checked using private/istform.
%
% inbounds  - 2-by-NUM_DIMS real double matrix.  NUM_DIMS must be equal to
%             tform.ndims_in.  It may not contain NaN's or Inf's.
%
% outbounds - 2-by-NUM_DIMS_OUT real double matrix.  NUM_DIMS_OUT is
%             equal to tform.ndims_out.

[tform,inbounds] = parse_inputs(varargin{:});

if isempty(tform.forward_fcn)
    outbounds = find_bounds_using_search(tform, inbounds);
else
    outbounds = find_bounds_using_forward_fcn(tform, inbounds);
end

%--------------------------------------------------
function out_bounds = find_bounds_using_forward_fcn(tform, in_bounds)

in_vertices = bounds_to_vertices(in_bounds);
in_points = add_in_between_points(in_vertices);
out_points = tformfwd(in_points, tform);
out_bounds = points_to_bounds(out_points);

%--------------------------------------------------
function out_bounds = find_bounds_using_search(tform, in_bounds)

% Strategy
% --------
% For each point u_k in a set of points on the boundary or inside of the
% input bounds, find the corresponding output location by minimizing this
% objective function:
%
%    norm(u_k - tforminv(x, tform))
%
% It seems reasonable to use the u_k values as starting points for the
% optimization routine, FMINSEARCH.

if isempty(tform.inverse_fcn)
    msg = sprintf('%s: forward_fcn and inverse_fcn fields of TFORM cannot both be empty.',...
          upper(mfilename));
    eid = sprintf('Images:%s:fwdAndInvFieldsCantBothBeEmpty',mfilename);
    error(eid,msg);
end

in_vertices = bounds_to_vertices(in_bounds);
in_points = add_in_between_points(in_vertices);
out_points = zeros(size(in_points));
num_dims = size(in_points,2);
success = 1;
options = optimset('Display','off');
for k = 1:size(in_points,1)
    [x,fval,exitflag] = fminsearch(@objective_function, in_points(k,:), ...
                                   options, tform, in_points(k,:));
    if exitflag <= 0
        success = 0;
        break;
    else
        out_points(k,:) = x;
    end
end

if success
    out_bounds = points_to_bounds(out_points);
else
    % Optimization failed; the fallback strategy is to make the output
    % bounds the same as the input bounds.  However, if the input
    % transform dimensionality is not the same as the output transform
    % dimensionality, there doesn't seem to be anything reasonable to
    % do.
    if tform.ndims_in == tform.ndims_out
        msg = sprintf('%s: Search procedure failed; returning OUTBOUNDS = INBOUNDS.',...
              upper(mfilename));
        wid = sprintf('Images:%s:searchFailed',mfilename);
        warning(wid,msg);
        out_bounds = in_bounds;
    else
        msg = sprintf('%s: Search procedure failed with a mixed-dimensionality TFORM.',...
              upper(mfilename));
        eid = sprintf('Images:%s:mixedDimensionalityTFORM',mfilename);
        error(eid,msg);
    end
end

%--------------------------------------------------
function s = objective_function(x, tform, u0)
% This is the function to be minimized by FMINSEARCH.

s = norm(u0 - tforminv(x, tform));

%--------------------------------------------------
function vertices = bounds_to_vertices(bounds)
% Convert a 2-by-num_dims bounds matrix to a 2^num_dims-by-num_dims
% matrix containing each of the vertices of the region corresponding to
% BOUNDS.
%
% Strategy: the k-th coordinate of each vertex bound can be either
% bounds(k,1) or bounds(k,2).  One way to enumerate all the possibilities
% is to count in binary from 0 to (2^num_dims - 1).

num_dims = size(bounds,2);
num_vertices = 2^num_dims;

binary = repmat('0',[num_vertices,num_dims]);
for k = 1:num_vertices
    binary(k,:) = dec2bin(k-1,num_dims);
end

mask = binary ~= '0';

low = repmat(bounds(1,:),[num_vertices 1]);
high = repmat(bounds(2,:),[num_vertices 1]);
vertices = low;
vertices(mask) = high(mask);

%--------------------------------------------------
function points = add_in_between_points(vertices)
% POINTS contains all of the input vertices, plus all the unique points
% that are in between each pair of vertices.

[num_vertices,num_dims] = size(vertices);
ndx = nchoosek(1:num_vertices,2);
new_points = (vertices(ndx(:,1),:) + vertices(ndx(:,2),:))/2;
new_points = unique(new_points, 'rows');

points = [vertices; new_points];

%--------------------------------------------------
function bounds = points_to_bounds(points)
% Find a 2-by-num_dims matrix bounding the set of points in POINTS.

bounds = [min(points,[],1) ; max(points,[],1)];

%--------------------------------------------------
function [tform,inbounds] = parse_inputs(varargin)

checknargin(2,2,nargin,mfilename)

tform = varargin{1};
inbounds = varargin{2};

if ~istform(tform)
    msg = sprintf('%s: First input argument must be a TFORM struct.',...
                  upper(mfilename));
    eid = sprintf('Images:%s:firstInputMustBeTformStruct',mfilename);
    error(eid,msg);
end

if prod(size(tform)) ~= 1
    msg = sprintf('%s: First input argument must be a 1-by-1 TFORM struct.',...
                  upper(mfilename));
    eid = sprintf('Images:%s:firstInputMustBeOneByOneTformStruct',mfilename);
    error(eid,msg);
end

if tform.ndims_in ~= tform.ndims_out
    msg = sprintf('%s: Input and output dimensions of TFORM must be the same.',...
                  upper(mfilename));
    eid = sprintf('Images:%s:inOutDimsOfTformMustBeSame',mfilename);
    error(eid,msg);
end

if ~isnumeric(inbounds) | (ndims(inbounds) > 2) | (size(inbounds,1) ~= 2)
    msg = sprintf('%s: INBOUNDS must be a 2-by-NUM_DIMS numeric matrix.',...
                  upper(mfilename));
    eid = sprintf('Images:%s:inboundsMustBe2byN',mfilename);
    error(eid,msg);
end

num_dims = size(inbounds,2);

if num_dims ~= tform.ndims_in
    msg = sprintf('%s: size(INBOUNDS,2) must equal TFORM.ndims_in.',...
                  upper(mfilename));
    eid = sprintf('Images:%s:secondDimOfInbundsMustEqualTformNdimsIn',mfilename);
    error(eid,msg);
end

if any(~isfinite(inbounds(:)))
    msg = sprintf('%s: INBOUNDS must contain only finite values.',...
                  upper(mfilename));
    eid = sprintf('Images:%s:inboundsMustBeFinite',mfilename);
    error(eid,msg);
end
