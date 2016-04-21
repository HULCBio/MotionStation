function dat = iddata(varargin)
% IDDATA Create DATA OBJECT to be used for Identification routines
%  
%    Very Basic Use:
%    DAT = IDDATA(Y,U,Ts) to create a data object with output Y and
%          input U and sampling interval Ts. Default Ts=1. If U=[], 
%          or not assigned, DAT defines a signal or a time series. 
%          With Y =[], DAT describes just the input.
%          Y is a N-by-Ny matrix with N being the number of data and Ny 
%          the number of output channels, and similarly for U.
%          Y and U must have the same number of rows.
%
%          For Frequency Domain Data use
%    DAT = IDDATA(Y,U,Ts,'FREQ',Freqs),
%          where Freqs is a column vector containing the frequencies. It is 
%          of the same length as Y and U. Note that Ts may be equal to 0
%          for frequency domain data, to indicate continuous time data.
%
%          Retrieve data by DAT.y, DAT.u and DAT.Ts 
%          Select portions by DAT1 = DAT(1:300) etc.
%
%    Basic Use:
%    DAT = IDDATA(Y,U,Ts,'OutputName',String,....) or 
%          SET(DAT,'OutputName',String,.... to add properties to
%          the data object, for logistics and plotting.
%          Type SET(IDDATA) for a complete list of properties. 
%          Some basic ones are
%          OutputData, InputData: refers to Y and U above.
%          OutputName: String. For multiputput, use cell arrays, e.g. 
%                      {'Speed','Voltage'}
%          OutputUnit: String. For multioutput use cell arrays, e.g. 
%                      {'mph','volt'}
%          InputName, InputUnit, analogously.
%          Tstart: Starting time for the samples. 
%          TimeUnit: String.
%          Properties can be set and retrieved either by SET and GET 
%          or by subfields:
%          GET(DAT,'OutputName') or DAT.OutputName
%          SET(DAT,'OutputName','Current') or
%          DAT.OutputName = {'Current'};
%          Referencing is case insensitive and 'y' is synonymous to 
%          'Output' and 'u' is synonymous to 'Input'. Autofill is used as 
%          soon as the property is unique, so DAT.yna is the same as 
%          DAT.OutputName etc.
%
%          For frequency domain data, the property Frequency contains the
%          frequency vector and the property Unit defines the frequency
%          unit.
%
%          To assign names and units to specific channels use
%          DAT.un(3)={'Speed'} or DAT.uu([3 7])={'Volt','m^3/s'}
%          See IDPROPS IDDATA for a complete list of properties.
%
% Manipulating Channels:
%     An easy way to set and retrieve channel properties is to use
%     subscripting. The subscripts are defined as 
%     DAT(SAMPLES,OUTPUTS,INPUTS), so DAT(:,3,:) is the data object
%     obtained from DAT by keeping all input channels,
%     but only output channel 3. (Trailing ':'s can be omitted so 
%     DAT(:,3,:)=DAT(:,3).)
%     The channels can also be retrieved by their names,so that 
%     DAT(:,{'speed','flow'},[]) is the data object where the 
%     indicated output channels have been selected and no input
%     channels are selected. Moreover
%     DAT1(101:200,[3 4],[1 3]) = DAT2(1001:1100,[1 2],[6 7])
%     will change samples 101 to 200 of output channels 3 and 4 and
%     input channels 1 and 3 in the iddata object DAT1 to the 
%     indicated values from iddata object DAT2. The names and units
%     of these channels will the also be changed accordingly.
%
%     To add new channels, use horizontal concatenation of IDDATA
%     objects:
%     DAT =[DAT1, DAT2];
%     or add the data record directly:  DAT.u(:,5) = U will add a
%     fifth input to DAT.
%     See also IDDATA/SUBSREF, IDDATA/SUBSASGN, and IDDATA/HORZCAT
%
% Non-Equal Sampling:
%     The Property 'SamplingInstants' gives the sampling instants 
%     of the data points. It can always be retrieved by 
%     get(DAT,'SamplingInstants') (or DAT.s) and is then computed
%     from DAT.Ts and DAT.Tstart. 'SamplingInstants' can also be 
%     set to an arbitrary vector of the same length as the data, 
%     so that non-equal sampling can be handled. Ts is then
%     automatically set to [].
%
% Handling Multiple Experiments:
%     The IDDATA object can also store data from separate
%     experiments. The property 'ExperimentName' is used to 
%     separate the experiments. The number of data as well as 
%     the sampling properties can vary from experiment to
%     experiment, but the number of input and output channels 
%     must be the same. (Use NaN to fill unmeasured channels in 
%     certain experiments.)
%     The data records will be cell arrays, where the cells
%     contain data from each experiment.
%     Multiple experiments can be defined directly by letting the
%     'y' and 'u' properties as well as 'Ts' and 'Tstart' be cell 
%     arrays.
%     It is easier to merge two experiments by
%     DAT = MERGE(DAT1,DAT2). (See HELP IDDATA/MERGE)
%     Particular experiments can be retrieved by the command GETEXP:
%     GETEXP(DAT,3) is experiment number 3 and GETEXP(DAT,{'Day1','Day4'}) retrieves
%     the two experiments with the indicated names.
%     Particular experiments can also be addressed by a fourth index to DAT as in
%     
%     DAT1 = DAT(Samples,Outputs,Inputs,Experiments).
%     See also IDDATA/SUBSREF and IDDATA/SUBSASGN.
 

%

%   Copyright 1986-2003 The MathWorks, Inc.
%   $Revision: 1.20.4.1 $  $Date: 2004/04/10 23:15:53 $

ni = nargin;
if ni & isempty(varargin{1}) % To allow for u = iddata([],u), u iddata
   if ni==2&isa(varargin{2},'iddata')
      if size(varargin{2},'ny')==0
         dat = varargin{2};
         return
      end
   end
end

if ni & isa(varargin{1},'iddata')
   % Quick exit  
   if ni==2 % forgiving syntax  dat = iddata(y,u) with y and u
      %iddata objects will be allowed.
      if isa(varargin{2},'iddata')
         if size(varargin{1},'nu')==0&size(varargin{2},'ny')==0
            dat = horzcat(varargin{1},varargin{2});
            return
         end
      end
   else
      dat = varargin{1};
      if ni>1,
         error('Use SET to modify the properties of IDDATA objects.');
      end
      return
   end
end

dat = ...
   struct('Domain','Time','Name',[],...
   'OutputData',{{[]}},'OutputName',{{}},'OutputUnit',{{}},...
   'InputData',{{[]}},'InputName',{{}},'InputUnit',{{}},...
   'Period',[],'InterSample',{''},...
   'Ts',{{1}},'Tstart',{{[]}},'SamplingInstants',{{[]}},'TimeUnit',{''},...
   'ExperimentName',{{}},'Notes',[]','UserData',[],'Version','1.0','Utility',[]);

% Dissect input list

DoubleInputs = 0;
PVstart = 0;
while DoubleInputs < ni & PVstart==0,
   nextarg = varargin{DoubleInputs+1};
   if isstr(nextarg) | ...
         (~isempty(nextarg) & iscellstr(nextarg)),
      PVstart = DoubleInputs+1;  
   else
      DoubleInputs = DoubleInputs+1;
   end
end
% Process numerical data 
if ni==0
   y=[];
end

%switch DoubleInputs,
if DoubleInputs > 0
   % Ouput only 
   [Value,error_str] = datachk(varargin{1},'OutputData');
   error(error_str)
   dat.OutputData=Value; y = Value;
   varargin=varargin(2:end);
   if DoubleInputs > 1
      [Value,error_str] = datachk(varargin{1},'InputData');
      error(error_str)
      dat.InputData=Value;
      varargin=varargin(2:end);
      if DoubleInputs > 2
         [Value,error_str] = datachk(varargin{1},'Ts');    
         error(error_str)
         for kk = 1:length(Value)
            if length(Value{kk})>1|Value{kk}<=0 % Check also the others
               error('The sampling interval must be a positive number or the empty matrix')
            end
         end
         dat.Ts=Value; 
         varargin=varargin(2:end);
      end
   end
else
   y = [];
end

dat = class(dat,'iddata');
dat = timemark(dat,'c');
% Finally, set any PV pairs
if isempty(varargin)
   try
      dat = pvset(dat,'OutputData',y); % This is to force the consistency checks
   catch
      error(lasterr)
   end
end

if ni&~isempty(varargin)
   try
      set(dat,'OutputData',y,varargin{:})
   catch
      error(lasterr)
   end
end
