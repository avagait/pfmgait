function mj_displayDenseFeatsOnVideo(F, avifile)
% mj_displayDenseFeatsOnVideo(F, avifile)
% Display dense points computed with Wang's software
% Based on 'displayDenseFeats'
%  - F: struct-array
%  - avifile: path to video file
%
% (c) MJMJ/2015

%% Prepare source video
videoSource = vision.VideoFileReader(avifile,'ImageColorSpace','Intensity','VideoOutputDataType','uint8');
frameIdx = 0;

%% Useful vars
frames = [F.frix];
uframes = unique(frames);
nframes = length(uframes);
lastframe = uframes(end);

%% Display tracklets
for ix = 1:nframes,   
   frix = uframes(ix);   

   % Forward
   while frameIdx < frix
      if ~isDone(videoSource)
         frame  = step(videoSource);
      end
      frameIdx = frameIdx + 1;
   end
   
   cframe = frames == frix;
   T = mj_recoverDTfromFeats(F(cframe));
   
   clf   
   imshow(frame);
   hold on
   %title(sprintf('Frame: %03d ', frix));
   set(gcf,'name',sprintf('Frame: %03d ', frix),'numbertitle','off') 
   
   % Draw tracklets
   for fix_ = 1:size(T,3) %:nfeats
      fix = fix_;
      x = T(1,:,fix);%x = T(1,:,fix_);
      y = T(2,:,fix);%y = T(2,:,fix_);
      plot(x, y, 'g', 'LineWidth',2);
      hold on
      plot(x(end), y(end), 'or', 'LineWidth', 2);          
   end % fix_
   
   drawnow
   
   if frix ~= lastframe
      pause(1.0/25);      
   end
   
end % ix

release(videoSource);
