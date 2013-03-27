%%
function makePlotsOPsOCs(OCs, OPs,p)
    opWin = p.opWin;
    fs = p.fs;
    numPeriods = p.numPeriods;


% plot
    winTime = opWin / (fs);
    periodicityTitle = ['OP ' '- Window Size: ' ...
        num2str(winTime) ' secs'];

    
    % periodicity range 40-800 bpm
    %frequency range 
    
    %set up OPs axes

   
    b = log10(p.lowPeriod);
    e = log10(p.hiPeriod);

    periodFreqs = logspace(b,e,numPeriods);
    
    f = p.numFreqs;
    
    %calc freq vec
    freqs = zeros(f,1);
    freqs(1)=p.bottomFreq;

    %find center  frequencys for 85 filters
    for i=2:f
        freqs(i)=freqs(i-1)*pow2(103.6/1200);
    end
    
    figure;
    
    imagesc((1:numPeriods),(1:f),OPs);
    
    ylabel('Hz');
    xlabel('Hz');
    
    ticks=8;
    
    set(gca,'YTick',(1:f/ticks:f))
    set(gca,'YTickLabel',freqs(1:round(f/ticks):f))
    set(gca,'XTick',(1:round(numPeriods/ticks):numPeriods))
    set(gca,'XTickLabel',periodFreqs(1:round(end/ticks):end))
 
    title(periodicityTitle);
    set(gca, 'YDir', 'normal');
    xlabel('BPM');
    ylabel('Hz');


    figure;
    OCs = OCs(1:p.pCoeff*p.fCoeff);
    imagesc(reshape(OCs,p.fCoeff,p.pCoeff));
    title('OCs');
    set(gca, 'YDir', 'normal');
    xlabel('periodicity coefficients');
    ylabel('frequency coefficients');


end