function pzmap(this,r,ioflag)
%PZMAP   Updates Pole Zero Plots based on i/o flag. 
%        This is the  Data-Source implementation of pzmap.         

%  Author(s): Kamesh Subbarao
%  Copyright 1986-2004 The MathWorks, Inc.
%  $Revision: 1.1.6.2 $  $Date: 2004/04/11 00:21:02 $
s = size(this.Model);
if prod(s(3:end))~=length(r.Data)
   return  % number of models does not match number of data objects
end

% Get new data from the @ltisource object.
NormalRefresh = strcmp(r.RefreshMode, 'normal');
Ts = getst(this.Model);
if nargin==3
   % Pole/zero map for individual I/O pairs
   for ct=1:length(r.Data)
      % Look for visible+cleared responses in response array
      if isempty(r.Data(ct).Poles) && strcmp(r.View(ct).Visible,'on')
         sys = this.Model(:,:,ct);
         if isfinite(sys) && iscomputable(sys,'iopzmap',NormalRefresh)
            d = r.Data(ct);
            d.Poles = getpole(this,ct);
            d.Zeros = getzero(this,ct);
            d.Ts = Ts;
         end
      end
   end   
   
else
   % Poles and transmission zeros
   for ct=1:length(r.Data)
      % Look for visible+cleared responses in response array
      if isempty(r.Data(ct).Poles) && strcmp(r.View(ct).Visible,'on')
         sys = this.Model(:,:,ct);
         if isfinite(sys) && iscomputable(sys,'pzmap',NormalRefresh)
            d = r.Data(ct);
            d.Poles = {pole(sys)};
            d.Zeros = {zero(sys)};
            d.Ts = Ts;
         end
      end
   end
   
end