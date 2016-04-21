function r=rpt_summ_table(varargin)
%Report Generator Summary Table
%   This object is used by any component wishing to
%   draw itself as a "summary table".  It is similar
%   in structure to the "property table" component.
%
%   See also RPTPROPTABLE

%   Copyright 1997-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2004/04/15 00:16:47 $

r.Table=[];

r=class(r,'rpt_summ_table');
inferiorto('rptcomponent');

r=set_table(r,varargin{:});