

figure('outerposition',[300 300 1200 600],'PaperUnits','points','PaperSize',[1200 600]); hold on

a = 1;
b = 2;

plot(VectorizedData(:,a),VectorizedData(:,b),'.')

plot(VectorizedData(m.idx == 'normal',a),VectorizedData(m.idx == 'normal',b),'r.')

C = zeros(size(VectorizedData,2),1);

for i = 1:size(VectorizedData,2)
	corr(VectorizedData(:,10),m.idx=='normal')
end