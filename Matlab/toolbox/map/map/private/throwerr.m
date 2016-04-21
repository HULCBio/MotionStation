function throwerr(id,varargin)
%THROWERR constructs and rethrows an error.
%   THROWERR(ID,VARGARGIN) constructs an error structure
%   with the ID and inputs from varargin and rethrows this structure.

%   Copyright 1996-2003 The MathWorks, Inc.
%   $Revision: 1.1.8.2 $  $Date: 2003/08/01 18:19:46 $

err.message = sprintf(varargin{:});
err.identifier = id;
rethrow(err);
