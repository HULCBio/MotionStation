function DC = dcgain(this,ModelIndex,RespInfo)
%DCGAIN  Computes steady-state response for step, impulse, or initial.

%  Copyright 1986-2004 The MathWorks, Inc.
%  $Revision: 1.1.6.2 $ $Date: 2004/04/11 00:20:45 $

ni = nargin;
if ni<2
   ModelIndex = 1;
end
if ni<3 | ~isfield(RespInfo,'Type')
   RespType = 'step';
else
   RespType = RespInfo.Type;
end

switch RespType
case 'step'
   DC = this.TimeResponse(ModelIndex).DCGain;
   if isempty(DC)
      if isstable(this,ModelIndex)>0
         DC = dcgain(this.Model(:,:,ModelIndex));
      else
         Size = getsize(this);
         DC = repmat(Inf,Size([1 2]));
      end
      % REVISIT: 3 -> 1
      tr = this.TimeResponse;
      tr(ModelIndex).DCGain = DC;
      this.TimeResponse = tr;
   end
   
case 'impulse'
   if LocalIsMarginallyStable(this,ModelIndex)
      [DC,eq] = dcgain(this.Model(:,:,ModelIndex));
      DC(eq.power>=0) = 0;
      DC(eq.power<-1) = Inf;
      idx = (eq.power==-1);
      DC(idx) = eq.factor(idx);
   else
      Size = getsize(this);
      DC = repmat(Inf,Size([1 2]));
   end
   
case 'initial'
   if ni==3 & isfield(RespInfo,'IC') & LocalIsMarginallyStable(this,ModelIndex)
      % Prepare model for steady-state evaluation
      x0 = RespInfo.IC;  % initial condition
      sys = this.Model(:,:,ModelIndex);
      [a,b,c,d,e,Ts] = dssdata(sys);
      sys = dss(a,x0,c,zeros(size(sys,1),1),e,Ts);
      % Compute steady state
      [DC,eq] = dcgain(sys);
      DC(eq.power>=0) = 0;
      DC(eq.power<-1) = Inf;
      idx = (eq.power==-1);
      DC(idx) = eq.factor(idx);
   else
      Size = getsize(this);
      DC = repmat(Inf,Size([1 2]));
   end
   
end


%------------ Local Functions ------------------------

function boo = LocalIsMarginallyStable(this,idx)
% Checks for marginally stable systems
try
   p = getpole(this,idx);
   p = cat(1,p{:});
   if this.Model.Ts
      comp = find(abs(p)==1);
      boo = all(abs(p)<= 1) & all(p(comp)==1) ;
   else
      comp = find(real(p)==0); 
      boo = all(real(p)<= 0) & all(p(comp)==0);
   end
catch
   boo = NaN; 
end