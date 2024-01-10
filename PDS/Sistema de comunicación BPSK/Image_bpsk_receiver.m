clc
clear

%% BladeRF
Rx = bladeRF('*:serial=030');

Rx.rx.frequency = 900e6;
Rx.rx.samplerate = 4e6;
Rx.rx.bandwidth = 2e6;
Rx.rx.gain = 40;

Rx.rx.config.num_buffers = 64;
Rx.rx.config.buffer_size = 16384;
Rx.rx.config.num_transfers = 16;
fprintf('Running with the following settings:\n');
disp(Rx.rx)
disp(Rx.rx.config)
%% Start reception
Rx.rx.start();
%Receive 0.250s of samples
samples = Rx.receive(0.250 * Rx.rx.samplerate);
%% De-filter
nSpan = 1;
sps = 10;
decimationFactor = 10;
rxFilter = comm.RaisedCosineReceiveFilter("FilterSpanInSymbols",nSpan,...
    "InputSamplesPerSymbol",sps,...
    "DecimationFactor",decimationFactor);
rxFilteredSignal = rxFilter(samples);

rxFilteredSignal = rxFilteredSignal(nSpan+1:end);

%% BPSK Demodulation
demodulated = pskdemod(rxFilteredSignal, 2, pi);

scatterplot(rxFilteredSignal);
title('Constelation: Signal received');
xlabel('Real');
ylabel('Imaginary');
grid on;

%% Find preamble
rng(0);
length_preamble = 1e2;
preamble = randi([0, 1], 1, length_preamble);

correlation = xcorr(demodulated, preamble);
[~, idx] = max(correlation);
startIdx = idx - length(demodulated) + 1;

dataAfterPreamble = demodulated(startIdx + length_preamble:end);
%% Reconstruct the image
receivedImageBits = dataAfterPreamble;

numBits = numel(receivedImageBits);
numBytes = floor(numBits / 8) * 8;
receivedImageBits = receivedImageBits(1:numBytes);
receivedImageBytes = reshape(receivedImageBits,8, []).';
receivedGrayImage = bi2de(receivedImageBytes);
receivedImage = reshape(receivedGrayImage, size(receivedImageBytes));

%% Show image
imshow(receivedImage);
title('Received image');

 