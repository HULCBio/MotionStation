% PEAKS   2�ϐ��֐��̗�
% 
% PEAKS�́A�K�E�X���z�̕ϊ��ƃX�P�[�����O�ɂ���ē�����2�ϐ��֐��ŁA
% MESH�ASURF�APCOLOR�ACONTOUR���̃f���ɖ𗧂��܂��B�Ăяo���̕��@�ɂ́A
% ���̂悤�Ȏ�ނ�����܂��B
%
%     Z = PEAKS;
%     Z = PEAKS(N);
%     Z = PEAKS(V);
%     Z = PEAKS(X,Y);
%
%     PEAKS;
%     PEAKS(N);
%     PEAKS(V);
%     PEAKS(X,Y);
%
%     [X,Y,Z] = PEAKS;
%     [X,Y,Z] = PEAKS(N);
%     [X,Y,Z] = PEAKS(V);
%
% �ŏ��̗�́A49�s49��̍s����o�͂��܂��B
% 2�Ԗڂ̗�́AN�sN��s����o�͂��܂��B
% 3�Ԗڂ̗�́AN = length(V)�̂Ƃ��AN�sN��̍s����o�͂��܂��B
% 4�Ԗڂ̗�́AX��Y�Ŋ֐���]�����܂��B�����ŁAX��Y�͓����T�C�Y�łȂ���
% �΂Ȃ�܂���B���ʂ�Z�������T�C�Y�ł��B
%
% ���̏o�͈����̂Ȃ�4�̗�́A���ʂ�SURF�v���b�g���s���܂��B
%
% �Ō��3�̗�́APCOLOR(X,Y,Z)�܂���SURF(X,Y,Z,DEL2(Z))�̂悤�ȃR�}��
% �h�Ŏg���A2�̍s��X��Y���o�͂��܂��B
%
% ���͂Ƃ��ė^�����Ȃ���΁A��{�I�ȍs��X��Y�́A
% 
%     [X,Y] = MESHGRID(V,V) 
% 
% �ŁAV�͗^����ꂽ�x�N�g�����A-3����3�̊Ԃœ��Ԋu�̗v�f��������N�̃x
% �N�g���ł��B���͈������^�����Ȃ���΁A�f�t�H���g��N��49�ł��B



%   CBM, 2-1-92, 8-11-92, 4-30-94.
%   Copyright 1984-2002 The MathWorks, Inc. 
%   $Revision: 1.8.4.1 $  $Date: 2004/04/28 01:49:15 $
