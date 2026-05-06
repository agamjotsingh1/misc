% (a, b) is center, v is velocity
function robotic_arm_circle(a, b, radius, v)
    % Link lengths = 1 m 
    L1 = 1;
    L2 = 1;

    % Angular Velocity of end effector = omega
    omega = v/radius;

    figure;
    hold on;
    axis equal;
    grid on;
    title('2-Link Robotic Arm Circle Path Following');
    xlabel('X');
    ylabel('Y');
    prev_theta1 = 0;
    prev_omega1 = 0;
    prev_theta2 = 0;
    prev_omega2 = 0;

    dt = 0.1; % time step for discretizing the motion

    % Plotting the circle for the end effector to trace
    theta_circle = linspace(0, 2*pi, 1000);
    x_circle = a + radius*cos(theta_circle);
    y_circle = b + radius*sin(theta_circle);

    % t in range 0 to 1000 with step size = dt
    for t = 0:dt:1000
        % (x, y) is the coordinate of the end effector
        x = a + radius*cos(omega*t);
        y = b + radius*sin(omega*t);

        % r distance from origin (not center)
        r = sqrt(x^2 + y^2);

        % Checking for out of reach points
        if r > L1 + L2
            fprintf("Out of reach: (%f, %f)\n", x, y);
            continue;
        end

        % Applying inverse kinematics to get the angles
        cos_theta2 = (r^2 - L1^2 - L2^2) / (2 * L1 * L2);
        theta2 = atan2(-sqrt(1 - cos_theta2^2), cos_theta2);
        beta = atan2(y, x);
        gamma = atan2(L2 * sin(theta2), L1 + L2 * cos(theta2));
        theta1 = beta - gamma;

        % Finding angular velocity (omega1 and omega2) = d(theta)/dt
        % and angular acceleration (alpha1 and alpha2) = d(omega)/dt
        % of both the actuators
        % The omega in d(omega)/dt is referring to omega1 and omega2, not the variable omega
        omega1 = (theta1 - prev_theta1)/dt;
        omega2 = (theta2 - prev_theta2)/dt;

        alpha1 = (omega1 - prev_omega1)/dt;
        alpha2 = (omega2 - prev_omega2)/dt;

        prev_theta1 = theta1;
        prev_theta2 = theta2;
        prev_omega1 = omega1;
        prev_omega2 = omega2;

        fprintf("Angle made with x-axis: Link 1 = %f degrees, Link 2 = %f degrees\n", rad2deg(theta1), rad2deg(theta1 + theta2));
        fprintf("Angular Velocity: Actuator 1 = %f, Actuator 2 = %f\n", omega1, omega2);
        fprintf("Angular Acceleration: Actuator 1 = %f, Actuator 2 = %f\n", alpha1, alpha2);

        % Plotting the arm and circle to trace for animation
        x1 = L1 * cos(theta1);
        y1 = L1 * sin(theta1);
        x2 = x1 + L2 * cos(theta1 + theta2);
        y2 = y1 + L2 * sin(theta1 + theta2);
        cla;
       
        plot(x_circle, y_circle, 'k');

        plot(0, 0, 'ks', 'MarkerSize', 10, 'MarkerFaceColor', 'k');
        plot([0, x1], [0, y1], 'b', 'LineWidth', 6);
        plot([x1, x2], [y1, y2], 'r', 'LineWidth', 8);
        plot(x1, y1, 'ko', 'MarkerSize', 8, 'MarkerFaceColor', 'k');
        plot(x2, y2, 'go', 'MarkerSize', 6, 'MarkerFaceColor', 'g');
        plot(x, y, 'mo', 'MarkerSize', 8, 'MarkerFaceColor', 'k');
        xlim([-2, 2]);
        ylim([-2, 2]);
        text(-18, 20, sprintf('θ1: %.1f°, θ2: %.1f°', theta1*180/pi, theta2*180/pi));
        err = sqrt((x2-x)^2 + (y2-y)^2);
        text(-18, 18, sprintf('Error: %.2f units', err));
        pause(0.01);

    end
end
