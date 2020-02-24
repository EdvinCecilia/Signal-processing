%% Import audio
filedir=[];                             % Set file path
               
filename='test.wav';                    % Set file name
fle=[filedir filename];                 % Make up the file path and name
SNR = 5;                                %Signal to noise ratio
[xx,fs] = audioread(fle);
xx=xx-mean(xx);                         % Eliminate DC component
x=xx/max(abs(xx));                      % Amplitude normalization
N=length(x);                            % Take signal length
time=(0:N-1)/fs;                        % Set time
signal=Gnoisegen(x,SNR);                % Superimposed noise

figure(1);
subplot(311);
plot(time,signal);
xlabel('Frame Time');
ylabel('Amplitude')
title('Original Signal');

%% Short-term energy extraction

% Set frame length, step size
wlen_time = 0.02; % [s]
step_time = 0.01; % [s]
wlen = round(wlen_time*fs);
nstep = round(step_time*fs);
nframes = fix((length(x)-wlen)/nstep)+1; % Frame number
frame_time = frame2time(nframes, wlen, nstep, fs); % Calculate the time corresponding to each frame

Er = get_st_energy( x,fs,wlen_time,step_time,'hamming','dB' );
% Because of noise, consider filtering the Er to smooth it.
Er = multimidfilter(Er,3);

figure(1);
subplot(312)
plot(frame_time,Er);
xlabel('Frame Time');
ylabel('Energy(dB)');
title('Short-term Energy');

%% 2. Get noise characteristics and define some parameters needed for silent detection
% (1) Measure environmental noise and obtain some noise parameters
noise_frame_idx=floor((0.1-wlen_time)/step_time)+1; % % Assume that the first 100ms is ambient noise
eavg=mean(Er(1:noise_frame_idx)); % Calculate the average short-term power of ambient noise
esig=std(Er(1:noise_frame_idx)); % Calculate the standard deviation of short-time power of ambient noise

% (2) Set threshold based on background noise
ITU = -15; % constant in the range [-10 -20] dB
ITR_HIGH = max([ITU-10 eavg+3*esig]); % The mean is increased by 3 times the standard deviation as the threshold for short-term power
ITR_LOW = ITR_HIGH - 3; % Greater than ITR_LOW, less than ITR_LOW, thought to be between voice and mute

%% 3. Single parameter double threshold detection
T1 = ITR_LOW;
T2 = ITR_HIGH;

SILENCE = 0;
TRANSITION = 1;
SPEECH = 2;

MAX_TRANSITION_FRAME_LENGTH = 10;
MIN_SPEECH_FRAME_LENGTH = 4;

dist = Er;
[B,E] = my_vad_param1d( dist,T1,T2,MAX_TRANSITION_FRAME_LENGTH,MIN_SPEECH_FRAME_LENGTH );

%% Draw
figure(1);
subplot(313);
plot(time,signal);
for k=1 : length(E)                           % Draw the starting point
    nx1= B(k);
    nx2 = E(k);
    line([frame_time(nx1) frame_time(nx1)],[-1.5 1.5],'color','r','LineStyle','-');
    line([frame_time(nx2) frame_time(nx2)],[-1.5 1.5],'color','r','LineStyle','--');
end

%% Play the sound
% for k=1 : length(E)
%     nx1= B(k);
%     nx2 = E(k);
%     fprintf('Press any key to continue...\n');
%     pause;
%     sound(signal(round(frame_time(nx1)*fs):round(frame_time(nx2)*fs)),fs);
% end
