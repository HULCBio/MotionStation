% SOS2CELL �́A�񎟌^�s����Z���z��ɕϊ����܂��B
% C = SOS2CELL(S) �́A���̌^������ L �s6��̓񎟌^�s�� S ��
%
%        S =   [B1 A1
%               B2 A2
%                ...
%               BL AL]
%
% ���̌^�������Z���z�� C �ɕϊ����܂��B
%
%     C = { {B1,A1}, {B2,A2}, ... {BL,AL} }
%
% �����ŁA�X�̕��q�x�N�g�� Bi �ƕ���x�N�g�� Ai �́A���`�܂��͓񎟂̑�
% �����̌W����\���܂��B
%
% �Q�C���v�f����͈����Ƃ��Đݒ肵�� C = SOS2CELL(S,G) �́A���̂悤��
% �^�̒萔���������̂ɕϊ����܂��B
%
%     C = { {G,1}, {B1,A1}, {B2,A2}, ... {BL,AL} }
%
% ���F
%     [b,a] = butter(4,.5);
%     [s,g] = tf2sos(b,a);
%     c = sos2cell(s,g)
%
% �Q�l�F CELL2SOS, TF2SOS, SOS2TF, ZP2SOS, SOS2ZP, SOS2SS, SS2SOS.



%   Copyright 1988-2002 The MathWorks, Inc.
