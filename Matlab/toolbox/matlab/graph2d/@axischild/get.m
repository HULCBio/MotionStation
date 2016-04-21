function val = get(A, varargin)
%AXISCHILD/GET Get axischild property
%   This file is an internal helper function for plot annotation.

%   Copyright 1984-2004 The MathWorks, Inc. 
%   $Date: 2004/01/15 21:11:33 $  $Revision: 1.8.4.2 $

HGObj = A.scribehgobj;

if nargin == 2
   switch varargin{1}
   case 'Prefix'
      val = A.Prefix;
   case 'Suffix'
      val = A.Suffix;
   case 'AutoDragConstraint'
      val = A.AutoDragConstraint;
   case 'DragConstraint'
      val = A.DragConstraint;
   case 'OldDragConstraint'
      val = A.OldDragConstraint;
   case 'Figure'
      HG = get(A,'MyHGHandle');
      val = ancestor(HG,'Figure');
   case 'Axis'
      HG = get(A,'MyHGHandle');
      val= ancestor(HG,'Axes');
   otherwise
      val = get(HGObj, varargin{:});
   end
else
   val = get(HGObj, varargin{:});
end


