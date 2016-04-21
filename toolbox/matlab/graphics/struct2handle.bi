%STRUCT2HANDLE Create Handle Graphics hierarchy from structure.
%   STRUCT2HANDLE(S, PARENTS) creates the handle graphics
%   objects described in struct S, as children of the objects
%   listed in PARENTS.  S and PARENTS must have same number of
%   elements.
%   STRUCT2HANDLE(...,'convert') Updates all property values which
%   contained handles of any other objects represented in struct S
%   to their new values.
%   STRUCT2HANDLE(...,'all') Ignores 'Serializable' property when
%   restoring objects, and restores all objects in S, including
%   those with 'Serializable' set to 'off'.
%   H = STRUCT2HANDLE(...) returns handles to the objects created
%   from top level of S.
%
%   S should be a structure returned from handle2struct containing
%   the following fields:
%      type:       the object type
%      properties: a structure containing property values
%      children:   a structure array with an element for each child
%      handle:     the object's handle at the time of conversion
%
%   See also HANDLE2STRUCT.

%   Copyright 1984-2002 The MathWorks, Inc. 
%   $Revision: 1.7 $  $Date: 2002/04/10 17:06:56 $
%   D. Foti  11/19/97
%   Built-in function.

  
