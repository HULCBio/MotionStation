function h = findcarrier(this)
%FINDCARRIER  Returns @waveform to which dataview component is attached.
%
%  Default implementation

%  Copyright 1986-2004 The MathWorks, Inc.
%  $Revision: 1.1.6.2 $ $Date: 2004/04/11 00:27:01 $
h = findcarrier(this.Parent);