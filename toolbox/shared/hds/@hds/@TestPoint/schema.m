function schema
% Defines properties for @TestPoint class

%   Copyright 1986-2003 The MathWorks, Inc.
%   $Revision: 1.1.6.3 $ $Date: 2004/04/11 00:28:57 $

% Register class 
p = findpackage('hds');
c = schema.class(p,'TestPoint',findclass(p,'dataset'));

% Public properties
p = schema.prop(c,'Storage','handle');  % Array container 
p.SetFunction = @LocalUpdateStorage;


%--------------- Local Functions -----------------------

function Value = LocalUpdateStorage(this,Value)
if ~isa(Value,'hds.ArrayContainer')
   error('Invalid value for Storage property.')
end
this.utSetStorage(Value);
