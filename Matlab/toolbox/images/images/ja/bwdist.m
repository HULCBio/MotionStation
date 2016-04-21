% BWDIST �����ϊ�
% D = BWDIST(BW) �́A�o�C�i���C���[�W BW �̃��[�N���b�h�����ϊ����v�Z��
% �܂��BBW �̒��̊e�s�N�Z���ɑ΂��āA�����ϊ��́ABW �̒��̃s�N�Z���Ƃ�
% �̍ŋߖT�̃[���łȂ��s�N�Z���̊Ԃ̋����ł��鐔�������蓖�Ă܂��BBWDIST
% �́A�f�t�H���g�ŁA���[�N���b�g�����v�ʂ��g���܂��BBW �́A���鎟������
% �����邱�Ƃ��ł��܂��BD �́ABW �Ɠ����T�C�Y�ł�
%
% [D,L] = BWDIST(BW) �́A�ŋߖT�ϊ����v�Z���A���x���s�� L �Ƃ��āA�����
% �o�͂��܂��BL �� BW �� D �Ɠ����T�C�Y�ł��BL �̊e�v�f�́ABW �̍ŋߖT��
% �[���łȂ��s�N�Z���̐��`�C���f�b�N�X���܂�ł��܂��B
%
% [D,L] = BWDIST(BW,METHOD) �́AMETHOD �̒l�Ɉˑ����āA�ύX���������ϊ���
% �v�Z�����܂��BMETHOD �́A'cityblock', 'chessboard', 'quasi-euclidean', 
% 'euclidean' �̂����ꂩ��ݒ肷�邱�Ƃ��ł��܂��BMETHOD �́A�w�肵�Ȃ���
% ���A�f�t�H���g��'euclidean'���g���܂��BMETHOD �́A�Z�k���邱�Ƃ��ł��܂��B
%
% �قȂ���@�́A�قȂ鋗���v�ʂɑΉ����܂��B2�����ŁA(x1,y1) �� (x2,y2)
% �� cityblock �����́Aabs(x1-x2) + abs(y1-y2) �ƂȂ�܂��Bchessboard ��
% ���́Amax(abs(x1-x2) �� abs(y1-y2)) �ł��BQuasi-Euclidean �����́A��
% �̂悤�ɂȂ�܂��B
%
%   abs(x1-x2) > abs(y1-y2) �̏ꍇ�Aabs(x1-x2) + (sqrt(2)-1)*abs(y1-y2)
%   ���̑��̏ꍇ�A�@�@�@�@�@�@�@    (sqrt(2)-1)*abs(x1-x2) + abs(y1-y2)
%
% Euclidean �����́Asqrt((x1-x2)^2 + (y1-y2)^2) �ł��B
%
% ����
% ----
% BWDIST �́A�^�� Euclidean �����ϊ����v�Z���邽�߂ɍ����̃A���S���Y����
% �g���Ă��܂��B���ɁA2 �����̏ꍇ�́A�����ł��B���̕��@�́A����I�ȍl��
% �����ŁA�p�ӂ���Ă��܂��B�������A�قȂ鋗���ϊ��́A���������̓C���[�W
% �ɑ΂��āA���΂��΁A���Ȃ�̍����ɂȂ邱�Ƃ�����܂��B���ɁA��[���v�f
% ���������݂���ꍇ�ł��B
%
% �N���X�T�|�[�g
% -------------
% BW �́A���l�z��܂��� logical �ł��B�܂���X�p�[�X�łȂ���΂Ȃ�܂�
% ��BD �� L �́ABW �Ɠ����T�C�Y�� double �s��ł��B
%
% ���
% --------
% ���ɁA���[�N���b�h�����ϊ��̊ȒP�ȗ��������܂��B
%
%       bw = zeros(5,5); bw(2,2) = 1; bw(4,4) = 1;
%       [D,L] = bwdist(bw)
%
% ���̗��́A2�����̋����ϊ��ɂ��āA4�̕��@���ׂ����̂ł��B
%
%       bw = zeros(200,200); bw(50,50) = 1; bw(50,150) = 1;
%       bw(150,100) = 1;
%       D1 = bwdist(bw,'euclidean');
%       D2 = bwdist(bw,'cityblock');
%       D3 = bwdist(bw,'chessboard');
%       D4 = bwdist(bw,'quasi-euclidean');
%       figure
%       subplot(2,2,1), subimage(mat2gray(D1)), title('Euclidean')
%       hold on, imcontour(D1)
%       subplot(2,2,2), subimage(mat2gray(D2)), title('City block')
%       hold on, imcontour(D2)
%       subplot(2,2,3), subimage(mat2gray(D3)), title('Chessboard')
%       hold on, imcontour(D3)
%       subplot(2,2,4), subimage(mat2gray(D4)), title('Quasi-Euclidean')
%       hold on, imcontour(D4)
%
% ���̗�� �́A���S�Ɉ�̔�[���̃s�N�Z�����܂�3�����̋����ϊ��ɑ�
% ���铙�l�ʃv���b�g���ׂ����̂ł��B
%
%       bw = zeros(50,50,50); bw(25,25,25) = 1;
%       D1 = bwdist(bw);
%       D2 = bwdist(bw,'cityblock');
%       D3 = bwdist(bw,'chessboard');
%       D4 = bwdist(bw,'quasi-euclidean');
%       figure
%       subplot(2,2,1), isosurface(D1,15), axis equal, view(3)
%       camlight, lighting gouraud, title('Euclidean')
%       subplot(2,2,2), isosurface(D2,15), axis equal, view(3)
%       camlight, lighting gouraud, title('City block')
%       subplot(2,2,3), isosurface(D3,15), axis equal, view(3)
%       camlight, lighting gouraud, title('Chessboard')
%       subplot(2,2,4), isosurface(D4,15), axis equal, view(3)
%       camlight, lighting gouraud, title('Quasi-Euclidean')
%
% �Q�l�FWATERSHED.



%   Copyright 1993-2002 The MathWorks, Inc.
