% [mu,D,G]=mubnd(M,delta,target)
%
% �s��M�ƃm�����L�E�s�m����DELTA�ɑ΂��āA�����ʍ\�������ْl�ɑ΂����E
% ���v�Z���܂��B
%
% DELTA�̊e�X�̃u���b�NDj���Adj�ŗ^������m�����ɋ߂Â��Ă��A
% 
%              MU * || Dj ||  <  dj
% 
% �ł������́A�s��I - M * DELTA�́A�t�������݂��܂��B
%
% TARGET���ݒ肳�ꂽ�ꍇ�AMU�̍ŏ����́AMU <= TARGET(�f�t�H���g = 1e-3)
% �ƂȂ�ƁA�����ɏI�����܂��BMUBND�́A�œKD,G�X�P�[�����O�s����o�͂���
% ���B
%
% �Q�l�F    MUSTAB, MUPERF.



% Copyright 1995-2002 The MathWorks, Inc. 
