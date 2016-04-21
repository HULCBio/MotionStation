function varargout=limitcycle(Hq,Ntrials,InputLength,StopCriterion,trace)
%LIMITCYLE  Detect zero-input limit cycles in quantized filter.
%   LIMITCYCLE(Hq) runs 20 Monte Carlo trials with random initial states
%   and zero input vector of length 100 and stops if a zero-input limit
%   cycle is detected in quantized filter Hq.  A string is returned
%   which is one of 'granular' to indicate that a granular overflow
%   occurred; 'overflow' to indicate that an overflow limit cycle
%   occurred; or 'none' to indicate that no limit cycles were detected
%   during the Monte Carlo trials.
%
%   LIMITCYCLE(Hq, NTRIALS, INPUTLENGTH, STOPCRITERION, TRACE) allows
%   you to set
%
%     NTRIALS, the number of Monte Carlo trials (default is 20).
%
%     INPUTLENGTH, the length of the zero vector used as input to the
%     filter (default is 100).
%
%     STOPCRITERION, the stop criterion, a string containing one of
%     'either' (the default), 'granular', 'overflow', or 'none'.  If
%     STOPCRITERION is 'either', then the Monte Carlo trials will stop
%     if either a granular or overflow limit cycle is detected;
%     'granular', stop only if a granular limit cycle was detected;
%     'overflow', stop only if an overflow limit cycle was detected;
%     'none', do not stop until all Monte Carlo trials have been run.
%
%     TRACE displays information at each Monte Carlo trial when TRACE is
%     nonzero.
%
%   If any of the input values are empty ([]), then the default
%   values are used.
%  
%   [LIMITCYCLETYPE, ZI, PERIOD, Z, OVERFLOWSPERSTEP, TRIAL, SECTION] = 
%     LIMITCYCLE(Hq, ...) also returns
%  
%     LIMITCYCLETYPE, one of 'granular' to indicate that a granular
%     overflow occurred; 'overflow' to indicate that an overflow limit
%     cycle occurred; or 'none' to indicate that no limit cycles were
%     detected during the Monte Carlo trials.
%
%     ZI the initial condition that caused the limit cycle.
%  
%     PERIOD an integer indicating the repeat period of the limit cycle
%     (-1 if the filter converged and the last state is zero, 0 if the
%     last state is not zero and no limit cycle was detected).
%   
%     Z is a matrix containing the sequence of states at every time step
%     (one column per time step).  The final conditions are in the last
%     column: ZF = Z(:,end).  The initial conditions are in the first
%     column: ZI = Z(:,1).  If the filter has multiple sections, then Z
%     only pertains to the section that found the limit cycles.
%  
%     OVERFLOWSPERSTEP is a vector of integers that indicates the total
%     number of overflows that occurred during each time step.  The kth
%     element of OVERFLOWSPERSTEP corresponds to the kth column of Z.
%  
%     TRIAL the number of the Monte Carlo trial that was stopped on.
%
%     SECTION is the number of the filter section that caused the limit
%     cycle.  Section numbering starts with 1 at the section closest to
%     the input.
%
%   Only the parameters of the last limit cycle are returned.  If no
%   limit cycles are detected, then the parameters of the last Monte
%   Carlo trial are returned.
%
%   Example:
%     % In this example, there is a region of initial conditions in which no
%     % overflow limit cycles occur, and a region where they do.  If no limit
%     % cycles are found before the Monte Carlo trials are over, then the
%     % state sequence will spiral down to zero.  If a limit cycle is found,
%     % then the states will not end at zero.  Each time the example is run,
%     % it uses a different sequence of random initial conditions.  Sometimes
%     % the state sequence spirals down, but gets stuck slightly away from
%     % zero; in this case, a granular limit cycle has occurred.
%  
%     A = [0 1; -.5 1]; B = [0; 1]; C = [1 0]; D = 0;
%     Hq=qfilt('statespace',{A,B,C,D},'Format',unitquantizer('round','wrap'));
%     [LimitCycleType,Zi,Period,Z,Ovfl,Trial]=limitcycle(Hq,20,50,'either');
%     figure(gcf);plot(Z(1,:), Z(2,:),'.-');
%     text(Z(1,:),Z(2,:),num2str((1:size(Z,2))'))
%     axis([-1 1 -1 1]);axis square;title(LimitCycleType)
%     xlabel('State 1'); ylabel('State 2');
%
%   See also QFILT, QFILT/FILTER, LIMITCYCLEDEMO.

%   Thomas A. Bryan, 22 July 1999
%   Copyright 1999-2002 The MathWorks, Inc.
%   $Revision: 1.16 $  $Date: 2002/04/14 15:30:34 $

error(nargchk(1,5,nargin));
error(nargoutchk(0,7,nargout));

% Set default inputs, if necessary, and validate all inputs.
if ~strcmpi(class(Hq),'qfilt')
  error('Hq must be a QFILT object.');
end
if ~exist('Ntrials','var') | isempty(Ntrials)
  Ntrials=20;
end
if ~isnumeric(Ntrials) | ~isscalar(Ntrials) | fix(Ntrials)~=Ntrials
  error('Ntrials must be a scalar integer');
end
if ~exist('InputLength','var') | isempty(InputLength)
  InputLength=100;
end
if ~isnumeric(InputLength) | ~isscalar(InputLength) | fix(InputLength)~=InputLength
  error('InputLength must be a scalar integer');
end
if ~exist('StopCriterion','var') | isempty(StopCriterion)
  StopCriterion = 'either';
end
[StopCriterion, errmsg]=qpropertymatch(StopCriterion,...
    {'either','granular','overflow','none'});
if ~isempty(errmsg)
  error('Invalid StopCriterion')
end
if ~exist('trace','var') | isempty(trace)
  trace = 0;
end

% Initialize output variables
ziOut = [];
LimitCycleType = 'none';
StateSequenceOut = [];
OverflowsPerStepOut = {};
PeriodOut = [];
sectionOut = [];

% Get filter attributes.
numberofsections = get(Hq,'NumberOfSections');
statespersection = get(Hq,'StatesPerSection');
filterstructure = get(Hq,'FilterStructure');
[qproduct,qsum] = quantizer(Hq,'product','sum');
coeff = get(Hq,'QuantizedCoefficients');
realflag = isreal(Hq);

if sum(statespersection)==0
  warning('This filter has no states and so cannot limit cycle.');
end
warnmode = warning('off');

% If this is a single section, wrap in a cell so single and multiple sections
% look alike.
if isnumeric(coeff{1})
  coeff = {coeff};
end

% Create a cell array of filters, one section per cell
s = get(Hq);
s.scalevalues=[];
h = cell(numberofsections,1);
for k=1:numberofsections
  s.referencecoefficients = coeff{k};
  h{k} = qfilt(s);
end

% Construct the correct format for the initial conditions for this filter. 
zi = ziexpand([],1,statespersection,numberofsections);

% The zero input vector
x = zeros(InputLength,1);

% For each Monte Carlo trial, generate random states and call the
% STATESEQUENCEFILTER to filtering the zero input vector X and return the
% sequence of states for each time step in z.  Examine
% the state sequence for each section of the filter.
%
% The Monte Carlo trials are halted if a limit cycle is found that matches
% the StopCriterion ('either', 'granular', 'overflow').  The Monte Carlo
% trials continue through Ntrials if the StopCriterion is 'none'.
%
% If the trace is nonzero, then the number of the current trial is
% displayed, and if a limit cycle is found, the initial conditions of that
% trial are displayed.
wbar = waitbar(0,sprintf(['LIMITCYCLE calculating.\n',...
      'Close this window to terminate early.']));
drawnow
trialOut=Ntrials;
% The try-catch is to allow early termination of the Monte Carlo trials.  The
% most recent results will be displayed.  The user can either control-c, or
% close the waitbar window.
try
  for trial=1:Ntrials
    if trace~=0
      disp(['Trial ',num2str(trial),' out of ',num2str(Ntrials)])
    end
    zi = randcell(qsum,zi);
    
    for section=1:numberofsections
      [y,z,OverflowsPerStep] = statesequencefilter(...
          h{section},x,zi{section});
      % STATESEQUENCEFILTER returns cell arrays for z, overflows, one per
      % filter section, so they have to be de-referenced because we are only
      % operating over one section.
      z = z{1};
      OverflowsPerStep = OverflowsPerStep{1};
      p = period(z);
      if p>0 
        if sum(OverflowsPerStep(end-p))>0
          LimitCycleType = 'overflow';
        else
          LimitCycleType = 'granular';
        end
        % Store for output
        ziOut = zi{section};
        PeriodOut = p;
        StateSequenceOut = z;
        OverflowsPerStepOut = OverflowsPerStep;
        sectionOut = section;
        trialOut = trial;
        if trace~=0
          limitcycledisplay(LimitCycleType,zi,trial,Ntrials,...
              section,numberofsections);
        end
        if strcmpi(StopCriterion,'either') | ...
              strcmpi(StopCriterion,LimitCycleType) 
          break
        end
      end
    end
    if p>0 & (strcmpi(StopCriterion,'either') | ...
          strcmpi(StopCriterion,LimitCycleType))
      break
    end
    if ~ishandle(wbar)
      % The waitbar has been closed, so terminate the trials.
      break
    end
    waitbar(trial/Ntrials,wbar);
  end
catch
  disp('Early termination of LIMITCYCLE Monte Carlo trials.');
end
% Restore the warning mode
warning(warnmode)
if ishandle(wbar)
  close(wbar)
end

% If a limit cycle was found, return the last one found.  Otherwise, return
% the results of the last Monte Carlo trial
if ~isempty(ziOut)
  % Put the initial condition back in the section in which it belongs.
  zi = ziexpand([],1,statespersection,numberofsections);
  zi{sectionOut} = ziOut; 
  p = PeriodOut;
  z = StateSequenceOut;
  OverflowsPerStep = OverflowsPerStepOut;
end

%Deal the outputs to the varargout cell array.
if nargout>0
  outcell={LimitCycleType,zi,p,z,OverflowsPerStep,trial,sectionOut};
  [varargout{1:max(1,nargout)}] = deal(outcell{1:max(1,nargout)});
else
  limitcycledisplay(LimitCycleType,zi,trialOut,Ntrials,...
      section,numberofsections);
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function c = randcell(q,c)
%RANDCELL  Random cell-array of quantized values
%
%   RANDCELL(Q,C) returns a cell array of uniformly distributed random values
%   the same size as C.  The values are distributed over the range of
%   quantizer object Q, and quantized.
%
%   See also QUANTIZER/RANDQUANT.
for k=1:length(c)
  c{k} = randquant(q,size(c{k}));
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function p = period(x)
%PERIOD  Period of identical columns
%
%   P = PERIOD(X) determines the distance P between the last column of X and the
%   closest identical column.  If the last column of X is 0, then P = -1.  If no
%   other columns of X are equal to the last column, then P = 0.
%
%   This function is used to determine the period of a limit cycle, where the
%   state vectors at each time step are stored in the columns of X.  It works
%   because if there is a limit cycle present, then it will be present at the
%   last time step, and so we do not need to look for any two identical columns,
%   we only need to look for a column that is identical with the last column.

[m,n] = size(x);
a = x(:,end);
if sum(a)==0
  % The last column is 0, so the filter converged.
  p = -1;
  return
end
s = sum(x-a(:,ones(1,n)),1);
i = find(s==0);
if length(i)==1
  % There are no other columns identical to the last column. 
  p = 0;
else
  % A column was found that is identical to the last column. 
  % Record the number of columns between the last and the next closest
  % identical column.
  p = i(end) - i(end-1);
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function limitcycledisplay(LimitCycleType,zi,trial,Ntrials,...
    section,numberofsections)
%LIMITCYCLEDISPLAY Display the progress at the command line if TRACE is true.
if strcmpi(LimitCycleType,'none')
  disp(['No limit cycles detected after ',num2str(trial),' Monte Carlo trials.']);
else
  sectionnote = '';
  if numberofsections>1
    sectionnote = ['in section ',num2str(section),' '];
  end
  disp([upper(LimitCycleType(1)),lower(LimitCycleType(2:end)),...
        ' limit cycle detected ',sectionnote,...
        'on Monte Carlo trial ',...
        num2str(trial),' out of ',num2str(Ntrials)]);
  disp('with initial condition:')
  if length(zi)>1
    disp(['Section ',num2str(section)])
    disp(zi{section})
  else
    disp(zi{1})
  end
end
