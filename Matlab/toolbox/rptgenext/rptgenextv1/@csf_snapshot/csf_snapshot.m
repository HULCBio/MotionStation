function c=csf_snapshot(varargin)
% Stateflow snapshot
% 
%    This component inserts a picture of a stateflow object 
%    in the report.  It must be parented by a Stateflow object 
%    report component.
%
%    Attribute page parameters:    
%          image file format
%          minimum required children for picture
%          image size
%    
%    Note: Use the "Attempt to shrink image..." option under "Image Size" 
%          to minimize the overall report size.  This makes the image sizes 
%          as small as possible while maintaining text legibility (as set in 
%          Stateflow Loop). 
%

%   Copyright 1997-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2004/04/15 00:18:30 $

c=rptgenutil('EmptyComponentStructure','csf_snapshot');
c=class(c,c.comp.Class,rptcomponent,zslmethods,zsfmethods);
c=buildcomponent(c,varargin{:});