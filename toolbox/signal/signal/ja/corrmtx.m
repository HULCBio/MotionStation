% CORRMTX �́A���ȑ��֍s����v�Z���܂��B
% X = CORRMTX(S,M) �́A���� N �̃x�N�g�� S �Ɛ��� M ��^���āAX'*X ���AS
% �� M+1 �s M+1 ��̎��ȑ��֍s���(�o�C�A�X�t��)����ɂȂ�N+M �s M+1 ��
% �̍s��X���o�͂��܂��B
%
% X = CORRMTX(S,M,METHOD) �́A METHOD �ɏ]���č쐬���ꂽ�s�� X ���o�͂�
% �܂��BMETHOD �ɂ́A���̂����ꂩ��ݒ肷�邱�Ƃ��ł��܂��B
% 
% 'autocorrelation' - ����́A���萄�肪�]�܂��ꍇ�Ɏg�p�ł��܂��B����
%                     ���A�o�C�A�X�t���ŁA�f�[�^�ɂ̓E�C���h�E���K�p����
%                     �Ă��܂�(�f�t�H���g)�B
% 
% 'prewindowed'     - �f�[�^�́A�ŏ��ɁA�E�C���h�E���K�p����܂��BX�́AN
%                     �sM+1��ł��B
% 
% 'postwindowed'    - �f�[�^�́A�Ō�ɁA�E�C���h�E���K�p����܂��BX�́AN
%                     �sM+1��ł��B
% 
% 'covariance'      - �f�[�^�̃E�C���h�E�����͍s���܂���B���x�͏オ���
%                     ���B����ɂ́A�o�C�A�X�̓K�p�͂���܂���BX�́AN-M
%                     �sM+1��ł��B
% 
% 'modified'        - ����́A�C�������U�@�ɑΉ����܂��B�����̏ꍇ�A����
%                     �U��萸�x�̍������肪�s���܂��B����ɂ́A�o�C�A�X
%                     �̓K�p�͂���܂���BX�́A2*(N-M)�sM+1��ł��B
%
% [X,R] = CORRMTX(...) �́AM+1�sM+1��̑��֍s�� R ���o�͂��܂��BR �́A
% X'*X�ŊȒP�Ɍv�Z�ł��܂��B
%
% �Q�l�F   XCORR, CONVMTX, ARCOV, ARMCOV, ARYULE, PMUSIC, ROOTMUSIC.



%   Copyright 1988-2002 The MathWorks, Inc.
