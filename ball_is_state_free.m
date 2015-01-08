function [ ok ] = ball_is_state_free( state, state_limits, obstacles, radius, time_range )
%IS_STATE_FREE returns true if the given state is valid
% - state is the 10 dimensional state vector
% - state_limits limits for the state variables
% - obstacles is an n by 6 matrix where each row contains one corner and
% the distance to the other
% - quad_dim contains the size of the quadcopter bounding-box

ok = true;
max_dist = .5;

if isa(state,'sym')

    %dt = time_range(2)-time_range(1);
    r = [time_range(1):max_dist:time_range(2)];

    s = eval(subs(state,r));

    for ii=1:size(state_limits, 1)
        if sum(s(ii,:)<state_limits(ii, 1)) > 0 || sum(s(ii,:)>state_limits(ii, 2)) > 0
        %if ~isAlways(state(ii) >= state_limits(ii, 1)) || ~isAlways(state(ii) <= state_limits(ii, 2))
            ok = false;
            return;
        end
        if collides(obstacles, radius, s)
            ok = false;
            return;
        end
    end
elseif isa(state, 'function_handle')

    %dt = time_range(2)-time_range(1);
    r = [time_range(1):max_dist:time_range(2)];

    for jj=1:length(r)
        s = state(r(jj));
        for ii=1:size(state_limits, 1)
            if s(ii) < state_limits(ii, 1) || s(ii) > state_limits(ii, 2)
                ok = false;
                return;
            end
        end
        if collides(obstacles, radius, s)
            ok = false;
            return;
        end
    end

else
    for ii=1:size(state_limits, 1)
        if state(ii) < state_limits(ii, 1) || state(ii) > state_limits(ii, 2)
            ok = false;
            return;
        end
    end
    if collides(obstacles, radius, state)
        ok = false;
        return;
    end
end


end

function [coll] = collides(obstacles, radius, s)

n_obs = size(obstacles, 1);
coll = false;
for ii=1:n_obs
    
    obs = obstacles(ii,:)';
    c_min_bl = s(1:2)-obs(1:2);
    c_min_tr = s(1:2)-(obs(1:2)+obs(3:4));
    
    if s(1)>obs(1) && s(1)<obs(1)+obs(3) && s(2)>obs(2) && s(2)<obs(2)+obs(4)
        coll = true;
        return;
    end
    
    dist_bot_left  = c_min_bl(1)^2+c_min_bl(2)^2;
    dist_top_left  = c_min_bl(1)^2+c_min_tr(2)^2;
    dist_top_right = c_min_tr(1)^2+c_min_tr(2)^2;
    dist_bot_right = c_min_tr(1)^2+c_min_tr(2)^2;
    
    if dist_bot_left <= radius*radius || ...
            dist_top_left <= radius*radius || ...
            dist_top_right <= radius*radius || ...
            dist_bot_right <= radius*radius
        
        coll = true;
        return;
        
    end
    
    
end
            
end

