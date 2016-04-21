/*
 * File: can_msg.i
 *
 * $Revision: 1.3 $
 * $Date: 2002/11/29 14:02:53 $
 *
 * Copyright 2002 The MathWorks, Inc.
 */

// Enumeration of frame types
enum CanFrameType {CAN_MESSAGE_STANDARD, CAN_MESSAGE_EXTENDED};

#define LEN 8
typedef struct {
   unsigned short LENGTH;
   unsigned short RTR;
   CanFrameType type;
   unsigned int ID;
   unsigned char DATA[LEN];
}  CAN_FRAME;


/* Add some methods to the JAVA class to overload setDATA to allow char and int arrays */
%extend CAN_FRAME {


  %typemap(javacode) SWIGTYPE %{

      public String toString(){
         String s = "";
         int i;
         short [] data = getDATA();
         s = s + data[0];
         for (i=1;i<data.length;i++){
            s = s + ", " + data[i];
         }
         return "CAN_FRAME : length = " + getLENGTH() +
            " : id = " + getID() + " : data = { " + s + " } : type = " + getType(); 
      }
      
      public static CAN_FRAME createXtd(int id){
         CAN_FRAME frame = new CAN_FRAME();
         frame.setID(id);
         frame.setType(VectorCAN.CAN_MESSAGE_EXTENDED);
         frame.setLENGTH(0);
         return frame;
      }

      public static CAN_FRAME createStd(int id){
         CAN_FRAME frame = new CAN_FRAME();
         frame.setID(id);
         frame.setType(VectorCAN.CAN_MESSAGE_STANDARD);
         frame.setLENGTH(0);
         return frame;
      }

      public void setDATA(int data[]) { 
         short tmp[] = new short[data.length];
         for(int i=0;i<data.length;i++){
            tmp[i]=(short)(data[i]);
         } 
         setLENGTH(data.length);
         setDATA(tmp);
      }

      public void setDATA(char data[]) { 
         short tmp[] = new short[data.length];
         for(int i=0;i<data.length;i++){
            tmp[i]=(short)(data[i]);
         } 
         setLENGTH(data.length);
         setDATA(tmp);
      }

      public void setDATA(byte data[]){
         short tmp[] = new short[data.length];
         for(int i=0;i<data.length;i++){
            int p1 = (int) data[i];
            int p2 = (int) 0xff;
            tmp[i]=(short)(p1 & p2);
         } 
         setLENGTH(data.length);
         setDATA(tmp);
      }
   %}
};

