
%COmpute the Jensen-Shannon Divergence
function d=jsd(OCI, OCJ)

numClasses = size(OCJ,1);

[m, OCI]=extractData(OCI);

d = zeros(numClasses,1);

for j=1:numClasses,
    
    [~,OCJcur] = extractData(OCJ(j,:));
    
    %get I-M distance
    d(j) = KLD(OCI,OCJcur);
    %get J-M distance;
 
   
end

end


function dKLD=KLD(OC1, OC2)

dKLD = trace(OC1.covOC*OC2.icovOC)+...
    trace(OC2.covOC*OC1.icovOC)+...
    trace((OC1.icovOC+OC2.icovOC)*...
    (OC1.meanOC-OC2.meanOC)'*(OC1.meanOC-OC2.meanOC));


end


%extract the data
function [m, stct] = extractData(OC)

    r=roots([1 1 -length(OC)]);
    m=round(r(2));
    
    stct.meanOC = OC(1:m);
    stct.covOC = OC(m+1:end);
    
    stct.covOC = (reshape(stct.covOC, m,m));
    stct.icovOC = inv(stct.covOC);
    
    

end


%%%% 
% what are n1 and n2?
function M=getMerged(OC1,OC2,m)

n1=m;
n2=m;
f1 = n1/(n1+n2);
f2 = n2/(n1+n2);

M.meanOC = OC1.meanOC*f1 + OC2.meanOC*f2;

meanTemp = (OC1.meanOC-OC2.meanOC);

M.covOC = f1*OC1.covOC + f2*OC2.covOC +...   
    f1*f2*(meanTemp'*meanTemp);

M.covOC = reshape(M.covOC, m,m);
M.icovOC = inv(M.covOC);



end

