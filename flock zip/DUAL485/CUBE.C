/*--------------------------------------------------------------------------*/
/* cube.c                                                                   */
/* draws a cube with xyz axes that follows the birds position/orientation   */
/*--------------------------------------------------------------------------*/
#include <graphics.h>
#include <stdlib.h>
#include <alloc.h>
#include <stdio.h>
#include <stdarg.h>
#include <string.h>
#include <math.h>
#include "asctech.h"

/*
    This Implementation is documented from PAGE 67 of

    PROGRAMMING PRINCIPALS IN COMPUTER GRAPHICS
     by Leendert Ammeraal
*/
float v11=0, v12=0, v13=0, v14=0,
      v21=0, v22=0, v23=0, v24=0,
      v31=0, v32=0, v33=0, v34=0,
      v41=0, v42=0, v43=0, v44=1;

float old_v11=0, old_v12=0, old_v13=0, old_v14=0,
      old_v21=0, old_v22=0, old_v23=0, old_v24=0,
      old_v31=0, old_v32=0, old_v33=0, old_v34=0,
      old_v41=0, old_v42=0, old_v43=0, old_v44=1;

float screen_dist = 1000, cx=300.5, cy=200.5, zoomconst = 2, cz = 0;
float old_cz, old_cx, old_cy, old_zoomconst, old_rho;

float h = 50;
float rho = 0;

void mv(float x, float y, float z);
void dw(float x, float y, float z);
void perspective(float x, float y, float z, float *pX, float *pY);
void fly_cube(unsigned char color_flg);

/*=============================== main =====================================*/



unsigned char update_cube()
{
    float tv11,tv12,tv13,tv21,tv22,tv23,tv31,tv32,tv33;
    float tempx,tempy,tempz;
    float tzoom, trho;
    /*
        Store the current Values
    */
    tv11 = v11;
    tv12 = v12;
    tv13 = v13;
    tv21 = v21;
    tv22 = v22;
    tv23 = v23;
    tv31 = v31;
    tv32 = v32;
    tv33 = v33;
    tempx = cx;
    tempy = cy;
    tempz = cz;
    tzoom = zoomconst;
    trho = rho;
    /*
        Draw the Old CUBE in Black
    */
    v11 = old_v11;
    v12 = old_v12;
    v13 = old_v13;
    v21 = old_v21;
    v22 = old_v22;
    v23 = old_v23;
    v31 = old_v31;
    v32 = old_v32;
    v33 = old_v33;
    cx = old_cx;
    cy = old_cy;
    cz = old_cz;
    zoomconst = old_zoomconst;
    rho = old_rho;
	fly_cube(FALSE);

    /*
        Draw the New Cube in Color
    */
    v11 = tv11;
    v12 = tv12;
    v13 = tv13;
    v21 = tv21;
    v22 = tv22;
    v23 = tv23;
    v31 = tv31;
    v32 = tv32;
    v33 = tv33;
    cx = tempx;
    cy = tempy;
    cz = tempz;
    zoomconst = tzoom;
    rho = trho;
	fly_cube(TRUE);

    /*
        Store the New data, just drawn, for next time
    */
    old_v11 = v11;
    old_v12 = v12;
    old_v13 = v13;
    old_v21 = v21;
    old_v22 = v22;
    old_v23 = v23;
    old_v31 = v31;
    old_v32 = v32;
    old_v33 = v33;
    old_cx = cx;
    old_cy = cy;
    old_cz = cz;
    old_zoomconst = zoomconst;
    old_rho = rho;
    return(TRUE);
}

void fly_cube(color_flg)
unsigned char color_flg;
{
  int j,i,k;


  /* Viewing distance rho */

  /* Theta, measured horizontaly from the x-axis */

  /* Phi, measured vertically from the z-axis */

  setcolor(color_flg*15);
  mv(h, -h, -h);
  dw(h, h, -h);
  setcolor(color_flg*11);
  dw(-h, h, -h);
  setcolor(color_flg*15);
  dw(-h, h, h);
  dw(-h, -h, h);
  dw(h, -h, h);
  dw(h, -h, -h);
  mv(h,h,-h);
  dw(h, h, h);
  dw(-h,  h, h);
  mv(h, h, h);
  dw(h, -h, h);
  mv(h, -h, -h);
  dw(-h, -h, -h);
  dw(-h, h, -h);
  mv(-h, -h, -h);
  dw(-h, -h, h);

  setcolor(color_flg*12);
  mv(0,0,0);
  dw(0,150,0);
  mv(0,0,0);
  dw(0,-150,0);

/* remote */
  setcolor(color_flg*13);
  mv(0,0,0);
  dw(0,0,-150);

  setcolor(color_flg*14);
  mv(0,0,0);
  dw(-150,0,0);
  mv(0,0,0);
  dw( 150,0,0);

}



/*---------------------------------- mv ------------------------------------*/
void mv(float x, float y, float z)
{
 float X, Y;
 perspective(x, y, z, &X, &Y);
 moveto((int)X, (int)Y);
}

/*---------------------------------- dw ------------------------------------*/
void dw(float x, float y, float z)
{
 float X, Y;
 perspective(x, y ,z, &X, &Y);
 lineto((int)X, (int)Y);
}

/*------------------------- perspective ------------------------------------*/
void perspective(float x, float y, float z, float *pX, float *pY)
{
 float xe, ye, ze;
 if (x == 0)
 x = 0.00001;

 if (y == 0)
 y = 0.00001;

 if (z == 0)
 z = 0.00001;
 x = zoomconst * x;
 y = zoomconst * y;
 z = zoomconst * z;
/*........................ Eye coordinates ..................................*/
 ze =  rho + ( v11 * x + v12 * y + v13 * z + cx );
 xe = - ( v21 * x + v22 * y + v23 * z + cy );
 ye =  ( v31 * x + v32 * y + v33 * z + cz );
 if (ze == 0) ze = 0.0001;
/*....................... Screen coordinates ...............................*/
 *pX = screen_dist * (xe / ze) + 320;
 *pY = - screen_dist * (ye / ze) + 240;
}

