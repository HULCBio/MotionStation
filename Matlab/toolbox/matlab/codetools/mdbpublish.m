function outputPath = mdbpublish(file, format, evalcode, newfigure, ...
    displaycode, stylesheet, location, imagetype, screencapture, ...
    maxheight, maxwidth, thumbnailOn)
%MDBPUBLISH   Helper function for the MATLAB Editor/Debugger that calls 
%   calls the Codepad publish function
%   
%   FILE name of file to publish
%   FORMAT one of the supported formats (html, xml, doc, ppt)
%   EVALCODE true if code should be evaluated
%   NEWFIGURE true if a new figure should be created
%   DISPLAYCODE true if code should be displayed in output
%   STYLESHEET path to custom stylesheet, or empty if default should be used
%   LOCATION path to save output in, or empty if default should be used
%   IMAGETYPE image filetype, one of the choices supported by IMWRITE 
%   SCREENCAPTURE true if screen capture should be used, false if print
%   MAXHEIGHT -1 if height should not be restricted, otherwise max height
%   MAXWIDTH -1 if width should not be restricted, otherwise max width
%   THUMBNAILON true if thumbnail image should be created in output directory
%
%   Copyright 1984-2003 The MathWorks, Inc. 
%   $Revision: 1.1.6.2 $ 

options.format = format;
options.evalCode = evalcode;
options.useNewFigure = newfigure;
options.showCode = displaycode;
options.stylesheet = stylesheet;
options.outputDir = location;
options.imageFormat = imagetype;
options.createThumbnail = thumbnailOn;
if screencapture
   options.figureSnapMethod = 'getframe';
else
   options.figureSnapMethod = 'print';
end   
if (maxheight ~= -1)
   options.maxHeight = maxheight;
end
if (maxwidth ~= -1)
   options.maxWidth = maxwidth;
end

outputPath = publish(file, options);
