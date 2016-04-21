% ARPACKC  EIGS �ɂ��ARPACK���C�u�����ւ�C-MEX �C���^�t�F�[�X
% 
% ARPACKC('dsaupd',IDO,BMAT,N,WHICH,NEV,TOL,RESID,NCV,V,LDV,...
%           IPARAM,IPNTR,WORKD,WORKL,LWORKL,INFO)
% IDO: �ʐM�p�����[�^�𖳌��ɂ���B���Ȃ킿�A0�ɏ����� {int32}
% BMAT: �W�����ɑ΂��Ă� 'I'�A��ʉ����ɑ΂��Ă� 'G'  {char}
% N: ���̃T�C�Y {int32}
% WHICH: 'LM','SM','LA','SA','BE'. {���� 2 �� char}
% NEV: �K�v�ƂȂ�ŗL�l�̐� {int32}
% TOL: �����̃g�������X�B�f�t�H���g�́Aeps/2�ł��B {double}
% RESID: �X�^�[�g�x�N�g���p�̏����� {���� N �� double}
% NCV: Lanczos �x�N�g���̐� {int32}
% V: Lanczos ���x�N�g�� {���� N*NCV �� double}
% LDV: V �̐擪���� {int32}
% IPARAM: {���� 11 int32}
% IPNTR: {���� 15 int32}
% WORKD: {���� 3*N double}
% WORKL: {���� LWORKL double}
% LWORKL: WORKL�̒��� >= NCV^2+8*NCV {int32}
% INFO {int32}
%
%   ARPACKC('dseupd',RVEC,HOWMNY,SELECT,D,Z,LDZ,SIGMA,...
%           BMAT,N,WHICH,NEV,TOL,RESID,NCV,V,LDV,...
%           IPARAM,IPNTR,WORKD,WORKL,LWORKL,INFO)
%   RVEC: �ŗL�l���v�Z���邩�ۂ� {int32}
%   HOWMNY: Ritz �x�N�g���ɑ΂��Ă� 'A'�B'S' �́ASELECT ����I�� {char}
%   SELECT: �v�Z���� Ritz �x�N�g���̎w�� {���� NEV �� int32}
%   D: �ŗL�l {���� NEV �� double}
%   Z: Ritz �x�N�g�� {���� N*NEV �� double}
%   LDZ: Z �̐擪���� {int32}
%   SIGMA: �X�J���ŗL�l�V�t�g {double}
%   Remaining ���͂́A�ŐV��'dsaupd' �Ăяo������͕ω����܂���B
%
%   ARPACKC('dnaupd',IDO,BMAT,N,WHICH,NEV,TOL,RESID,NCV,V,LDV,...
%           IPARAM,IPNTR,WORKD,WORKL,LWORKL,INFO)
%   ���̎����������āA'dsaupd' �ɑ΂�����̂Ɠ����ł��B
%   WHICH: 'LM','SM','LR','SR','LI','SI'. {���� 2 �� char}
%   LWORKL: WORKL �̒���>= 3*NCV*(NCV+2) {int32}
%
%   ARPACKC('dneupd',RVEC,HOWMNY,SELECT,D,DI,Z,LDZ,SIGMAR,SIGMAI,....
%            WORKEV, BMAT,N,WHICH,NEV,TOL,RESID,NCV,V,LDV,...
%           IPARAM,IPNTR,WORKD,WORKL,LWORKL,INFO)
%   ���̎����������āA'dseupd' ��'dnaupd' �ɑ΂�����̂Ɠ����ł��B
%   HOWMNY: 'A'�FRItz �x�N�g���p�A'P'�F�S Schur �x�N�g���p
%           'S'�FSELECT ���� Ritz �x�N�g����I�� {char}
%   D: Ritz �l�̎����� {���� NEV+1 �� double}
%   DI: Ritz �l�̋����� {���� NEV+1 �� double}
%   Z: {���� N*(NEV+1) �� double}
%   SIGMAR: �X�J���ŗL�l�V�t�g�̎����� {double}
%   SIGMAI: �X�J���ŗL�l�V�t�g�̋����� {double}
%   WORKEV: {���� 3*NCV �� double}
%
%   ARPACKC('znaupd',IDO,BMAT,N,WHICH,NEV,TOL,RESID,NCV,V,LDV,...
%           IPARAM,IPNTR,WORKD,WORKL,LWORKL,RWORK,INFO)
%   ���̎����������āA'dnaupd' �Ɠ����ł��B
%   RESID: {���� 2*N �� double}
%   V: {���� 2*N*NCV �� double}
%   WORKD: {���� 2*3*N �� double}
%   WORKL: {���� 2*LWORKL �� double}
%   LWORKL: ���f�� WORKL �̒��� >= 3*NCV^2+5*NCV {int32}
%   RWORK: {2*NCV double}
%
%   ARPACKC('zneupd',RVEC,HOWMNY,SELECT,D,Z,LDZ,SIGMA,WORKEV,...
%           BMAT,N,WHICH,NEV,TOL,RESID,NCV,V,LDV,...
%           IPARAM,IPNTR,WORKD,WORKL,LWORKL,RWORK,INFO)
%   ���̎����������āA'dneupd' �� 'znaupd' �Ɠ����ł��B
%   D: {���� 2*(NEV+1) �� double}
%   Z: {���� 2*N*NEV �� double}
%   SIGMA: �����x�N�g���ɃX�g�A����Ă��镡�f���V�t�g {���� 2 �� double}
%   WORKEV: {���� 2*2*NCV �� double}
%
% ���ӁFznaupd �� zneupd �ɑ΂��āA���ׂĂ� double �̕ϐ��́A���f����
% �X�g�A����̂ŁAARPACK �ŕK�v�Ƃ���Ă��钷����2�{��K�v�Ƃ��܂��B
% MATLAB �̕��f������ RESID �� WORKD �́Aznaupd �֓n���O�ɁAFORTRAN�X�g
% ���[�W�ɃC���^���[�u���邽�߂ɕϊ����邱�Ƃ��K�v�ł��BD �� V �́A
% zneupd ����߂��ꂽ��AFORTRAN �X�g���[�W����ϊ������K�v������܂��B
% ����"���f��"�x�N�g���́A���͂��o�͂ł��Ȃ��A��x���蓖�Ă���ƕύX
% ����K�v������܂���B
%
% ARPACK�́AFORTRAN�T�u���[�`�����W�߂����̂ŁA���̃A�h���X���痘
% �p�ł��܂��B
%      http://www.caam.rice.edu/software/ARPACK/
%
% �ڍׂɂ��ẮA�ȉ����Q�Ƃ��Ă��������B
%
%   R.B. Lehoucq, D.C. Sorensen and C. Yang,
%   ARPACK Users' Guide: Solution of Large-Scale Eigenvalue Problems
%   with Implicitly Restarted Arnoldi Methods
%   SIAM Publications, Philadelphia, (1998).
%   ISBN 0-89871-407-9
%
%  D.C. Sorensen,
%  Implicit application of polynomial filters in a k-Step Arnoldi Method,
%   SIAM J. Matrix Analysis and Applications, 13, pp. 357-385, (1992).
%
%   R.B. Lehoucq  and D.C. Sorensen,
%   Deflation Techniques for an Implicitly Re-started Arnoldi Iteration,
%   SIAM J. Matrix Analysis and Applications, 17, pp. 789-821, (1996).
%
% ARPACK ��The MathWorks�o�[�W�����́AJune 2,2000 �̓��t�̃p�b�`����
% ��ł��܂��B
%
% The MathWorks�́AARPACK ���킸���ɕύX���āAIPNTR �̒�����15�܂Œ���
% ���܂����B���̂��߁A�J�����g�̌J��Ԃ��񐔂́AIPNTR(15) �ɖ߂���܂��B
% The MathWorks�́A���̃g�b�v���x����FORTRAN�T�u���[�`�����R���p�C��
% ���܂����B
%      dsaupd �� dseupd (real symmetric)
%      dnaupd �� dneupd (real nonsymmetric)
%      znaupd �� zneupd (complex)
% ����сALAPACK 3.0 �Ƀ����N���鋤�L���C�u�������� DLAHQR ��LAPACK 
% 2.0 �o�[�W�����Ɋ܂܂�Ă��邷�ׂẴT�|�[�g���Ă���T�u���[�`���B
% C mex-�t�@�C�� ARPACKC �́AMATLAB���͂��������A�Ή�����ARPACK 
% ���[�`�����Ăяo���܂��BARPACKC �� EIGS �ŗp�����AARPCK�t�ʐM��
% �s��A�v���P�[�V�������������܂��B
%
% �Q�l�FEIGS.


%   Copyright 1984-2002 The MathWorks, Inc. 
%   $Revision: 1.2.4.1 $  $Date: 2004/04/28 02:02:26 $
