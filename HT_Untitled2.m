% sourceChoice = {'recorded'|'live'}
sourceChoice = 'recorded';

% Set for how long the live processing should last
endTime = 20;
% And how many samples per channel should be acquired and processed at each
% iteration
audioFrameLength = 3200;

switch sourceChoice
    case 'live'
        fs = 16000;
        audioInput = audioDeviceReader(...
            'Device', 'Microphone Array (Microsoft Kinect USB Audio)',...
            'SampleRate', fs, ...
            'NumChannels', 4,...
            'OutputDataType','double',...
            'SamplesPerFrame', audioFrameLength);
    case 'recorded'
        % The following audio files holds a 20-second recording of 4 raw
        % audio channels acquired with a Microsoft Kinect(TM) for
        % Windows(R) in the presence of a noisy source moving in front of
        % the array roughly from -40 to about +40 degrees and then back
        % to the initial position.
        audioFileName = 'Z:\QuailKit\audio\SM304472_0+1_20181004$110000.wav';
        audioInput = dsp.AudioFileReader(...
            'OutputDataType','double',...
            'Filename', audioFileName,...
            'PlayCount', inf, ...
            'SamplesPerFrame', audioFrameLength);
        fs = audioInput.SampleRate;
end
micPositions = [0,0.2];
micPairs = [1,2];
numPairs = size(micPairs, 1);
bufferLength = 64;

% Use a helper object to rearrange the input samples according the how the
% microphone pairs are selected
preprocessor = PairArrayPreprocessor(...
    'MicPositions', micPositions,...
    'MicPairs', micPairs,...
    'BufferLength', bufferLength);
micSeparations = getPairSeparations(preprocessor);

% The main algorithmic builing block of this example is a cross-correlator.
% That is used in conjunction with an interpolator to ensure a finer DOA
% resolution. In this simple case it is sufficient to use the same two
% objects across the different pairs available. In general, however,
% different channels may need to independently save their internal states
% and hence to be handled by separate objects.
XCorrelator = dsp.Crosscorrelator(...
    'Method', 'Frequency Domain');
interpFactor = 8;
b = interpFactor * fir1((2*interpFactor*8-1),1/interpFactor);
groupDelay = median(grpdelay(b));
interpolator = dsp.FIRInterpolator(...
    'InterpolationFactor',interpFactor,...
    'Numerator',b);
tic
for idx = 1:(endTime*fs/audioFrameLength)
    cycleStart = toc;
    % Read a multichannel frame from the audio source
    % The returned array is of size AudioFrameLength x size(micPositions,2)
    multichannelAudioFrame = audioInput();

    % Rearrange the acquired sample in 4-D array of size
    % bufferLength x numBuffers x 2 x numPairs where 2 is the number of
    % channels per microphone pair
    bufferedFrame = preprocessor(multichannelAudioFrame);

    % First estimate the DOA for each pair, independently

    % Initialize arrays used across available pairs
    numBuffers = size(bufferedFrame, 2);
    delays = zeros(1,numPairs);
    anglesInRadians = zeros(1,numPairs);
    xcDense = zeros((2*bufferLength-1)*interpFactor, numPairs);

    % Loop through available pairs
    for kPair = 1:numPairs
        % Estimate inter-microphone delay for each 2-channel buffer
        delayVector = zeros(numBuffers, 1);
        for kBuffer = 1:numBuffers
            % Cross-correlate pair channels to get a coarse
            % crosscorrelation
            xcCoarse = XCorrelator( ...
                bufferedFrame(:,kBuffer,1,kPair), ...
                bufferedFrame(:,kBuffer,2,kPair));

            % Interpolate to increase spatial resolution
            xcDense = interpolator(flipud(xcCoarse));

            % Extract position of maximum, equal to delay in sample time
            % units, including the group delay of the interpolation filter
            [~,idxloc] = max(xcDense);
            delayVector(kBuffer) = ...
                (idxloc - groupDelay)/interpFactor - bufferLength;
        end

        % Combine DOA estimation across pairs by selecting the median value
        delays(kPair) = median(delayVector);

        % Convert delay into angle using the microsoft pair spatial
        % separations provided
        anglesInRadians(kPair) = HelperDelayToAngle(delays(kPair), fs, ...
            micSeparations(kPair));
    end

    % Combine DOA estimation across pairs by keeping only the median value
    DOAInRadians = median(anglesInRadians);

    % Arrow display
    DOAPointer(DOAInRadians)

    % Delay cycle execution artificially if using recorded data
    if(strcmp(sourceChoice,'recorded'))
        pause(audioFrameLength/fs - toc + cycleStart)
    end
end

release(audioInput)