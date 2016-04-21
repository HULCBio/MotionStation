// $Revision: 1.4.8.1 $ $Date: 2004/03/16 18:33:16 $

function initialize() {
   // 800,616 is the size of the object.
   // +20 is slop to prevent scrollbars on Mozilla on Linux.
   var wantedWidth = 800+20;
   var wantedHeight = 616+20;
   // Mozilla measures the rendering area, but IE measures the whole window.
   // This sets the size based on rendering area for both.
   var dWidth = window.innerWidth || document.body.clientWidth;
   var dHeight = window.inneHeight || document.body.clientHeight;
   resizeBy(wantedWidth-dWidth,wantedHeight-dHeight);
}