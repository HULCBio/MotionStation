function w = javaDAClipboard

    persistent theClip;

    if isempty(theClip)
        theClip = DAStudio.Clipboard;
    end

    w = java(theClip);
    

%   Copyright 2002-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2004/04/15 00:32:14 $
