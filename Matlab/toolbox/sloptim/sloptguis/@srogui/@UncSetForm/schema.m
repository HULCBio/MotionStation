function schema
% Base class for literal specification of parameter uncertainty.
% (used as data model in UncertaintyDialog table)

%   Author(s): Pascal Gahinet
%   $Revision: 1.1.6.2 $ $Date: 2004/04/11 00:45:16 $
%   Copyright 1986-2003 The MathWorks, Inc.

% Register class 
c = schema.class(findpackage('srogui'),'UncSetForm');
c.Description = 'Literal specification of parameter uncertainty';

if (isempty(findtype('SRO_OptimizedSet')))
   schema.EnumType('SRO_OptimizedSet',{'none','all','vertex'});
end

%%%%%%%%%%%%%%%%%%%%%%
%-- Public Properties
%%%%%%%%%%%%%%%%%%%%%%
p = schema.prop(c,'Optimized','SRO_OptimizedSet');  % struct
p.FactoryValue = 'vertex';

p = schema.prop(c,'Parameters','MATLAB array');

% Version
p = schema.prop(c, 'Version', 'double');
p.FactoryValue = 1.0;
p.AccessFlags.PublicGet = 'off';
p.AccessFlags.PublicSet = 'off';

p = schema.prop(c, 'Listeners', 'handle vector');
p.AccessFlags.PublicGet = 'off';
p.AccessFlags.PublicSet = 'off';
