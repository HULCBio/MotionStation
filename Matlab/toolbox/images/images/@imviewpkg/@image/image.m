function h = image;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%   file: @imviewpkg/@image/image.m
%
%   UDD object representing a Matlab image array  %
%
%   Copyright 1993-2003 The MathWorks, Inc.  
%   $Revision.1.4.1 $ $Date: 2003/05/03 17:51:29 $
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%Constructor for the ivimage class:
h = imviewpkg.image;

%Set the default properties
h.name           = 'unknown';
h.imagetype      = 'unknown';
h.width          = 0;
h.height         = 0;
h.classtype      = 'unknown';
h.minvalue       = 0;
h.maxvalue       = 0;
h.displayblack   = 0;
h.displaywhite   = 0;
h.scalerangemin  = 0;
h.scalerangemax  = 0;
h.allintegers    = false;
h.magnification  = '100';

% h.jmetadata is a handle to the Metadata java class
h.jmetadata  = handle(com.mathworks.toolbox.images.Metadata);

