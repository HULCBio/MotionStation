function sizes = size(MPCobj,type) 
%SIZE  Size and order of MPC objects.
%
%   D = SIZE(MPCOBJ) returns the row vector D = [NU NYM] for an MPC object MPCOBJ 
%   with NU manipulated input variables and NYM measured controlled outputs.
%
%   D = SIZE(MPCOBJ,TYPE) returns the number of signals of type TYPE, where TYPE
%   is one of the following:
%
%       'uo'  unmeasured controlled outputs
%       'md'  measured disturbances
%       'ud'  unmeasured disturbances
%       'mv'  manipulated variables
%       'mo'  measured controlled outputs
%
%   SIZE(MPCOBJ) by itself makes a nice display.
%
%   See also DISPLAY

%   Author: A. Bemporad
%   Copyright 1986-2004 The MathWorks, Inc.
%   $Revision: 1.1.8.5 $  $Date: 2004/04/10 23:35:17 $   

% Get sizes
if ~isempty(MPCobj),
    nym=length(MPCobj.MPCData.myindex);
    nyu=MPCobj.MPCData.ny-nym;
    nu=MPCobj.MPCData.nu;
    nv=length(MPCobj.MPCData.mdindex);
    nd=length(MPCobj.MPCData.unindex);
else
    nym=0;
    nyu=0;
    nu=0;
    nv=0;
    nd=0;
end


if nargout==0 & nargin<2,
    try
        %display(MPCobj);
        disp(sprintf(['MPC controller with %d measured output(s), ' ...
            '%d unmeasured output(s),\n%d manipulated input(s), ' ...
            '%d measured disturbance(s), %d unmeasured disturbance(s)'],...
            nym,nyu,nu,nv,nd));
    catch
        rethrow(lasterror);
    end
    return;
end


if nargin<2,
    sizes =[nu nym];
    return
end

switch lower(type)
    case 'mv'
        sizes=nu;
    case 'mo'
        sizes=nym;
    case 'md'
        sizes=nv;
    case 'ud'
        sizes=nd;
    case 'uo'
        sizes=nyu;
    otherwise
        error('mpc:size:unknown','Unknown signal type. Valid signal types are ''mv'', ''mo'', ''uo'', ''md'', ''ud''');
end
