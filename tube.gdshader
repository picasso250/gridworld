shader_type canvas_item;

uniform vec4 water_color = vec4(0.5, 0.8, 1.0, 1.0);  // 浅蓝色水
uniform vec4 wall_color = vec4(0.6, 0.5, 0.45, 1.0);   // 暖灰色管壁

uniform float pipe_diameter : hint_range(0.01, 1.0) = 0.4; // 水管的直径 (相对于屏幕宽度或高度)
uniform float wall_thickness : hint_range(0.01, 0.2) = 0.1; // 管壁的厚度
uniform int pipe_orientation : hint_range(0, 1) = 0; // 0: 横向, 1: 竖直
uniform float water_speed : hint_range(0.0, 1.0) = 0.5;  // 水的移动速度

void fragment() {
    float pipe_x_start, pipe_x_end, pipe_y_start, pipe_y_end;
    float wall_x_start, wall_x_end, wall_y_start, wall_y_end;
    float water_x_start, water_x_end, water_y_start, water_y_end;
    float water_x_start2, water_x_end2, water_y_start2, water_y_end2;

    // 修改此处，使time_offset的范围变为[0, 1)
    float time_offset = fract(TIME * water_speed);  // 让水流在[0, 1)范围内平铺

    // 横向水管 (pipe_orientation == 0)
    if (pipe_orientation == 0) {
        pipe_x_start = 0.0;
        pipe_x_end = 1.0;
        pipe_y_start = (1.0 - pipe_diameter) / 2.0;
        pipe_y_end = pipe_y_start + pipe_diameter;

        // 管壁的y范围
        wall_y_start = pipe_y_start - wall_thickness;
        wall_y_end = pipe_y_end + wall_thickness;
        wall_x_start = 0.0;
        wall_x_end = 1.0;

        // 水区域：宽高取最小值，保证是正方形
        float water_size = min(pipe_y_end - pipe_y_start, pipe_x_end - pipe_x_start);
        
        // 水流的X轴偏移，周期性平铺
        water_x_start = fract((1.0 - water_size) / 2.0 + time_offset);  // 循环在[0, 1)范围
        water_x_end = water_x_start + water_size;
        water_y_start = pipe_y_start;
        water_y_end = pipe_y_end;

        // 计算第二个水流区域，它将在第一个区域的右侧平铺
        water_x_start2 = water_x_start - 1.0;  // 从左边接续
        water_x_end2 = water_x_start2 + water_size;
        water_y_start2 = pipe_y_start;
        water_y_end2 = pipe_y_end;
    }
    // 竖直水管 (pipe_orientation == 1)
    else {
        pipe_x_start = (1.0 - pipe_diameter) / 2.0;
        pipe_x_end = pipe_x_start + pipe_diameter;
        pipe_y_start = 0.0;
        pipe_y_end = 1.0;

        wall_x_start = pipe_x_start - wall_thickness;
        wall_x_end = pipe_x_end + wall_thickness;
        wall_y_start = 0.0;
        wall_y_end = 1.0;

        // 水区域：宽高取最小值，保证是正方形
        float water_size = min(pipe_x_end - pipe_x_start, pipe_y_end - pipe_y_start);
        
        // 水流的Y轴偏移，周期性平铺
        water_y_start = fract((1.0 - water_size) / 2.0 + time_offset);  // 循环在[0, 1)范围
        water_y_end = water_y_start + water_size;
        water_x_start = pipe_x_start;
        water_x_end = pipe_x_end;

        // 计算第二个水流区域，它将在第一个区域的下方平铺
        water_y_start2 = water_y_start - 1.0;  // 从下方接续
        water_y_end2 = water_y_start2 + water_size;
        water_x_start2 = pipe_x_start;
        water_x_end2 = pipe_x_end;
    }

    // 检查当前片元是否在水流区域或其平铺部分内
    if (UV.x >= wall_x_start && UV.x <= wall_x_end && 
        UV.y >= wall_y_start && UV.y <= wall_y_end) {

        // 如果当前片元在管壁区域，显示管壁颜色
        if (UV.x < pipe_x_start || UV.x > pipe_x_end || 
            UV.y < pipe_y_start || UV.y > pipe_y_end) {
            COLOR = wall_color;  // 显示管壁的颜色
        }
        // 如果当前片元在水流区域或其平铺部分内，显示水的颜色
        else if ((UV.x >= water_x_start && UV.x <= water_x_end && 
                  UV.y >= water_y_start && UV.y <= water_y_end) ||
                 (UV.x >= water_x_start2 && UV.x <= water_x_end2 && 
                  UV.y >= water_y_start2 && UV.y <= water_y_end2)) {
            COLOR = water_color;  // 显示水的颜色
        }
        // 否则，丢弃该片元
        else {
            discard;  // 不在水管范围内的像素透明
        }
    } else {
        discard;  // 不在水管范围内的像素透明
    }
}
