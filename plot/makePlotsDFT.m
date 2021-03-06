
%%
function makePlotsDFT(OPs, DFTs,p)
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
    figure
    subplot(211);
    plot((1:numPeriods),OPs);
    
    ylabel('Hz');
    xlabel('Hz');
    
    ticks=8;

    set(gca,'XTick',(1:round(numPeriods/ticks):numPeriods))
    set(gca,'XTickLabel',periodFreqs(1:round(end/ticks):end))
 
    title(periodicityTitle);
    set(gca, 'YDir', 'normal');
    xlabel('BPM');


    
    subplot(212);
    

    plot(DFTs);
    title('DFTs');
    set(gca, 'YDir', 'normal');
    xlabel('periodicity coefficients');
    ylabel('frequency coefficients');


end