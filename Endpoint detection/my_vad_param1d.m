function [ B,E ] = my_vad_param1d( dist,T1,T2,MAX_TRANSITION_FRAME_LENGTH,MIN_SPEECH_FRAME_LENGTH )
%function [ output_args ] = my_vad_param1d( dist,T1,T2,MAX_TRANSITION_FRAME_LENGTH,MIN_SPEECH_FRAME_LENGTH )
%   Single parameter double threshold detection function
%
%   input parameters
%       Dist: distance measure for each frame
%       T1: low threshold
%       T2: high threshold
%       MAX_TRANSITION_FRAME_LENGTH: Number of frames for the maximum allowed transition
%       MIN_SPEECH_FRAME_LENGTH: The shortest number of voice frames allowed
%  return parameters
%       B: The frame number of the endpoint. Array¡£
%       E£ºThe frame number of the end point. Array.

if nargin < 5
   MIN_SPEECH_FRAME_LENGTH = 5;
end
if nargin < 4
    MAX_TRANSITION_FRAME_LENGTH = 8;
end


SILENCE = 0;
TRANSITION = 1;
SPEECH = 2;

state = SILENCE;
speech_counter = 0;
transition_counter = 0;

B = [];
E = [];

k_speech = 0; % Voice segment number

for k = 1 : length(dist)
    dist_k = dist(k);
    switch state
        case{SILENCE,TRANSITION} % From mute, transition
            if dist_k > T2 % The threshold that has entered the speech segment
                state = SPEECH;
                speech_counter = speech_counter + 1;
                transition_counter = 0;
                k_speech = k_speech + 1;
                B(k_speech) = k;
            elseif dist_k > T1 % In the transition only, the voice has not started yet.
                state = TRANSITION; 
                speech_counter = 0;
%                 speech_counter = speech_counter + 1;
%                 transition_counter = 0; 
            elseif dist_k < T1 % Still silent
                state = SILENCE;
                speech_counter = 0;
                transition_counter = 0;
            end
        case SPEECH % From the voice segment
            
            if dist_k > T1   % Higher than the low threshold, it is still in the voice segment.
                state = SPEECH;
                speech_counter = speech_counter + 1; % The voice segment continues to count
                transition_counter = 0;
            else % Below the lower T1 threshold, it "seems" to enter the silent segment.
                transition_counter = transition_counter + 1;
                % It is possible that the end of the speech may be a pause between speeches, possibly bursting noise
                if transition_counter < MAX_TRANSITION_FRAME_LENGTH % Less than the longest interval, pause in the predetermined voice
                    state = SPEECH; % It is also considered to be the voice segment --> to play the role of "sudence"
                    speech_counter = speech_counter + 1;
                    
                else % If the pause is long, it may be that the voice is over.it should be considered as noise.
                    if speech_counter < MIN_SPEECH_FRAME_LENGTH % Judging whether speech is over or noise
                        state = SILENCE; % noise
                        speech_counter = 0;
                        transition_counter = 0;
                        if k_speech > 0 % Just if the noise is mistaken as a starting point£¬
                            k_speech = k_speech - 1;
                            B = B(1:end-1); % Found that it is bursty noise, just remove the starting point of the record just 
                                            % from the starting point array
                        end
                    elseif speech_counter > MIN_SPEECH_FRAME_LENGTH % speech
                        state = SILENCE; % end
                        speech_counter = 0;
                        transition_counter = 0;
                        E(k_speech) = k;
                    end
                end
            end
    end
end

if length(B)>length(E) 
    % If the last destination is not found, the last frame is taken as the end point.
    E(length(E)+1) = length(dist);
end