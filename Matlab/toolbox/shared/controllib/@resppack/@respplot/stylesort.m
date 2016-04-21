function stylesort(this,sortbycolor,sortbylinestyle,sortbymarkerstyle)
%  STYLESORT  Helper method to specify the how the color/linestyle/markerstyle
%  properties are sorted in a response.
%
%  Possible values for each style type: 'response','input','output','channel'

%  Author(s): John Glass
%  Revised:
%  Copyright 1986-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2004/04/11 00:22:47 $

% Restack the used styles for each response
for ct1 = 1:length(this.Responses)
    this.Style.restackstyle(this.Responses(1-ct1+length(this.Responses)));
end

% Update the sortbystyle properties in the style database
this.Style.SortByColor = sortbycolor;
this.Style.SortByLineStyle = sortbylinestyle;
this.Style.SortByMarkerStyle = sortbymarkerstyle;

% Apply the new styles to each response
for ct1 = 1:length(this.Responses)
    this.Responses(ct1).applystyle;
end