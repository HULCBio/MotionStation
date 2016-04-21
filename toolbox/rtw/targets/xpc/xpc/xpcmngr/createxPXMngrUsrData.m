function xpcmngrUserData=createxPXMngrUsrData
%CREATEXPXMNGRUSRDATA xPC Target GUI
%   CREATEXPXMNGRUSRDATA Initialization data for the xPC Target Manager GUI.

%   Copyright 1996-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.3 $

% keep track of xpcmngr userdata
xpcmngrUserData.figure=[];
xpcmngrUserData.scfigure=[];
xpcmngrUserData.trackframe=[];  %1=app mngr, 2=log mngr 3= sc mngr
xpcmngrUserData.lasttrackframe=[];
xpcmngrUserData.splitter=[];
xpcmngrUserData.xpcInsbarCtl=[];
%xpcmngrUserData.scopeAxes=[];
xpcmngrUserData.figColor = [0.5 0.5 0.5];
xpcmngrUserData.TabCtrl=[];
xpcmngrUserData.axesContextMenu=[];
xpcmngrUserData.lineStyleOrder=[];
xpcmngrUserData.tickLabelOpt=[];
xpcmngrUserData.guiInfo.modelname=[];
xpcmngrUserData.guiInfo.Scopes=[];
xpcmngrUserData.toolbar=[];
xpcmngrUserData.toolbar.children.actionIcons=[];
xpcmngrUserData.toolbar.children.modeIcons=[];
xpcmngrUserData.menu=[];
xpcmngrUserData.treeCtrl=[]; 
xpcmngrUserData.mdlHierachCtl=[];
xpcmngrUserData.mdlHierachCtl=[];
xpcmngrUserData.blockbarCtrl=[];
xpcmngrUserData.sbarTree=[];
xpcmngrUserData.sbarPanel=[];
xpcmngrUserData.timerObj=[];
xpcmngrUserData.listCtrl=[];
xpcmngrUserData.tgapplistCtrl=[];
xpcmngrUserData.scidlistCtrl=[];
xpcmngrUserData.rtfCtrl=[];
xpcmngrUserData.sigViewer=[];
xpcmngrUserData.scTypertfCtrl=[];
%--------------------------------------------
xpcmngrUserData.tg.allH=[];
xpcmngrUserData.tg.app=[];
xpcmngrUserData.tg.app.sbarAppParms=[];
xpcmngrUserData.tg.app.sbarAppStT=[];
xpcmngrUserData.tg.app.sbarNSig=[];
xpcmngrUserData.tg.app.sbarNPt=[];
xpcmngrUserData.tg.app.sbarSc=[];
xpcmngrUserData.tg.app.sbarAppSaT=[];
xpcmngrUserData.tg.app.frameAppH=[];

%PT frame components%%%%%%%%%%%%%%
xpcmngrUserData.tg.pt.ptstatbar=[];
xpcmngrUserData.tg.pt.uiparpopuph=[];
xpcmngrUserData.tg.pt.ptlistviewCtrl=[];
xpcmngrUserData.tg.pt.allH=[];
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
xpcmngrUserData.tg.logging=[];

%%%%app Manager User data
xpcmngrUserData.targetmngr.handles=[];

%%%%Logg Manager User data
xpcmngrUserData.logmngr.handles=[];

%%%%Scope Manager User data
xpcmngrUserData.scmngr.scbarStat=[];
xpcmngrUserData.scmngr.axesColor= 'k';
xpcmngrUserData.scmngr.ticColor='w';
xpcmngrUserData.scmngr.axesColorOrder = [1 1 0
                                         1 0 1
                                         0 1 1
                                         1 0 0
                                         0 1 0
                                         0 0 1
                                         1 1 0
                                         0.5 0.5 0.5
                                         0.100 0.400 0.200 ];
%Scope Manager Host Data                                     
xpcmngrUserData.scmngr.Scope.scaxes=[];
xpcmngrUserData.scmngr.Scope.allH=[];
xpcmngrUserData.scmngr.Scope.scObjs=[];
xpcmngrUserData.scmngr.Scope.grid=[];
xpcmngrUserData.scmngr.Scope.ScHilite=[];
xpcmngrUserData.scmngr.Scope.scbarStat=[];

%Scope Manager target Data
xpcmngrUserData.scmngr.tgScope.scaxes=[];
xpcmngrUserData.scmngr.tgScope.ScHilite=[];
xpcmngrUserData.scmngr.tgScope.scText=[];
xpcmngrUserData.scmngr.tgScope.scObjs=[];

%Scope Manager target Data
xpcmngrUserData.scmngr.fileScope.scaxes=[];
xpcmngrUserData.scmngr.fileScope.ScHilite=[];
xpcmngrUserData.scmngr.fileScope.scText=[];
xpcmngrUserData.scmngr.fileScope.scObjs=[];
