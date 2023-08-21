% Parameters
image_raw = imread("Example_Image.png");
sound_len = 5;          % Desired length of sound clip, seconds
fs = 44100;             % Sampling frequency

im = double(im2gray(image_raw));
im = im - min(im, [],"all"); im = im/max(im,[],"all");

target_win_len = floor(sound_len * fs / size(im, 1));
orig_win_len = size(im, 1);
num_wins = size(im, 2);

output = zeros(target_win_len * num_wins, 1);
for i = 0:num_wins-1
    % win = bartlett(orig_win_len);
    snippet = flip(im(:,i+1)); %.*win
    sig = ifft(snippet, target_win_len);
    output(1+i*target_win_len:(i+1)*target_win_len) = real(sig);
end
output = normalize(output,'range')*.8;

audiowrite("output.wav",output,fs);




