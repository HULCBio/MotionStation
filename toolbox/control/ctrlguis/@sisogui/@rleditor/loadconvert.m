function SavedData = loadconvert(Editor,SavedData,Version)
%LOADCONVERT   Upgrades format of saved session data.

%   Author(s): P. Gahinet
%   Copyright 1986-2002 The MathWorks, Inc. 
%   $Revision: 1.3 $  $Date: 2002/04/10 04:58:48 $

% REVISIT: super::loadconvert
if Version<=1
   SavedData.TitleStyle = rmfield(SavedData.Title,{'String','Visible'});
   SavedData.Title = SavedData.Title.String;
   SavedData.XlabelStyle = rmfield(SavedData.Xlabel,{'String','Visible'});
   SavedData.Xlabel = SavedData.Xlabel.String;
   SavedData.YlabelStyle = rmfield(SavedData.Ylabel,{'String','Visible'});
   SavedData.Ylabel = SavedData.Ylabel.String;
   
   SavedData.LimitStack = ...
      struct('Limits',SavedData.LimitStack,'Index',min(1,size(SavedData.LimitStack,1)));
end