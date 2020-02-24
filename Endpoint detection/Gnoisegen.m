function [y,noise] = Gnoisegen(x,snr)
% The Gnoisegen function superimposes Gaussian white noise into the speech signal x.
% [y,noise] = Gnoisegen(x,snr)
% x is the voice signal, and snr is the set signal-to-noise ratio in dB.
% y is the noisy speech after superimposing Gaussian white noise, noise is the superimposed noise
noise=randn(size(x));              % Generating Gaussian white noise with randn function
Nx=length(x);                      % Find the signal x length
signal_power = 1/Nx*sum(x.*x);     % Find the average energy of the signal
noise_power=1/Nx*sum(noise.*noise);% Find the energy of the noise
noise_variance = signal_power / ( 10^(snr/10) );    % 	Calculate the variance value of the noise setting
noise=sqrt(noise_variance/noise_power)*noise;       % Corresponding white noise according to the average energy of noise
y=x+noise;                         % Forming noisy speech
