function c=attribute(c,action,varargin)
%ATTRIBUTE launches the setup file editor options page

% Copyright 1994-2002 The MathWorks, Inc.
%   $Revision: 1.6 $  $Date: 2002/04/10 16:56:03 $

c=feval('attribute',c.rpt_summ_table,c,action,varargin{:});