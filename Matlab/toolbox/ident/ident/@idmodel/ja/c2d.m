% C2D �́A�A�����Ԃ��痣�U���Ԃւ̕ϊ������s���܂��B
%
% MD = C2D(MC,T,METHOD)
%
% MC: IDMODEL �I�u�W�F�N�g�Ƃ��ė^������A�����ԃ��f��
%
% T : �T���v�����O�Ԋu
% MD: ���U���ԃ��f���AIDMODEL ���f���I�u�W�F�N�g
% METHOD: 'Zoh' (�f�t�H���g) �܂��� 'Foh'
%     ���͂��[�����z�[���h(�敪�I�萔)��ꎟ�z�[���h(�敪�I���`)�ł���
%     ���Ƃ̉���ɑΉ����܂��B
%      
% IDPOLY ���f���́AIDPOLY���f���Ƃ��ďo�͂���܂��B
% IDSS ���f���́AIDSS���f���Ƃ��ďo�͂���܂����A'Structured' �p�����g
%      ���[�[�V������ 'Free' �ɕύX����܂��B
% IDGREY ���f���́A'CDmfile' == 'cd' �̏ꍇ IDGREY ���f���Ƃ��ďo�͂���A
%        ���̑��̏ꍇ�AIDSS ���f���Ƃ��ďo�͂���܂��B
%   
% MC �� InputDelay �́AMD �Ɍp������܂��B
% T �̒萔�{�łȂ� InputDelays ����舵�����߂ɂ́AControl System Toolbox
% ���K�v�ł��B
%
% IDPOLY ���f���ɑ΂��āAMC �̋����U�s�� P �́A���l������p���ĕϊ�
% ����܂��B�����ɑ΂��ėp������X�e�b�v�T�C�Y�́AM-�t�@�C�� NUDERST
% �ŗ^�����܂��BIDSS�AIDARX�A����� IDGREY ���f���ɑ΂��āA���o�͓���
% �ɂ��Ă̋����U��񂪊܂܂�Ă��܂����A�����U�s��́A�ϊ�����܂���B
%
% (������x�̎��Ԃ�)�����U���̕ϊ���h���ɂ́A
%    C2D(MC,T,Method,'CovarianceMatrix','None') 
% ���g�p���܂��B(�C�ӂ̗�����g�p���܂�)(�ŏ��� SET(MC,'Cov','No') ��
% �s���Ă��������ʂ������܂�)
%
% Control System Toolbox���C���X�g�[������Ă���ꍇ�A���̂悤�Ɏ��s
% ���܂��B
%    MD = C2D(MD,T,METHOD)
% �����ŁAMETHOD �́A'tustin', 'prewarp', 'matched' �̂����ꂩ�ł���A
% �ϊ��́A�Ή������@�Ŏ��s����܂��BHELP SS/C2D ���Q�Ƃ��Ă��������B
% ���̌�A�����U���͕ϊ�����܂���B
%
%   �Q�l:  IDMODEL/D2C


%   L. Ljung 10-2-90, 94-08-27
%   Copyright 1986-2001 The MathWorks, Inc.
