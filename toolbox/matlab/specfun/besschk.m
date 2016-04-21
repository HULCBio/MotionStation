function [msg,nu,z,siz] = besschk(nu,z)
%BESSCHK Check arguments to bessel functions.
%   [MSG,NU,Z,SIZ] = BESSCHK(NU,Z)

%   Copyright 1984-2004 The MathWorks, Inc. 
%   $Revision: 1.20.4.3 $  $Date: 2004/03/02 21:48:34 $

message = '';
siz = size(z);
if ~isnumeric(nu) || ~isnumeric(z)
   message = 'Arguments must be numeric.';
   identifier = 'MATLAB:besschk:nonNumericInput';
elseif ~isreal(nu)
   message = 'NU must be real';
   identifier = 'MATLAB:besschk:nonRealNU';
elseif length(nu) == 1
   % do nothing
elseif length(z) == 1
   z = z(ones(size(nu)));
   siz = size(z);
elseif isempty(nu) || isempty(z)
   siz = [length(z) length(nu)];
elseif automesh(nu,z)
   % If the increment in nu is 1, don't automesh since besselmx
   % will do the meshgrid and compute the result faster.
%   if all(diff(nu) == 1) & all(nu >= 0)
   if all((nu(2:end)-nu(1:end-1))== 1) & all(nu >= 0)
      siz = [length(z) length(nu)];
   else
      [nu,z] = meshgrid(nu,z);
      siz = size(z);
   end
elseif isequal(size(nu),size(z))
   % If the increment in nu is 1, then check for already meshgridded
   % inputs that can be unmeshed.  The result will still be gridded by
   % besselmx, it will just be computed faster.
%   if all(diff(nu(1,:)) == 1) & all(nu >= 0)
   if all((nu(1,2:end)-nu(1,1:end-1)) == 1) & all(nu >= 0)
      [nnu,zz] = meshgrid(nu(1,:),z(:,1));
      % If the inputs are already gridded, unmesh them.
      if isequal(nnu,nu) && isequal(zz,z),
         nu = nu(1,:);
         z = z(:,1);
         siz = [length(z) length(nu)];
      end
   end
elseif ~isequal(size(nu),size(z)), 
   message = 'NU and Z must be the same size.';
   identifier = 'MATLAB:besschk:NUAndZSizeMismatch';
end

if isempty(message)
    % Form empty Message Structure
    msg.message = '';
    msg.identifier = '';
    msg=msg(zeros(0,1));
else
    msg.message = message;
    msg.identifier = identifier;
end

