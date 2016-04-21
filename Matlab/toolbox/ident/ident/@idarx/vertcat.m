function sys = vertcat(varargin)
%VERTCAT  Vertical concatenation of IDARX models.
%
%   MOD = VERTCAT(MOD1,MOD2,...) performs the concatenation 
%   operation
%         MOD = [MOD1 ; MOD2 , ...]
% 
%   This operation amounts to appending  the outputs of the 
%   IDMODEL objects MOD1, MOD2,... and feeding all these models
%   with the same input vector.
% 
%   See also IDARX/HORZCAT.

%   Copyright 1986-2001 The MathWorks, Inc.
%   $Revision: 1.5 $ $Date: 2001/04/06 14:21:59 $

ni = nargin;
for i = 1:ni,
   sizes = size(varargin{i});
end
nsys = length(varargin);
if nsys==0,
   sys = idss;  return
end

% Initialize output SYS to first input system
sys = idarx(varargin{1}); 
for j = 2:nsys,
   P = pvget(sys.idmodel,'CovarianceMatrix');
   [A,B] = arxdata(sys);
   Lam = pvget(sys,'NoiseVariance');
   if isempty(P)|isstr(P)
      noP = 1;
   else 
      noP = 0;
   end
   if ~noP
      par = pvget(sys.idmodel,'ParameterVector');
      l2 = length(par);
      sys1 = parset(sys,[1:l2]');
      [A1,B1] = arxdata(sys1); %% This is for tracking elements
      %% in the covariance matrix
   end
   %% Hidden models:
   ut=pvget(sys,'Utility');
   
   
   % Concatenate remaining input systems
   sysj = idarx(varargin{j});
   [a,b] = arxdata(sysj);
   lam = pvget(sysj,'NoiseVariance');
   %%LL%% It's a problem to concat lam: The variance of Lam is not stored,
   %% and depends on the number of data used to estimate lam. N could
   %% be different in the two models. Store covlam somewhere?
   
   % Check dimension compatibility
   sizes = size(B(:,:,1));
   sj = size(b(:,:,1));
   if sj(2)~=sizes(2),
      error('In [SYS1 ; SYS2], SYS1 and SYS2 must have the same number of inputs.')
   end
   
   try 
      sys.idmodel = [sys.idmodel ; sysj.idmodel];
   catch
      error(lasterr)
   end
   
   % Perfom concatenation
   
   [Ny,Ny,Na]=size(A);
   [ny,ny,na] = size(a);
   Lam = [[Lam,zeros(Ny,ny)];[zeros(ny,Ny),lam]];
   if Na>na
      aa=zeros(ny,ny,Na);
      aa(:,:,1:na)=a;
      a = aa;
   elseif na>Na
      AA = zeros(Ny,Ny,na);
      AA(:,:,1:Na) = A;
      A =AA;
   end
   
   A = [[A,zeros(Ny,ny,max(Na,na))];[zeros(ny,Ny,max(Na,na)),a]];
   [Ny,Nu,Nb]=size(B);
   [ny,nu,nb] = size(b);
   if Nb>nb
      bb=zeros(ny,nu,Nb);
      bb(:,:,1:nb)=b;
      b = bb;
   elseif nb>Nb
      BB = zeros(Ny,Nu,nb);
      BB(:,:,1:Nb) = B;
      B =BB;
   end
   B = [B;b];
   
   if ~noP
      Pj = pvget(sysj.idmodel,'CovarianceMatrix');
      if isempty(Pj)|isstr(Pj)
         noP = 1;
      else
         P = [[P,zeros(size(P,1),size(Pj,2))];[zeros(size(Pj,1),size(P,2)),Pj]];
         parj = pvget(sysj.idmodel,'ParameterVector');
         l1 = l2 + 1;
         l2 = l1 + length(parj);
         sysj1 = parset(sysj,[l1:l2]');
         [a1,b1] = arxdata(sysj1);
         [Ny,Ny,Na]=size(A1);
         [ny,ny,na] = size(a1);
         if Na>na
            aa1=zeros(ny,ny,Na);
            aa1(:,:,1:na)=a1;
            a1 = aa1;
         elseif na>Na
            AA1 = zeros(Ny,Ny,na);
            AA1(:,:,1:Na) = A1;
            A1 =AA1;
         end
         
         A1 = [[A1,zeros(Ny,ny,max(Na,na))];[zeros(ny,Ny,max(Na,na)),a1]];
         [Ny,Nu,Nb]=size(B1);
         [ny,nu,nb] = size(b1);
         if Nb>nb
            bb1=zeros(ny,nu,Nb);
            bb1(:,:,1:nb)=b1;
            b1 = bb1;
         elseif nb>Nb
            BB1 = zeros(Ny,Nu,nb);
            BB1(:,:,1:Nb) = B1;
            B1 =BB1;
         end
         B1 = [B1;b1];
      end
   end
   
   % Create result
   sys = pvset(sys,'A',A,'B',B,'NoiseVariance',Lam);
   
   cov =[];
   if ~noP
      sys1 = pvset(sys,'A',A1,'B',B1);
      par = pvget(sys1.idmodel,'ParameterVector');
      if length(P)>=max(par)
         cov = P(par,par);
      end
   end
   %% Hidden models
   utj = pvget(sysj,'Utility');
   ut = pvget(sys,'Utility');
   try
      idpj = utj.Idpoly;
      idp = ut.Idpoly;
      if isempty(idpj)|isempty(idp)
         idp =[];
      else
         idp = [idp,idpj];
      end
   catch
      idp = [];
   end
   ut.Idpoly = idp;
   
   sys.idmodel = pvset(sys.idmodel,'CovarianceMatrix',cov,'Utility',ut);
   
end
