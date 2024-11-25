shader_type canvas_item;

uniform vec4 water_color = vec4(0.0, 0.0, 1.0, 1.0);  // 蓝色水
uniform vec4 wall_color = vec4(0.8, 0.7, 0.5, 1.0);   // 土黄色管壁
uniform float pipe_diameter : hint_range(0.01, 1.0) = 0.4; // 水管的直径 (相对于屏幕宽度或高度)
uniform float wall_thickness : hint_range(0.01, 0.2) = 0.1; // 管壁的厚度
uniform int pipe_orientation : hint_range(0, 1) = 0; // 0: 横向, 1: 竖直

void fragment() {
    float pipe_x_start, pipe_x_end, pipe_y_start, pipe_y_end;
    float wall_x_start, wall_x_end, wall_y_start, wall_y_end;
    float water_x_start, water_x_end, water_y_start, water_y_end;

    // 横向水管 (pipe_orientation == 0)
    if (pipe_orientation == 0) {
        pipe_x_start = 0.0;  // 左边界，管子横向时从左到右
        pipe_x_end = 1.0;    // 右边界，管子横向时从左到右
        pipe_y_start = (1.0 - pipe_diameter) / 2.0; // 水管的上下范围
        pipe_y_end = pipe_y_start + pipe_diameter;  // 水管的上下范围

        // 管壁的y范围
        wall_y_start = pipe_y_start - wall_thickness;
        wall_y_end = pipe_y_end + wall_thickness;
        // 水管的墙壁横向不变
        wall_x_start = 0.0;
        wall_x_end = 1.0;

        // 水区域：宽高取最小值，保证是正方形
        float water_size = min(pipe_y_end - pipe_y_start, pipe_x_end - pipe_x_start);
        water_x_start = (1.0 - water_size) / 2.0;
        water_x_end = water_x_start + water_size;
        water_y_start = pipe_y_start;
        water_y_end = pipe_y_end;
    }
    // 竖直水管 (pipe_orientation == 1)
    else {
        pipe_x_start = (1.0 - pipe_diameter) / 2.0;  // 左边界，管子竖直时从上到下
        pipe_x_end = pipe_x_start + pipe_diameter;   // 右边界，管子竖直时从上到下
        pipe_y_start = 0.0;                          // 水管的上下范围
        pipe_y_end = 1.0;                            // 水管的上下范围

        // 管壁的x范围
        wall_x_start = pipe_x_start - wall_thickness;
        wall_x_end = pipe_x_end + wall_thickness;
        // 水管的墙壁竖向不变
        wall_y_start = 0.0;
        wall_y_end = 1.0;

        // 水区域：宽高取最小值，保证是正方形
        float water_size = min(pipe_x_end - pipe_x_start, pipe_y_end - pipe_y_start);
        water_y_start = (1.0 - water_size) / 2.0;
        water_y_end = water_y_start + water_size;
        water_x_start = pipe_x_start;
        water_x_end = pipe_x_end;
    }

    // Check if the current fragment's UV lies within the pipe wall or water area
    if (UV.x >= wall_x_start && UV.x <= wall_x_end && 
        UV.y >= wall_y_start && UV.y <= wall_y_end) {

        // If inside the pipe wall, show the wall color
        if (UV.x < pipe_x_start || UV.x > pipe_x_end || 
            UV.y < pipe_y_start || UV.y > pipe_y_end) {
            COLOR = wall_color;  // 显示管壁的颜色
        }
        // If inside the pipe water square, show the water color
        else if (UV.x >= water_x_start && UV.x <= water_x_end && 
                 UV.y >= water_y_start && UV.y <= water_y_end) {
            COLOR = water_color;  // 显示水的颜色
        }
        // Else, discard if not inside either
        else {
            discard;  // 不在水管范围内的像素透明
        }
    } else {
        discard;  // 不在水管范围内的像素透明
    }
}
