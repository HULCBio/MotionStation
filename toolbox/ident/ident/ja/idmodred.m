% IDMODRED   ���f���̒᎟����
%   Control Systems Toolbox ���K�v�ł��B
%   MRED = IDMODRED(M,ORDER)
%
%   M     : IDMODEL(IDPOLY, IDARX, IDPOLY, IDGREY) �Ƃ��Ē�`���ꂽ�I��
%           �W�i�����f��
%   ORDER : ���f����᎟��������Ƃ��̊�]���鎟��
%      ORDER=[](�f�t�H���g)�̏ꍇ�A�v���b�g���\������A�����̑I����v��
%           ���Ă��܂��B
%   MRED = IDMODRED(M,ORDER,'DisturbanceModel','None') ���g���āA�o�͌�
%          �����f��(K = 0) ���쐬����A����A�m�C�Y���f�����᎟��������
%          �܂��B
%   MRED  : �᎟�������ꂽ���f���ŁAIDSS ���f���Ƃ��ĕ\��
%
% ���[�`���́AControl System Toolbox �̊֐� balreal �� modred ���x�[�X��
% ���Ă��܂��B
%
% �Q�l�F BALREAL, MODRED, IDMODEL.

%   L. Ljung 10-10-93


%   Copyright 1986-2001 The MathWorks, Inc.
