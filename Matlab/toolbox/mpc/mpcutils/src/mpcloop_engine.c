/*
  mpcloop_engine.c: MPC simulation
  
  Syntax:    [u,y,xp,xmpc]=mpcloop_engine(MPCstruct);
  
      Author: A. Bemporad
      Copyright 1986-2003 The MathWorks, Inc.
      $Revision: 1.1.10.3 $  $Date: 2003/12/04 01:37:50 $
 */

#include "mex.h"
#include "mpcloop_engine.h"
#include "mpc_common.c"
/*
 MPC_COMMON.C contains the following functions (shared with MPCLOOP_ENGINE.C):
        mdlOutputs(mxArray *S, int_T tid)
        mdlUpdate(mxArray *S, int_T tid)
 */

static void mpcloop_engine( double *UU, double *YY, double *XP,  double *XMPC, const mxArray *S)

{
    int i,j;
    
    long int t; /* simulation time */
    
    /* Retrieve some useful constants */
    
    int nu = (int)*mxGetPr(p_nu(S));    /* Size of manipulated input vector */
    int nx = (int)*mxGetPr(p_nx(S));    /* Size of state vector */
    int ny = (int)*mxGetPr(p_ny(S));    /* Size of output vector*/
    int nym = (int)*mxGetPr(p_nym(S));  /* Size of measured output vector*/
    int nv = (int)*mxGetPr(p_nv(S));    /* Size of measured disturbance vector*/
    int ndp = (int)*mxGetPr(p_ndp(S));  /* Size of unmeasured disturbance vector to simulation model*/
    int nxp = (int)*mxGetPr(p_nxp(S));  /* Size of state vector of simulation model*/
    
    /* Define pointers to structure elements (to speed up simulation):*/
    real_T *xp0 = mxGetPr(p_xp0(S));    /* initial conditions */
    real_T *md_signal = mxGetPr(p_md_signal(S));  /* meas. dist. signal */
    real_T *ud_signal = mxGetPr(p_ud_signal(S));  /* unmeas. dist. signal*/
    real_T *mn_signal = mxGetPr(p_mn_signal(S));  /* Y meas. noise signal*/
    real_T *un_signal = mxGetPr(p_un_signal(S));  /* U noise signal*/
    int Nmd = mxGetN(p_md_signal(S));
    int Nud = mxGetN(p_ud_signal(S));
    int Nmn = mxGetN(p_mn_signal(S));
    int Nun = mxGetN(p_un_signal(S));
    real_T *Cp = mxGetPr(p_Cp(S));
    real_T *Dvp = mxGetPr(p_Dvp(S));
    real_T *Ddp = mxGetPr(p_Ddp(S));
    real_T *Ap = mxGetPr(p_Ap(S));
    real_T *Bup = mxGetPr(p_Bup(S));
    real_T *Bvp = mxGetPr(p_Bvp(S));
    real_T *Bdp = mxGetPr(p_Bdp(S));
    real_T *myindex = mxGetPr(p_myindex(S));
    real_T *xpoff = mxGetPr(p_xpoff(S));       /* plant state offset */
    real_T *dxpoff = mxGetPr(p_dxpoff(S));     /* plant state derivative/increment offset */
    real_T *xoff = mxGetPr(p_xoff(S));         /* state offset of MPC plant model */
    real_T *ypoff = mxGetPr(p_ypoff(S));       /* plant y-offset */
    
    int p = (int)*mxGetPr(p_p(S));             /* Prediction horizon */
    
    long int Tf = (long int) *mxGetPr(p_Tf(S));/* Total simulation time*/
    
    boolean_T unconstr = (boolean_T) *mxGetPr(p_unconstr(S)); /* =1 means remove MPC constraints */
    boolean_T openloop = (boolean_T) *mxGetPr(p_openloop(S)); /* =1 means do open-loop simulation */
    real_T *mv_signal = mxGetPr(p_mv_signal(S));  /* U signal (with offset) for open-loop simulation*/
    
    real_T adder;     /* Accumulator*/

    real_T *lastx, *lastu, *optimalseq, *v, *y, *r, *u, *ym, *v_t, *d_t, *yn_t, *un_t, *x_t;
    long int *lastt;
    real_T *deltayoff;   /* difference plant-nominal y.offset */
    real_T *deltauoff;   /* difference plant-nominal u.offset*/
    real_T *deltavoff;   /* difference plant-nominal v.offset*/
    real_T *xaux;     /* Temporary storage for state update*/
    real_T *vp_t, *up_t;
    /*real_T *mv_t;*/

    /*#ifdef WAITBAR*/
    mxArray *rhs[2];         /* waitbar handle and value. If handle=-1, then no bar is drawn*/
    real_T bar_time=0;


    /* Set vars for waitbar and counter*/
    rhs[0] =  mxCreateDoubleMatrix(1, 1, mxREAL); /*fraction of time*/
    rhs[1] = p_barhandle(S); /* get pointer to handle from structure*/
    /*#endif*/

    lastx = (real_T *)mxCalloc(nx,sizeof(real_T));
    lastu = (real_T *)mxCalloc(nu,sizeof(real_T));
    optimalseq = (real_T *)mxCalloc(mxGetM(p_optimalseq(S)),sizeof(real_T));
    v = (real_T *)mxCalloc((p+1)*nv,sizeof(real_T));  /* measured disturbance (sequence) given to MPC (w/out offsets)*/
    v_t = (real_T *)mxCalloc(nv,sizeof(real_T));      /* current meas. dist. (with nominal offset)*/
    d_t = (real_T *)mxCalloc(ndp,sizeof(real_T));     /* current unmeas. dist.*/
    yn_t = (real_T *)mxCalloc(nym,sizeof(real_T));    /* current meas. noise*/
    un_t = (real_T *)mxCalloc(nu,sizeof(real_T));     /* current noise on manipulated vars*/
    x_t = (real_T *)mxCalloc(nxp,sizeof(real_T));     /* plant state (without offsets)*/
    lastt = (long int *)mxCalloc(1,sizeof(long int));
    vp_t = (real_T *)mxCalloc(nv,sizeof(real_T));     /* current meas. dist. (with plant offset)*/
    up_t = (real_T *)mxCalloc(nu,sizeof(real_T));     /* current input (with plant offset)*/
    xaux = (real_T *)mxCalloc(nxp,sizeof(real_T));    /* temporary storage for state update*/
    y = (real_T *)mxCalloc(ny,sizeof(real_T));
    r = (real_T *)mxCalloc(ny*p,sizeof(real_T));
    u = (real_T *)mxCalloc(nu,sizeof(real_T));
    ym = (real_T *)mxCalloc(nym,sizeof(real_T));
    deltayoff = (real_T *)mxCalloc(ny,sizeof(real_T));
    deltauoff = (real_T *)mxCalloc(nu,sizeof(real_T));
    if (nv-1>0)
        deltavoff = (real_T *)mxCalloc(nv-1,sizeof(real_T));

    /*printf(">>DEBUG 1: OK!!!\n");*/


    /* Initialize lastx, lastu, optimalseq, lastt to parameter values*/

    memcpy(lastx, mxGetPr(p_lastx(S)), nx*sizeof(real_T));
    memcpy(lastu, mxGetPr(p_lastu(S)), nu*sizeof(real_T));
    memcpy(optimalseq, mxGetPr(p_optimalseq(S)),
    	mxGetM(p_optimalseq(S))*sizeof(real_T));

    memcpy(deltayoff, mxGetPr(p_ypoff(S)), ny*sizeof(real_T));
    memcpy(deltauoff, mxGetPr(p_upoff(S)), nu*sizeof(real_T));

    if (nv-1>0)
        memcpy(deltavoff, mxGetPr(p_vpoff(S)), (nv-1)*sizeof(real_T));

    for (i=0;i<ny;i++)
        deltayoff[i]-=mxGetPr(p_yoff(S))[i];
    for (i=0;i<nu;i++)
        deltauoff[i]-=mxGetPr(p_uoff(S))[i];
    for (i=0;i<nv-1;i++)
        deltavoff[i]-=mxGetPr(p_voff(S))[i];

    /*Initial Plant state*/
    for (i=0; i<nxp; i++)
        x_t[i]=xp0[i]-xpoff[i];

    /* additional measured disturbance due to offsets*/
    for (i=0; i<p+1; i++) {
        v[i*nv+nv-1]=1.0;
    }

    *lastt=0;

    for (t=0; t<Tf; t++){

        for (i=0; i<nxp; i++) /*save current Plant state*/
            XP[t*nxp+i]=x_t[i]+xpoff[i];

        if (!openloop)
            for (i=0; i<nx; i++) /*save current MPC state*/
                XMPC[t*nx+i]=lastx[i]+xoff[i];


        /* get current disturbance signals*/
        getrv(v_t,md_signal,t,t,nv-1,nv-1,Nmd);
        getrv(d_t,ud_signal,t,t,ndp,ndp,Nud);
        getrv(yn_t,mn_signal,t,t,nym,nym,Nmn);
        getrv(un_t,un_signal,t,t,nu,nu,Nun);

        /* Compute current output and save it*/
        /*DISP_VEC(x_t,nxp,"x_t")*/
        /*printf(">>DEBUG: t=%d, v_t[0]=%5.2f\n",t,v_t[0]);*/
        for (i=0; i<nv-1; i++) /* Adjust v-offsets to plant offsets*/
            vp_t[i]=v_t[i]+deltavoff[i];
        for (i=0; i<ny; i++) {
            CLR; /* i.e., adder = 0*/
            MVP(Cp, x_t, i, ny, nxp);
            MVP(Dvp, vp_t, i, ny, nv-1);
            MVP(Ddp, d_t, i, ny, ndp);
            y[i]=adder;
            YY[t*ny+i]=y[i]+ypoff[i]; /*save current output*/
        }

        /*DISP_VEC(deltayoff,ny,"deltayoff");*/
        /*DISP_VEC(y,ny,"y");*/


        if (openloop)      	/* get current MV signal (with offset)*/
            getrv(u,mv_signal,t,t,nu,nu,Nun);

        else {
            for (i=0; i<nym; i++){
                j=(int)(myindex[i])-1;
                ym[i]=y[j]+deltayoff[j]+yn_t[i];}           
            /* if yoff~=ypoff, ym is offset-free. Otherwise it is affected by*/
            /* an offset error due to wrong estimation of output nominal*/
            /* operating point*/

            /* reference signal (or MV signal) is loaded inside mdlOutputs*/

            /* measurement update of state observer + MPC computation*/
            mdlOutputs(S,t,lastx,lastu,v,optimalseq,lastt,v_t,ym,u,
            unconstr);

        }
        /* Save current input (lastu is already updated by mdlOutputs)*/
        /* and add noise*/

        /*DISP_VEC(deltauoff,nu,"deltauoff");*/

        for (i=0; i<nu; i++) {
            /*          if (openloop) {*/
            up_t[i]=u[i]-mxGetPr(p_uoff(S))[i]+un_t[i];  /*add input noise*/
            /*            UU[t*nu+i]=u[i]+un_t[i];*/
            /*		  }*/
            /*		  else {*/
            /*            up_t[i]=u[i]+deltauoff[i]+un_t[i];*/
            /*                    Adjust u-offsets to plant offsets + noise*/
            /*                    Nominal input offset is already included in u[i]*/
            /*            UU[t*nu+i]=up_t[i];*/
            /*        }*/
            UU[t*nu+i]=up_t[i]+mxGetPr(p_upoff(S))[i];
        }
        /*DISP_VEC(up_t,nu,"up_t")*/


        if (!openloop)
            mdlUpdate(S,t,lastx,lastu,v_t,lastt);  /* time-update of state observer*/


        /* Plant update*/

        /*DISP_MAT(mxGetPr(p_Bup(S)),nxp,nu,"Bup")*/

        /*DISP_VEC(x_t,nxp,"x_t(before)")*/
        for (i=0; i<nxp; i++) {
            CLR; /* i.e., adder = 0*/
            MVP(Ap, x_t, i, nxp, nxp);
            MVP(Bup, up_t, i, nxp, nu);
            /*DISP_ADDER(i)*/
            MVP(Bvp, vp_t, i, nxp, nv-1);
            MVP(Bdp, d_t, i, nxp, ndp);
            xaux[i]=adder+dxpoff[i];
        }

        /*Update Plant state vector*/
        memcpy(x_t,xaux, nxp*sizeof(real_T));
        /*DISP_VEC(x_t,nxp,"x_t(after)")*/

        /*printf(">>DEBUG: OK!!!\n");*/

        /*#ifdef WAITBAR*/
        if (*mxGetPr(rhs[1])>-1) {
            /* Update progress bar*/
            adder=(real_T)(t+1)/Tf;
            /*if (adder-bar_time>=.004) */ /*only allows updating waitbar up to 250 times*/
            if (adder-bar_time>=.04)  /*only allows updating waitbar up to 25 times*/
            /*adder=(real_T)(t+1)/Tf*100;*/
            /*if (adder-bar_time>=4)  *//*only allows updating waitbar up to 25 times*/
            {
                bar_time=adder;
                *mxGetPr(rhs[0])=(double)adder;

                mexCallMATLAB(0,NULL, 2, rhs, "waitbar");
                /*mexCallMATLAB(0,NULL, 0, NULL, "drawnow");*/

                /*mexCallMATLAB(0,NULL, 1, rhs, "mpc_set_bar");*/

                /*adder=*mxGetPr(rhs[1]);*/
                /*printf("h=%5.2f, t=%d, timebar=%5.5f\n",adder,t,bar_time);*/
                /*mexCallMATLAB(0,NULL, 0, NULL, "keyboard");*/
                /*mexCallMATLAB(0,NULL, 0,NULL, "global progress_bar");*/
                /*mexCallMATLAB(0,NULL, 1, rhs, "progress_bar.setValue");*/
                /*printf("%5.2f\n",adder);*/
            }
        }
        /*#endif*/
    }

    /*Release allocated memory*/
    
    mxFree(lastx);
    mxFree(lastu);
    mxFree(optimalseq);
    mxFree(v);
    mxFree(v_t);
    mxFree(d_t);
    mxFree(yn_t);
    mxFree(un_t);
    mxFree(x_t);
    mxFree(lastt);
    mxFree(vp_t);
    mxFree(up_t);
    mxFree(xaux);
    mxFree(y);
    mxFree(r);
    mxFree(u);
    mxFree(ym);
    mxFree(deltayoff);
    mxFree(deltauoff);
    if (nv-1>0)
        mxFree(deltavoff);

    mxDestroyArray(rhs[0]);

    return;

}

void mexFunction( int nlhs, mxArray *plhs[],
	int nrhs, const mxArray *prhs[] )

{
    double *u, *y, *xp, *xmpc;
    int_T Tf=(int)*mxGetPr(p_Tf(MPCstruct_IN));

    int nu = (int)*mxGetPr(p_nu(MPCstruct_IN));    /* Size of manipulated input vector*/
    int nx = (int)*mxGetPr(p_nx(MPCstruct_IN));    /* Size of state vector*/
    int ny = (int)*mxGetPr(p_ny(MPCstruct_IN));    /* Size of output vector*/
    int nym = (int)*mxGetPr(p_nym(MPCstruct_IN));  /* Size of measured output vector*/
    int nv = (int)*mxGetPr(p_nv(MPCstruct_IN));    /* Size of measured disturbance vector*/
    int nxp = (int)*mxGetPr(p_nxp(MPCstruct_IN));  /* Size of state vector of simulation model*/
 
    /* Create a matrix for the return argument: vector dim=#rows, time-steps=#columns*/
    U_OUT = mxCreateDoubleMatrix(nu,Tf,mxREAL);
    Y_OUT = mxCreateDoubleMatrix(ny,Tf,mxREAL);
    XP_OUT = mxCreateDoubleMatrix(nxp,Tf,mxREAL);
    XMPC_OUT = mxCreateDoubleMatrix(nx,Tf,mxREAL);

    /* Assign pointers to the various parameters*/
    u = mxGetPr(U_OUT);
    y = mxGetPr(Y_OUT);
    xp = mxGetPr(XP_OUT);
    xmpc = mxGetPr(XMPC_OUT);

    
    /* Do the actual computations in a subroutine*/
    mpcloop_engine(u,y,xp,xmpc,MPCstruct_IN);

    /*printf("DEBUG: Type 'return' to continue (probably Matlab will crash !) \n");*/
    /*mexCallMATLAB(0,NULL, 0, NULL, "keyboard");*/
    return;
}
