function setCursor(this,type)
%SETCURSOR Set icon for MapView cursor.
%
%   setCursor(TYPE) sets the cursor for the MapView to TYPE.  TYPE is any
%   valid Pointer for a Handle Graphics figure.

%   Copyright 1996-2003 The MathWorks, Inc.
%   $Revision: 1.1.6.3 $  $Date: 2004/02/01 21:57:06 $

switch lower(type)
 case 'wait'
  p.Pointer = this.Figure.Pointer;
  p.PointerShapeCData = this.Figure.PointerShapeCData;
  p.PointerShapeHotSpot = this.Figure.PointerShapeHotSpot;
  this.Figure.Pointer = 'watch';
  setappdata(this.Figure,'PrevPointer',p);
 case 'arrow'
  this.Figure.Pointer = 'arrow';
 case 'restore'
  p = getappdata(this.Figure,'PrevPointer');
  if ~isempty(p)
    set(this.Figure,p);
    setappdata(this.Figure,'PrevPointer',[]);
  else
    setCursor(this,'arrow');
  end
end
