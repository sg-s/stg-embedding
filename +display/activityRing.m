% plots activity rings allowing us to visualize 
% many burst metris at once 

function activityRing(origin, PD_dc, LP_dc, LP_phase, base_radius)


% first make a circle
theta = pi/2-linspace(0,2*pi,100);
radius = base_radius*ones(100,1);
[x,y]=pol2cart(theta(:),radius);
plot(origin(1)+x,origin(2)+y,'Color',[.8 .8 .8],'LineWidth',3)

% show PD activity
theta = pi/2-linspace(0,PD_dc*2*pi,20);
radius = base_radius*ones(20,1);
radius_inner = .6*ones(20,1);

[x,y]=pol2cart(theta(:),radius);
[x2,y2]=pol2cart(theta(:),radius_inner);


fill(origin(1)+[x; flipud(x2)],origin(2)+[y; flipud(y2)],[.5 .5 .5])


% now show LP activity
theta = pi/2-linspace(LP_phase*2*pi,(LP_dc + LP_phase)*2*pi,20);
radius_inner = base_radius*ones(20,1);
radius = base_radius*1.4*ones(20,1);

[x,y]=pol2cart(theta(:),radius);
[x2,y2]=pol2cart(theta(:),radius_inner);

fill(origin(1)+[x; flipud(x2)],origin(2)+[y; flipud(y2)],[1 .5 .5])

