function sys = horzcat(varargin)
%HORZCAT  Horizontal concatenation of IDPROC models.
%
%   MOD = HORZCAT(MOD1,MOD2,...) performs the concatenation 
%   operation
%         MOD = [MOD1 , MOD2 , ...]
% 
%   This operation amounts to appending the inputs and 
%   adding the outputs of the models MOD1, MOD2,...:
%   G_1 u_1 + G_2 u_2 + ...
% 
%   If MODk have non-trivial disturbancemodels, the one of MOD1
%   will be inherited.


%   Copyright 1986-2003 The MathWorks, Inc.
%   $Revision: 1.6.4.1 $  $Date: 2004/04/10 23:17:07 $

% Will destroy Idpoly models in Utility

ni = nargin;
nsys = length(varargin);
if nsys==0,
    sys = idproc;  return
end

% Initialize output SYS to first input system
sys = varargin{1};
if ~isa(sys,'idproc')
    error('All arguments must be IDPROC objects.')
end
dm = pvget(sys,'DisturbanceModel');
sys = pvset(sys,'DisturbanceModel','None');
for j = 2:nsys
    sysj = varargin{j};
    if ~isa(sysj,'idproc')
    error('All arguments must be IDPROC objects.')
end

    sysj = pvset(sysj,'DisturbanceModel','None');
    sys.Kp.status = [sys.Kp.status sysj.Kp.status];
    sys.Kp.min = [sys.Kp.min sysj.Kp.min];
    sys.Kp.max = [sys.Kp.max sysj.Kp.max];
    
    sys.Tp1.status = [sys.Tp1.status sysj.Tp1.status];
    sys.Tp1.min = [sys.Tp1.min sysj.Tp1.min];
    sys.Tp1.max = [sys.Tp1.max sysj.Tp1.max];
    
    sys.Tp2.status = [sys.Tp2.status sysj.Tp2.status];
    sys.Tp2.min = [sys.Tp2.min sysj.Tp2.min];
    sys.Tp2.max = [sys.Tp2.max sysj.Tp2.max];
    
    sys.Tp3.status = [sys.Tp3.status sysj.Tp3.status];
    sys.Tp3.min = [sys.Tp3.min sysj.Tp3.min];
    sys.Tp3.max = [sys.Tp3.max sysj.Tp3.max];
    
    sys.Tw.status = [sys.Tw.status sysj.Tw.status];
    sys.Tw.min = [sys.Tw.min sysj.Tw.min];
    sys.Tw.max = [sys.Tw.max sysj.Tw.max];
    
    sys.Zeta.status = [sys.Zeta.status sysj.Zeta.status];
    sys.Zeta.min = [sys.Zeta.min sysj.Zeta.min];
    sys.Zeta.max = [sys.Zeta.max sysj.Zeta.max];
    
    sys.Tz.status = [sys.Tz.status sysj.Tz.status];
    sys.Tz.min = [sys.Tz.min sysj.Tz.min];
    sys.Tz.max = [sys.Tz.max sysj.Tz.max];
    
    sys.Td.status = [sys.Td.status sysj.Td.status];
    sys.Td.min = [sys.Td.min sysj.Td.min];
    sys.Td.max = [sys.Td.max sysj.Td.max];
    
    sys.Integration = [sys.Integration sysj.Integration];
    
    sys.InputLevel.status = [sys.InputLevel.status sysj.InputLevel.status];
    sys.InputLevel.min = [sys.InputLevel.min sysj.InputLevel.min];
    sys.InputLevel.max = [sys.InputLevel.max sysj.InputLevel.max];
    sys.InputLevel.value = [sys.InputLevel.value sysj.InputLevel.value];

    
    par = pvget(sys,'ParameterVector');
    parj = pvget(sysj,'ParameterVector');
    
    P = pvget(sys,'CovarianceMatrix');  
    Pj = pvget(sysj,'CovarianceMatrix');
    PP = [P,zeros(size(P,1),size(Pj,2));zeros(size(Pj,1),size(P,2)),Pj];
    if length(PP)~=length([par;parj]) % destroy cov
        PP = [];
    end
    idm = pvget(sys,'idmodel');
    idmj = pvget(sysj,'idmodel');
    ut = pvget(sys,'Utility');
    utj = pvget(sys,'Utility');
    try 
        idm = [idm idmj];
        idm = pvset(idm,'ParameterVector',[par;parj],'CovarianceMatrix',PP);
        sys = parset(sys,[par;parj]);
        idg = sys.idgrey;
        idgj = sysj.idgrey;
        llfile = idg.file;
        llfile{1} = [idg.file{1},idgj.file{1}];
        nu = size(idg,'nu');
        llfile{5} = [idg.file{5};idgj.file{5}+nu*8];
        llfile{8} = sys.InputLevel;
        was = warning;
        warning off
        idg = pvset(idg,'FileArgument',llfile,'idmodel',idm);
        sys.idgrey=idg;
        warning(was)
    catch
        error(lasterr)
    end
    
    % Now utility
%     try
%         idp = ut.Idpoly;
%         idpj = utj.Idpoly;
%         if ~isempty(idp)&~isempty(idpj)
%             idp = {[idp{1} idpj{1}]};
%         else
%             idp = [];
%         end
%         ut.Idpoly = idp;
%         sys = uset(sys,ut);
%     end
end
sys = pvset(sys,'DisturbanceModel',dm);

 
