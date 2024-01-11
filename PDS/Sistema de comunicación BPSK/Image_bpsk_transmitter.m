clc;
clear;
%% Create bits and preamble
rng('default'); % Reproducibility
% Generating random preamble and signal (bits)
length_preamble = 1e2;
preamble = randi([0, 1], 1, length_preamble);

original_image = imread('lena.png');
figure(2)
imshow(original_image); title('original');
binary_sequence = reshape((dec2bin(typecast(original_image(:), 'uint8'), 8) - '0').', 1, []);

% binary_sequence = [preamble binary_sequence];

length_signal = length(binary_sequence);

index = randi(length_signal - length_preamble + 1);

binary_sequence = [randi([0, 1], 1, 2*length_preamble), preamble, binary_sequence];
%% BPSK modulation
modulated = pskmod(binary_sequence, 2, pi);
scatterplot(modulated);
title('Señal Modulada BPSK');
xlabel('Parte Real');
ylabel('Parte Imaginaria');
grid on;

%% Filtering
nSpan = 1;
sps = 10;
txFilter = comm.RaisedCosineTransmitFilter("FilterSpanInSymbols",nSpan,...
    "OutputSamplesPerSymbol",sps);
txSignal = txFilter([modulated'; zeros(nSpan,1)]);

%% BladeRF
Tx = bladeRF('*:serial=030');

Tx.tx.frequency = 900e6;
Tx.tx.samplerate = 4e6;
Tx.tx.bandwidth = 2e6;
Tx.tx.gain = 40;

Tx.tx.config.num_buffers = 64;
Tx.tx.config.buffer_size = 16384;
Tx.tx.config.num_transfers = 16;

fprintf('Running with the following settings:\n');
disp(Tx.tx)
disp(Tx.tx.config)
%% Start transmition
Tx.tx.start();
delay_seconds = 0;

Tx.transmit(txSignal, delay_seconds, 0, true, true);