function dY = WienerDeriv(y, dx, order)
% dY = WienerDeriv(y, dx, order)
% Calculate derivative of noisy signal y using the fft of y.
% Assumes noise is white noise and signal is band-limited to have ZERO
%  power at half the Nyquist frequency or greater.
% INPUTS:
%  -y: true signal plus additive white noise.
%  -dx:  sampling interval
%  OPTIONAL:
%  -order: order of derivative, defaults to 1
% OUTPUTS:
%  -dY:  estimated derivative of signal
if nargin < 3
  order = 1;
elseif nargin < 2
  help WienerDeriv
  if nargout == 0
    return
  else
    error('Invalid number of input arguments.')
  end
end

y = y - mean(y);
yFft = fft(y);
[ySpectrum, w] = Spectrum(y);
iw = 1i * w;

nSpectrum = getNoiseSpectrum(ySpectrum);

filter = iw.^(order) .* (1 - abs(nSpectrum ./ ySpectrum'));
yFft = yFft .* filter';
dY = ifft(yFft, 'symmetric');
return



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function nSpectrum = getNoiseSpectrum(ySpectrum)
% Assume noise is white noise, and signal has ZERO power at half the
%  Nyquest frequency or faster

numCorr = length(ySpectrum);

fastInd = round(numCorr / 4);
noiseRange = fastInd:(numCorr + 1 - fastInd);
yNoise = sqrt(abs(ySpectrum(noiseRange)));
nAmp = median(yNoise).^2; %#ok<NASGU>
nMax = max(yNoise).^2;

% Set anything below nAmp amplitude as white noise
nAmp = nMax;
bigInd = abs(ySpectrum) > nAmp;
nSpectrum(~bigInd) = ySpectrum(~bigInd);
nSpectrum(bigInd) = nAmp * sign(ySpectrum(bigInd));
return
