function private_set_string(hThis,str)

hTextbox = get(hThis,'TextBoxHandle');
if ishandle(hTextbox)
   set(hTextbox,'String',str);
end