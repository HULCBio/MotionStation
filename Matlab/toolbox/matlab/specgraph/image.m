%IMAGE  Display image.
%   IMAGE(C) displays matrix C as an image.  Each element of C
%   specifies the color of a rectilinear patch in the image.  C can be
%   a matrix of dimension MxN or MxNx3, and can contain double, uint8,
%   or uint16 data.
%
%   When C is a 2-dimensional MxN matrix, the elements of C are used
%   as indices into the current COLORMAP to determine the color.  The
%   value of the image object's CDataMapping property determines the
%   method used to select a colormap entry.  For 'direct' CDataMapping
%   (the default), values in C are treated as colormap indices
%   (1-based if double, 0-based if uint8 or uint16).  For 'scaled' 
%   CDataMapping, values in C are first scaled according to the axes 
%   CLim and then the result is treated as a colormap index.  When C is
%   a 3-dimensional MxNx3 matrix, the elements in C(:,:,1) are
%   interpreted as red intensities, in C(:,:,2) as green intensities,
%   and in C(:,:,3) as blue intensities, and the CDataMapping property
%   of image is ignored.  For matrices containing doubles, color
%   intensities are on the range [0.0, 1.0].  For uint8 and uint16 
%   matrices, color intensities are on the range [0, 255].
%
%   IMAGE(C) places the center of element C(1,1) at (1,1) in the axes,
%   and the center of element (M,N) at (M,N) in the axes, and draws
%   each rectilinear patch as 1 unit in width and height.  As a
%   result, the outer extent of the image occupies [0.5 N+0.5 0.5 M+0.5]
%   of the axes, and each pixel center of the image lies at integer
%   coordinates ranging between 1 and M or N.
%
%   IMAGE(X,Y,C), where X and Y are vectors, specifies the locations
%   of the pixel centers of C(1,1) and C(M,N).  Element C(1,1) is
%   centered over (X(1), Y(1)), element C(M,N) is centered over
%   (X(end), Y(end)), and the pixel centers of the remaining elements
%   of C are spread out evenly between those two points, so that the
%   rectilinear patches are all of equal width and height.
%
%   IMAGE returns a handle to an IMAGE object.
%
%   C or the X,Y,C triple can be followed by property/value
%   pairs to specify additional properties of the image.
%   C or the X,Y,C triple can be omitted entirely, and all
%   properties specified using property/value pairs.
%
%   IMAGE(...,'Parent',AX) specifies AX as the parent axes for the
%   image object during creation. 
%
%   When called with C or X,Y,C, IMAGE sets the axes limits to tightly
%   enclose the image, sets the axes YDir property to 'reverse', and
%   sets the axes View property to [0 90].
%
%   The image object will not render at axes View angles other than
%   [0 90].  To get a similar effect to rotating an image, use SURF
%   with texture mapping or PCOLOR.
%
%   Execute GET(H), where H is an image handle, to see a list of image
%   object properties and their current values. Execute SET(H) to see a
%   list of image object properties and legal property values.
%
%   See also IMAGESC, COLORMAP, PCOLOR, SURF, IMREAD, IMWRITE.

%   Copyright 1984-2002 The MathWorks, Inc. 
%   $Revision: 5.14.4.1 $  $Date: 2002/10/24 02:14:05 $
%   Built-in function.

