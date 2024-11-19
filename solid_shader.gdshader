shader_type canvas_item;

uniform vec4 solid_color = vec4(0.5, 0.5, 0.5, 1.0); // 固体颜色，默认灰色

void fragment() {
    COLOR = solid_color; // 将颜色直接设置为固体颜色
}
