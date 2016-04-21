function result = slfind(varargin)
%slfind(options)
%  Finds objects under Simulink's root object
%
%	Tom Walsh
%   Copyright 2001-2002 The MathWorks, Inc.
%   $Revision: 1.1.2.1 $  $Date: 2004/04/15 01:00:14 $

rt = slroot;
result = rt.find(varargin);
