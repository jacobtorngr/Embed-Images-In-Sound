% Parameters
image_raw = imread("Example_Image.png");
sound_len = 5;          % Desired length of sound clip, seconds
fs = 44100;             % Sampling frequency

bins = min(floor(fs*sound_len / size(image_raw,2)), size(image_raw,1));
im = imresize(image_raw, [bins,...
    floor(bins*(size(image_raw,2)/size(image_raw,1)))]);
im = double(im2gray(im));
im = im - min(im, [],"all"); im = im/max(im,[],"all");

orig_win_len = size(im, 1);
half_target_win_len = floor(sound_len*fs / orig_win_len / 2);
num_wins = size(im, 2);

f_orig = linspace(0,fs/2,orig_win_len);
f_stretch = linspace(0, fs/2, half_target_win_len);

output = zeros(2*half_target_win_len * num_wins, 1);
for i = 0:num_wins-1
    snippet = interp1(f_orig, im(:,i+1), f_stretch,"nearest");
    sig = fftshift(ifft(flip(snippet), 2*half_target_win_len));
    output(1+i*2*half_target_win_len:(i+1)*2*half_target_win_len) = real(sig);
end
output = (2*normalize(output,'range')-1)*.8;

audiowrite("output.wav",output,fs);




