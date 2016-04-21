function c=csl_mdl_changelog(varargin)
%Model Change Log
%   The Model Change Log component uses the looped model's
%   ModifiedHistory parameter to construct a table which
%   displays information about each logged revision to the
%   model.  The model history contains information about the
%   author of each change, the model version of the change,
%   the time and date of the change, and a description of the
%   change.  Each of these pieces of information is a single
%   column which you may choose to display or not display.
%
%   If your model has a long revision history, you may wish
%   to limit the number of revisions reported.
%
%   Model revision history parameters can be accessed through
%   the Model Properties dialog box under the model's "File" 
%   menu.  The "Options" tab controls how the version number
%   increments.  The "History" tab controls when to update
%   the history and allows you to hand-edit the ModifiedHistory
%   string.
%
%   See also CSL_MDL_LOOP

%   Copyright 1997-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2004/04/15 00:19:56 $

c=rptgenutil('EmptyComponentStructure','csl_mdl_changelog');
c=class(c,c.comp.Class,rptcomponent,zslmethods);
c=buildcomponent(c,varargin{:});
