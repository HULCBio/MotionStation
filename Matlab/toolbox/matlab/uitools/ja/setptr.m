% SETPTR   figure�̃|�C���^�̐ݒ�
% 
% SETPTR(FIG,CURSOR_NAME)�́Acursor_name �ɏ]���āA�n���h���ԍ��� FIG
% �ł���figure�̃J�[�\����ݒ肵�܂��B
% 
%    'hand'       - ��̂Ђ�^
%    'hand1'      - 1�Ə����Ă����̂Ђ�^
%    'hand2'      - 2�Ə����Ă����̂Ђ�^
%    'closedhand' - �}�E�X���������Ƃ��A�������
%    'glass'      - ���ዾ�^
%    'glassplus' - ������ '+' �����钎�ዾ�^
%    'glassminus' - ������ '-' �����钎�ዾ�^
%    'lrdrag'     - ��/�E�̃h���b�O�̃J�[�\��
%    'ldrag'   - ���h���b�O�J�[�\��
%    'rdrag'   - �E�h���b�O�J�[�\��
%    'uddrag'     - ��/���̃h���b�O�̃J�[�\��
%    'udrag'   - ������h���b�O�J�[�\��
%    'ddrag'   - �������h���b�O�J�[�\��
%    'add'        - + �����t�����
%    'addzero'    - o ��t���̖��
%    'addpole'    - 'x'��t���̖��
%    'eraser'     - �C���[�T
%    'help'       - �N�G�X�`�����}�[�N�t�����
%    [ crosshair | fullcrosshair | {arrow} | ibeam | watch | topl |...
%     topr | botl | botr | left | top | right | bottom | circle | ...
%     cross | fleur ]
%         - �W���̃J�[�\��
%
% SetData = setptr(CURSOR_NAME)�́A�w�肵�� CURSOR_NAME �Ƀ|�C���^��
% ���m�ɐݒ肷��v���p�e�B���ƒl�̑g���킹���܂ރZ���z����o�͂��܂��B��
% �Ƃ��΁A���̂悤�ɂ��܂��B
% 
%     SetData = setptr('arrow');set(FIG,SetData{:})

%   Author: T. Krauss, 10/95
%   Copyright 1984-2002 The MathWorks, Inc. 
