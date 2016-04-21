function varargout = bodeasym(varargin)
%BODEASYM Plots the asymptotic Bode magnitude curve
%   BODEASYM(SYS) plots an asymptotic approximation to the Bode
%   magnitude for the LTI Object SYS. The plot is shown in dB.
%
%   BODEASYM(SYS,PlotStr) plots the approximation with the color,
%   linestyle, and marker specified in PlotStr. See the PLOT 
%   command for valid plot style strings.
%
%   See also  BODE

%   BODEASYM(SYS,PlotStr,AX) plots the approximation to the axes with
%   handle AX.
%
%   ASYM = BODEASYM(SYS,AX) can be used to return the line handle
%   the asymptote.

%   Authors: Karen D. Gondoly
%   Revised: Adam W. DiVergilio
%   Copyright 1986-2002 The MathWorks, Inc. 
%   $Revision: 1.10 $  $Date: 2002/04/10 05:51:58 $

error(nargchk(1,3,nargin))

sys = varargin{1};
if ~isa(sys,'lti')
   error('Invalid LTI object.')
end

if nargin>1 & ~isempty(varargin{2}),
   [LL,CC,MM] = colstyle(varargin{2}); 
   if isempty(LL), LL='-'; end,
   if isempty(MM), MM='none'; end,
   if isempty(CC),
      AllC=get(0,'defaultaxescolororder');
      CC = AllC(1,:);
   end
else
   CC = [.7 .7 .7];
   LL = ':';
   MM = '.';
end

if nargin>2 ,
   ax = varargin{3};
else
   ax = gca; % Not robust if the user doesn't click on the Magnitude axes
   set(ax,'Xscale','log');
end

[Z,P,k]=zpkdata(sys,'v');

AllWn = [damp(P);damp(Z)];

[SortWn,IndSort] = sort(AllWn);
ind=find(SortWn);
SortWn = SortWn(ind); IndSort = IndSort(ind);
[UniqWn,I,J]=unique(SortWn);

IndPZ=ones(length(AllWn),1);
IndPZ(length(P)+1:end)=-1;

sys0 = zpk(Z(find(AllWn(length(P)+1:end))), ...
   P(find(AllWn(1:length(P)))),k);
K = dcgain(sys0);

Xlim = get(ax,'Xlim');
if Xlim(1)>=UniqWn(1),
   Xlim(1) = 0.1*UniqWn(1);
end
if Xlim(2)<=UniqWn(end),
   Xlim(2) = 10*UniqWn(end);
end
Xvec = [Xlim(1);UniqWn;Xlim(2)];

n = sum(IndPZ(find(~AllWn)));
Yvec = zeros(length(Xvec),1);
Yvec(1) = K/(Xvec(1)^n);
Yvec(2) = K/(Xvec(2)^n);

for ct = 3:length(Xvec),
   n = n + sum(IndPZ(IndSort(find(SortWn==Xvec(ct-1)))));
   Yvec(ct) = (Yvec(ct-1)*(Xvec(ct-1)^n))/(Xvec(ct)^n);
end % for ct

Asym = line(Xvec,20*log10(Yvec),'Parent',ax,'Color',CC, ...
   'LineStyle',LL,'Marker',MM,'Tag','BodeAsymptoteLine','HitTest','off');

if nargout,
   varargout{1} = Asym;
end
