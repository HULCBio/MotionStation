% BODERESP �́A���f���̎��g���������A�W���΍��Ƌ��Ɍv�Z���܂��B
% 
%   [MAG,PHASE,W] = BODERESP(M)   
%
% �����ŁAM �̓��f���I�u�W�F�N�g(IDMODEL, IDPOLY, IDSS, IDFRD, IDGREY)��
% ���BMAG �́A�����̃Q�C���ŁAPHASE �͈ʑ�(�x�P��)�ł��BW �́A�������v�Z
% �������g����\���x�N�g���ł��B���g���x�N�g���́A[MAG,PHASE,W] = BOD-
% ERESP(M,W) �Ŏw��ł��܂��B���g���P�ʂ́Arad/s �ł��B
%
% M ���ANY �o�͂� NU ���͂������AW ���ANW �̎��g���ł���ꍇ�AMAG �� 
% PHASE �́ANY-NU-NW �̑傫���̔z��ŁAMAG(ky,ku,k) �́A����ku ����o�� 
% ky �܂ł̎��g�� W(k) �ł̉�����^���܂��B
%
% M �����n��̏ꍇ�AMAG �́A�p���[�X�y�N�g�����Ӗ����APHASE �́A��Ƀ[��
% �ɂȂ�܂��B
% 
% ���̊֐��́A���U���ԃ��f�����A�����ԃ��f�����@�\���܂��B
%   
% ���f�� M �̏o�͂Ɋ֘A�����m�C�Y�X�y�N�g���𓾂邽�߂ɁABODERESP(M('no-
% ise')) ���g���܂��B����̓���/�o�͉����ɃA�N�Z�X���邽�߂ɂ́ABODERESP
% (M(ky,ku))���g���܂��B
%
% �Q�C���ƈʑ��̕W���΍��́A���̃X�e�[�g�����g�ŕ\����܂��B
% 
%   [MAG,PHASE,W,SDMAG,SDPHAS] = BODERESP(M).
%   
% �Q�l�F IDMODEL/BODE, FFPLOT, IDMODEL/NYQUIST, IDFRD

%   L. Ljung 7-7-87,1-25-92


%   Copyright 1986-2001 The MathWorks, Inc.
