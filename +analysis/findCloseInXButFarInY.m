function [A,B]=findCloseInXButFarInY(X,Y,A,B)


arguments
	X (:,2)
	Y (:,2)
	A
	B
end



% rm_this = isnan(sum(X,2)) | isnan(sum(Y,2));

% X = normalize(X);
% Y = normalize(Y);


% N = 1e3;
% D = zeros(N,1);
% A = zeros(N,1);
% B = zeros(N,1);

% for i = 1:N

% 	a = randi(length(X),100,1);

% 	DX = pdist(X(a,:));
% 	DX(DX>1) = Inf;
% 	DY = pdist(Y(a,:));
% 	DY(DY<1) = -Inf;
% 	DY(DY>2) = 2;
% 	DD = squareform(DX - DY);

% 	[row,col] = find(DD==min(DD(:)));

% 	A(i) = a(row(1));
% 	B(i) = a(col(1));

% 	D(i) = min(DD(:));

% end

% [~,idx]=min(D);
% A = A(idx);
% B = B(idx);


% debug

figure('outerposition',[300 300 1200 901],'PaperUnits','points','PaperSize',[1200 901]); hold on
subplot(2,2,1); hold on
plot(X(:,1),X(:,2),'.','Color',[.5 .5 .5])
plot(X([A B],1),X([A B],2),'ro','MarkerFaceColor','r')


subplot(2,2,2); hold on
plot(Y(:,1),Y(:,2),'.','Color',[.5 .5 .5])
plot(Y([A B],1),Y([A B],2),'ro','MarkerFaceColor','r')