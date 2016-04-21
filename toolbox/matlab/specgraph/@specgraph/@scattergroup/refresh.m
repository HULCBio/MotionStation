function refresh(this)
%REFRESH Refresh scatter plot
  
%   Copyright 1984-2004 The MathWorks, Inc.

is3D = ~isempty(this.zdata);

if ~strcmp(this.dirty,'clean')
  
  [x,y,s,c] = deal(this.xdata,this.ydata,...
                     this.sizedata,this.cdata);
  if is3D
    z = this.zdata;
  end
  
  if ~is3D && strcmp(this.Jitter,'on')
    x = x + (rand(size(x))-0.5)*(2*this.JitterAmount);
  end

  if ~isempty(this.children)
    delete(this.children);
  end

  % check for scalar sizedata, cdata or colorspec
  if (length(s) == 1)
    s = repmat(s,length(x),1);
  end

  msg = [];
  constantcolor = false;
  if size(c,1) == 1
    if size(c,2) ~= 3
      c = c(:);
    else
      constantcolor = true;
    end
  end
  if ~any(size(c,2) == [1 3])
    msg = 'CData must be a ColorSpec, vector or N-by-3 matrix.';
  end
  if constantcolor, color = c; end
  mfc = get(this,'MarkerFaceColor');
  mec = get(this,'MarkerEdgeColor');

  if (length(s) == 1)
    s = s(1:length(x));
  end
    
  if (length(x) ~= length(y)) || ...
        ((length(x) ~= size(c,1)) && ~constantcolor) || ...
        (length(x) ~= length(s)) || isempty(x)
    msg = 'data length must match';
  end
  
  if is3D && length(x)~=length(z)
    msg = 'data length must match';
  end
  
  if ~isempty(msg)
    this.dirty = 'inconsistent';
  else

    % strip out nan data
    nani = isnan(x(:)) | isnan(y(:)) | isnan(s(:));
    if is3D, nani = nani | isnan(z(:)); end
    nani = ~nani;
    x = x(nani);
    y = y(nani);
    s = s(nani);
    if is3D, z = z(nani); end
    if ~constantcolor, c = c(nani,:); end
  
    if length(x) > 100 && (constantcolor || size(c,2) == 1)

      % if there aren't a small number of points then group them
      % into a single patch according to marker size. This speeds
      % up rendering and shrinks the memory footprint. It means
      % however that the sizes are rounded to integers, which
      % might affect very high resolution rendering.

      sint = ceil(s); 

      % get list of distinct sizes
      s2 = sint(1);
      count = 1;
      for k = 2:length(sint)
        ind = find(sint(k) == s2);
        if isempty(ind)
          s2 = [s2 sint(k)];
          count = [count 1];
        else
          count(ind) = count(ind)+1;
        end
      end

      % pre-allocate size lists
      for k = 1:length(s2)
        xi{k} = zeros(count(k),1);
        yi{k} = zeros(count(k),1);
        if is3D
          zi{k} = zeros(count(k),1);
        end
        if ~constantcolor
          ci{k} = zeros(count(k),size(c,2));
        end
      end

      % fill each size list
      for k = 1:length(sint)
        ind = find(sint(k) == s2);
        xi{ind}(count(ind)) = x(k);
        yi{ind}(count(ind)) = y(k);
        if is3D
            zi{ind}(count(ind)) = z(k);    
        end 
        if ~constantcolor
          ci{ind}(count(ind),:) = c(k,:);
        end
        count(ind) = count(ind)-1;
      end

      % make patches for each size
      for k = 1:length(xi)
        if ~constantcolor
          color = ci{k};
        end
        if is3D
          verts = [xi{k},yi{k},zi{k}];
        else
           verts = [xi{k},yi{k}];
        end
        p = patch('Parent',double(this),...
                  'HitTest','off',...
                  'Vertices',verts,...
                  'Faces',1:size(xi{k},1),...
                  'FaceVertexCData',color,...
                  'FaceColor','none',...
                  'EdgeColor','none',...
                  'MarkerFaceColor',mfc,...
                  'MarkerEdgeColor',mec,...
                  'Marker',get(this,'Marker'),...
                  'MarkerSize',sqrt(sint(k)));
        % painters doesn't support RGB cdata
        if constantcolor
          if strcmp(mfc,'flat')
            set(p,'MarkerFaceColor',color);
          end
          if strcmp(mec,'flat')
            set(p,'MarkerEdgeColor',color);
          end
          set(p,'FaceVertexCData',[]);
        end
      end
    else % use one patch per vertex
      for k = 1:length(x)
        if ~constantcolor
          color = c(k,:);
        end
        if is3D
          verts = [x(k),y(k),z(k)];
        else
          verts = [x(k),y(k)];
        end
        p = patch('Parent',double(this),...
                  'HitTest','off',...
                  'Vertices',verts,...
                  'Faces',1,...
                  'FaceVertexCData',color,...
                  'FaceColor','none',...
                  'EdgeColor','none',...
                  'MarkerFaceColor',mfc,...
                  'MarkerEdgeColor',mec,...
                  'Marker',get(this,'marker'),...
                  'MarkerSize',sqrt(s(k)));
        % painters doesn't support RGB cdata
        if constantcolor
          if strcmp(mfc,'flat')
            set(p,'MarkerFaceColor',color);
          end
          if strcmp(mec,'flat')
            set(p,'MarkerEdgeColor',color);
          end
          set(p,'FaceVertexCData',[]);
        end
      end
      
    end

    this.dirty = 'clean';
    update(this);
    setLegendInfo(this);
  end
end

