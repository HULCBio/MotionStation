function m = idmodel(ny,nu,Ts,Pvec,Cmat)
%IDMODEL  constructor for the IDMODEL parent object.
%
%  IDMODEL is parent to the model objects IDPOLY, IDSS, IDARX and
%  IDGREY, used by the System Identification Toolbox. See IDHELP
%  for more infomation.
%
%  M = IDMODEL(NY,NU) creates an IDMODEL object with NY outputs and
%  NU inputs, with default sample time of 1.
%
%  M = IDMODEL(NY,NU,TS) creates an IDMODEL object with NY outputs,
%  NU inputs, and a sample time TS.
%
%  M = IDMODEL(NY,NU,TS,PV,CM) creates an IDMODEL object with NY 
%  outputs, NU inputs, sample time TS, parameter vector PV, and
%  covariance matrix CM. 
%
% Note: This function is not intended for users.  Use IDSS, IDPOLY,
%        IDARX, or IDGREY to create IDMODEL objects.

%   Copyright 1986-2003 The MathWorks, Inc.
%   $Revision: 1.15.4.1 $  $Date: 2004/04/10 23:17:26 $

ni = nargin;
if (ni == 1)&isa(ny, 'idmodel')
  m = ny;
  return
end
superiorto('iddata')
try
   superiorto('lti','frd')
catch
   end
ni = nargin;
if ni < 1, ny = 0; end
if ni < 2, nu = 0; end
if ni < 3, Ts = 1; end
if ni < 4, Pvec = zeros(0,1); end
if ni < 5, Cmat = []; end
EmptyStr = {''};
%kk=EmptyStr(ones(nu,1),1)%,...%
%EmptyStr(ones(ny,1),1),...%
m = struct('Name',             '',...
           'Ts',               Ts,...
           'InputName',        {defnum([],'u',nu)},...%{EmptyStr(ones(nu,1),1)},...%{cell(nu,1)},...
           'InputUnit',        {EmptyStr(ones(nu,1),1)},...%{cell(nu,1)},...
           'OutputName',       {defnum([],'y',ny)},...%{EmptyStr(ones(ny,1),1)},...%{cell(ny,1)},...
           'OutputUnit',       {EmptyStr(ones(ny,1),1)},...%{cell(ny,1)},...
           'TimeUnit',         '',...
           'ParameterVector',  Pvec,...
	        'PName',            {{}},...%{EmptyStr(ones(length(Pvec),1),1)},...%[],...%{defnum([],'p',length(Pvec))},...
           'CovarianceMatrix', Cmat,...
           'NoiseVariance',    eye(ny,ny),...
           'InputDelay',       zeros(nu,1),...
           'Algorithm',        iddef('algorithm'),...
           'EstimationInfo',   iddef('estimation'),...
           'Notes',            {{}},...
           'UserData',         [],...
           'Utility',          [],...
           'Version',          1.0);

m = class(m, 'idmodel');
