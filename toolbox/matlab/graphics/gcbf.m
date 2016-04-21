function fig = gcbf
%GCBF Get handle to current callback figure.
%   FIG = GCBF returns the handle of the figure that contains the object
%   whose callback is currently executing.  If the current callback object
%   is the figure, the figure is returned.
%
%   When no callbacks are executing, GCBF returns [].  If the current figure
%   gets deleted during callback execution, GCBF returns [].
%
%   The return value of GCBF is identical to the FIGURE output argument of
%   GCBO.
%
%   See also GCBO, GCO, GCF, GCA.

%   Copyright 1984-2002 The MathWorks, Inc. 
%   $Revision: 1.10 $  $Date: 2002/04/10 17:07:20 $

[obj, fig] = gcbo;
