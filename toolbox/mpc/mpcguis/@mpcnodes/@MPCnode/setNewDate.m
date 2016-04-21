function setNewDate(this)
%  setNewDate  
%
%  Sets "Updated" property of an MPCnode object

%  Author:  Larry Ricker
%  Copyright 1986-2003 The MathWorks, Inc. 
%  $Revision: 1.1.6.1 $ $Date: 2003/10/15 18:48:56 $

this.Updated = datestr(now);
