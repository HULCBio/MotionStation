function hax = getaxes(this,varargin)
%GETAXES  Returns handles of HG axes making up editor.

%   Copyright 1986-2002 The MathWorks, Inc. 
%   $Revision: 1.2 $  $Date: 2002/04/10 05:02:36 $

% RE: Needed for property editor interface
hax = getaxes(this.Axes,varargin{:});