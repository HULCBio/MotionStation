## Copyright (C) 2010 Soren Hauberg <soren@hauberg.org>
## Copyright (C) 2012 Jordi Gutiérrez Hermoso <jordigh@octave.org>
##
## This program is free software; you can redistribute it and/or modify it under
## the terms of the GNU General Public License as published by the Free Software
## Foundation; either version 3 of the License, or (at your option) any later
## version.
##
## This program is distributed in the hope that it will be useful, but WITHOUT
## ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or
## FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more
## details.
##
## You should have received a copy of the GNU General Public License along with
## this program; if not, see <http://www.gnu.org/licenses/>.

## -*- texinfo -*-
## @deftypefn {Function File} {@var{props} = } regionprops (@var{BW})
## @deftypefnx {Function File} {@var{props} = } regionprops (@var{BW}, @var{properties}, @dots{})
## Compute object properties in a binary image.
##
## @code{regionprops} computes various properties of the individual objects (as
## identified by @code{bwlabel}) in the binary image @var{BW}. The result is a
## structure array containing an entry per property per object.
##
## The following properties can be computed:
##
## @table @asis
## @item "Area"
## The number of pixels in the object.
##
## @item "BoundingBox"
## @itemx "bounding_box"
## The bounding box of the object. This is represented as a 4-vector where the
## first two entries are the @math{x} and @math{y} coordinates of the upper left
## corner of the bounding box, and the two last entries are the width and the
## height of the box.
##
## @item "Centroid"
## The center coordinate of the object.
##
## @item "EulerNumber"
## @itemx "euler_number"
## The Euler number of the object (see @code{bweuler} for details).
##
## @item "Extent"
## The area of the object divided by the area of the bounding box.
##
## @item "FilledArea"
## @itemx "filled_area"
## The area of the object including possible holes.
##
## @item "FilledImage"
## @itemx "filled_image"
## A binary image with the same size as the object's bounding box that contains
## the object with all holes removed.
##
## @item "Image"
## An image with the same size as the bounding box that contains the original pixels.
##
## @item "MaxIntensity"
## @itemx "max_intensity"
## The maximum intensity inside the object.
##
## @item "MeanIntensity"
## @itemx "mean_intensity"
## The mean intensity inside the object.
##
## @item "MinIntensity"
## @itemx "min_intensity"
## The minimum intensity inside the object.
##
## @item "Perimeter"
## The length of the boundary of the object.
##
## @item "PixelIdxList"
## @itemx "pixel_idx_list"
## The indices of the pixels in the object.
##
## @item "PixelList"
## @itemx "pixel_list"
## The actual pixel values inside the object. This is only useful for grey scale
## images.
##
## @item "PixelValues"
## @itemx "pixel_values"
## The pixel values inside the object represented as a vector.
##
## @item "WeightedCentroid"
## @itemx "weighted_centroid"
## The centroid of the object where pixel values are used as weights.
## @end table
##
## The requested properties can either be specified as several input arguments
## or as a cell array of strings. As a short-hand it is also possible to give
## the following strings as arguments.
##
## @table @asis
## @item "basic"
## The following properties are computed: @t{"Area"}, @t{"Centroid"} and
## @t{"BoundingBox"}. This is the default.
##
## @item "all"
## All properties are computed.
## @end table
##
## @seealso{bwlabel, bwperim, bweuler}
## @end deftypefn

function retval = regionprops (bw, varargin)
  ## Check input
  if (nargin < 1)
    error ("regionprops: not enough input arguments");
  endif

  if (numel (varargin) == 0)
    properties = {"basic"};
  elseif (numel (varargin) == 1 && iscellstr (varargin{1}))
      properties = varargin{1};
  elseif (iscellstr (varargin))
    properties = varargin;
  else
    error ("regionprops: properties must be a cell array of strings");
  endif

  properties = lower (properties);

  all_props = {"Area", "EulerNumber", "BoundingBox", "Extent", "Perimeter",\
               "Centroid", "PixelIdxList", "FilledArea", "PixelList",\
               "FilledImage", "Image", "MaxIntensity", "MinIntensity",\
               "WeightedCentroid", "MeanIntensity", "PixelValues",\
               "Orientation"};
    
  if (ismember ("basic", properties))
    properties = union (properties, {"Area", "Centroid", "BoundingBox"});
    properties = setdiff (properties, "basic");
  endif

  if (ismember ("all", properties))
    properties = all_props;
  endif
  
  if (!iscellstr (properties))
    error ("%s %s", "regionprops: properties must be specified as a list of",
           "strings or a cell array of strings");
  endif

  ## Fix capitalisation, underscores of user-supplied properties...
  for k = 1:numel (properties)
    property = lower (strrep(properties{k}, "_", ""));
    [~, idx] = ismember (property, lower (all_props));
    if (!idx)
      error ("regionprops: unsupported property: %s", property);
    endif
    properties(k) = all_props{idx};
  endfor
    
  N = ndims (bw);

  ## Get a labelled image
  if (!islogical (bw) && all (bw >= 0) && all (bw == round (bw)))
    L = bw; # the image was already labelled
    num_labels = max (L (:));
  elseif (N > 2)
    [L, num_labels] = bwlabeln (bw);
  else
    [L, num_labels] = bwlabel (bw);
  endif
  
  ## Return an empty struct with specified properties if there are no labels
  if num_labels == 0
    retval = struct ([properties; repmat({{}}, size(properties))]{:});
    return;
  endif

  ## Compute the properties
  retval = struct ();
  for property = lower(properties)
    property = property{:};
    switch (property)
      case "area"
        for k = 1:num_labels
          retval (k).Area = local_area (L == k);
        endfor
        
      case {"eulernumber", "euler_number"}
        for k = 1:num_labels
          retval (k).EulerNumber = bweuler (L == k);
        endfor

      case {"boundingbox", "bounding_box"}
        for k = 1:num_labels
          retval (k).BoundingBox = local_boundingbox (L == k);
        endfor

      case "extent"
        for k = 1:num_labels
          bb = local_boundingbox (L == k);
          area = local_area (L == k);
          idx = length (bb)/2 + 1;
          retval (k).Extent = area / prod (bb(idx:end));
        endfor

      case "perimeter"
        if (N > 2)
          warning ("regionprops: skipping perimeter for Nd image");
        else
          for k = 1:num_labels
            retval (k).Perimeter = sum (bwperim (L == k) (:));
          endfor
        endif

      case "centroid"
        for k = 1:num_labels
          C = all_coords (L == k);
          retval (k).Centroid = [mean(C)];
        endfor

      case {"pixelidxlist", "pixel_idx_list"}
        for k = 1:num_labels
          retval (k).PixelIdxList = find (L == k);
        endfor
      
      case {"filledarea", "filled_area"}
        for k = 1:num_labels
          retval (k).FilledArea = sum (bwfill (L == k, "holes") (:));
        endfor

      case {"pixellist", "pixel_list"}
        for k = 1:num_labels
          C = all_coords (L == k, true, true);
          retval (k).PixelList = C;
        endfor

      case {"filledimage", "filled_image"}
        for k = 1:num_labels
          retval (k).FilledImage = bwfill (L == k, "holes");
        endfor

      case "image"
        for k = 1:num_labels
          tmp = (L == k);
          C = all_coords (tmp, false);
          idx = arrayfun (@(x,y) x:y, min (C), max (C), "unif", 0);
          idx = substruct ("()", idx);
          retval (k).Image = subsref (tmp, idx);
        endfor

      case {"maxintensity", "max_intensity"}
        for k = 1:num_labels
          retval (k).MaxIntensity = max (bw (L == k) (:));
        endfor
    
      case {"minintensity", "min_intensity"}
        for k = 1:num_labels
          retval (k).MinIntensity = min (bw (L == k) (:));
        endfor
    
      case {"weightedcentroid", "weighted_centroid"}
        for k = 1:num_labels
          C = all_coords (L == k, true, true);
          vals = bw (L == k) (:);
          vals /= sum (vals);
          retval (k).WeightedCentroid = [dot(C, repmat(vals, 1, columns(C)))];
        endfor

      case {"meanintensity", "mean_intensity"}
        for k = 1:num_labels
          retval (k).MeanIntensity = mean (bw (L == k) (:));
        endfor
        
      case {"pixelvalues", "pixel_values"}
        for k = 1:num_labels
          retval (k).PixelValues = bw (L == k)(:);
        endfor
    
      case "orientation"
        if (N > 2)
          warning ("regionprops: skipping orientation for Nd image");
          break
        endif

        for k = 1:num_labels
          [Y, X] = find (L == k);
          if (numel (Y) > 1)
            C = cov ([X(:), Y(:)]);
            [V, lambda] = eig (C);
            [max_val, max_idx] = max (diag (lambda));
            v = V (:, max_idx);
            retval (k).Orientation = 180 - 180 * atan2 (v (2), v (1)) / pi;
          else
            retval (k).Orientation = 0; # XXX: What does the other brand do?
          endif
        endfor
        
      %{
      case "majoraxislength"
        for k = 1:num_labels
          [Y, X] = find (L == k);
          if (numel (Y) > 1)
            C = cov ([X(:), Y(:)]);
            lambda = eig (C);
            retval (k).MajorAxisLength = (max (lambda));
          else
            retval (k).MajorAxisLength = 1;
          endif
        endfor
        
      case "minoraxislength"
        for k = 1:num_labels
          [Y, X] = find (L == k);
          if (numel (Y) > 1)
            C = cov ([X(:), Y(:)]);
            lambda = eig (C);
            retval (k).MinorAxisLength = (min (lambda));
          else
            retval (k).MinorAxisLength = 1;
          endif
        endfor
      %}
      
      #case "extrema"
      #case "convexarea"      
      #case "convexhull"
      #case "solidity"
      #case "conveximage"
      #case "subarrayidx"
      #case "eccentricity"
      #case "equivdiameter"

      otherwise
        error ("regionprops: unsupported property '%s'", property);
    endswitch
  endfor
endfunction

function retval = local_area (bw)
  retval = sum (bw (:));
endfunction

function retval = local_boundingbox (bw)
  C = all_coords (bw);
  retval = [min(C) - 0.5, max(C) - min(C) + 1];
endfunction

function C = all_coords (bw, flip = true, singleton = false)
  N = ndims (bw);
  idx = find (bw);
  C = cell2mat (nthargout (1:N, @ind2sub, size(bw), idx));

  ## Coordinate convention for 2d images is to flip the X and Y axes
  ## relative to matrix indexing. Nd images inherit this for the first
  ## two dimensions.
  if (flip)
    [C(2), C(1)] = deal (C(1), C(2));
  endif

  ## Some functions above expect to work columnwise, so don't return a
  ## vector
  if (rows (C) == 1 && !singleton)
    C = [C; C];
  endif
endfunction
