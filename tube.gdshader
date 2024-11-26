shader_type canvas_item;

uniform vec4 pipe_color = vec4(0.6, 0.5, 0.45, 1.0);   // 水管的颜色

uniform float radius : hint_range(0.01, 0.5) = 0.3;  // 中间圆点的半径
uniform float pipe_size : hint_range(0.01, 1.0) = 0.3; // 小胳膊的宽度

// 控制是否显示水管的四个小胳膊
uniform bool show_left_arm = false;   // 是否显示左边小胳膊
uniform bool show_right_arm = false;  // 是否显示右边小胳膊
uniform bool show_top_arm = false;    // 是否显示上边小胳膊
uniform bool show_bottom_arm = false; // 是否显示下边小胳膊

void fragment() {
    vec2 center = vec2(0.5, 0.5);
    float dist_to_center = distance(UV, center);

    // 判断是否在中间圆点内
    if (dist_to_center <= radius) {
        COLOR = pipe_color;  // 显示圆点的颜色
    }
    // 判断并绘制小胳膊
    else if (show_left_arm && UV.x >= 0.0 && UV.x <= pipe_size &&
             UV.y >= center.y - pipe_size / 2.0 && UV.y <= center.y + pipe_size / 2.0) {
        COLOR = pipe_color;  // 左边小胳膊的颜色
    }
    else if (show_right_arm && UV.x >= 1.0 - pipe_size && UV.x <= 1.0 &&
             UV.y >= center.y - pipe_size / 2.0 && UV.y <= center.y + pipe_size / 2.0) {
        COLOR = pipe_color;  // 右边小胳膊的颜色
    }
    else if (show_top_arm && UV.x >= center.x - pipe_size / 2.0 && UV.x <= center.x + pipe_size / 2.0 &&
             UV.y >= 1.0 - pipe_size) {
        COLOR = pipe_color;  // 上边小胳膊的颜色
    }
    else if (show_bottom_arm && UV.x >= center.x - pipe_size / 2.0 && UV.x <= center.x + pipe_size / 2.0 &&
             UV.y >= 0.0 && UV.y <= pipe_size) {
        COLOR = pipe_color;  // 下边小胳膊的颜色
    }
    else {
        discard;  // 丢弃其他部分
    }
}
