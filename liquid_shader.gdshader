shader_type canvas_item;

uniform vec4 liquid_color = vec4(0.0, 0.0, 1.0, 1.0); // 液体的颜色，默认为蓝色
uniform float liquid_amount = 1.0; // 液体的量，范围从0到1

void fragment() {
    // 液体的显示
    // 将液体根据液体量呈现为从下到上的进度条

    vec4 color = liquid_color;

    // 如果在液体范围内，显示液体的颜色
    if (UV.y > (1.0 - liquid_amount)) {
        color.a = 1.0; // 完全不透明
    } else {
        color.a = 0.0; // 在液体之外是完全透明
    }

    COLOR = color;
}
