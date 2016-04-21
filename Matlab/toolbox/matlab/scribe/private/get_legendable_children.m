function ch=get_legendable_children(ax, includeImages)

% Copyright 2004 The MathWorks, Inc.

if isprop(handle(ax),'legendableChildren')
    legkids = get(handle(ax),'legendableChildren');
    legkids = legkids(:);
else
    legkids = get(ax,'Children');
end

goodkid = true(length(legkids),1);
% v6-style scatter uses a special mechanism for legend
scattergrouplist = []; 

for k=1:length(legkids)
  h = legkids(k);
  goodkid(k) = graph2dhelper('islegendable',h,includeImages);
  if goodkid(k) && isappdata(h,'scattergroup')
    scattergroup = getappdata(h,'scattergroup');
    if gotscattergroup(scattergrouplist,scattergroup)
      goodkid(k) = false;
    else
      scattergrouplist(end+1) = scattergroup;
    end
  end
end

ch = flipud(legkids(goodkid));
