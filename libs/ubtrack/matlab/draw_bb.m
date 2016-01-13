function draw_bb(BB, col, bb_thick,  score, id)

% draw_bb(BB, col, bb_thick,  score, id,  pars)
% Draws bounding-box BB to current figure
%
% Input:
% - BB = [minx maxx miny maxy]
% - col = an index into colors(col,:) (a global color table)
% - score = draw score in same color as BB
% - id = draw id in same color as BB
%
% Author:
% V. Ferrari
%

% fetch colors from global workspace
global colors;

% bb color
col_id = col;
col_id = mod(col_id-1,size(colors,1))+1;
col = colors(col_id,:);

% Draw BB (= 4 line segments)
hold on;
plot([BB(1) BB(2) BB(2) BB(1) BB(1)], [BB(3) BB(3) BB(4) BB(4) BB(3)], 'Color', col, 'LineWidth', bb_thick);

% Draw score
score_size = 15;
min_x = BB(1)+bb_thick/2+4;
min_y = BB(3)+bb_thick/2+score_size/2+3;
% text(x,y,...) is drawn with the bottom-right of the first char on x,y
text(min_x, min_y, num2str(score,'%1.3f'), 'color', col, 'FontSize', 15, 'FontWeight', 'bold');

% Draw id
id_size = 15;
min_x = BB(1)+bb_thick/2+4;
min_y = BB(4)-bb_thick/2-id_size/2;
text(min_x, min_y, num2str(id), 'color', col, 'FontSize', 15, 'FontWeight', 'bold');
