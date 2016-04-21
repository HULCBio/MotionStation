function [x,StateSequence,OverflowsPerStep,Hq] = statesequencefilter(Hq,x,zi)
%STATESEQUENCEFILTER  Filter and return state sequence 
%   [Y, STATESEQUENCE] = STATESEQUENCEFILTER(Hq, X, ZI) filters vector X with
%   quantized filter Hq, and initial conditions ZI, and returns the output of
%   the filter Y, and the sequence of states at every time step in cell-array
%   STATESEQUENCE (one element per filter section, one column per time step).
%   The final conditions of the Kth filter section are in the last column of
%   STATESEQUENCE{K}: ZF{K} = STATESEQUENCE{K}(:,end).  The initial conditions
%   of the Kth filter section are in the first column of STATESEQUENCE{K}: 
%   ZI{K} = STATESEQUENCE{K}(:,1).
%
%   If ZI is missing or empty [], then zero initial conditions are used.
%
%   [Y, STATESEQUENCE, OVERFLOWSPERSTEP] = STATESEQUENCEFILTER(...) also returns
%   the number of overflows at each time step of the filter in cell array
%   OVERFLOWSPERSTEP.  The overflows of the Kth section are in
%   OVERFLOWSPERSTEP{K}.
%
%   Example:
%     A = [-1 -1; 0.5 0];
%     B = [0; 1];
%     C = [1 0];
%     D = 0;
%     Hq = qfilt('statespace',{A,B,C,D},'OverFlowMode','Wrap');
%     x = zeros(20,1);
%     zi = [0.25 1.8];
%     [y, StateSequence, OverflowsPerStep] = statesequencefilter(Hq,x,zi);
%     plot(StateSequence{1}(1,:), StateSequence{1}(2,:),'-o')
%     axis([-2 2 -2 2]); axis square; grid
%     title('State Sequence: Note Overflow Limit Cycle behavior.')
%
%   See also QFILT, QFILT/FILTER, QFILT/LIMITCYCLE.

%   Thomas A. Bryan, 21 July 1999
%   Copyright 1999-2003 The MathWorks, Inc.
%   $Revision: 1.13.4.2 $  $Date: 2004/04/12 23:26:02 $

nargchk(2,3,nargin);
nargoutchk(0,3,nargout);

% Set default inputs, if necessary, and validate all inputs.
if ~isnumeric(x) | ~privisvector(x)
  error('X must be a numeric vector.')
end
InputLength = length(x);
if ~strcmpi(class(Hq),'qfilt')
  error('Hq must be a QFILT object.');
end
if nargin<3
  zi = [];
end

% Get filter attributes.
nsections = numberofsections(Hq);
nz = statespersection(Hq);
fstruct = filterstructure(Hq);
[qcoefficient,qinput,qoutput,qmultiplicand,qproduct,qsum] = quantizer(Hq,...
    'coefficient','input','output','multiplicand','product','sum');
% Reset all but the coefficient quantizer
reset(qinput,qoutput,qmultiplicand,qproduct,qsum);
coeff = quantizedcoefficients(Hq);
if isnumeric(coeff{1})
  coeff = {coeff};
end

zicell = ziexpand(zi,1,nz,nsections);
StateSequence = cell(size(zicell));
OverflowsPerStep = cell(1,nsections);

% Quantize the input
x = quantize(qinput,x);

% Make sure that the scalevalues are set correctly.
[msg,scalevalues] = scalevaluescheck(Hq);
error(msg)

% Only scale if scalevalues are not empty and this scale value is not
% exactly equal to 1.
if ~isempty(scalevalues) & scalevalues(1)~=1
  x = quantize(qproduct,scalevalues(1)*quantize(qmultiplicand,x));
end


% For every section of the filter, create Java objects for the filter and the
% initial state for the section, filter with the C++ filter
% and record the output of each section.
for section = 1:length(zicell)
  [n1,n2] = privfiltparams(coeff{section},fstruct);   
  % Zero pad the initial conditions for the temporary states that are used by
  % the C++ filters

  % Execute the filter.
  [x,z,v] = privfilter(coeff{section},x(:),zicell{section},fstruct, ...
      qcoefficient, qinput, qoutput, qmultiplicand, qproduct, qsum) ;
  
  if length(scalevalues)>=section+1 & scalevalues(section+1)~=1
      % Only scale if there are enough scale values and this scalevalue is not
      % exactly equal to 1.
      x = quantize(qproduct,scalevalues(section+1)*quantize(qmultiplicand,x));
  end
  
  OverflowsPerStep{section} = v;
  StateSequence{section} = z;
end

% Quantize the output
x = quantize(qoutput,x);

