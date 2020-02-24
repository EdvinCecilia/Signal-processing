   [x,fs]=audioread('test.wav');
   lfft = 1024;   % FFT length 
   lfft2 = lfft/2;
   winlgh = 256  %window length
   frmlgh = 32;  %frame length
   noverlap = winlgh - frmlgh;
   x = 2.0*x/max(abs(x)); %Framing the original signal
   etime = length(x)/fs; %During time
   spec = abs(spectrogram(x, winlgh, noverlap ,lfft, fs));  %Spectrum amplitude
%    subplot(211);
%    plot((1:length(x))/fs,x)
%    xlabel('Time (s)');
%    title('SPEECH');
%    axis([0 etime -2.5 2.5]);
%    subplot(212)
   imagesc(0:.010:etime, 0:1000:5000, log10(abs(spec)));axis('xy')
   xlabel('Time  (s)'),ylabel('Frequency  (Hz)');
   title('SPECTROGRAM');
%    colormap(hot);

 