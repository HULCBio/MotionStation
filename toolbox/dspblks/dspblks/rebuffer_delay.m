function D = rebuffer_delay(varargin)
% REBUFFER_DELAY returns the number of samples of delay introduced 
%   by buffering and unbuffering operations.
%
%   D = REBUFFER_DELAY(F,N,V) returns the number of samples of delay
%   for given input buffer size, F, and output buffer size, N, with
%   V overlapped samples in multitasking mode. 
%
%   D = REBUFFER_DELAY(F,N,V,'singletasking') returns the number of 
%   samples of delay in singletasking mode. 

%   Copyright 1995-2002 The MathWorks, Inc.
%   $Revision: 1.9 $  $Date: 2002/04/14 20:53:23 $

[F, N, V, taskflag, msg] = parseArgs(varargin{:});
error(msg);

D = computeLatency(F,N,V,taskflag);


% --------------------------------------------------------
function [F, N, V, taskidx, msg] = parseArgs(F,N,V,varargin)
% parseArgs Parse input arguments and perform error checking.

taskidx = [];

msg = nargchk(3,4,nargin);
if ~isempty(msg), return; end

if isempty(varargin)
   taskstr = 'multitasking';
else
   taskstr = varargin{1};
end

% Check that input arguments are valid:
if ( (~isnumeric(F)) | ~isnumeric(N) | (F <= 0) | (N <= 0) | (fix(F) ~= F) |(fix(N) ~= N) ),
   msg = 'Buffer sizes must be real positive integers.';
   return
end

if (~isnumeric(V) | (fix(V) ~= V)),
   msg = 'Overlap must be a real integer.';
   return
end

if ( ~isstr(taskstr) ),
   msg = 'Tasking flag must be string with either ''singletasking'' or ''multitasking''.';
   return
end

if (V>=N),
   msg = 'Overlap (V) must be less than output buffer size (N).';
   return
end

if (F>N) & (V<0),
   % Unbuffering
   msg = 'Underlap is not supported when unbuffering.';
   return;
end

% Underlap is mapped to no overlap to determine delay:
if (V<0),
   V=0;
end


% Tasking string:
taskidx = strmatch(lower(taskstr),{'singletasking','multitasking'});

if (isempty(taskidx) | (length(taskidx)>1))
   msg = 'Tasking string must be either ''singletasking'' or ''multitasking''.';
   return
end


% --------------------------------------------------------
function D = computeLatency(F,N,V,taskidx)

%
% Single-rate mode (regardless of tasking mode):
%
if ((F == N) & (V == 0)),  
    D = 0;
elseif (F == (N-V)),           
    D = N-V;

else
    %
    % Multi-rate mode (tasking mode matters):   
    %
   if (taskidx == 1),
      % Single-Tasking mode
      if ((V==0) & (F>N) & (mod(F,N)==0)),
         D = 0;
      else
         if (V > 0),
            D = N + V;
         else
            D = N;
         end
      end
   else
      % Multi-Tasking mode
      
      % Determine delay:
      if (F<=N),
         % Buffering mode:
         D = N+V;
      else
         % Unbuffering mode:
         if (V==0),
            % No overlap:
            if mod(F,N), % if (nonzero, i.e., not modular)
               D = F+N;
            else
               D = F;   
            end
         else
            % Overlap:
            % B is a vector containing the initial conditions
            % (i.e. the nonoverlapped samples of delay). 
            % Determine the number of samples of delay without overlap:
            if mod(F,N), 
               B = F+N-V;
            else
               B = F;
            end
            
            % Create a matrix of N columns (rows undetermined for now), 
            % filling the rows with the N elements from B and overlap 
            % V samples on the next row. 
            
            % Read the first N samples from B and fill the first row.
            % Overlap V samples on the next row:
            B = B-N;
            D = N+V; 
            
            while (B > 0)
               % Determine the number of elements left in the row (nsamps)
               % and check that there's at least nsamps left in B.
               nsamps = ceil(D/N)*N - D;  
               if (nsamps <= B)
                  % Since a row is filled, we can overlap the data in the
                  % next row.
                  D = D + nsamps + V;
                  B = B - nsamps;
               else
                  % If there's not nsamps left in B, then read the rest of
                  % B, but don't overlap since we didn't complete a row.
                  D = D + B;
                  B = 0;
               end
            end
         end
      end
   end
end   
   

%[EOF] rebuffer_delay.m