%CONVHULLN N-�����̓ʕ�
% K = CONVHULLN(X) �́AX �̓ʕ�̖ʂ��\������ X �̒��̓_�̃C���f�b�N�X 
% K ���o�͂��܂��BX �́An-�����̋�ԂɈʒu���� m �_��\�킷m �s n ���
% �z��ł��B�ʕp �ʂ����ꍇ�́AK �� p �s n ��ɂȂ�܂��B
%
% CONVHULLN �́AQhull ���g�p���܂��B
%
% K = CONVHULLN(X,OPTIONS) �́AQhull �̃I�v�V�����Ƃ��Ďg�p�����悤�ɁA
% ������ OPTIONS �̃Z���z����w�肵�܂��B�f�t�H���g�̃I�v�V�����́A
% ���̂��̂ł��B
%     2D, 3D ����� 4D ���͂ɑ΂��āA{'Qt'}  
%     5D ����� ��荂���̓��͂ɑ΂��āA{'Qt','Qx'} 
% OPTIONS �� [] �̏ꍇ�A�f�t�H���g�̃I�v�V�������g�p����܂��B
% OPTIONS �� {''} �̏ꍇ�A�I�v�V�����͎g�p����܂���B�f�t�H���g�̂���
% ���g�p����܂���B
% Qhull �Ƃ��̃I�v�V�����ɂ��Ă̏ڍׂ́Ahttp://www.qhull.org. ��
% �Q�Ƃ��Ă��������B
%
% [K,V] = CONVHULLN(...) �́AV �ɓʕ�̑̐ς��o�͂��܂��B
%
% ���:
%     X = [0 0; 0 1e-10; 0 0; 1 1];
%     K = convhulln(X)
%   �́A�ǉ��I�v�V���� 'Pp' �ɂ�胏�[�j���O���\���ɂ��܂��B
%     K = convhulln(X,{'Qt','Pp'})
%
% �Q�l CONVHULL, QHULL, DELAUNAYN, VORONOIN, TSEARCHN, DSEARCHN.

%   Copyright 1984-2003 The MathWorks, Inc. 
