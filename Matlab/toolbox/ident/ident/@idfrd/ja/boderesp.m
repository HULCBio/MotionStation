% IDFRD/BODERESP �́A���f���̎��g���֐��Ƃ��̕W���΍����v�Z���܂��B
% 
% [MAG,PHASE,W] = BODERESP(G)   
%
% �����ŁAG �́AIDFRD �I�u�W�F�N�g�ł��BMAG �͉����̃Q�C���ŁAPHASE �͈�
% ��(�P�ʂ͓x)�ł��BG.Frequency �̎��g���ɑ΂��ĉ������v�Z����A�x�N�g��
% W �ɏo�͂���܂��B���g���P�ʂ� rad/s �ŁAG.UNITS �͖����ł��B
%
% M ���ANY �o�́ANU ���͂������AW �����g���_ NW �������Ă���ꍇ�AMAG 
% �� PHASE �́AMAG(ky,ku,k) ���A���� ku ����o�� ky �܂ł̎��g�� W(k) ��
% �̉��������� NY-NU-NW �̔z��ł��B
%
% M �����n��̏ꍇ�AMAG �͂��̃p���[�X�y�N�g�����o�͂��APHASE �͏�Ƀ[��
% �ɂȂ�܂��B
% ���̊֐��́A���U���ԃ��f���ł��A�A�����ԃ��f���ł��@�\���܂��B
% BODERESP(M('noise')) ���g���āA���f�� M �̏o�͂Ɋ֘A�����(�m�C�Y)�X
% �y�N�g���𓾂܂��BBODERESP(M(ky,ku)) ���g���āA����ȓ���/�o�͂̉�����
% �A�N�Z�X�ł��܂��B
%
% [MAG,PHASE,W,SDMAG,SDPHAS] = BODERESP(M) ���g���āA�Q�C���ƈʑ��̕W����
% �����v�Z�ł��܂��B
%   
% �Q�l�F BODE, FFPLOT, NYQUIST and IDFRD.


%   L. Ljung 7-7-87,1-25-92


%   Copyright 1986-2001 The MathWorks, Inc.
