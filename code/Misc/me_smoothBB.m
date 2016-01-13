function BB = me_smoothBB(timeline,BB,radius,stdev)
% timeline - time instances corresp to BB
% BB(:,fix) - [x y width height]' 
% length of the smoothing kernel (odd)

% start timeline from 1
timeline = timeline - timeline(1) + 1;

% convert to center/aspecthw/scale representation;
BB(1,:) = (2*BB(1,:)+BB(3,:)-1)/2;
BB(2,:) = (2*BB(2,:)+BB(4,:)-1)/2;
BB(3,:) = BB(4,:)./BB(3,:);
% height as scale



% smooth

fulltimeline = zeros(1,timeline(end));
fulltimeline(timeline) = 1;
fullbb = zeros(4,timeline(end));
fullbb(:,timeline) = BB;

kernel = normpdf(-radius:radius,0,stdev);

fulltimeline = filter2(kernel,padarray(fulltimeline,[0 radius],0),'valid');
fullbb = filter2(kernel,padarray(fullbb,[0 radius],0),'valid');
fullbb = fullbb./repmat(fulltimeline,4,1);

BB = fullbb(:,timeline);

% BB(1,:) = smooth(timeline,BB(1,:),span,'moving');
% BB(2,:) = smooth(timeline,BB(2,:),span,'moving');
% BB(3,:) = smooth(timeline,BB(3,:),span,'moving');
% BB(4,:) = smooth(timeline,BB(4,:),span,'moving');

% convert back
BB(3,:) = BB(4,:)./BB(3,:);
BB(1,:) = (2*BB(1,:)-BB(3,:)+1)/2;
BB(2,:) = (2*BB(2,:)-BB(4,:)+1)/2;

