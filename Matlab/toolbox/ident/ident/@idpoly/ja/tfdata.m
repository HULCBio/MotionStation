% IDPOLY/TFDATA �́AIDPOLY ���f���I�u�W�F�N�g��`�B�֐��ɕϊ����܂��B
%
% [NUM,DEN] = TFDATA(MODEL) �́A���f���I�u�W�F�N�g MODEL �̕��q�ƕ����
% �o�͂��܂��BNY �o�́ANU ���͂����`�B�֐��ɑ΂��āANUM �� DEN �́ANUM
% {I,J}������ J ����o�� I �܂ł̓`�B�֐����w�肷�� NY �s NU ��̃Z���z
% ��ł��B
% 
% [NUM,DEN,SDNUM,SDDEN] = TFDATA(MODEL) �́A���q�W���ƕ���W���̕W���΍�
% ���o�͂��܂��B
% 
% MODEL �̑��̃v���p�e�B�́AGET ���g�����A�܂��́A���ړI�ɍ\���̂̎Q�Ɩ@
% (���Ƃ��΁AMODEL.Ts)���g���ăA�N�Z�X���܂��B
%
% MODEL �����n��(NU = 0)�̏ꍇ�ANY �m�C�Y������̉���y���o�͂���܂��B
% NY�sNY��̂��̂悤�ȓ`�B�֐�������܂��B
%
% ���͂����V�X�e���ɑ΂���(���K�����ꂽ)�m�C�Y�����𓾂�ɂ́A
% 
%       [NUM,DEN] = TFDATA(MODEL('noise'))
% 
% ���g���Ă��������B
%
% �m�C�Y�̕΍��̐��K�����܂ނ��߂ɃI�v�V�������g�p���āA�m�C�Y����
% ����`�����l���ɕϊ����邽�߂ɂ́ANOISECNV���g���Ă��������B
% 
% SISO ���f�� MODEL �ɑ΂��āA�V���^�b�N�X
% 
%       [NUM,DEN] = TFDATA(MODEL,'v')
% 
% �́A�Z���z��łȂ��s�x�N�g���Ƃ��āA���q�ƕ�����o�͂��܂��B
%
% �Q�l�F IDMODEL/SSDATA, IDMODEL/ZPKDATA, IDMODEL/POLYDATA,
%        IDMODEL/FREQRESP, NOISECNV.

%   L. Ljung 10-2-90


%   Copyright 1986-2001 The MathWorks, Inc.
