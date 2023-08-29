% Parameters
image_raw = imread("Example_Image.png");
sound_len = 20;         % Desired length of sound clip, seconds
fs = 44100;             % Sampling frequency
gain = .8;              % Maximum amplitude
stochastic = true;      % Toggle between stochastic or deterministic signal

bins = min(floor(sqrt(sound_len*fs)), size(image_raw,1));

im = imresize(image_raw, [bins, bins]);
im = double(im2gray(im));
im = im - min(im, [],"all"); im = im/max(im,[],"all");

orig_win_len = size(im, 1);
half_target_win_len = floor(sound_len*fs / orig_win_len / 2);
num_wins = size(im, 2);

f_orig = linspace(0,fs/2,orig_win_len);
f_stretch = linspace(0, fs/2, half_target_win_len);

output = zeros(2*half_target_win_len * num_wins, 1);
j=0;
for i = 0:num_wins-1
    snippet = interp1(f_orig, im(:,i+1), f_stretch,"nearest");

    switch stochastic
        case false
            sig = fftshift(ifft(flip(snippet), 2*half_target_win_len));
        case true
            cacs = ifft(flip(snippet), 2*half_target_win_len);
            acs = real(cacs(1:half_target_win_len));
            
            R = toeplitz(acs(1:end-1));
            if rcond(R) < 1e-4
                j = j+1;
                % Use previous column
            else
                r = acs(2:end)';
                coeff = R\-r;
                d02 = dot([1; coeff], snippet);
                w = randn(1,2*half_target_win_len);
                sig = filter(coeff, d02, w);
            end
    end
    output(1+i*2*half_target_win_len:(i+1)*2*half_target_win_len) = real(sig);
end

output = (2*normalize(output,'range')-1)*gain;

audiowrite("output.wav",output,fs);




