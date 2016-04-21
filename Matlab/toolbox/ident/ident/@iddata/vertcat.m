function dat = vertcat(varargin)
% VERTCAT Vertical concatenation of IDDATA sets.
%
%   DAT = VERTCAT(DAT1,DAT2,..,DATn) or DAT = [DAT1;DAT2;...;DATn]
%   creates a data set DAT with input and output samples composed 
%   of those in DATk. Each experiment will thus consist of longer
%   data records, with the same number of channels.
%
%   To select portions of the data use subreferencing: DAT = DAT(1:300);
% 
%   The channel names must be the same in each of DATk, and so
%   must the experiment names
% 
%   See also IDDATA/SUBSREF, IDDATA/HORZCAT, IDDATA/SUBSASGN

%   Copyright 1986-2003 The MathWorks, Inc.
%   $Revision: 1.11.4.1 $  $Date: 2004/04/10 23:16:26 $

dat = varargin{1};
ny = get(dat,'ny');
nu = get(dat,'nu');
exno1 = dat.ExperimentName;
una = dat.InputName;
yna = dat.OutputName;
uu = dat.InputUnit;
yu = dat.OutputUnit;
int = dat.InterSample;
Ts = dat.Ts;
per = dat.Period;
for i=2:nargin
   datt=varargin{i};
   if ~isa(datt,'iddata')
       error('All the objects to be concatenated must be IDDATA objects.')
   end
    if ~strcmp(dat.Domain,datt.Domain)
       error('You cannot concatenate frequency and time domain data.')
   end
   ny1=get(datt,'ny');
   nu1=get(datt,'ny');
   nexp=get(datt,'ne');
   exno=datt.ExperimentName;
   if ny1~=ny
      error('The number of output channels must be the same.')
   end
   
   if nu1~=nu1
      error('The number of input channels must be the same.')
   end
   if length(exno)~=length(exno1)
      error('The number of experiments must be the same.')
   end
   if ~all(strcmp(yna,datt.OutputName))|~all(strcmp(una,datt.InputName))
      warning('Channel names not equal. Those of the first set are used.')
   end
   if ~all(strcmp(yu,datt.OutputUnit))|~all(strcmp(uu,datt.InputUnit))
      warning('Channel units not equal. Those of the first set are used.')
   end
   
   %% check for channel names & units, override
   %% Check sampling interval, use samplingInstants if necessary
   %% check period, inf dominant
   %% check intersample, error
   pert = datt.Period;
   Tst = datt.Ts;
   intt = datt.InterSample;
   Ts = dat.Ts;
   if strcmp(lower(dat.Domain),'frequency')
	   dat = freqvert(dat,datt);
	   return
   end
   samp = dat.SamplingInstants;
   sampt = datt.SamplingInstants;
   samptr = pvget(datt,'SamplingInstants');
   sampr = pvget(dat,'SamplingInstants');
   for kk=1:get(dat,'Ne')
      if isempty(Ts{kk})
         if isempty(Tst{kk}) % Then we concatenate the sampling instants
            if max(samp{kk})>min(sampt{kk})
               error('SamplingInstants must be increasing along the data.')
            end
            samp{kk} = [samp{kk};sampt{kk}];
         else  % new data equal sampling: Add with new sampling interval
            if datt.Tstart{kk}<0
               error('Negative Tstart in new data will give bad SamplingInstants.')
            end
            samp{kk} = [samp{kk};samptr{kk}+max(samp{kk})]; 
         end
      else % Old data equal sampling
         if isempty(Tst{kk}) % new data not equally sampled
            if max(sampr{kk})>min(samptr{kk})
               error('SamplingInstants must be increasing along the data.')
            end
            samp{kk} =[sampr{kk};sampt{kk}];
         else % new data equally sampled
            if Ts{kk}~=Tst{kk} % Different samplingtimes
               if datt.Tstart{kk}<0
                  error('Negative Tstart in new data will give bad SamplingInstants.')
               end 
               samp{kk} = [sampr{kk};samptr{kk}+max(sampr{kk})];
            end
         end
         end
         
         
         per1 = per{kk}; pert1 = pert{kk};
         noeq = find(per1~=pert1);
         per{kk}(noeq) = inf*ones(length(noeq),1);
         yn{kk}=[dat.OutputData{kk};datt.OutputData{kk}];
         un{kk}=[dat.InputData{kk};datt.InputData{kk}];
         if ~all(strcmp(int(:,kk),intt(:,kk)))
            error('You cannot concatenate inputs with different InterSample behaviour.')
         end
         
      end
      dat.OutputData = yn;
      dat.InputData = un;
      dat.Period = per;
      dat = pvset(dat,'SamplingInstants',samp);
   end
   
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  function dat = freqvert(dat,datt)
  fr = dat.SamplingInstants;
  frt = datt.SamplingInstants;
  for kexp = 1:length(fr)
	  frn = [fr{kexp};frt{kexp}];
	  yn = [dat.OutputData{kexp};datt.OutputData{kexp}];
	  un = [dat.InputData{kexp};datt.InputData{kexp}];
	  [dum,ind] = sort(frn);
	  yns{kexp} = yn(ind,:);
	  uns{kexp} = un(ind,:);
	  frs{kexp} = frn(ind);
  end
  dat.OutputData = yns;
  dat.InputData = uns;
  dat.SamplingInstants = frs;
  