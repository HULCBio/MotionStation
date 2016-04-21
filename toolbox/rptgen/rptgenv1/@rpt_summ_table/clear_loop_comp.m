function varargout=clear_loop_comp(r,c,l)
%CLEAR_LOOP_COMP delete temporary child loop component
%   c=clear_loop_comp(r,c,l)
%
%   If a child loop component ("l") was temporarily created
%   with make_loop_comp, this method will delete
%   the component.
%
%   Note that that the attributes of "l" will be
%   copied to the relevant c.att.FooComponent.att
%   structure.
%
%   See also MAKE_LOOP_COMP


%   Copyright 1997-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2004/04/15 00:16:39 $

loopAtt=subsref(l,substruct('.','att'));

delete(rptcp(l));

if nargout==1
   typeInfo=get_table(r,c);
   strucName=sprintf('%sComponent',typeInfo.id);
   varargout{1}=subsasgn(c,...
      substruct('.','att','.',strucName,'.','att'),loopAtt);
end

