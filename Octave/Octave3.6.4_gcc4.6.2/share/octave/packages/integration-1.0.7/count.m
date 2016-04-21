global NUM_COUNT

if ( exist('NUM_COUNT') == 1)
  NUM_COUNT=NUM_COUNT+length(x(:));
else
  NUM_COUNT=length(x(:));
endif
