function plant = imp2step(delt,nout,theta1,theta2,theta3,theta4,theta5,...
			  theta6,theta7,theta8,theta9,thetalO,thetall,...
			  thetal2,thetal3,thetal4,thetal5,thetal6,...
			  thetal7,thetal8,thetal9,theta20,theta21,...
			  theta22,theta23,theta24,theta25)
%IMP2STEP Generate step response model from impulse response coefficients.
% 	plant = imp2step(delt,nout,theta1,theta2, ...)
%
% Inputs:
%  delt: sampling time used for obtaining impulse response coefficients.
%  nout: output stability indicator. For stable systems, this argument
%	 is set equal to number of outputs, ny. For systems with one
%	 or more integrating outputs, this argument is a column vector
%	 of length ny with nout(i)=O indicating an integrating output
%	 and nout(i)=1 indicating a stable output.
%  theta1, theta2, ...: impulse response coefficient matrices for output
%	 1, 2, ...  Max. number of thetas which can be supplied is 25.
%
% Output:
%  plant: the step response coefficient matrix of dimension (n*ny+ny+2)
%	  by nu, where n is number of coefficients for each input, and
%	  ny are number of input and output, respectively.
%
% See also MLR, PLSR.

%     Copyright 1994-2003 The MathWorks, Inc.
%       $Revision: 1.1.6.2 $

if nargin == 0,
   disp('Usage: plant = imp2step(delt,nout,theta1,theta2,...)')
   return
end
if nargin < 3,
   error('Too few input arguments!');
   return
end
noutput = nargin - 2;
if length(nout) == 1
   if nout <= 0
      noutind=0;
	  ny=1;
   else
      noutind = ones(nout,1);
      ny = nout;
   end
else
   noutind = nout(:);  % NOTE:  allows nout to be row vector
   ny = length(nout);
end
if ny ~= noutput,
   error('Total number of thetas must equal either nout or length(nout)');
   return
end
[nrt,nct] = size(theta1);
plant = zeros(nrt*noutput+ny+2,nct);
% Calculate step response coefficients & set up the step response
% matrix for MPC design.
for i = 1:noutput
   istring = ['theta',int2str(i)];
   [nrtn,nctn] = size(eval(istring));
   if nrt ~= nrtn
      error('Rows of thetas are inconsistent!');
   end
   if nct ~= nctn
      disp(['theta1 has ',int2str(nrt),' columns while ',istring,...
	        ' has ',int2str(nctn),' columns.']);
      error('Number of column for each theta must be the same!');
      return
   end
   temp = cumsum(eval(istring));
   if nrt <= nrtn
      temp1 = temp(1:nrt,:);
   else
      temp1 = temp;
      temp1(nrtn:nrt,:) = ones(nrt-nrtn,1)*temp(nrtn,:);
   end
   for j = 1:nrt
      plant(noutput*(j-1)+i,:) = temp1(j,:);
   end
end
plant(j*noutput+1:j*noutput+ny+2,1) = [noutind; ny; delt];

% End of function imp2step.