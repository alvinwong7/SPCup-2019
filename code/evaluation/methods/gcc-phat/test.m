clear variables
theta = -179:180;
phi = -90:90;
cost = zeros(length(theta),length(phi));

for i = 1:length(theta)
    for j = 1:length(phi)
        cost(i,j) = transition3(0,0,theta(i),phi(j),0.1,25);
    end
end

figure;
surf(cost(:,:),'EdgeColor','none')
axis xy; axis tight; colormap(jet); view(0,90);