function SavedData = loadconvert(Editor,SavedData,Version)
%LOADCONVERT   Upgrades format of saved session data.

%   Author(s): P. Gahinet
%   Copyright 1986-2002 The MathWorks, Inc. 
%   $Revision: 1.3 $  $Date: 2002/04/10 05:02:24 $

if Version<=1
   SavedData.TitleStyle = rmfield(SavedData.Title,{'String','Visible'});
   SavedData.Title = SavedData.Title.String;
   SavedData.XlabelStyle = rmfield(SavedData.Xlabel,{'String','Visible'});
   SavedData.Xlabel = SavedData.Xlabel.String;
   SavedData.YlabelStyle = rmfield(SavedData.Ylabel,{'String','Visible'});
   SavedData.Ylabel = SavedData.Ylabel.String;
end