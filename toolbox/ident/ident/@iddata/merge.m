function dat = merge(dat1,varargin)
%MERGE Merging two IDDATA data sets 
%
%   DAT = MERGE(DAT1,DAT2,DAT3,...)  
%   creates a multiple experiments data set the sets can be
%   used to fit models to separate and non-continuous data records.
%
%   Separate experiments are retrieved by the command GETEXP or by
%   subreferencing with a fourth index:
%   DAT2 = DAT(:,:,:,2) or DAT2 = DAT(:,:,:,'Day4'), where 'Day4' is the name of the
%   second experiment.  
%
%   See also GETEXP, IDDATA/SUBSREF.
%
%

%   Copyright 1986-2003 The MathWorks, Inc.
%   $Revision: 1.13.4.1 $  $Date: 2004/04/10 23:16:01 $

dat = dat1;
for ka = 1:length(varargin)
   dat2 = varargin{ka};
   if ~isa(dat1,'iddata')|~isa(dat2,'iddata')
      error('Only IDDATA objects can be merged.')
   end
     if ~strcmp(lower(dat1.Domain),lower(dat2.Domain))
       error('You cannot merge frequency and time domain data.')
   end
   y = [dat1.OutputData,dat2.OutputData];
   u = [dat1.InputData,dat2.InputData];
   yna1 = dat1.OutputName;
   yna2 = dat2.OutputName;
   una1 = dat1.InputName;
   una2 = dat2.InputName;
   yu1 = dat1.OutputUnit;
   yu2 = dat2.OutputUnit;
   uu1 = dat1.InputUnit;
   uu2 = dat2.InputUnit;
   if length(yna1)~=length(yna2)
     error(['The experiments must all have the same number of' ...
	    ' outputs.'])
   end
   if length(una1)~=length(una2)
     error(['The experiments must all have the same number of' ...
	    ' inputs.'])
   end
   for ku = 1:length(yna1)
      if ~strcmp(yna1{ku},yna2{ku})
         error('The OutputNames in the experiments shall coincide.')
      end
      if ~strcmp(yu1{ku},yu2{ku})
         error('The OutputUnits in the experiments shall coincide.')
      end
   end
   for ku = 1:length(una1)
      if ~strcmp(una1{ku},una2{ku})
         error('The InputNames in the experiments shall coincide.')
      end
      if ~strcmp(uu1{ku},uu2{ku})
         error('The InputUnits in the experiments shall coincide.')
      end
   end
   
   
   ts = [dat1.Ts,dat2.Ts];
   tstart = [dat1.Tstart,dat2.Tstart];
   sa = [dat1.SamplingInstants, dat2.SamplingInstants];
   %dat = dat1;
   try
      dat=pvset(dat1,'OutputData',y,'InputData',u,'Ts',ts,...
         'SamplingInstants',sa,'Period',[dat1.Period, dat2.Period]);
     dat.Tstart = tstart;
     if length(una1)>0
       dat=pvset(dat,'InterSample',[dat1.InterSample,dat2.InterSample]);
   end
   catch
      error(lasterr)
   end
   
   if ~strcmp(dat2.ExperimentName{1},'Exp1')
      dat=pvset(dat,'ExperimentName',[dat1.ExperimentName;dat2.ExperimentName]);
   end
   dat1 = dat;
end

