function E = get_st_energy( x,fs,wlen_time,step_time,win_type,energy_unit )
%function zcr = get_st_energy( x,fs,wlen_time,step_time,win_type,energy_unit )
%   Get short-term energy (not divided by frame length, so not calculated power).
%   Input parameters
%          x: voice signal --> mono
%           Fs: sampling rate
%           Wlen_time: window time (s)
%           Step_time: step time (s)
%           win_type£º'hamming','hanning',...,use hamming 
%           energy_unit£º'dB'£¬Displayed in normalized energy (unit: dB). Otherwise it is a linear scale.
%   Return parameter
%           E£ºShort-term energy (abscissa is the frame number)

wlen = round(wlen_time * fs);
nstep = round(step_time * fs);

if nargin < 5
    win = hamming(wlen);
elseif nargin == 5
    if strcmp(win_type, 'hamming')
        win = hamming(wlen);
    elseif strcmp(win_type, 'hanning')
        win = hanning(wlen);
    else
        win = hamming(wlen);
    end
else
    win = hamming(wlen);
end

nFrames = floor((length(x) - wlen)/nstep) + 1; %Total number of frames
E = [];

for k = 1:nFrames
    idx = (k-1) * nstep + (1:wlen);
    x_sub = x(idx) .* win;
    E(k) = sum(x_sub.^2); 
end

% Whether it needs to be converted into dB
if nargin == 6
    if strcmp(energy_unit, 'dB') 
        E = 10*log10(E/max(E)+eps);
    end
end
end