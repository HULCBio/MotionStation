## Copyright (C) 2002 Jeff Orchard <jorchard@cs.uwaterloo.ca>
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
## @deftypefn {Function File} {} imrotate(@var{M}, @var{theta}, @var{method}, @var{bbox})
## Rotation of a 2D matrix.
##
## Applies a rotation of @var{THETA} degrees to matrix @var{M}.
##
## The @var{method} argument is not implemented, and is only included for compatibility with Matlab.
## This function uses Fourier interpolation,
## decomposing the rotation matrix into 3 shears.
##
## @var{bbox} can be either 'loose' or 'crop'.
## 'loose' allows the image to grow to accomodate the rotated image.
## 'crop' keeps the same size as the original, clipping any part of the image
## that is moved outside the bounding box.
## @end deftypefn

function fs = imrotate_Fourier(f, theta, method="fourier", bbox="loose")

    ## Input checking
    if (nargin < 2)
      error("imrotate_Fourier: not enough input arguments");
    endif
    [imrows, imcols, tmp] = size(f);
    if (tmp != 1)
      error("imrotate_Fourier: first input argument must be a gray-scale image");
    endif
    if (!isscalar(theta))
      error("imrotate_Fourier: second input argument must be a real scalar");
    endif

    # Get original dimensions.
    [ydim_orig, xdim_orig] = size(f);

    # This finds the index coords of the centre of the image (indices are base-1)
    #   eg. if xdim_orig=8, then xcentre_orig=4.5 (half-way between 1 and 8)
    xcentre_orig = (xdim_orig+1) / 2;
    ycentre_orig = (ydim_orig+1) / 2;

    # Pre-process the angle ===========================================================
    # Whichever 90 degree multiple theta is closest to, that multiple of 90 will
    # be implemented by rot90. The remainder will be done by shears.

    # This ensures that 0 <= theta < 360.
    theta = rem( rem(theta,360) + 360, 360 );

    # This is a flag to keep track of 90-degree rotations.
    perp = 0;

    if ( theta>=0 && theta<=45 )
        phi = theta;
    elseif ( theta>45 && theta<=135 )
        phi = theta - 90;
        f = rot90(f,1);
        perp = 1;
    elseif ( theta>135 && theta<=225 )
        phi = theta - 180;
        f = rot90(f,2);
    elseif ( theta>225 && theta<=315 )
        phi = theta - 270;
        f = rot90(f,3);
        perp = 1;
    else
        phi = theta;
    endif



    if ( phi == 0 )
        fs = f;
        if ( strcmp(bbox,"loose") == 1 )
            return;
        else
            xmax = xcentre_orig;
            ymax = ycentre_orig;
            if ( perp == 1 )
                xmax = max([xmax ycentre_orig]);
                ymax = max([ymax xcentre_orig]);
                [ydim xdim] = size(fs);
                xpad = ceil( xmax - (xdim+1)/2 );
                ypad = ceil( ymax - (ydim+1)/2 );
                fs = impad(fs, [xpad,xpad], [ypad,ypad], "zeros");
            endif
            xcentre_new = (size(fs,2)+1) / 2;
            ycentre_new = (size(fs,1)+1) / 2;
        endif
    else

        # At this point, we can assume -45<theta<45 (degrees)

        phi = phi * pi / 180;
        theta = theta * pi / 180;
        R = [ cos(theta) -sin(theta) ; sin(theta) cos(theta) ];

        # Find max of each dimension... this will be expanded for "loose" and "crop"
        xmax = xcentre_orig;
        ymax = ycentre_orig;

        # If we don't want wrapping, we have to zeropad.
        # Cropping will be done later, if necessary.
        if ( strcmp(bbox, "wrap") == 0 )
            corners = ( [ xdim_orig xdim_orig -xdim_orig -xdim_orig ; ydim_orig -ydim_orig ydim_orig -ydim_orig ] + 1 )/ 2;
            rot_corners = R * corners;
            xmax = max([xmax rot_corners(1,:)]);
            ymax = max([ymax rot_corners(2,:)]);

            # If we are doing a 90-degree rotation first, we need to make sure our
            # image is large enough to hold the rot90 image as well.
            if ( perp == 1 )
                xmax = max([xmax ycentre_orig]);
                ymax = max([ymax xcentre_orig]);
            endif

            [ydim xdim] = size(f);
            xpad = ceil( xmax - xdim/2 );
            ypad = ceil( ymax - ydim/2 );
            %f = impad(f, [xpad,xpad], [ypad,ypad], "zeros");
            xcentre_new = (size(f,2)+1) / 2;
            ycentre_new = (size(f,1)+1) / 2;
        endif

        #size(f)
        [S1, S2] = MakeShears(phi);

        tic;
        f1 = imshear(f, 'x', S1(1,2), 'loose');
        f2 = imshear(f1, 'y', S2(2,1), 'loose');
        fs = real( imshear(f2, 'x', S1(1,2), 'loose') );
        %fs = f2;
        xcentre_new = (size(fs,2)+1) / 2;
        ycentre_new = (size(fs,1)+1) / 2;
    endif

    if ( strcmp(bbox, "crop") == 1 )

        # Crop to original dimensions
        x1 = ceil (xcentre_new - xdim_orig/2);
        y1 = ceil (ycentre_new - ydim_orig/2);
        fs = fs (y1:(y1+ydim_orig-1), x1:(x1+xdim_orig-1));

    elseif ( strcmp(bbox, "loose") == 1 )

        # Find tight bounds on size of rotated image
        # These should all be positive, or 0.
        xmax_loose = ceil( xcentre_new + max(rot_corners(1,:)) );
        xmin_loose = floor( xcentre_new - max(rot_corners(1,:)) );
        ymax_loose = ceil( ycentre_new + max(rot_corners(2,:)) );
        ymin_loose = floor( ycentre_new - max(rot_corners(2,:)) );

        %fs = fs( (ymin_loose+1):(ymax_loose-1) , (xmin_loose+1):(xmax_loose-1) );
        fs = fs( (ymin_loose+1):(ymax_loose-1) , (xmin_loose+1):(xmax_loose-1) );

    endif

    ## Prevent overshooting
    if (strcmp(class(f), "double"))
      fs(fs>1) = 1;
      fs(fs<0) = 0;
    endif

endfunction

function [S1, S2] = MakeShears(theta)
    S1 = eye(2);
    S2 = eye(2);

    S1(1,2) = -tan(theta/2);
    S2(2,1) = sin(theta);
endfunction
