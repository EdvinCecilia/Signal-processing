function frameTime=frame2time(frameNum,framelen,inc,fs)
% Calculate the time corresponding to each frame after framing
frameTime=(((1:frameNum)-1)*inc+framelen/2)/fs;