function xx = constlay(k, flag)
% CONSTLAY Layout the constellation for square QASK.
%     X = CONSTLAY(K) is an internal utility function.

%   Copyright 1996-2003 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $

if nargin < 2
  flag = 0;
end
a = [1, 0;3, 2];
b = a;
xx = a;
k = k - 2;

while k >= 1
  xx = subconstlay(xx);
  k = k - 2;
end

[leny, lenx] = size(xx);
if k < 0
  xx = xx(1:lenx/2, :);
  [leny, lenx] = size(xx);
  if lenx >= 4
    xx = [xx(:, lenx/2:lenx), xx(:, 1:lenx/2-1)];
  end
  if lenx >= 8
    xx = [xx(lenx/4+2:lenx/2, :); xx(1:lenx/4+1, :)];
    if flag
      appd = NaN*ones(lenx/8, lenx/8);
      xx = [appd xx(:, 1:lenx/8)' appd; ...
            xx(:, lenx/8+1 : lenx - lenx/8);...
            appd xx(:, lenx - lenx/8 + 1 : lenx)' appd];
    else
      % for the simulink use. This is to make up the conner.
      [appd1, appd] = meshgrid(xx(1, lenx/8+1:lenx/4), xx(1, 1:lenx/8)');
      appd1 = tril(appd1) + triu(appd) - diag(diag(appd));
      [appd2, appd] = meshgrid(xx(1, lenx-lenx/4+1:lenx-lenx/8)',...
                               xx(leny, 1:lenx/8));
      appd2 = flipud(appd2);
      appd = flipud(appd);
      appd2 = tril(appd) + triu(appd2) - diag(diag(appd));
      appd2 = flipud(appd2);
      [appd3, appd] = meshgrid(xx(leny, lenx/8+1:lenx/4),...
                               xx(1, lenx-lenx/8+1:lenx)');
      appd3 = fliplr(appd3);
      appd  = fliplr(appd);
      appd3 = tril(appd) + triu(appd3) - diag(diag(appd));
      appd3 = fliplr(appd3);
      [appd4, appd] = meshgrid(xx(leny, lenx-lenx/4+1:lenx-lenx/8)',...
                               xx(leny, lenx-lenx/8+1:lenx));
      appd4 = tril(appd) + triu(appd4) - diag(diag(appd));
      xx = [appd1 xx(:, 1:lenx/8)' appd2; ...
            xx(:, lenx/8+1 : lenx - lenx/8);...
            appd3 xx(:, lenx - lenx/8 + 1 : lenx)' appd4];
    end
  end
else
  if lenx >= 4
    xx = [xx(:, lenx/2:lenx), xx(:, 1:lenx/2-1)];
    xx = [xx(lenx/2+2:lenx, :); xx(1:lenx/2+1, :)];
  end
end

% verify the correctness To have it turned on, change "if 0" to "if 1"
if 0 && (k >=0)
  for i = 1 : length(xx)-1
    for j= 1 : length(xx)-1
      zz = [sum(de2bi(bitxor(xx(i,j), xx(i, j+1)))); ...
          sum(de2bi(bitxor(xx(i,j), xx(i+1, j))))];
      yy = max(zz);
      if yy > 1
        fprintf('When i = %d and j = %d, the distance is > 1\n', i, j);
      end
    end
  end
end
% end of constlay

% The basic building function.
function xx = subconstlay(a)
b = [1, 0;3, 2];
for i = 1 : 2
  for j = 1 : 2
    bb{i,j} = fliplr(de2bi(b(i,j), 2));
    aa{i,j} = a;
  end
end

for i = 1 : 2
  for j = 1 : 2
    if bb{i, j}(1) == 1
      aa{i, j} = flipud(aa{i,j});
    end
    if bb{i,j}(2) == 1
      aa{i, j} = fliplr(aa{i, j});
    end
  end
end

mul = max(max(aa{1,1}))+1;
xx = [aa{1, 1}+b(1,1)*mul, aa{1, 2}+b(1,2)*mul; ...
      aa{2, 1}+b(2,1)*mul, aa{2, 2}+b(2,2)*mul];
%end of subconstlay
