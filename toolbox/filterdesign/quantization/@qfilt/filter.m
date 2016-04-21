function [x,zf, s, z, v] = filter(Hq,x,zi,dim)
%FILTER Quantized digital filter.
%   Y = FILTER(Hq,X) filters the real or complex input data X using quantized
%   filter object Hq.  Hq defines the filter to be used and Y is the filtered
%   data.  Vectors Y and X are of equal length.
%
%   If X is a matrix, FILTER operates on the columns of X.  If X is an
%   N-dimensional array, FILTER operates along the first non-singleton
%   dimension.
%
%   [Y,Zf] = FILTER(Hq,X,Zi) gives access to initial and final states, Zi and
%   Zf, of the delays.  Zi and Zf are required to conform to the filter
%   structure specified in Hq.  Zi can be described as follows:
%
%      All cases:
%         - If no Zi is specified, then zero initial conditions are used.
%           This is equivalent to passing Zi as [] or {}.
%         - If Zi is a scalar, then the value is used for all states in all
%           sections.
%
%      Single sections:
%         - Zi can be a vector with length equal to the number of states Ns.
%         - Zi can be a matrix of size Ns-by-D, where D is the number of
%           filtered data vectors.  This is useful when X is an N-dimensional
%           array.  
%
%      Cascaded sections:
%         - Zi can be a 1-by-N cell of vectors each with length Ns, where N
%           is the number of sections and Ns is the number of states in the
%           section. 
%         - Zi can be a 1-by-N cell of Ns-by-D matrices, where D is the
%           number of filtered data vectors.
%         - Zf returned will be a 1-by-N cell array of final condition
%           vectors, each of size Ns-by-D where D is the number of filtered
%           data vectors. 
%
%   * Ns is determined by Hq's StatesPerSection property.
%   * N is determined by Hq's NumberOfSections property.
%
%   [Y, Zf, S] = FILTER(Hq,X,...) also returns a MATLAB structure S
%   containing quantization information.  See QREPORT for details.
%
%   [Y, Zf, S, Z, V] = FILTER(Hq,X,...) also returns the state sequence Z, and
%   the number of overflows at each time step of the filter V.  With four or
%   five output arguments, the input X must be a vector.  Z is a cell array
%   containing the sequence of states at every time step (one element per filter
%   section, one column per time step).  The final conditions of the Kth filter
%   section are in the last column of Z{K}: ZF{K} = Z{K}(:,end).  The initial
%   conditions of the Kth filter section are in the first column of Z{K}: ZI{K}
%   = Z{K}(:,1).  The overflows of the Kth section are in V{K}.
%
%   FILTER(Hq,X,[],DIM) 
%   FILTER(Hq,X,Zi,DIM) operates along the dimension DIM of X.
%
%   Unlike MATLAB's built-in double-precision filter function, this quantized
%   filter function does not normalize the filter coefficients.
%
%   Examples:
%
%   % Filtering a signal.
%     Fs = 100;                         % Sampling Frequency
%     t = (1:100)/Fs;                   % Time
%     f = [ 2; 15; 25];                 % Frequencies
%     A = [.5  .9  .8];                 % Amplitudes
%     x = A*sin(2*pi*f*t);              % Signal
%   % Design the reference coefficients:
%     [b,a] = ellip(4,0.1,40,[10 20]*2/Fs);
%   % Design a fixed-point quantized filter:
%     Hq = qfilt('df2', {b a});
%     setbits(Hq,[32 15])
%   % Filter out 2 and 25 Hz sinusoids.  Then plot and compare:
%     y = filter(Hq,x);
%     plot(t,[x; y])
%     legend('Original signal','Filtered signal')
%
%   % Example of a limitcycle.
%     A = [-1 -1; 0.5 0];
%     B = [0; 1];
%     C = [1 0];
%     D = 0;
%     Hq = qfilt('statespace',{A,B,C,D},'quantizer',{'wrap',[32 30]});
%     x = zeros(20,1);
%     zi = [0.25 1.8];
%     [y, zf, s, z, v] = filter(Hq,x,zi);
%     plot(z{1}(1,:), z{1}(2,:),'-o')
%     axis([-2 2 -2 2]); axis square; grid
%     title('State Sequence: Note Overflow Limit Cycle behavior.')
%
%   See also QFILT/IMPZ, QFILT/FREQZ, QFILT/ZPLANE, QREPORT.

%   Thomas A. Bryan
%   Copyright 1999-2003 The MathWorks, Inc.
%   $Revision: 1.35.4.2 $  $Date: 2004/04/12 23:25:08 $

  error(nargchk(2,4,nargin))
  error(nargoutchk(0,5,nargout))


  % Check for cell data:
  if ~isnumeric(x)
    error('X must be numeric.')
  end
  if nargin<3
    zi=[];
  end

  % State sequence filtering
  if nargout>3  % [x,zf,s,z,v] = FILTER(Hq,x,...)
                % State sequence filter.  Bypass regular filtering routine.
                if ~privisvector(x)
                  error('With 4 or 5 output arguments, input X must be a vector.')
                end
                % Initialize hqreport, except for coefficients, which was initialized when
                % the coefficients were entered.
                Hq.report = qreportinit(1,Hq.report.coefficient);
                [x,z,v,Hq] = statesequencefilter(Hq,x,zi);
                zf = cell(size(z));
                for k=1:length(z);
                  zf{k} = z{k}(:,end);
                end
                % Update the report data
                [qcoefficient,qinput,qoutput,qmultiplicand,qproduct,qsum] = quantizer(Hq,...
                                                  'coefficient','input','output','multiplicand','product','sum');
                Hq.report.input(1) = qreportupdate(Hq.report.input(1),qinput);
                Hq.report.output(1) = qreportupdate(Hq.report.output(1),qoutput);
                Hq.report.multiplicand(1) = qreportupdate(Hq.report.multiplicand(1),qmultiplicand);
                Hq.report.product(1) = qreportupdate(Hq.report.product(1),qproduct);
                Hq.report.sum(1) = qreportupdate(Hq.report.sum(1),qsum);
                if ~isempty(inputname(1))
                  assignin('caller',inputname(1),Hq);
                end
                s = Hq.report;
                return
  end    % State sequence filtering

  % Verify that DIM is ok
  if nargin<4
    dim=[];
  end
  if ~isempty(dim) & ~(isscalar(dim) & fix(dim)==dim)
    error('DIM must be empty or a scalar integer.');
  end
  if ~isempty(dim) & dim>ndims(x)
    error('DIM specified exceeds the dimensions of X.')
  end


  if isempty(dim)
    % Work along the first nonsingleton dimension
    [x,nshifts] = shiftdim(x);
  else
    % Put DIM in the first dimension (this matches the order that the built-in
    % filter uses - attfcn:mfDoDimsPerm)
    perm = [dim,1:dim-1,dim+1:ndims(x)];
    x = permute(x,perm);
  end

  % The number of data vectors that we will filter over
  sizx = size(x);
  ndata = prod(sizx(2:end));

  % Expand initial conditions zi, and prepare to overwrite them with the final 
  % conditions zf.
  nsections = get(Hq,'NumberOfSections');
  statespersection = get(Hq,'StatesPerSection');
  try
    zf = ziexpand(zi,ndata, statespersection, nsections);
  catch
    error(lasterr)
  end

  % Get and reset the quantizer objects
  [qcoefficient,qinput,qoutput,qmultiplicand,qproduct,qsum] = quantizer(Hq,...
                                                  'coefficient','input','output','multiplicand','product','sum');
  reset(qinput, qoutput, qmultiplicand, qproduct, qsum);
  % Initialize hqreport, except for coefficients, which was initialized when
  % the coefficients were entered.
  Hq.report = qreportinit(nsections,Hq.report.coefficient);

  % Don't warn until the end
  warnmode = warning;
  warning off

  % Get and quantize the coefficients.  We quantize the coefficients here so
  % the coefficient quantizer states will be set.
  coeffs = get(Hq, 'QuantizedCoefficients');
  if isnumeric(coeffs{1})
    % Wrap single section into a cell array so single and multiple sections are
    % treated the same.
    coeffs = {coeffs};
  end

  % Make sure that the scalevalues are set correctly.
  [msg,scalevalues] = scalevaluescheck(Hq);
  error(msg)

  % Quantize the input, and scale.
  x = quantize(qinput, x);

  % Only scale if scalevalues are not empty and this scale value is not
  % exactly equal to 1.
  if ~isempty(scalevalues) & scalevalues(1)~=1
    x = quantize(qproduct,scalevalues(1)*quantize(qmultiplicand,x));
  end
  Hq.report.input(1) = qreportupdate(Hq.report.input(1),qinput);
  Hq.report.multiplicand(1) = qreportupdate(Hq.report.multiplicand(1),qmultiplicand);
  Hq.report.product(1) = qreportupdate(Hq.report.product(1),qproduct);
  
  filterstructure = get(Hq,'FilterStructure');
  for jsection = 1:nsections
    reset(qmultiplicand, qproduct, qsum)
    % The C++ filter handles data with multiple columns.
    [x,zf{jsection}] = privfilter(coeffs{jsection}, ...
                                  x, zf{jsection}, filterstructure, ...
                                  qcoefficient,qinput,qoutput,qmultiplicand,qproduct,qsum);      
    if length(scalevalues)>=jsection+1 & scalevalues(jsection+1)~=1
      % Only scale if there are enough scale values and this scalevalue is not
      % exactly equal to 1.
      x = quantize(qproduct,scalevalues(jsection+1)*quantize(qmultiplicand,x));
    end
    Hq.report.multiplicand(jsection) = qreportupdate(Hq.report.multiplicand(jsection),qmultiplicand);
    Hq.report.product(jsection) = qreportupdate(Hq.report.product(jsection),qproduct);
    Hq.report.sum(jsection) = qreportupdate(Hq.report.sum(jsection),qsum);
  end

  % Quantize the output
  x = quantize(qoutput,x);
  Hq.report.output = qreportupdate(Hq.report.output,qoutput);

  % Convert back to the original shape
  if isempty(dim)
    x = shiftdim(x, -nshifts);
  else
    x = ipermute(x,perm);
  end

  % Assign optional output parameters
  if nargout>=3
    s = Hq.report;
  end

  % Report overflows
  nover = countoverflows(Hq.report);
  warning(warnmode)
  wrec = warning('query', 'FilterDesign:Qfilt:Overflows');
  if nover>0 & ~strcmpi(wrec.state, 'off')
    warning('FilterDesign:Qfilt:Overflows', ...
            '%s overflows in QFILT/FILTER.', num2str(nover));
    qfiltlog(Hq.report);
  end

  if ~isempty(inputname(1))
    assignin('caller',inputname(1),Hq);
  end
  

function nover = countoverflows(report);
  nover = report.input.nover + ...
          report.output.nover;
  for k=1:length(report.product)
    nover = nover + report.product(k).nover + report.sum(k).nover + ...
            report.coefficient(k).nover;
  end

