% IDMODEL/SSDATA   IDMODEL ���f���ɑ΂����ԋ�ԍs����o�͂��܂��B
%
%   [A,B,C,D,K,X0] = SSDATA(M)
%
% M �́A���f���̃T���v�����O���� Ts �Ɉˑ�����A���A�܂��͗��U���Ԃ� 

%   $Revision: 1.1 $  $Date: 2003/04/18 17:08:43 $
5 IDPOLY�AIDARX�AIDSS ����� IDGREY �̂悤�ȔC�ӂ� IDMODEL �I�u�W�F�N�g
% �ł��B
%
%     x[k+1] = A x[k] + B u[k] + K e[k] ;      x[0] = X0
%     y[k] = C x[k] + D u[k] + e[k]
%
% [A,B,C,D,K,X0,dA,dB,dC,dD,dK,dX0] = SSDATA(M) �́A���f���̕s�m����
% (�W���΍�) dA ���Ԃ��܂��B
% 
% M �����n���(���͂��Ȃ�)�ꍇ�AB �� D �͋�s��Ƃ��ĕԂ���܂��B����
% �Ƃ��m�C�Y�� e �́A�o�͂ƂȂ邱�Ƃɒ��ӂ��Ă��������B�m�C�Y����ʏ�
% �̓��͂ɕϊ�����ɂ́A�P�ʂ�����̕��U�𐳋K�����邽�߂̃I�v�V������
% �p���āAM = NOISECNV(M,noise) ���g�p���Ă��������B
%
% �Q�l: NOISECNV, TFDATA, ZPKDATA.

  
   