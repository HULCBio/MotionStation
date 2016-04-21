function d = idfrd2iddata(f);
%
% Converts a idfrd object to an iddata object suitable for
% frequency domain estimation 
%

% Copyright 2002 The MathWorks, Inc.
%   $Revision: 1.1.4.1 $  $Date: 2004/04/10 23:18:36 $
resp = pvget(f,'ResponseData');
[p,m,N] = size(resp);
if p*m~=1,
  Y = zeros(N*m,p);
  U = zeros(N*m,m);
  for k =1:m,
    if p~=1, % Problem with squeeze when p==1
      Y((k-1)*N+1:k*N,:) = squeeze(resp(:,k,:)).';
    else
      Y((k-1)*N+1:k*N,:) = squeeze(resp(:,k,:));    
    end
    U((k-1)*N+1:k*N,k) = ones(N,1);
  end
  freq = kron(ones(m,1),pvget(f, 'Frequency'));
else
  freq = pvget(f, 'Frequency');
  Y = resp(:);
  U = ones(length(freq),1);
end
d = iddata(Y,U,'Domain','Frequency');
d = pvset(d,'SamplingInstants',freq); %TM fix
Ts = pvget(f,'Ts');
if Ts==0, %CT-models 
  Ts = 0; % Data has an unspecified sampling time
  for k=1:m,
    is{k} = 'bl';
  end
  d = pvset(d,'InterSample',is');
end
d= pvset(d,'Ts',Ts,...
	 'InputName',pvget(f,'InputName'),...
	 'OutputName',pvget(f,'OutputName'),...
	 'InputUnit',pvget(f,'InputUnit'),...
	 'OutputUnit',pvget(f,'OutputUnit') );

