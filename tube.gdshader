shader_type canvas_item;

uniform vec4 water_color = vec4(0.5, 0.8, 1.0, 1.0);  // 水的颜色
uniform vec4 pipe_color = vec4(0.6, 0.5, 0.45, 1.0);   // 水管的颜色

uniform float pipe_size : hint_range(0.01, 1.0) = 0.4; // 水管的直径
uniform float water_size : hint_range(0.01, 1.0) = 0.2;  // 水的大小

// 控制水的位置，使用 vec2 来合并水平和垂直位置
uniform vec2 water_center = vec2(0.5, 0.5);  // 水的中心位置
uniform vec2 water2_center = vec2(0.5, 0.5); // 第二片水的中心位置

// 控制是否显示水管的四个小胳膊
uniform bool show_left_arm = false;   // 是否显示左边小胳膊
uniform bool show_right_arm = false;  // 是否显示右边小胳膊
uniform bool show_top_arm = false;    // 是否显示上边小胳膊
uniform bool show_bottom_arm = false; // 是否显示下边小胳膊

void fragment() {
    float pipe_x_start, pipe_x_end, pipe_y_start, pipe_y_end;
    float water_x_start, water_x_end, water_y_start, water_y_end;
    float water2_x_start, water2_x_end, water2_y_start, water2_y_end;

    // 计算管子的位置
    pipe_x_start = (1.0 - pipe_size) / 2.0;
    pipe_x_end = pipe_x_start + pipe_size;
    pipe_y_start = (1.0 - pipe_size) / 2.0;
    pipe_y_end = pipe_y_start + pipe_size;

    // 计算水的位置，基于水的中心
    water_x_start = water_center.x - water_size / 2.0;
    water_x_end = water_x_start + water_size;
    water_y_start = water_center.y - water_size / 2.0;
    water_y_end = water_y_start + water_size;

    // 计算第二片水的位置，基于水2的中心
    water2_x_start = water2_center.x - water_size / 2.0;
    water2_x_end = water2_x_start + water_size;
    water2_y_start = water2_center.y - water_size / 2.0;
    water2_y_end = water2_y_start + water_size;

    // 先判断水1的位置
    if (UV.x >= water_x_start && UV.x <= water_x_end &&
        UV.y >= water_y_start && UV.y <= water_y_end) {
        COLOR = water_color;  // 显示水的颜色
    }
    // 然后判断水2的位置
    else if (UV.x >= water2_x_start && UV.x <= water2_x_end &&
             UV.y >= water2_y_start && UV.y <= water2_y_end) {
        COLOR = water_color;  // 显示第二片水的颜色
    }
    // 然后判断管子的位置
    else if (UV.x >= pipe_x_start && UV.x <= pipe_x_end &&
             UV.y >= pipe_y_start && UV.y <= pipe_y_end) {
        COLOR = pipe_color;  // 显示管子的颜色
    }
    // 判断并绘制小胳膊
    else if (show_left_arm && UV.x >= 0.0 && UV.x <= pipe_size &&
             UV.y >= pipe_y_start && UV.y <= pipe_y_end) {
        COLOR = pipe_color;  // 左边小胳膊的颜色
    }
    else if (show_right_arm && UV.x >= 1.0 - pipe_size && UV.x <= 1.0 &&
             UV.y >= pipe_y_start && UV.y <= pipe_y_end) {
        COLOR = pipe_color;  // 右边小胳膊的颜色
    }
    else if (show_top_arm && UV.x >= pipe_x_start && UV.x <= pipe_x_end &&
             UV.y >= 1.0 - pipe_size && UV.y <= 1.0) {
        COLOR = pipe_color;  // 上边小胳膊的颜色
    }
    else if (show_bottom_arm && UV.x >= pipe_x_start && UV.x <= pipe_x_end &&
             UV.y >= 0.0 && UV.y <= pipe_size) {
        COLOR = pipe_color;  // 下边小胳膊的颜色
    }
    else {
        discard;  // 丢弃其他部分
    }
}
